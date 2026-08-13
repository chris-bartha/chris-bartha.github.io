-- One more Tricky True or False statement, bringing the category to 301.
-- Sharks appear in the fossil record roughly 450 million years ago; the
-- earliest trees around 385 million years ago.

insert into public.quiz_questions (
  id,
  category_id,
  prompt,
  correct_answer,
  wrong_answers,
  language_code,
  grade_level,
  subject,
  display_order,
  is_active
) values (
  'tricky_true_false_0301',
  'tricky_true_false',
  'Sharks are older than trees.',
  'True',
  array['False']::text[],
  'en',
  null,
  'Animal Myths',
  301,
  true
);

do $validation$
begin
  if (
    select count(*)
    from public.quiz_questions
    where category_id = 'tricky_true_false'
      and is_active
  ) <> 301 then
    raise exception 'Tricky True or False must contain exactly 301 active questions';
  end if;

  -- The two answers must stay close to an even split, or the category becomes guessable.
  if (
    select count(*)
    from public.quiz_questions
    where category_id = 'tricky_true_false'
      and correct_answer = 'True'
  ) not between 130 and 171 then
    raise exception 'Tricky True or False must stay near an even True/False balance';
  end if;

  if exists (
    select 1
    from public.quiz_questions as proposed
    join public.quiz_questions as existing
      on lower(trim(existing.prompt)) = lower(trim(proposed.prompt))
     and existing.id <> proposed.id
    where proposed.category_id = 'tricky_true_false'
  ) then
    raise exception 'Tricky True or False contains a prompt already used by another question';
  end if;
end;
$validation$;
