-- Add Unlimited Mode without changing the meaning of existing standard scores.
-- Existing rows receive the non-rewriting constant default of false.

alter table public.history_quiz_results
  add column is_unlimited boolean not null default false;
alter table public.geography_quiz_results
  add column is_unlimited boolean not null default false;
alter table public.mixed_quiz_results
  add column is_unlimited boolean not null default false;
alter table public.hungarian_quiz_results
  add column is_unlimited boolean not null default false;
alter table public.fifth_grader_quiz_results
  add column is_unlimited boolean not null default false;

alter table public.fifth_grader_quiz_results
  add constraint fifth_grader_result_standard_mode_only
  check (not is_unlimited);

alter table public.quiz_public_attempts
  add column is_unlimited boolean not null default false;

create index quiz_public_attempts_unlimited_score_idx
  on public.quiz_public_attempts (score desc, completed_at desc)
  where is_unlimited;

alter table public.quiz_metrics
  add column unlimited_quizzes_taken integer not null default 0
    check (unlimited_quizzes_taken >= 0),
  add column standard_total_correct integer not null default 0
    check (standard_total_correct >= 0),
  add column standard_total_questions integer not null default 0
    check (standard_total_questions >= 0);

alter table public.quiz_metrics
  add column standard_average_percentage numeric(5, 2)
    generated always as (
      case
        when standard_total_questions = 0 then 0
        else round(
          standard_total_correct::numeric * 100 / standard_total_questions,
          2
        )
      end
    ) stored;

create or replace view private.all_quiz_results_for_tracking
with (security_invoker = true)
as
select
  id as source_id,
  user_id,
  'history'::text as category_id,
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds,
  is_unlimited
from public.history_quiz_results
union all
select
  id,
  user_id,
  'geography',
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds,
  is_unlimited
from public.geography_quiz_results
union all
select
  id,
  user_id,
  'mix',
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds,
  is_unlimited
from public.mixed_quiz_results
union all
select
  id,
  user_id,
  'hungarian',
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds,
  is_unlimited
from public.hungarian_quiz_results
union all
select
  id,
  user_id,
  'fifth_grader',
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds,
  is_unlimited
from public.fifth_grader_quiz_results;

revoke all on table private.all_quiz_results_for_tracking
  from public, anon, authenticated, service_role;

create or replace function private.refresh_quiz_metrics(
  target_user_id uuid,
  target_category_id text
)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  summary record;
begin
  if target_user_id is null
     or target_category_id not in (
       'history', 'geography', 'mix', 'hungarian', 'fifth_grader'
     ) then
    raise exception 'Invalid quiz tracking target'
      using errcode = '22023';
  end if;

  select
    count(*)::integer as attempts_taken,
    count(*) filter (where not result.is_unlimited)::integer as quizzes_taken,
    count(*) filter (where result.is_unlimited)::integer as unlimited_quizzes_taken,
    coalesce(sum(result.score), 0)::integer as total_correct,
    coalesce(sum(result.total_questions), 0)::integer as total_questions,
    coalesce(sum(result.score) filter (
      where not result.is_unlimited
    ), 0)::integer as standard_total_correct,
    coalesce(sum(result.total_questions) filter (
      where not result.is_unlimited
    ), 0)::integer as standard_total_questions,
    coalesce(
      round(max(
        result.score::numeric * 100 / result.total_questions
      ) filter (where not result.is_unlimited), 2),
      0
    ) as best_percentage,
    (array_agg(
      result.score order by result.completed_at desc, result.source_id desc
    ))[1]::smallint as last_score,
    (array_agg(
      result.total_questions order by result.completed_at desc, result.source_id desc
    ))[1]::smallint as last_total,
    max(result.completed_at) as last_played_at
  into summary
  from private.all_quiz_results_for_tracking as result
  where result.user_id = target_user_id
    and result.category_id = target_category_id;

  if summary.attempts_taken = 0 then
    delete from public.quiz_metrics
    where user_id = target_user_id
      and category_id = target_category_id;
    return;
  end if;

  insert into public.quiz_metrics (
    user_id,
    category_id,
    quizzes_taken,
    unlimited_quizzes_taken,
    total_correct,
    total_questions,
    standard_total_correct,
    standard_total_questions,
    best_percentage,
    last_score,
    last_total,
    last_played_at,
    updated_at
  ) values (
    target_user_id,
    target_category_id,
    summary.quizzes_taken,
    summary.unlimited_quizzes_taken,
    summary.total_correct,
    summary.total_questions,
    summary.standard_total_correct,
    summary.standard_total_questions,
    summary.best_percentage,
    summary.last_score,
    summary.last_total,
    summary.last_played_at,
    now()
  )
  on conflict (user_id, category_id) do update set
    quizzes_taken = excluded.quizzes_taken,
    unlimited_quizzes_taken = excluded.unlimited_quizzes_taken,
    total_correct = excluded.total_correct,
    total_questions = excluded.total_questions,
    standard_total_correct = excluded.standard_total_correct,
    standard_total_questions = excluded.standard_total_questions,
    best_percentage = excluded.best_percentage,
    last_score = excluded.last_score,
    last_total = excluded.last_total,
    last_played_at = excluded.last_played_at,
    updated_at = now();
