-- Quiz Time: question bank, anonymous players, per-quiz results, and metrics.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table public.quiz_categories (
  id text primary key,
  display_name text not null,
  description text not null,
  language_code text not null default 'en' check (language_code in ('en', 'hu')),
  display_order smallint not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.quiz_questions (
  id text primary key,
  category_id text not null references public.quiz_categories(id),
  prompt text not null,
  correct_answer text not null,
  wrong_answers text[] not null,
  language_code text not null default 'en' check (language_code in ('en', 'hu')),
  grade_level smallint check (grade_level between 1 and 5),
  subject text,
  display_order integer not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint quiz_questions_three_wrong_answers check (cardinality(wrong_answers) = 3),
  constraint quiz_questions_grade_for_fifth_grader check (
    (category_id = 'fifth_grader' and grade_level is not null and subject is not null)
    or
    (category_id <> 'fifth_grader' and grade_level is null)
  )
);

create index quiz_questions_category_active_idx
  on public.quiz_questions (category_id, is_active, grade_level);

create table public.quiz_players (
  user_id uuid primary key references auth.users(id) on delete cascade,
  device_id uuid not null,
  browser_language text,
  timezone text,
  first_seen_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now()
);

create table public.history_quiz_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  score smallint not null,
  total_questions smallint not null,
  first_try_correct smallint not null default 0,
  second_try_correct smallint not null default 0,
  started_at timestamptz not null,
  completed_at timestamptz not null default now(),
  duration_seconds integer not null,
  answers jsonb not null default '[]'::jsonb,
  lifelines_used jsonb not null default '{}'::jsonb,
  constraint history_result_valid_score check (total_questions > 0 and score between 0 and total_questions),
  constraint history_result_valid_counts check (first_try_correct >= 0 and second_try_correct >= 0 and first_try_correct + second_try_correct = score),
  constraint history_result_valid_duration check (duration_seconds >= 0),
  constraint history_result_answers_array check (jsonb_typeof(answers) = 'array'),
  constraint history_result_lifelines_object check (jsonb_typeof(lifelines_used) = 'object')
);

create table public.geography_quiz_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  score smallint not null,
  total_questions smallint not null,
  first_try_correct smallint not null default 0,
  second_try_correct smallint not null default 0,
  started_at timestamptz not null,
  completed_at timestamptz not null default now(),
  duration_seconds integer not null,
  answers jsonb not null default '[]'::jsonb,
  lifelines_used jsonb not null default '{}'::jsonb,
  constraint geography_result_valid_score check (total_questions > 0 and score between 0 and total_questions),
  constraint geography_result_valid_counts check (first_try_correct >= 0 and second_try_correct >= 0 and first_try_correct + second_try_correct = score),
  constraint geography_result_valid_duration check (duration_seconds >= 0),
  constraint geography_result_answers_array check (jsonb_typeof(answers) = 'array'),
  constraint geography_result_lifelines_object check (jsonb_typeof(lifelines_used) = 'object')
);

create table public.mixed_quiz_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  score smallint not null,
  total_questions smallint not null,
  first_try_correct smallint not null default 0,
  second_try_correct smallint not null default 0,
  started_at timestamptz not null,
  completed_at timestamptz not null default now(),
  duration_seconds integer not null,
  answers jsonb not null default '[]'::jsonb,
  lifelines_used jsonb not null default '{}'::jsonb,
  constraint mixed_result_valid_score check (total_questions > 0 and score between 0 and total_questions),
  constraint mixed_result_valid_counts check (first_try_correct >= 0 and second_try_correct >= 0 and first_try_correct + second_try_correct = score),
  constraint mixed_result_valid_duration check (duration_seconds >= 0),
  constraint mixed_result_answers_array check (jsonb_typeof(answers) = 'array'),
  constraint mixed_result_lifelines_object check (jsonb_typeof(lifelines_used) = 'object')
);

