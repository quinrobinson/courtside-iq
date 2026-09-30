-- Self-service account deletion — Phase 4.15d
--
-- REPLACES THE delete-account EDGE FUNCTION, which failed with a 500 on test
-- that could not be traced from the client: GoTrue's admin.deleteUser needs
-- the service role and something in that path rejected it, twice, and the
-- request logs do not carry the reason.
--
-- The raw cascade delete of auth.users was PROVEN to work in a rolled-back
-- transaction, so this uses that path directly. A SECURITY DEFINER function,
-- owned by the migration role, deletes the caller and everything migration
-- 20260723000000 cascades from them.
--
-- WHY THIS IS SAFE, and safer than the Edge Function it replaces:
--
--   It takes NO id. It deletes auth.uid() - the caller PostgREST resolved
--   from the verified JWT - so a parent can only ever delete themselves.
--   There is no parameter that could name another account.
--
--   search_path is pinned. An unpinned SECURITY DEFINER function can be
--   hijacked by a caller who puts a malicious function earlier on their
--   path; pinning it to public, auth closes that.
--
--   The feedback anonymise and the delete are ONE transaction. The Edge
--   Function did them as two steps, so a crash between them could strand a
--   deleted-but-still-emailed note. Here they commit or roll back together.

create or replace function public.delete_current_user()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  uid uuid := auth.uid();
  em text;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  -- Keep the note, drop the personal half. Approved 2026-07-23: a bug report
  -- is worth acting on; the email is not ours to keep once the account is
  -- gone.
  select email into em from auth.users where id = uid;
  if em is not null then
    update public.feedback set email = null where email = em;
  end if;

  -- One delete. Players, games, stats, insights, snapshots, teams and the
  -- subscription follow by cascade; so do the auth.sessions and
  -- auth.identities, which reference auth.users with their own cascades.
  delete from auth.users where id = uid;
end;
$$;

-- Only a signed-in caller, and only for themselves (the body enforces the
-- "themselves"). Never anon.
revoke all on function public.delete_current_user() from public, anon;
grant execute on function public.delete_current_user() to authenticated;