end;
$$;

revoke all on function private.refresh_quiz_metrics(uuid, text)
  from public, anon, authenticated, service_role;

create or replace function private.sync_quiz_tracking()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  request_user uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if request_user is null or request_user <> new.user_id then
      raise exception 'A quiz result may only update tracking for the current player'
        using errcode = '42501';
    end if;
  elsif tg_op = 'UPDATE' then
    if request_user is not null
       and (request_user <> old.user_id or request_user <> new.user_id) then
      raise exception 'A quiz result may only update tracking for the current player'
        using errcode = '42501';
    end if;
  elsif request_user is not null and request_user <> old.user_id then
    raise exception 'A quiz result may only update tracking for the current player'
      using errcode = '42501';
  end if;

  if tg_op = 'DELETE' then
    delete from public.quiz_public_attempts
    where source_id = old.id;

    perform private.refresh_quiz_metrics(old.user_id, tg_argv[0]);
    return old;
  end if;

  if tg_op = 'UPDATE' and old.id <> new.id then
    delete from public.quiz_public_attempts
    where source_id = old.id;
  end if;

  insert into public.quiz_public_attempts (
    source_id,
    category_id,
    score,
    total_questions,
    first_try_correct,
    second_try_correct,
    completed_at,
    duration_seconds,
    is_unlimited
  ) values (
    new.id,
    tg_argv[0],
    new.score,
    new.total_questions,
    new.first_try_correct,
    new.second_try_correct,
    new.completed_at,
    new.duration_seconds,
    new.is_unlimited
  )
  on conflict (source_id) do update set
    category_id = excluded.category_id,
    score = excluded.score,
    total_questions = excluded.total_questions,
    first_try_correct = excluded.first_try_correct,
    second_try_correct = excluded.second_try_correct,
    completed_at = excluded.completed_at,
    duration_seconds = excluded.duration_seconds,
    is_unlimited = excluded.is_unlimited;

  if tg_op = 'UPDATE' and old.user_id <> new.user_id then
    perform private.refresh_quiz_metrics(old.user_id, tg_argv[0]);
  end if;
  perform private.refresh_quiz_metrics(new.user_id, tg_argv[0]);

  return new;
end;
$$;

revoke all on function private.sync_quiz_tracking()
  from public, anon, authenticated, service_role;

-- Keep the owner-only SQL view useful without changing existing column order.
create or replace view public.quiz_metrics_dashboard
with (security_invoker = true)
as
select
  m.user_id,
  p.device_id,
  c.display_name as quiz,
  m.quizzes_taken,
  m.standard_average_percentage as average_percentage,
  m.best_percentage,
  m.total_correct,
  m.total_questions,
  m.last_score,
  m.last_total,
  m.last_played_at,
  p.timezone,
  p.browser_language,
  m.unlimited_quizzes_taken,
  m.average_percentage as all_modes_average_percentage
from public.quiz_metrics m
join public.quiz_categories c on c.id = m.category_id
left join public.quiz_players p on p.user_id = m.user_id
order by m.last_played_at desc nulls last;

revoke all on table public.quiz_metrics_dashboard
  from public, anon, authenticated;
grant select on table public.quiz_metrics_dashboard
  to service_role;

-- Reconcile the public mirror. The conditional update leaves every existing
-- standard row untouched because its new flag is already false.
insert into public.quiz_public_attempts (
  source_id,
  category_id,
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds,
  is_unlimited
)
select
  source_id,
  category_id,
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds,
  is_unlimited
from private.all_quiz_results_for_tracking
on conflict (source_id) do update set
  category_id = excluded.category_id,
  score = excluded.score,
  total_questions = excluded.total_questions,
  first_try_correct = excluded.first_try_correct,
  second_try_correct = excluded.second_try_correct,
  completed_at = excluded.completed_at,
  duration_seconds = excluded.duration_seconds,
  is_unlimited = excluded.is_unlimited
where (
  public.quiz_public_attempts.category_id,
  public.quiz_public_attempts.score,
  public.quiz_public_attempts.total_questions,
  public.quiz_public_attempts.first_try_correct,
  public.quiz_public_attempts.second_try_correct,
  public.quiz_public_attempts.completed_at,
  public.quiz_public_attempts.duration_seconds,
  public.quiz_public_attempts.is_unlimited
) is distinct from (
  excluded.category_id,
  excluded.score,
  excluded.total_questions,
  excluded.first_try_correct,
  excluded.second_try_correct,
  excluded.completed_at,
  excluded.duration_seconds,
  excluded.is_unlimited
);

