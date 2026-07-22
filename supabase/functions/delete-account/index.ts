// Delete account — Phase 4.15d
//
// Removing a row from auth.users needs the service role, which cannot live in
// the client. This is the only reason this function exists.
//
// IT DELETES THE CALLER AND NOBODY ELSE. The uid comes from the JWT the
// client sent, never from the request body. A function that took an id as a
// parameter would let any signed-in parent delete any other account by
// guessing a uuid, and uuids appear in this app's own URLs.
//
// EVERYTHING ELSE GOES BY CASCADE, not by a list of deletes here. Migration
// 20260723000000 points public.users at auth.users, so one delete takes the
// players, games, stats, insights, trend snapshots, teams and subscription
// with it. A hand-written sequence would be one table behind the schema the
// first time a table is added, and nothing would fail loudly when it was.
//
// FEEDBACK IS THE EXCEPTION, deliberately. Approved 2026-07-23: the note is
// kept because it may be a bug report worth acting on, and the email is
// blanked because it is the personal part. That is a judgement about
// content, so it cannot be a foreign key.

import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "").trim();
  if (!token) return json({ error: "missing_token" }, 401);

  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // persistSession:false IS LOad-BEARING, not boilerplate. Without it,
  // getUser(token) below makes the client adopt the caller's token as its
  // own session - so the later admin.deleteUser goes out with the USER's
  // Bearer token instead of the service-role key, GoTrue forbids it, and the
  // whole thing fails as a 500. That was the first bug on test.
  const admin = createClient(url, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // Resolve the caller FROM THE TOKEN. This is the whole security model: the
  // account deleted below is the one that asked, and there is no parameter
  // that could say otherwise.
  const { data: caller, error: authError } = await admin.auth.getUser(token);
  const uid = caller?.user?.id;
  if (authError || !uid) return json({ error: "invalid_token" }, 401);

  const email = caller.user?.email ?? "";

  // Blank the personal half of any feedback they left, keeping the note.
  // Done BEFORE the delete: afterwards there is no email to match on, and
  // the rows would be stranded with an address attached to nobody.
  if (email) {
    const { error: feedbackError } = await admin
      .from("feedback")
      .update({ email: null })
      .eq("email", email);

    // Not fatal. A parent asked to be deleted, and refusing because one
    // update failed leaves them with an account they wanted gone. Logged so
    // the residue can be found and cleared.
    if (feedbackError) {
      console.error("feedback anonymise failed", uid, feedbackError.message);
    }
  }

  const { error: deleteError } = await admin.auth.admin.deleteUser(uid);
  if (deleteError) {
    console.error("account delete failed", uid, deleteError.message);
    // `detail` is TEMPORARY and TEST-ONLY diagnostic. The caller is already
    // authenticated as themselves, so it leaks nothing about anyone else -
    // but strip it before this ever goes to prod. Remove with this comment.
    return json({ error: "delete_failed", detail: deleteError.message }, 500);
  }

  console.log("account deleted", uid);
  return json({ deleted: true });
});
