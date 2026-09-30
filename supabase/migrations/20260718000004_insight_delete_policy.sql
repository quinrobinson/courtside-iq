-- Allow a user to delete their own player_development_insights rows.
--
-- generate-player-insight claims a generation with a null-insight placeholder
-- row and must remove it if the generation fails, so the next attempt is not
-- blocked by a dead claim. The table had SELECT, INSERT and UPDATE policies but
-- no DELETE, so that cleanup silently affected zero rows and returned no error
-- - orphaning the claim permanently and degrading every later request into a
-- 7.5s poll before it regenerated.
--
-- Found by reading the policy list rather than by testing: an RLS-blocked
-- delete is indistinguishable from a successful one at the client.

create policy "Users can delete own player insights"
  on public.player_development_insights for delete
  using (exists (
    select 1 from public.players p
    where p.id = player_development_insights.player_id
      and p.user_id = (select auth.uid())
  ));
