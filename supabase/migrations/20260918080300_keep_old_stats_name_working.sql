-- Put get_my_quiz_stats back as a thin alias.
--
-- 20260918080000 renamed it to get_quiz_best_scores and dropped the old name in
-- the same migration. The database is pushed from here, but the browser is
-- deployed from GitHub Pages, so for as long as the two are out of step the live
-- supabase-client.js is still calling a function that no longer exists and the
-- "Your best scores" screen fails for everyone.
--
-- A rename is only safe once the callers are deployed. Until then both names
-- answer, and the old one is a one-line wrapper rather than a second copy of the
-- query, so the two cannot drift apart.

create or replace function public.get_my_quiz_stats(
  viewer_timezone text default 'UTC'
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select public.get_quiz_best_scores(viewer_timezone);
$$;

revoke all on function public.get_my_quiz_stats(text)
  from public, anon, authenticated;
grant execute on function public.get_my_quiz_stats(text)
  to anon, authenticated, service_role;

comment on function public.get_my_quiz_stats(text) is
  'Compatibility alias for get_quiz_best_scores, kept while an older deploy may still call it. Safe to drop once every client is on the new name.';