create table public.hungarian_quiz_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  score smallint not null,
  total_questions smallint not null,
  first_try_correct smallint not null default 0,
  second_try_correct smallint not null default 0,
  started_at timestamptz not null,
  completed_at timestamptz not null default now(),
  duration_seconds integer not null,
  answers jsonb not null default '[]'::jsonb,
  lifelines_used jsonb not null default '{}'::jsonb,
  constraint hungarian_result_valid_score check (total_questions > 0 and score between 0 and total_questions),
  constraint hungarian_result_valid_counts check (first_try_correct >= 0 and second_try_correct >= 0 and first_try_correct + second_try_correct = score),
  constraint hungarian_result_valid_duration check (duration_seconds >= 0),
  constraint hungarian_result_answers_array check (jsonb_typeof(answers) = 'array'),
  constraint hungarian_result_lifelines_object check (jsonb_typeof(lifelines_used) = 'object')
);

create table public.fifth_grader_quiz_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  score smallint not null,
  total_questions smallint not null,
  first_try_correct smallint not null default 0,
  second_try_correct smallint not null default 0,
  started_at timestamptz not null,
  completed_at timestamptz not null default now(),
  duration_seconds integer not null,
  answers jsonb not null default '[]'::jsonb,
  lifelines_used jsonb not null default '{}'::jsonb,
  constraint fifth_grader_result_valid_score check (total_questions > 0 and score between 0 and total_questions),
  constraint fifth_grader_result_valid_counts check (first_try_correct >= 0 and second_try_correct >= 0 and first_try_correct + second_try_correct = score),
  constraint fifth_grader_result_valid_duration check (duration_seconds >= 0),
  constraint fifth_grader_result_answers_array check (jsonb_typeof(answers) = 'array'),
  constraint fifth_grader_result_lifelines_object check (jsonb_typeof(lifelines_used) = 'object')
);

create index history_quiz_results_user_completed_idx
  on public.history_quiz_results (user_id, completed_at desc);
create index geography_quiz_results_user_completed_idx
  on public.geography_quiz_results (user_id, completed_at desc);
create index mixed_quiz_results_user_completed_idx
  on public.mixed_quiz_results (user_id, completed_at desc);
create index hungarian_quiz_results_user_completed_idx
  on public.hungarian_quiz_results (user_id, completed_at desc);
create index fifth_grader_quiz_results_user_completed_idx
  on public.fifth_grader_quiz_results (user_id, completed_at desc);

create table public.quiz_metrics (
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id text not null references public.quiz_categories(id),
  quizzes_taken integer not null default 0 check (quizzes_taken >= 0),
  total_correct integer not null default 0 check (total_correct >= 0),
  total_questions integer not null default 0 check (total_questions >= 0),
  average_percentage numeric(5, 2) generated always as (
    case
      when total_questions = 0 then 0
      else round(total_correct::numeric * 100 / total_questions, 2)
    end
  ) stored,
  best_percentage numeric(5, 2) not null default 0 check (best_percentage between 0 and 100),
  last_score smallint not null default 0,
  last_total smallint not null default 0,
  last_played_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, category_id)
);

create or replace function private.update_quiz_metrics()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  request_user uuid := (select auth.uid());
  result_percentage numeric(5, 2);
begin
  if request_user is null or request_user <> new.user_id then
    raise exception 'A quiz result may only update metrics for the current user'
      using errcode = '42501';
  end if;

  result_percentage := round(new.score::numeric * 100 / new.total_questions, 2);

  insert into public.quiz_metrics (
    user_id,
    category_id,
    quizzes_taken,
    total_correct,
    total_questions,
    best_percentage,
    last_score,
    last_total,
    last_played_at,
    updated_at
  ) values (
    new.user_id,
    tg_argv[0],
    1,
    new.score,
    new.total_questions,
    result_percentage,
    new.score,
    new.total_questions,
    new.completed_at,
    now()
  )
  on conflict (user_id, category_id) do update set
    quizzes_taken = public.quiz_metrics.quizzes_taken + 1,
    total_correct = public.quiz_metrics.total_correct + excluded.total_correct,
    total_questions = public.quiz_metrics.total_questions + excluded.total_questions,
    best_percentage = greatest(public.quiz_metrics.best_percentage, excluded.best_percentage),
    last_score = excluded.last_score,
    last_total = excluded.last_total,
    last_played_at = excluded.last_played_at,
    updated_at = now();

  return new;
end;
$$;

