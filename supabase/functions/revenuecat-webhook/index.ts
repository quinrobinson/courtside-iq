// Edge Function: revenuecat-webhook
//
// Receives RevenueCat subscriber lifecycle events and maintains
// public.subscriptions, the server's source of truth for entitlement.
//
// ---------------------------------------------------------------------------
// SECURITY - read before deploying
//
// This endpoint MUST be deployed with --no-verify-jwt, because RevenueCat
// cannot present a Supabase JWT. That makes it publicly reachable, so the
// shared secret below is the ONLY thing standing between the internet and this
// function.
//
//   supabase functions deploy revenuecat-webhook --no-verify-jwt
//
// Set REVENUECAT_WEBHOOK_SECRET as a project secret, and set the identical
// value as the Authorization header in the RevenueCat dashboard
// (Project Settings -> Integrations -> Webhooks -> Authorization header).
//
// If the secret is not configured, this function refuses every request rather
// than falling open. An unauthenticated writer to the entitlement table could
// grant itself premium.
// ---------------------------------------------------------------------------

import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const WEBHOOK_SECRET = Deno.env.get("REVENUECAT_WEBHOOK_SECRET") ?? "";

const ENTITLEMENT = "premium_users";

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

/**
 * Map a RevenueCat event type to our lifecycle status.
 *
 * Anything unrecognized returns null and is acknowledged without a write - a
 * new RevenueCat event type must never silently flip someone to expired.
 */
function statusFor(eventType: string): string | null {
  switch (eventType) {
    case "INITIAL_PURCHASE":
    case "RENEWAL":
    case "UNCANCELLATION":
    case "NON_RENEWING_PURCHASE":
    case "SUBSCRIPTION_EXTENDED":
      return "active";

    case "PRODUCT_CHANGE":
      return "active";

    // Auto-renew switched off. Still entitled until current_period_end - the
    // user paid for this period.
    case "CANCELLATION":
      return "cancelled";

    // Grace period: payment failing but access continues while RevenueCat
    // retries. Cutting a parent off here would be wrong.
    case "BILLING_ISSUE":
      return "billing_issue";

    case "EXPIRATION":
      return "expired";

    default:
      return null;
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  // Fail CLOSED. A missing secret means misconfiguration, not permission.
  if (!WEBHOOK_SECRET) {
    console.error("revenuecat_webhook_secret_missing");
    return json({ error: "not_configured" }, 503);
  }
  if (!SERVICE_ROLE_KEY) {
    console.error("service_role_key_missing");
    return json({ error: "not_configured" }, 503);
  }

  const auth = req.headers.get("Authorization") ?? "";
  if (auth !== WEBHOOK_SECRET) {
    // Deliberately vague: do not help a prober distinguish "wrong secret" from
    // "not configured".
    return json({ error: "unauthorized" }, 401);
  }

  let payload: Record<string, unknown>;
  try {
    payload = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const event = (payload.event ?? {}) as Record<string, unknown>;
  const eventType = String(event.type ?? "");
  const eventId = event.id ? String(event.id) : null;

  // app_user_id is the Supabase uid: the client calls Purchases.logIn(uid).
  // original_app_user_id is the fallback when an alias fires the event.
  const appUserId = String(event.app_user_id ?? event.original_app_user_id ?? "");

  if (!eventType || !appUserId) {
    return json({ error: "missing_fields" }, 400);
  }

  // RevenueCat sends TEST events from the dashboard button. Acknowledge them so
  // the dashboard shows green, but never write.
  if (eventType === "TEST") {
    console.log("revenuecat_test_event_ok");
    return json({ ok: true, test: true });
  }

  const status = statusFor(eventType);
  if (status === null) {
    // Unknown or non-entitlement event (TRANSFER, SUBSCRIBER_ALIAS, etc).
    // Acknowledge so RevenueCat stops retrying; do not touch state.
    console.log("revenuecat_event_ignored", eventType);
    return json({ ok: true, ignored: eventType });
  }

  // Only act on our entitlement. A future second entitlement must not silently
  // drive premium.
  const entitlementIds = Array.isArray(event.entitlement_ids)
    ? (event.entitlement_ids as string[])
    : event.entitlement_id
    ? [String(event.entitlement_id)]
    : [];

  if (entitlementIds.length > 0 && !entitlementIds.includes(ENTITLEMENT)) {
    console.log("revenuecat_other_entitlement", entitlementIds.join(","));
    return json({ ok: true, ignored: "other_entitlement" });
  }

  // A uuid app_user_id is required - anonymous RevenueCat ids ($RCAnonymous...)
  // belong to users who never logged in and have no Supabase row to attach to.
  const isUuid =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(appUserId);
  if (!isUuid) {
    console.log("revenuecat_non_uuid_app_user_id", appUserId.slice(0, 20));
    return json({ ok: true, ignored: "anonymous_user" });
  }

  const expiresMs = event.expiration_at_ms ?? event.expiration_at ?? null;
  const currentPeriodEnd = typeof expiresMs === "number"
    ? new Date(expiresMs).toISOString()
    : null;

  const eventMs = event.event_timestamp_ms ?? null;
  const eventAt = typeof eventMs === "number"
    ? new Date(eventMs).toISOString()
    : new Date().toISOString();

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });

  const { error } = await admin.from("subscriptions").upsert(
    {
      user_id: appUserId,
      rc_app_user_id: appUserId,
      entitlement: ENTITLEMENT,
      status,
      product_id: event.product_id ? String(event.product_id) : null,
      store: event.store ? String(event.store) : null,
      current_period_end: currentPeriodEnd,
      will_renew: status === "active" ? true : status === "cancelled" ? false : null,
      last_event_type: eventType,
      last_event_id: eventId,
      last_event_at: eventAt,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );

  if (error) {
    // 500 so RevenueCat retries. A dropped event leaves entitlement stale.
    console.error("subscriptions_upsert_failed", error.message);
    return json({ error: "db_error" }, 500);
  }

  console.log("revenuecat_event_applied", eventType, status);
  return json({ ok: true, status });
});
