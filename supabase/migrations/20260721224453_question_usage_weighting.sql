-- Track question exposure globally and gently favor less-seen questions.

alter table public.quiz_questions
  add column times_shown bigint not null default 0,
  add column times_answered bigint not null default 0,
  add column times_correct bigint not null default 0,
  add column last_shown_at timestamptz,
  add column last_answered_at timestamptz;

alter table public.quiz_questions
  add constraint quiz_questions_times_shown_nonnegative
    check (times_shown >= 0),
  add constraint quiz_questions_times_answered_nonnegative
    check (times_answered >= 0),
  add constraint quiz_questions_times_correct_valid
    check (times_correct >= 0 and times_correct <= times_answered);

create or replace function public.record_question_views(selected_question_ids text[])
returns void
language plpgsql
volatile
security invoker
set search_path = ''
as $$
declare
  valid_question_count integer;
begin
  if (select auth.uid()) is null then
    raise exception 'A signed-in quiz player is required'
      using errcode = '42501';
  end if;

  if selected_question_ids is null
     or cardinality(selected_question_ids) < 1
     or cardinality(selected_question_ids) > 20 then
    raise exception 'A quiz round must contain between 1 and 20 questions'
      using errcode = '22023';
  end if;

  select count(*)
    into valid_question_count
  from public.quiz_questions as question
  where question.id = any(selected_question_ids)
    and question.is_active;

  -- A mismatch also rejects duplicate or unknown question IDs.
  if valid_question_count <> cardinality(selected_question_ids) then
    raise exception 'The quiz round contains duplicate, unknown, or inactive questions'
      using errcode = '22023';
  end if;

  update public.quiz_questions as question
  set
    times_shown = question.times_shown + 1,
    last_shown_at = now()
  where question.id = any(selected_question_ids)
    and question.is_active;
end;
$$;

revoke all on function public.record_question_views(text[])
  from public, anon, authenticated;
grant execute on function public.record_question_views(text[])
  to authenticated;

create policy "Players can record active question views"
  on public.quiz_questions for update
  to authenticated
  using (is_active)
  with check (is_active);

-- Column-level privileges let the browser increment exposure counts without
-- granting permission to alter prompts, answers, or answer statistics.
grant update (times_shown, last_shown_at)
  on table public.quiz_questions
  to authenticated;

create or replace function private.update_question_answer_stats()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  request_user uuid := (select auth.uid());
begin
  if request_user is null or request_user <> new.user_id then
    raise exception 'Question statistics may only be recorded for the current player'
      using errcode = '42501';
  end if;

  with answer_counts as (
    select
      answer.value ->> 'question_id' as question_id,
      count(*)::bigint as answered_count,
      count(*) filter (
        where answer.value ->> 'correct' = 'true'
      )::bigint as correct_count
    from jsonb_array_elements(new.answers) as answer(value)
    where jsonb_typeof(answer.value) = 'object'
      and nullif(answer.value ->> 'question_id', '') is not null
    group by answer.value ->> 'question_id'
  )
  update public.quiz_questions as question
  set
    times_answered = question.times_answered + answer_counts.answered_count,
    times_correct = question.times_correct + answer_counts.correct_count,
    last_answered_at = now()
  from answer_counts
  where question.id = answer_counts.question_id;

  return new;
end;
$$;

revoke all on function private.update_question_answer_stats()
  from public, anon, authenticated;

create trigger history_question_answer_stats_after_insert
  after insert on public.history_quiz_results
  for each row execute function private.update_question_answer_stats();
create trigger geography_question_answer_stats_after_insert
  after insert on public.geography_quiz_results
  for each row execute function private.update_question_answer_stats();
create trigger mixed_question_answer_stats_after_insert
  after insert on public.mixed_quiz_results
  for each row execute function private.update_question_answer_stats();
create trigger hungarian_question_answer_stats_after_insert
  after insert on public.hungarian_quiz_results
  for each row execute function private.update_question_answer_stats();
create trigger fifth_grader_question_answer_stats_after_insert
  after insert on public.fifth_grader_quiz_results
  for each row execute function private.update_question_answer_stats();

create view public.quiz_question_stats_dashboard
with (security_invoker = true)
as
select
  question.id as question_id,
  category.display_name as quiz,
  question.prompt,
  question.times_shown,
  question.times_answered,
  question.times_correct,
  case
    when question.times_answered = 0 then null
    else round(question.times_correct::numeric * 100 / question.times_answered, 1)
  end as correct_percentage,
  question.last_shown_at,
  question.last_answered_at,
  question.is_active
from public.quiz_questions as question
join public.quiz_categories as category on category.id = question.category_id
order by question.times_shown, question.times_answered, question.display_order;

revoke all on table public.quiz_question_stats_dashboard
  from public, anon, authenticated;
grant select on table public.quiz_question_stats_dashboard
  to service_role;
