-- Tricky True or False: schema, category, results table, and tracking.
-- This category runs with a single attempt per question. With only two choices a
-- second chance would hand over the answer, so the app disables it here.

-- Every other category offers four choices. A true/false statement needs exactly
-- one wrong answer, so the fixed count becomes a per-category rule.
alter table public.quiz_questions
  drop constraint quiz_questions_three_wrong_answers;

alter table public.quiz_questions
  add constraint quiz_questions_answer_count check (
    case
      when category_id = 'tricky_true_false' then cardinality(wrong_answers) = 1
      else cardinality(wrong_answers) = 3
    end
  );

-- Guarantee the two choices really are True and False, and never both the same.
alter table public.quiz_questions
  add constraint quiz_questions_true_false_pair check (
    category_id <> 'tricky_true_false'
    or (
      correct_answer in ('True', 'False')
      and wrong_answers = array[
        case when correct_answer = 'True' then 'False' else 'True' end
      ]::text[]
    )
  );

-- Keep Fifth Grader as the special final choice and the retired mix last.
update public.quiz_categories
set display_order = case id
  when 'fifth_grader' then 7
  when 'mix' then 8
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
  'tricky_true_false',
  'Tricky True or False',
  'Statements where the obvious answer is often the wrong one',
  'en',
  6,
  true
);

create table public.tricky_true_false_quiz_results (
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
  constraint tricky_true_false_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint tricky_true_false_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  -- Single-attempt category: no point may ever come from a second chance.
  constraint tricky_true_false_result_no_second_chances
    check (second_try_correct = 0),
  constraint tricky_true_false_result_valid_duration
    check (duration_seconds >= 0),
  constraint tricky_true_false_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint tricky_true_false_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index tricky_true_false_results_user_completed_idx
  on public.tricky_true_false_quiz_results (user_id, completed_at desc);

alter table public.tricky_true_false_quiz_results enable row level security;

create policy "Players can submit their own tricky true-or-false results"
  on public.tricky_true_false_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.tricky_true_false_quiz_results
  from anon, authenticated;
grant insert on table public.tricky_true_false_quiz_results
  to authenticated;
grant all on table public.tricky_true_false_quiz_results
  to service_role;

create trigger tricky_true_false_question_answer_stats_after_insert
  after insert on public.tricky_true_false_quiz_results
  for each row execute function private.update_question_answer_stats();

-- Extend the source-of-truth projection used by private and public metrics.
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
select id, user_id, 'fifth_grader', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.fifth_grader_quiz_results;

revoke all on table private.all_quiz_results_for_tracking
  from public, anon, authenticated, service_role;

create trigger tricky_true_false_quiz_tracking_after_change
  after insert or update or delete on public.tricky_true_false_quiz_results
  for each row execute function private.sync_quiz_tracking('tricky_true_false');

comment on table public.tricky_true_false_quiz_results is
  'Source-of-truth results for the Tricky True or False quiz category. Single attempt per question, so second_try_correct is always zero.';
