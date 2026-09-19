-- Both screens now count days in her timezone, not the viewer's.
--
-- A streak is counted in calendar days and she plays past midnight, so the day
-- boundary decides which sessions fall together. The same history reads as a
-- 60-day streak in America/Los_Angeles and a 5-day streak in America/Toronto --
-- not because anything changed, but because a three-hour shift moves late-night
-- sessions across midnight and opens gaps that were never there.
--
-- /metrics took the timezone from whoever was looking, which was defensible when
-- it was the only screen. Now that the in-app best-scores screen shows the same
-- history to every visitor, two people in different timezones would see two
-- different streaks on two screens describing one person. Hers is the only frame
-- in which the number means anything, so both screens use it.
--
-- The function is otherwise byte-identical to 20260918070300; only the timezone
-- resolution changed, and the viewer's timezone is still the fallback.

create or replace function private.player_timezone()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select player.timezone
  from public.quiz_players as player
  join (
    select result.user_id, count(*) as rounds
    from private.all_quiz_results_for_tracking as result
    group by result.user_id
    order by count(*) desc
    limit 1
  ) as busiest on busiest.user_id = player.user_id;
$$;

revoke all on function private.player_timezone() from public, anon, authenticated;
grant execute on function private.player_timezone() to anon, authenticated, service_role;

comment on function private.player_timezone() is
  'The timezone of whoever has played the most rounds. Both day-counting screens use it so a streak does not change with the viewer.';

create or replace function public.get_quiz_public_metrics(
  viewer_timezone text default 'UTC'
)
returns jsonb
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  effective_timezone text;
  local_today date;