-- Reconcile per-player aggregates without rewriting already-correct rows.
with source_metrics as (
  select
    result.user_id,
    result.category_id,
    count(*) filter (where not result.is_unlimited)::integer as quizzes_taken,
    count(*) filter (where result.is_unlimited)::integer as unlimited_quizzes_taken,
    sum(result.score)::integer as total_correct,
    sum(result.total_questions)::integer as total_questions,
    coalesce(sum(result.score) filter (
      where not result.is_unlimited
    ), 0)::integer as standard_total_correct,
    coalesce(sum(result.total_questions) filter (
      where not result.is_unlimited
    ), 0)::integer as standard_total_questions,
    coalesce(round(max(
      result.score::numeric * 100 / result.total_questions
    ) filter (where not result.is_unlimited), 2), 0) as best_percentage,
    (array_agg(
      result.score order by result.completed_at desc, result.source_id desc
    ))[1]::smallint as last_score,
    (array_agg(
      result.total_questions order by result.completed_at desc, result.source_id desc
    ))[1]::smallint as last_total,
    max(result.completed_at) as last_played_at
  from private.all_quiz_results_for_tracking as result
  group by result.user_id, result.category_id
)
insert into public.quiz_metrics (
  user_id,
  category_id,
  quizzes_taken,
  unlimited_quizzes_taken,
  total_correct,
  total_questions,
  standard_total_correct,
  standard_total_questions,
  best_percentage,
  last_score,
  last_total,
  last_played_at,
  updated_at
)
select
  user_id,
  category_id,
  quizzes_taken,
  unlimited_quizzes_taken,
  total_correct,
  total_questions,
  standard_total_correct,
  standard_total_questions,
  best_percentage,
  last_score,
  last_total,
  last_played_at,
  now()
from source_metrics
on conflict (user_id, category_id) do update set
  quizzes_taken = excluded.quizzes_taken,
  unlimited_quizzes_taken = excluded.unlimited_quizzes_taken,
  total_correct = excluded.total_correct,
  total_questions = excluded.total_questions,
  standard_total_correct = excluded.standard_total_correct,
  standard_total_questions = excluded.standard_total_questions,
  best_percentage = excluded.best_percentage,
  last_score = excluded.last_score,
  last_total = excluded.last_total,
  last_played_at = excluded.last_played_at,
  updated_at = now()
where (
  public.quiz_metrics.quizzes_taken,
  public.quiz_metrics.unlimited_quizzes_taken,
  public.quiz_metrics.total_correct,
  public.quiz_metrics.total_questions,
  public.quiz_metrics.standard_total_correct,
  public.quiz_metrics.standard_total_questions,
  public.quiz_metrics.best_percentage,
  public.quiz_metrics.last_score,
  public.quiz_metrics.last_total,
  public.quiz_metrics.last_played_at
) is distinct from (
  excluded.quizzes_taken,
  excluded.unlimited_quizzes_taken,
  excluded.total_correct,
  excluded.total_questions,
  excluded.standard_total_correct,
  excluded.standard_total_questions,
  excluded.best_percentage,
  excluded.last_score,
  excluded.last_total,
  excluded.last_played_at
);

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
  select timezone.name
    into effective_timezone
  from pg_catalog.pg_timezone_names as timezone
  where timezone.name = coalesce(nullif(viewer_timezone, ''), 'UTC')
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
        round(
          attempt.score::numeric * 100 / attempt.total_questions,
          1
        ) as percentage,
        (attempt.completed_at at time zone effective_timezone)::date as local_date
      from public.quiz_public_attempts as attempt
    ),
    standard_attempts as materialized (
      select * from normalized where not is_unlimited
    ),
    unlimited_attempts as materialized (
      select * from normalized where is_unlimited
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
        coalesce(round(avg(duration_seconds)), 0)::integer as average_duration_seconds
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
        coalesce(sum(score), 0)::integer as total_correct,
        coalesce(sum(second_try_correct), 0)::integer as second_chance_correct,
        coalesce(round(avg(duration_seconds)), 0)::integer as average_duration_seconds
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
        max(completed_at) as last_played_at
      from unlimited_attempts
      group by category_id
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
        'first_try_correct', activity_overview.first_try_correct,
        'second_chance_correct', activity_overview.second_chance_correct,
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
        'last_played_at', activity_overview.last_played_at
      ),
      'unlimited', jsonb_build_object(
        'runs', unlimited_overview.runs,
        'best_score', unlimited_overview.best_score,
        'average_score', unlimited_overview.average_score,
        'total_correct', unlimited_overview.total_correct,
        'second_chance_correct', unlimited_overview.second_chance_correct,
        'average_duration_seconds', unlimited_overview.average_duration_seconds,
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
            limit 3
          ) as top_run
        ), '[]'::jsonb)
      ),
      'categories', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'id', category.id,
            'name', category.display_name,
            'quizzes', coalesce(standard_rollup.quizzes, 0),
            'unlimited_quizzes', coalesce(unlimited_rollup.runs, 0),
            'unlimited_best_score', coalesce(unlimited_rollup.best_score, 0),
            'unlimited_average_score', coalesce(unlimited_rollup.average_score, 0),
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

comment on column public.history_quiz_results.is_unlimited is
  'True when the result came from sudden-death Unlimited Mode.';
comment on column public.quiz_public_attempts.is_unlimited is
  'Identity-free mode marker used to separate standard and Unlimited metrics.';
comment on function public.get_quiz_public_metrics(text) is
  'Returns standard metrics, combined activity, and separate Unlimited Mode records for /metrics.';
