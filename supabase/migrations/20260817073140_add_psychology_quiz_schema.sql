-- Psychology: the brain, memory, biases, and why people behave as they do.
-- A standard four-choice category, so the friendly second-chance rule applies.

-- Keep Fifth Grader as the special final choice and the retired mix last.
update public.quiz_categories
set display_order = case id
  when 'fifth_grader' then 8
  when 'mix' then 9
end
where id in ('fifth_grader', 'mix');

insert into public.quiz_categories (
  id,
  display_name,
  description,
  language_code,
  display_order,
  is_active
) values (
  'psychology',
  'Psychology',
  'The brain, memory, biases, and why people do what they do',
  'en',
  7,
  true
);

create table public.psychology_quiz_results (
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
  is_unlimited boolean not null default false,
  constraint psychology_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint psychology_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint psychology_result_valid_duration
    check (duration_seconds >= 0),
  constraint psychology_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint psychology_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index psychology_results_user_completed_idx
  on public.psychology_quiz_results (user_id, completed_at desc);

alter table public.psychology_quiz_results enable row level security;

create policy "Players can submit their own psychology results"
  on public.psychology_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.psychology_quiz_results
  from anon, authenticated;
grant insert on table public.psychology_quiz_results
  to authenticated;
grant all on table public.psychology_quiz_results
  to service_role;

create trigger psychology_question_answer_stats_after_insert
  after insert on public.psychology_quiz_results
  for each row execute function private.update_question_answer_stats();

-- Extend the source-of-truth projection used by private and public metrics.
-- This view must list every result table or refresh_quiz_metrics silently
-- returns nothing for the missing category.
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
select id, user_id, 'geography', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.geography_quiz_results
union all
select id, user_id, 'mix', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.mixed_quiz_results
union all
select id, user_id, 'hungarian', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.hungarian_quiz_results
union all
select id, user_id, 'textbook_history', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.textbook_history_quiz_results
union all
select id, user_id, 'time_traveler', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.time_traveler_quiz_results
union all
select id, user_id, 'tricky_true_false', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.tricky_true_false_quiz_results
union all
select id, user_id, 'psychology', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.psychology_quiz_results
union all
select id, user_id, 'fifth_grader', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.fifth_grader_quiz_results;

revoke all on table private.all_quiz_results_for_tracking
  from public, anon, authenticated, service_role;

create trigger psychology_quiz_tracking_after_change
  after insert or update or delete on public.psychology_quiz_results
  for each row execute function private.sync_quiz_tracking('psychology');

comment on table public.psychology_quiz_results is
  'Source-of-truth results for the Psychology quiz category.';
