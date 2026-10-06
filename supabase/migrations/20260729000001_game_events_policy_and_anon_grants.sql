-- SECURITY FIX #2 — found by the sweep that followed the view leak
-- (20260729000000). Applied to prod AND test 2026-07-29, then written here.
--
-- 1) A BLANKET POLICY WAS OVERRIDING THE CORRECT ONE
--
-- public.game_events carried two SELECT policies:
--
--   "Authenticated users can view game events"  USING (true)      <- wrong
--   game_events_read_my_players                 USING (my player) <- right
--
-- PostgreSQL unions PERMISSIVE policies with OR, so the blanket one did not
-- "add" access next to the stricter rule - it REPLACED the effective limit.
-- Every signed-in parent could read every other family's game events.
--
-- Measured on PROD before the fix: one parent saw 56 rows across 38 players.
-- After: 1 row, their own. The scoped policy already covers the legitimate
-- case, so dropping the blanket one loses nothing.
--
-- RULE: never leave a `USING (true)` policy on a table holding user data. It
-- is not additive, it is the ceiling. (The two `true` policies that remain in
-- this schema are on event_types_list and player_positions_list - 2 and 6 rows
-- of pure reference data, no user content. Those are correct.)
--
-- 2) ANON NO LONGER EXECUTES THE SECURITY DEFINER HELPERS
--
-- Defence in depth rather than a hole being closed: all three have search_path
-- pinned, and none return another user's rows - the worst case was learning a
-- boolean or a count for a UUID you would already have to know.
--
-- is_premium and player_count MUST remain callable by `authenticated`: the
-- players INSERT policy (free-tier limit) calls them. Verified after applying
-- that a real subscriber still returns is_premium = true.

drop policy if exists "Authenticated users can view game events" on public.game_events;

revoke execute on function public.is_premium(uuid) from anon;
revoke execute on function public.player_count(uuid) from anon;
revoke execute on function public.compute_trend_snapshot(uuid, uuid) from anon;
