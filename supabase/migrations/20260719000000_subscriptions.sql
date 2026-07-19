-- Phase 4.4a: server-side entitlement record
--
-- Premium is currently a client-side bool (FFAppState().isUserPremium) synced
-- from RevenueCat on the device. The server has no idea who is paying, which
-- means:
--   - every premium gate is a UI `if` and trivially bypassed
--   - free-tier limits cannot be enforced in RLS
--   - we cannot even ANSWER "how many users are paying", so we cannot safely
--     turn on a limit without risking locking out a paying customer
--
-- This table is written ONLY by the revenuecat-webhook Edge Function via the
-- service role. It is the server's source of truth for entitlement.
--
-- THIS MIGRATION CHANGES NO BEHAVIOR. Nothing reads it for gating yet; that is
-- Phase 4.4b, deliberately separate so enforcement is switched on with real
-- numbers in view.

create table if not exists public.subscriptions (
  user_id             uuid primary key references auth.users(id) on delete cascade,

  -- RevenueCat's app_user_id. Should equal user_id (we call Purchases.logIn
  -- with the Supabase uid), but stored so a mismatch is visible rather than
  -- silently reconciled.
  rc_app_user_id      text,

  entitlement         text not null default 'premium_users',

  -- Lifecycle, straight from RevenueCat's event types.
  --   active        currently entitled
  --   billing_issue in grace period, still entitled, payment failing
  --   cancelled     auto-renew off, still entitled until current_period_end
  --   expired       no longer entitled
  status              text not null default 'expired'
                      check (status in ('active','billing_issue','cancelled','expired')),

  product_id          text,
  store               text,   -- app_store | play_store | promotional | ...

  current_period_end  timestamptz,
  will_renew          boolean,

  -- Audit trail so a surprising state can be traced to the event that set it.
  last_event_type     text,
  last_event_id       text,
  last_event_at       timestamptz,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists subscriptions_status_idx
  on public.subscriptions (status);

create index if not exists subscriptions_period_end_idx
  on public.subscriptions (current_period_end);

alter table public.subscriptions enable row level security;

-- Users may read their own subscription (the client shows plan state, renewal
-- date, and billing-issue banners). Nobody may write from the client - the
-- webhook holds the service role.
drop policy if exists "Users can read own subscription" on public.subscriptions;
create policy "Users can read own subscription"
  on public.subscriptions for select
  using ((select auth.uid()) = user_id);

-- ---------------------------------------------------------------------------
-- is_premium(uid) - the single server-side answer to "is this user entitled?"
--
-- `cancelled` still counts: auto-renew is off but the user paid through
-- current_period_end and must keep access until then. `billing_issue` also
-- counts - that is RevenueCat's grace period, and cutting a parent off mid
-- grace period over a card that is about to be fixed is the wrong default.
-- ---------------------------------------------------------------------------
create or replace function public.is_premium(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_catalog
as $$
  select exists (
    select 1
    from public.subscriptions s
    where s.user_id = uid
      and s.status in ('active', 'billing_issue', 'cancelled')
      and (s.current_period_end is null or s.current_period_end > now())
  );
$$;

grant execute on function public.is_premium(uuid) to authenticated, service_role;

comment on table public.subscriptions is
  'Server-side entitlement, written only by the RevenueCat webhook. Source of truth for is_premium().';
comment on function public.is_premium(uuid) is
  'True when the user is entitled. Includes cancelled-but-not-expired and billing-issue grace periods.';
