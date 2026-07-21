-- Public, aggregate-only metrics for the owner-facing dashboard.
-- Raw answer payloads, user IDs, and device IDs remain private.

create table public.quiz_public_attempts (
  source_id uuid primary key,
  category_id text not null references public.quiz_categories(id),
  score smallint not null,
  total_questions smallint not null,
  first_try_correct smallint not null default 0,
  second_try_correct smallint not null default 0,
  completed_at timestamptz not null,
  duration_seconds integer not null,
  constraint quiz_public_attempts_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint quiz_public_attempts_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint quiz_public_attempts_valid_duration
    check (duration_seconds >= 0)
);

create index quiz_public_attempts_completed_idx
  on public.quiz_public_attempts (completed_at desc);

create index quiz_public_attempts_category_completed_idx
  on public.quiz_public_attempts (category_id, completed_at desc);

alter table public.quiz_public_attempts enable row level security;

create policy "Anyone can read sanitized quiz attempts"
  on public.quiz_public_attempts for select
  to anon, authenticated
  using (true);

-- Categories contain only public labels and ordering used by both pages.
create policy "Visitors can read active categories"
  on public.quiz_categories for select
  to anon
  using (is_active);

revoke all on table public.quiz_public_attempts from anon, authenticated;
grant select on table public.quiz_public_attempts to anon, authenticated;
grant select on table public.quiz_categories to anon;
grant all on table public.quiz_public_attempts to service_role;

create or replace function private.copy_quiz_result_to_public_attempts()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  request_user uuid := (select auth.uid());
begin
  if request_user is null or request_user <> new.user_id then
    raise exception 'A public quiz summary may only be created for the current player'
      using errcode = '42501';
  end if;

  insert into public.quiz_public_attempts (
    source_id,
    category_id,
    score,
    total_questions,
    first_try_correct,
    second_try_correct,
    completed_at,
    duration_seconds
  ) values (
    new.id,
    tg_argv[0],
    new.score,
    new.total_questions,
    new.first_try_correct,
    new.second_try_correct,
    new.completed_at,
    new.duration_seconds
  )
  on conflict (source_id) do nothing;

  return new;
end;
$$;

revoke all on function private.copy_quiz_result_to_public_attempts()
  from public, anon, authenticated;

create trigger history_public_metrics_after_insert
  after insert on public.history_quiz_results
  for each row execute function private.copy_quiz_result_to_public_attempts('history');
create trigger geography_public_metrics_after_insert
  after insert on public.geography_quiz_results
  for each row execute function private.copy_quiz_result_to_public_attempts('geography');
create trigger mixed_public_metrics_after_insert
  after insert on public.mixed_quiz_results
  for each row execute function private.copy_quiz_result_to_public_attempts('mix');
create trigger hungarian_public_metrics_after_insert
  after insert on public.hungarian_quiz_results
  for each row execute function private.copy_quiz_result_to_public_attempts('hungarian');
create trigger fifth_grader_public_metrics_after_insert
  after insert on public.fifth_grader_quiz_results
  for each row execute function private.copy_quiz_result_to_public_attempts('fifth_grader');

-- Backfill completed quizzes without copying identities or answer details.
insert into public.quiz_public_attempts (
  source_id, category_id, score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
)
select id, 'history', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
from public.history_quiz_results
on conflict (source_id) do nothing;

insert into public.quiz_public_attempts (
  source_id, category_id, score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
)
select id, 'geography', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
from public.geography_quiz_results
on conflict (source_id) do nothing;

insert into public.quiz_public_attempts (
  source_id, category_id, score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
)
select id, 'mix', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
from public.mixed_quiz_results
on conflict (source_id) do nothing;

insert into public.quiz_public_attempts (
  source_id, category_id, score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
)
select id, 'hungarian', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
from public.hungarian_quiz_results
on conflict (source_id) do nothing;

