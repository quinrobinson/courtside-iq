-- get_age_band: return NULL for an unknown birth date, not the middle band.
--
-- The function returned '11U-13U' when birth_date IS NULL. That fallback was
-- deliberate and mirrored in metrics_config.dart and metrics.ts, but it had
-- two consequences that only became visible on device:
--
--   1. An ASSUMPTION was indistinguishable from a FACT. A player created
--      without a birth date was listed as "11U-13U", which the app has no way
--      of knowing, and the caveat banner that exists to say "these ratings are
--      not calibrated" keyed on age_band IS NULL and so could never fire.
--
--   2. Ratings were computed against middle-school cutoffs for a player whose
--      age is unknown. An 8-year-old and a 17-year-old were both measured
--      against 11U-13U play, while the number presented itself as
--      age-normalised. Age fairness is the entire premise of Growth IQ.
--
-- After this, age_band is NULL for those players and the client shows the
-- designed locked state instead of a number it cannot stand behind. The
-- clients already handle a null band: ageBandFromString returns null and
-- growthIq() locks with GrowthIqLock.noBirthDate.
--
-- No data changes. player_profile_view picks this up automatically because it
-- calls the function rather than storing the result.

create or replace function public.get_age_band(birth_date date)
returns text
language sql
stable
as $function$
  select case
    -- NULL, not a guess. See the note above.
    when birth_date is null then null
    when date_part('year', age(birth_date)) <= 10 then '8U-10U'
    when date_part('year', age(birth_date)) <= 13 then '11U-13U'
    else '14U-18U'
  end;
$function$;
