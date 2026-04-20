-- Allow users to update player_game_stats rows for their own games.
-- Without this policy, RLS silently blocks writes from the
-- `generate-game-insight` Edge Function (PostgREST returns success
-- with zero rows affected), leaving `game_insights` permanently null.

create policy "Users can update stats for own games"
  on public.player_game_stats
  for update
  using (
    exists (
      select 1 from public.games
      where games.id = player_game_stats.game_id
        and games.user_id = ((select auth.uid())::text)
    )
  )
  with check (
    exists (
      select 1 from public.games
      where games.id = player_game_stats.game_id
        and games.user_id = ((select auth.uid())::text)
    )
  );