begin
  -- Her timezone, not the viewer's. See the migration header.
  select timezone.name
    into effective_timezone
  from pg_catalog.pg_timezone_names as timezone
  where timezone.name = coalesce(
    nullif(private.player_timezone(), ''),
    nullif(viewer_timezone, ''),
    'UTC'
  )
  limit 1;

  effective_timezone := coalesce(effective_timezone, 'UTC');
  local_today := (current_timestamp at time zone effective_timezone)::date;

  return (
    with normalized as materialized (
      select
        attempt.source_id,
        attempt.category_id,
        attempt.score::integer as score,
        attempt.total_questions::integer as total_questions,
        attempt.first_try_correct::integer as first_try_correct,
        attempt.second_try_correct::integer as second_try_correct,
        attempt.completed_at,
        attempt.duration_seconds,
        attempt.is_unlimited,
        round(attempt.score::numeric * 100 / attempt.total_questions, 1) as percentage,
        (attempt.completed_at at time zone effective_timezone)::date as local_date
      from public.quiz_public_attempts as attempt
    ),
    standard_attempts as materialized (
      select * from normalized where not is_unlimited
    ),
    unlimited_attempts as materialized (
      select * from normalized where is_unlimited
    ),
    -- Through the view, not the table: an anonymous visitor cannot read
    -- quiz_questions and would otherwise see every pool as zero.
    pool_sizes as (
      select category_id, pool_size from public.quiz_pool_sizes
    ),
    standard_overview as (
      select
        count(*)::integer as total_quizzes,
        coalesce(
          round(sum(score)::numeric * 100 / nullif(sum(total_questions), 0), 1),
          0
        ) as average_percentage,
        coalesce(max(percentage), 0) as best_percentage,
        count(*) filter (where score = total_questions)::integer as perfect_scores,
        coalesce(sum(score), 0)::integer as total_correct,
        coalesce(sum(total_questions), 0)::integer as total_questions,
        coalesce(round(avg(duration_seconds)), 0)::integer as average_duration_seconds,
        max(completed_at) as last_played_at
      from standard_attempts
    ),
    activity_overview as (
      select
        count(*)::integer as total_sessions,
        count(*) filter (where local_date = local_today)::integer as quizzes_today,
        count(*) filter (
          where local_date = local_today and not is_unlimited
        )::integer as standard_today,
        count(*) filter (
          where local_date = local_today and is_unlimited
        )::integer as unlimited_today,
        count(*) filter (where local_date >= local_today - 6)::integer as quizzes_last_7_days,
        count(*) filter (where local_date >= local_today - 29)::integer as quizzes_last_30_days,
        coalesce(sum(score), 0)::integer as total_correct,
        coalesce(sum(total_questions), 0)::integer as total_questions,
        coalesce(sum(first_try_correct), 0)::integer as first_try_correct,
        coalesce(sum(second_try_correct), 0)::integer as second_chance_correct,
        coalesce(sum(duration_seconds), 0)::bigint as total_seconds,
        count(distinct local_date)::integer as active_days,
        min(completed_at) as first_played_at,
        max(completed_at) as last_played_at
      from normalized
    ),
    unlimited_overview as (
      select
        count(*)::integer as runs,
        coalesce(max(score), 0)::integer as best_score,
        coalesce(round(avg(score), 1), 0) as average_score,
        coalesce(
          percentile_cont(0.5) within group (order by score),
          0
        )::numeric(10, 1) as median_score,
        coalesce(sum(score), 0)::integer as total_correct,
        coalesce(sum(total_questions), 0)::integer as questions_answered,
        coalesce(sum(first_try_correct), 0)::integer as first_try_correct,
        coalesce(sum(second_try_correct), 0)::integer as second_chance_correct,
        coalesce(
          round(sum(score)::numeric * 100 / nullif(sum(total_questions), 0), 1),
          0
        ) as accuracy,
        coalesce(round(avg(duration_seconds)), 0)::integer as average_duration_seconds,
        coalesce(sum(duration_seconds), 0)::bigint as total_seconds,
        count(*) filter (where local_date >= local_today - 29)::integer as runs_last_30_days,
        count(*) filter (where score >= 100)::integer as runs_over_100,
        min(completed_at) as first_run_at,
        max(completed_at) as last_run_at
      from unlimited_attempts
    ),
    play_dates as (
      select distinct local_date from normalized
    ),
    date_islands as (
      select
        local_date,
        local_date - row_number() over (order by local_date)::integer as island
      from play_dates
    ),
    streaks as (
      select
        min(local_date) as start_date,
        max(local_date) as end_date,
        count(*)::integer as days
      from date_islands
      group by island
    ),
    category_standard_rollup as (
      select
        category_id,
        count(*)::integer as quizzes,
        coalesce(
          round(sum(score)::numeric * 100 / nullif(sum(total_questions), 0), 1),
          0
        ) as average_percentage,
        coalesce(max(percentage), 0) as best_percentage,
        count(*) filter (where score = total_questions)::integer as perfect_scores,
        coalesce(sum(score), 0)::integer as total_correct,
        coalesce(sum(total_questions), 0)::integer as total_questions,
        coalesce(sum(first_try_correct), 0)::integer as first_try_correct,
        coalesce(sum(second_try_correct), 0)::integer as second_chance_correct,
        coalesce(round(avg(duration_seconds)), 0)::integer as average_duration_seconds,
        max(completed_at) as last_played_at
      from standard_attempts
      group by category_id
    ),
    category_unlimited_rollup as (
      select
        category_id,
        count(*)::integer as runs,
        coalesce(max(score), 0)::integer as best_score,
        coalesce(round(avg(score), 1), 0) as average_score,
        coalesce(sum(score), 0)::integer as total_correct,
        coalesce(sum(total_questions), 0)::integer as questions_answered,
        coalesce(sum(second_try_correct), 0)::integer as second_chance_correct,
        coalesce(
          round(sum(score)::numeric * 100 / nullif(sum(total_questions), 0), 1),
          0
        ) as accuracy,
        max(completed_at) as last_played_at
      from unlimited_attempts
      group by category_id
    ),
    -- When each category's longest run happened. Ties go to the most recent.
    category_best_run as (
      select distinct on (run.category_id)
        run.category_id,
        run.completed_at as best_at,
        run.total_questions as best_total,
        run.duration_seconds as best_duration_seconds
      from unlimited_attempts as run
      join category_unlimited_rollup as rollup
        on rollup.category_id = run.category_id
       and rollup.best_score = run.score
      order by run.category_id, run.completed_at desc
    ),
    -- A percentage means nothing when the denominator is "however far she got",
    -- so an Unlimited run is grouped by how long it lasted instead.
    run_length_buckets as (
      select
        case
          when score < 10 then '0-9'
          when score < 25 then '10-24'
          when score < 50 then '25-49'
          when score < 100 then '50-99'
          when score < 200 then '100-199'
          when score < 400 then '200-399'
          else '400+'
        end as bucket,
        case
          when score < 10 then 1
          when score < 25 then 2
          when score < 50 then 3
          when score < 100 then 4
          when score < 200 then 5
          when score < 400 then 6
          else 7
        end as bucket_order,
        score
      from unlimited_attempts
    ),
    run_length_rollup as (
      select
        bucket,
        bucket_order,
        count(*)::integer as runs,
        max(score)::integer as longest
      from run_length_buckets
      group by bucket, bucket_order
    ),
    score_rollup as (
      select
        score,
        total_questions,
        percentage,
        count(*)::integer as quizzes,
        max(completed_at) as latest_at
      from standard_attempts
      group by score, total_questions, percentage
    ),
    score_category_rollup as (
      select
        score,
        total_questions,
        category_id,
        count(*)::integer as quizzes
      from standard_attempts
      group by score, total_questions, category_id
    ),
    daily_series as (
      select generate_series(
        local_today - 29,
        local_today,
        interval '1 day'
      )::date as day
    ),
    daily_rollup as (
      select
        local_date,
        count(*)::integer as quizzes,
        count(*) filter (where not is_unlimited)::integer as standard_quizzes,
        count(*) filter (where is_unlimited)::integer as unlimited_quizzes,
        coalesce(max(score) filter (where is_unlimited), 0)::integer as best_unlimited_score,
        coalesce(sum(score), 0)::integer as correct,
        coalesce(sum(total_questions), 0)::integer as questions
      from normalized
      where local_date >= local_today - 29
      group by local_date
    )
    select jsonb_build_object(
      'generated_at', current_timestamp,
      'timezone', effective_timezone,
      'overview', jsonb_build_object(
        'total_quizzes', standard_overview.total_quizzes,
        'total_sessions', activity_overview.total_sessions,
        'unlimited_quizzes', unlimited_overview.runs,
        'unlimited_share', case
          when activity_overview.total_sessions = 0 then 0
          else round(
            unlimited_overview.runs::numeric * 100 / activity_overview.total_sessions, 1
          )
        end,
        'quizzes_today', activity_overview.quizzes_today,
        'standard_today', activity_overview.standard_today,
        'unlimited_today', activity_overview.unlimited_today,
        'quizzes_last_7_days', activity_overview.quizzes_last_7_days,
        'quizzes_last_30_days', activity_overview.quizzes_last_30_days,
        'average_percentage', standard_overview.average_percentage,
        'best_percentage', standard_overview.best_percentage,
        'perfect_scores', standard_overview.perfect_scores,
        'standard_total_correct', standard_overview.total_correct,
        'standard_total_questions', standard_overview.total_questions,
        'total_correct', activity_overview.total_correct,
        'total_questions', activity_overview.total_questions,
        'accuracy', case
          when activity_overview.total_questions = 0 then 0
          else round(
            activity_overview.total_correct::numeric * 100
              / activity_overview.total_questions, 1
          )
        end,
        'first_try_correct', activity_overview.first_try_correct,
        'second_chance_correct', activity_overview.second_chance_correct,
        'total_seconds', activity_overview.total_seconds,
        'average_duration_seconds', standard_overview.average_duration_seconds,
        'active_days', activity_overview.active_days,
        'current_streak', coalesce((
          select streak.days
          from streaks as streak
          where streak.end_date = (select max(local_date) from play_dates)
            and streak.end_date >= local_today - 1
        ), 0),
        'longest_streak', coalesce((select max(days) from streaks), 0),
        'first_played_at', activity_overview.first_played_at,
        'last_played_at', activity_overview.last_played_at,
        'question_bank', coalesce((
          select sum(pool_size)::integer from pool_sizes
        ), 0)
      ),
      'unlimited', jsonb_build_object(
        'runs', unlimited_overview.runs,
        'runs_last_30_days', unlimited_overview.runs_last_30_days,
        'runs_over_100', unlimited_overview.runs_over_100,
        'best_score', unlimited_overview.best_score,
        'average_score', unlimited_overview.average_score,
        'median_score', unlimited_overview.median_score,
        'total_correct', unlimited_overview.total_correct,
        'questions_answered', unlimited_overview.questions_answered,
        'accuracy', unlimited_overview.accuracy,
        'first_try_correct', unlimited_overview.first_try_correct,
        'second_chance_correct', unlimited_overview.second_chance_correct,
        'average_duration_seconds', unlimited_overview.average_duration_seconds,
        'total_seconds', unlimited_overview.total_seconds,
        'first_run_at', unlimited_overview.first_run_at,
        'last_run_at', unlimited_overview.last_run_at,
        'run_lengths', coalesce((
          select jsonb_agg(
            jsonb_build_object(
              'bucket', bucket_group.bucket,
              'runs', bucket_group.runs,
              'longest', bucket_group.longest,
              'share_percentage', round(
                bucket_group.runs::numeric * 100
                  / nullif(unlimited_overview.runs, 0),
                1
              )
            )
            order by bucket_group.bucket_order
          )
          from run_length_rollup as bucket_group
        ), '[]'::jsonb),
        'top_runs', coalesce((
          select jsonb_agg(to_jsonb(top_run) order by top_run.score desc, top_run.completed_at desc)
          from (
            select
              result.source_id,
              result.category_id,
              category.display_name as category_name,
              result.score,
              result.total_questions,
              result.first_try_correct,
              result.second_try_correct,
              result.duration_seconds,
              result.completed_at
            from unlimited_attempts as result
            join public.quiz_categories as category
              on category.id = result.category_id
            order by result.score desc, result.completed_at desc
            limit 10
          ) as top_run
        ), '[]'::jsonb)
      ),
      -- The standard rounds that happened before the change. Kept whole.
      'archive', jsonb_build_object(
        'rounds', standard_overview.total_quizzes,
        'average_percentage', standard_overview.average_percentage,
        'best_percentage', standard_overview.best_percentage,
        'perfect_scores', standard_overview.perfect_scores,
        'total_correct', standard_overview.total_correct,
        'total_questions', standard_overview.total_questions,
        'average_duration_seconds', standard_overview.average_duration_seconds,
        'last_played_at', standard_overview.last_played_at
      ),
      'categories', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'id', category.id,
            'name', category.display_name,
            'language_code', category.language_code,
            'pool_size', coalesce(pool.pool_size, 0),
            'quizzes', coalesce(standard_rollup.quizzes, 0),
            'unlimited_quizzes', coalesce(unlimited_rollup.runs, 0),
            'unlimited_best_score', coalesce(unlimited_rollup.best_score, 0),
            'unlimited_best_at', best_run.best_at,
            'unlimited_best_total', best_run.best_total,
            'unlimited_average_score', coalesce(unlimited_rollup.average_score, 0),
            'unlimited_total_correct', coalesce(unlimited_rollup.total_correct, 0),
            'unlimited_questions_answered', coalesce(unlimited_rollup.questions_answered, 0),
            'unlimited_accuracy', coalesce(unlimited_rollup.accuracy, 0),
            'unlimited_second_chance_correct',
              coalesce(unlimited_rollup.second_chance_correct, 0),
            -- How much of the bank the best run reached, which is the number
            -- that says "she has finished this quiz".
            'best_share_of_pool', case
              when coalesce(pool.pool_size, 0) = 0 then 0
              else round(
                coalesce(unlimited_rollup.best_score, 0)::numeric * 100 / pool.pool_size,
                1
              )
            end,
            'average_percentage', coalesce(standard_rollup.average_percentage, 0),
            'best_percentage', coalesce(standard_rollup.best_percentage, 0),
            'perfect_scores', coalesce(standard_rollup.perfect_scores, 0),
            'total_correct', coalesce(standard_rollup.total_correct, 0),
            'total_questions', coalesce(standard_rollup.total_questions, 0),
            'first_try_correct', coalesce(standard_rollup.first_try_correct, 0),
            'second_chance_correct', coalesce(standard_rollup.second_chance_correct, 0),
            'average_duration_seconds', coalesce(standard_rollup.average_duration_seconds, 0),
            'last_played_at', greatest(
              standard_rollup.last_played_at,
              unlimited_rollup.last_played_at
            )
          )
          order by category.display_order
        )
        from public.quiz_categories as category
        left join category_standard_rollup as standard_rollup
          on standard_rollup.category_id = category.id
        left join category_unlimited_rollup as unlimited_rollup
          on unlimited_rollup.category_id = category.id
        left join category_best_run as best_run
          on best_run.category_id = category.id
        left join pool_sizes as pool on pool.category_id = category.id
        where category.is_active
      ), '[]'::jsonb),
      'score_distribution', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'score', score_group.score,
            'total_questions', score_group.total_questions,
            'percentage', score_group.percentage,
            'quizzes', score_group.quizzes,
            'share_percentage', round(
              score_group.quizzes::numeric * 100 /
                nullif(standard_overview.total_quizzes, 0),
              1
            ),
            'latest_at', score_group.latest_at,
            'categories', coalesce((
              select jsonb_agg(
                jsonb_build_object(
                  'id', category_count.category_id,
                  'name', category.display_name,
                  'quizzes', category_count.quizzes
                )
                order by category.display_order
              )
              from score_category_rollup as category_count
              join public.quiz_categories as category
                on category.id = category_count.category_id
              where category_count.score = score_group.score
                and category_count.total_questions = score_group.total_questions
            ), '[]'::jsonb)
          )
          order by score_group.percentage desc, score_group.score desc
        )
        from score_rollup as score_group
        cross join standard_overview
      ), '[]'::jsonb),
      'daily_activity', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'date', to_char(days.day, 'YYYY-MM-DD'),
            'quizzes', coalesce(activity.quizzes, 0),
            'standard_quizzes', coalesce(activity.standard_quizzes, 0),
            'unlimited_quizzes', coalesce(activity.unlimited_quizzes, 0),
            'best_unlimited_score', coalesce(activity.best_unlimited_score, 0),
            'correct', coalesce(activity.correct, 0),
            'questions', coalesce(activity.questions, 0)
          )
          order by days.day
        )
        from daily_series as days
        left join daily_rollup as activity on activity.local_date = days.day
      ), '[]'::jsonb),
      'recent_results', coalesce((
        select jsonb_agg(to_jsonb(recent) order by recent.completed_at desc)
        from (
          select
            result.source_id,
            result.category_id,
            category.display_name as category_name,
            result.score,
            result.total_questions,
            result.percentage,
            result.first_try_correct,
            result.second_try_correct,
            result.duration_seconds,
            result.completed_at,
            result.is_unlimited
          from normalized as result
          join public.quiz_categories as category on category.id = result.category_id
          order by result.completed_at desc
          limit 30
        ) as recent
      ), '[]'::jsonb)
    )
    from standard_overview
    cross join activity_overview
    cross join unlimited_overview
  );
end;
$$;

revoke all on function public.get_quiz_public_metrics(text)
  from public, anon, authenticated;
grant execute on function public.get_quiz_public_metrics(text)
  to anon, authenticated, service_role;

comment on function public.get_quiz_public_metrics(text) is
  'Unlimited-first metrics for /metrics, counted in the player''s own timezone. The pre-change standard rounds stay under "archive".';