insert into public.quiz_public_attempts (
  source_id, category_id, score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
)
select id, 'fifth_grader', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds
from public.fifth_grader_quiz_results
on conflict (source_id) do nothing;

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
        round(
          attempt.score::numeric * 100 / attempt.total_questions,
          1
        ) as percentage,
        (attempt.completed_at at time zone effective_timezone)::date as local_date
      from public.quiz_public_attempts as attempt
    ),
    overview as (
      select
        count(*)::integer as total_quizzes,
        count(*) filter (where local_date = local_today)::integer as quizzes_today,
        count(*) filter (where local_date >= local_today - 6)::integer as quizzes_last_7_days,
        count(*) filter (where local_date >= local_today - 29)::integer as quizzes_last_30_days,
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
        count(distinct local_date)::integer as active_days,
        min(completed_at) as first_played_at,
        max(completed_at) as last_played_at
      from normalized
    ),
    play_dates as (
      select distinct local_date
      from normalized
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
    category_rollup as (
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
      from normalized
      group by category_id
    ),
    score_rollup as (
      select
        score,
        total_questions,
        percentage,
        count(*)::integer as quizzes,
        max(completed_at) as latest_at
      from normalized
      group by score, total_questions, percentage
    ),
    score_category_rollup as (
      select
        score,
        total_questions,
        category_id,
        count(*)::integer as quizzes
      from normalized
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
        'total_quizzes', overview.total_quizzes,
        'quizzes_today', overview.quizzes_today,
        'quizzes_last_7_days', overview.quizzes_last_7_days,
        'quizzes_last_30_days', overview.quizzes_last_30_days,
        'average_percentage', overview.average_percentage,
        'best_percentage', overview.best_percentage,
        'perfect_scores', overview.perfect_scores,
        'total_correct', overview.total_correct,
        'total_questions', overview.total_questions,
        'first_try_correct', overview.first_try_correct,
        'second_chance_correct', overview.second_chance_correct,
        'average_duration_seconds', overview.average_duration_seconds,
        'active_days', overview.active_days,
        'current_streak', coalesce((
          select streak.days
          from streaks as streak
          where streak.end_date = (select max(local_date) from play_dates)
            and streak.end_date >= local_today - 1
        ), 0),
        'longest_streak', coalesce((select max(days) from streaks), 0),
        'first_played_at', overview.first_played_at,
        'last_played_at', overview.last_played_at
      ),
      'categories', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'id', category.id,
            'name', category.display_name,
            'quizzes', coalesce(rollup.quizzes, 0),
            'average_percentage', coalesce(rollup.average_percentage, 0),
            'best_percentage', coalesce(rollup.best_percentage, 0),
            'perfect_scores', coalesce(rollup.perfect_scores, 0),
            'total_correct', coalesce(rollup.total_correct, 0),
            'total_questions', coalesce(rollup.total_questions, 0),
            'first_try_correct', coalesce(rollup.first_try_correct, 0),
            'second_chance_correct', coalesce(rollup.second_chance_correct, 0),
            'average_duration_seconds', coalesce(rollup.average_duration_seconds, 0),
            'last_played_at', rollup.last_played_at
          )
          order by category.display_order
        )
        from public.quiz_categories as category
        left join category_rollup as rollup on rollup.category_id = category.id
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
              score_group.quizzes::numeric * 100 / nullif(overview.total_quizzes, 0),
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
        cross join overview
      ), '[]'::jsonb),
      'daily_activity', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'date', to_char(days.day, 'YYYY-MM-DD'),
            'quizzes', coalesce(activity.quizzes, 0),
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
            result.completed_at
          from normalized as result
          join public.quiz_categories as category on category.id = result.category_id
          order by result.completed_at desc
          limit 30
        ) as recent
      ), '[]'::jsonb)
    )
    from overview
  );
end;
$$;

revoke all on function public.get_quiz_public_metrics(text)
  from public, anon, authenticated;
grant execute on function public.get_quiz_public_metrics(text)
  to anon, authenticated, service_role;

comment on table public.quiz_public_attempts is
  'Sanitized, identity-free quiz attempts intentionally readable by the public metrics page.';
comment on function public.get_quiz_public_metrics(text) is
  'Returns the small aggregate payload used by the public /metrics dashboard.';
