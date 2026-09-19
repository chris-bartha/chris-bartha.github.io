-- "Your best scores" — her own numbers, on her own screen.
--
-- The per-category result tables are insert-only from the browser on purpose:
-- they hold answer payloads and user ids. quiz_metrics has no read policy at
-- all. So the screen gets one function instead of a table read, and that
-- function can only ever see the rows belonging to the caller.
--
-- Unlimited Mode is now the only mode outside Fifth Grader, so a "best score"
-- here means the longest run, not the highest percentage. Both are returned:
-- the percentage still means something for the ten-question Fifth Grader ladder
-- and for every standard round she played before the change.

create or replace function public.get_my_quiz_stats(
  viewer_timezone text default 'UTC'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  request_user uuid := (select auth.uid());
  effective_timezone text;
  local_today date;
begin
  if request_user is null then
    raise exception 'Only a signed-in player has scores to show'
      using errcode = '42501';
  end if;

  select timezone.name
    into effective_timezone
  from pg_catalog.pg_timezone_names as timezone
  where timezone.name = coalesce(nullif(viewer_timezone, ''), 'UTC')
  limit 1;

  effective_timezone := coalesce(effective_timezone, 'UTC');
  local_today := (current_timestamp at time zone effective_timezone)::date;

  return (
    with mine as materialized (
      select
        result.source_id,
        result.category_id,
        result.score::integer as score,
        result.total_questions::integer as total_questions,
        result.first_try_correct::integer as first_try_correct,
        result.second_try_correct::integer as second_try_correct,
        result.completed_at,
        result.duration_seconds,
        result.is_unlimited,
        round(result.score::numeric * 100 / result.total_questions, 1) as percentage,
        (result.completed_at at time zone effective_timezone)::date as local_date
      from private.all_quiz_results_for_tracking as result
      where result.user_id = request_user
    ),
    overall as (
      select
        count(*)::integer as runs,
        coalesce(sum(score), 0)::integer as total_correct,
        coalesce(sum(total_questions), 0)::integer as total_questions,
        coalesce(
          round(sum(score)::numeric * 100 / nullif(sum(total_questions), 0), 1),
          0
        ) as accuracy,
        coalesce(max(score), 0)::integer as best_score,
        coalesce(sum(duration_seconds), 0)::bigint as total_seconds,
        count(distinct local_date)::integer as days_played,
        count(*) filter (where local_date = local_today)::integer as runs_today,
        coalesce(sum(score) filter (where local_date = local_today), 0)::integer as correct_today,
        min(completed_at) as first_played_at,
        max(completed_at) as last_played_at
      from mine
    ),
    play_dates as (
      select distinct local_date from mine
    ),
    date_islands as (
      select
        local_date,
        local_date - row_number() over (order by local_date)::integer as island
      from play_dates
    ),
    streaks as (
      select
        max(local_date) as end_date,
        count(*)::integer as days
      from date_islands
      group by island
    ),
    per_category as (
      select
        category_id,
        count(*)::integer as runs,
        max(score)::integer as best_score,
        coalesce(max(percentage), 0) as best_percentage,
        sum(score)::integer as total_correct,
        sum(total_questions)::integer as total_questions,
        round(sum(score)::numeric * 100 / nullif(sum(total_questions), 0), 1) as accuracy,
        max(completed_at) as last_played_at,
        (array_agg(score order by completed_at desc, source_id desc))[1]::integer as last_score
      from mine
      group by category_id
    ),
    best_dates as (
      -- When each category's best run happened. Ties go to the most recent.
      select distinct on (mine.category_id)
        mine.category_id,
        mine.completed_at as best_at,
        mine.total_questions as best_total
      from mine
      join per_category on per_category.category_id = mine.category_id
      where mine.score = per_category.best_score
      order by mine.category_id, mine.completed_at desc
    )
    select jsonb_build_object(
      'generated_at', current_timestamp,
      'timezone', effective_timezone,
      'overall', jsonb_build_object(
        'runs', overall.runs,
        'total_correct', overall.total_correct,
        'total_questions', overall.total_questions,
        'accuracy', overall.accuracy,
        'best_score', overall.best_score,
        'total_seconds', overall.total_seconds,
        'days_played', overall.days_played,
        'runs_today', overall.runs_today,
        'correct_today', overall.correct_today,
        'current_streak', coalesce((
          select streak.days
          from streaks as streak
          where streak.end_date = (select max(local_date) from play_dates)
            and streak.end_date >= local_today - 1
        ), 0),
        'longest_streak', coalesce((select max(days) from streaks), 0),
        'first_played_at', overall.first_played_at,
        'last_played_at', overall.last_played_at,
        'best_run', (
          select jsonb_build_object(
            'category_id', best.category_id,
            'name', category.display_name,
            'score', best.score,
            'total_questions', best.total_questions,
            'completed_at', best.completed_at
          )
          from mine as best
          join public.quiz_categories as category on category.id = best.category_id
          order by best.score desc, best.completed_at desc
          limit 1
        )
      ),
      'categories', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'id', category.id,
            'name', category.display_name,
            'language_code', category.language_code,
            'runs', rollup.runs,
            'best_score', rollup.best_score,
            'best_total', best_dates.best_total,
            'best_percentage', rollup.best_percentage,
            'best_at', best_dates.best_at,
            'last_score', rollup.last_score,
            'total_correct', rollup.total_correct,
            'total_questions', rollup.total_questions,
            'accuracy', coalesce(rollup.accuracy, 0),
            'last_played_at', rollup.last_played_at,
            'pool_size', (
              select count(*)::integer
              from public.quiz_questions as question
              where question.category_id = category.id and question.is_active
            )
          )
          order by rollup.best_score desc, rollup.last_played_at desc
        )
        from per_category as rollup
        join public.quiz_categories as category on category.id = rollup.category_id
        left join best_dates on best_dates.category_id = rollup.category_id
        where category.is_active
      ), '[]'::jsonb),
      'recent', coalesce((
        select jsonb_agg(to_jsonb(row) order by row.completed_at desc)
        from (
          select
            recent.category_id,
            category.display_name as name,
            recent.score,
            recent.total_questions,
            recent.is_unlimited,
            recent.completed_at
          from mine as recent
          join public.quiz_categories as category on category.id = recent.category_id
          order by recent.completed_at desc
          limit 8
        ) as row
      ), '[]'::jsonb)
    )
    from overall
  );
end;
$$;

revoke all on function public.get_my_quiz_stats(text)
  from public, anon, authenticated;
grant execute on function public.get_my_quiz_stats(text) to authenticated;

comment on function public.get_my_quiz_stats(text) is
  'Her own scores for the in-app "Your best scores" screen. Reads only rows belonging to the caller.';