revoke all on function private.update_quiz_metrics() from public, anon, authenticated;

create trigger history_quiz_metrics_after_insert
  after insert on public.history_quiz_results
  for each row execute function private.update_quiz_metrics('history');
create trigger geography_quiz_metrics_after_insert
  after insert on public.geography_quiz_results
  for each row execute function private.update_quiz_metrics('geography');
create trigger mixed_quiz_metrics_after_insert
  after insert on public.mixed_quiz_results
  for each row execute function private.update_quiz_metrics('mix');
create trigger hungarian_quiz_metrics_after_insert
  after insert on public.hungarian_quiz_results
  for each row execute function private.update_quiz_metrics('hungarian');
create trigger fifth_grader_quiz_metrics_after_insert
  after insert on public.fifth_grader_quiz_results
  for each row execute function private.update_quiz_metrics('fifth_grader');

create view public.quiz_metrics_dashboard
with (security_invoker = true)
as
select
  m.user_id,
  p.device_id,
  c.display_name as quiz,
  m.quizzes_taken,
  m.average_percentage,
  m.best_percentage,
  m.total_correct,
  m.total_questions,
  m.last_score,
  m.last_total,
  m.last_played_at,
  p.timezone,
  p.browser_language
from public.quiz_metrics m
join public.quiz_categories c on c.id = m.category_id
left join public.quiz_players p on p.user_id = m.user_id
order by m.last_played_at desc nulls last;

alter table public.quiz_categories enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_players enable row level security;
alter table public.history_quiz_results enable row level security;
alter table public.geography_quiz_results enable row level security;
alter table public.mixed_quiz_results enable row level security;
alter table public.hungarian_quiz_results enable row level security;
alter table public.fifth_grader_quiz_results enable row level security;
alter table public.quiz_metrics enable row level security;

create policy "Players can read active categories"
  on public.quiz_categories for select
  to authenticated
  using (is_active);

create policy "Players can read active questions"
  on public.quiz_questions for select
  to authenticated
  using (is_active);

create policy "Players can read their own profile"
  on public.quiz_players for select
  to authenticated
  using ((select auth.uid()) = user_id);
create policy "Players can create their own profile"
  on public.quiz_players for insert
  to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Players can refresh their own profile"
  on public.quiz_players for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Players can submit their own history results"
  on public.history_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Players can submit their own geography results"
  on public.geography_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Players can submit their own mixed results"
  on public.mixed_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Players can submit their own Hungarian results"
  on public.hungarian_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Players can submit their own fifth-grader results"
  on public.fifth_grader_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.quiz_categories from anon, authenticated;
revoke all on table public.quiz_questions from anon, authenticated;
revoke all on table public.quiz_players from anon, authenticated;
revoke all on table public.history_quiz_results from anon, authenticated;
revoke all on table public.geography_quiz_results from anon, authenticated;
revoke all on table public.mixed_quiz_results from anon, authenticated;
revoke all on table public.hungarian_quiz_results from anon, authenticated;
revoke all on table public.fifth_grader_quiz_results from anon, authenticated;
revoke all on table public.quiz_metrics from anon, authenticated;
revoke all on table public.quiz_metrics_dashboard from anon, authenticated;

grant select on table public.quiz_categories to authenticated;
grant select on table public.quiz_questions to authenticated;
grant select, insert, update on table public.quiz_players to authenticated;
grant insert on table public.history_quiz_results to authenticated;
grant insert on table public.geography_quiz_results to authenticated;
grant insert on table public.mixed_quiz_results to authenticated;
grant insert on table public.hungarian_quiz_results to authenticated;
grant insert on table public.fifth_grader_quiz_results to authenticated;

grant all on table public.quiz_categories to service_role;
grant all on table public.quiz_questions to service_role;
grant all on table public.quiz_players to service_role;
grant all on table public.history_quiz_results to service_role;
grant all on table public.geography_quiz_results to service_role;
grant all on table public.mixed_quiz_results to service_role;
grant all on table public.hungarian_quiz_results to service_role;
grant all on table public.fifth_grader_quiz_results to service_role;
grant all on table public.quiz_metrics to service_role;
grant select on table public.quiz_metrics_dashboard to service_role;
