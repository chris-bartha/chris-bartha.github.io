-- Merge "Tankönyvi történelem" into "Történelem magyarul".
--
-- The two Hungarian categories were both history and she moved between them
-- constantly; one 730-question bank suits the way she actually plays (average
-- Hungarian run: 155 questions, best: the entire bank in one go) far better
-- than two banks she clears in an evening each.
--
-- textbook_history keeps its results table and its category row so the recorded
-- scores stay intact and readable, exactly as the retired mix category does.
-- Only the questions move.

-- The curriculum questions carry subject labels and the seed bank does not.
-- Give the untagged half a label of its own so the merged category can still be
-- balanced by subject later.
update public.quiz_questions
set subject = 'Vegyes történelem'
where category_id = 'hungarian'
  and subject is null;

update public.quiz_questions
set category_id = 'hungarian',
    display_order = display_order + 1000
where category_id = 'textbook_history';

update public.quiz_categories
set display_name = 'Történelem magyarul',
    description = 'Magyar és világtörténelem, az iskolai tananyaggal együtt',
    display_order = 1
where id = 'hungarian';

update public.quiz_categories
set is_active = false,
    display_order = 90
where id = 'textbook_history';

do $validation$
declare
  merged_count integer;
  orphan_count integer;
begin
  select count(*) into merged_count
  from public.quiz_questions
  where category_id = 'hungarian' and is_active;

  if merged_count <> 730 then
    raise exception 'The merged Hungarian category must hold 730 active questions, found %', merged_count;
  end if;

  select count(*) into orphan_count
  from public.quiz_questions
  where category_id = 'textbook_history';

  if orphan_count <> 0 then
    raise exception 'No question may remain in textbook_history, found %', orphan_count;
  end if;

  if exists (
    select 1 from public.quiz_questions
    where category_id = 'hungarian' and subject is null
  ) then
    raise exception 'Every merged Hungarian question needs a subject label';
  end if;

  if exists (
    select 1
    from public.quiz_questions as question
    where question.category_id = 'hungarian'
      and (
        cardinality(question.wrong_answers) <> 3
        or (
          select count(distinct lower(trim(answer)))
          from unnest(question.wrong_answers) as answer
        ) <> 3
        or exists (
          select 1
          from unnest(question.wrong_answers) as answer
          where lower(trim(answer)) = lower(trim(question.correct_answer))
        )
      )
  ) then
    raise exception 'Every merged Hungarian question must have three distinct wrong answers';
  end if;
end;
$validation$;

comment on table public.textbook_history_quiz_results is
  'Retired 2026-09-17: its questions merged into the hungarian category. Kept so the historical scores survive.';
