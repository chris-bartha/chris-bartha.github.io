-- Two new Hungarian categories, and a place to put the fact behind an answer.
--
--   Több vagy kevesebb?        two choices, Több / Kevesebb, one try per question
--   Két igazság és egy hazugság  three statements, she picks the lie
--
-- Both are new answer shapes, so the per-category cardinality rule grows again.

-- The payoff of "több vagy kevesebb" is learning the real figure, and the payoff
-- of a two-truths question is being told what was true instead of the lie. One
-- nullable sentence per question carries that; the quiz shows it after she
-- answers and ignores it when it is null, so every existing bank is unaffected.
alter table public.quiz_questions
  add column explanation text;

alter table public.quiz_questions
  add constraint quiz_questions_explanation_not_blank
  check (explanation is null or length(btrim(explanation)) > 0);

comment on column public.quiz_questions.explanation is
  'Optional one-sentence note shown after the answer is revealed. Null everywhere it would only repeat the answer.';

-- Four options is still the rule; three categories now say otherwise.
alter table public.quiz_questions
  drop constraint quiz_questions_answer_count;

alter table public.quiz_questions
  add constraint quiz_questions_answer_count check (
    case category_id
      when 'tricky_true_false'  then cardinality(wrong_answers) = 1
      when 'tobb_vagy_kevesebb' then cardinality(wrong_answers) = 1
      when 'ket_igazsag'        then cardinality(wrong_answers) = 2
      else cardinality(wrong_answers) = 3
    end
  );

-- The two choices must really be Több and Kevesebb, and never both the same.
alter table public.quiz_questions
  add constraint quiz_questions_more_or_less_pair check (
    category_id <> 'tobb_vagy_kevesebb'
    or (
      correct_answer in ('Több', 'Kevesebb')
      and wrong_answers = array[
        case when correct_answer = 'Több' then 'Kevesebb' else 'Több' end
      ]::text[]
    )
  );

-- A question that does not name the quantity it is comparing is unanswerable,
-- and the two-truths setup only works if it asks which statement is false.
alter table public.quiz_questions
  add constraint quiz_questions_more_or_less_prompt check (
    category_id <> 'tobb_vagy_kevesebb'
    or prompt like '%több vagy kevesebb, mint %'
  );

alter table public.quiz_questions
  add constraint quiz_questions_two_truths_prompt check (
    category_id <> 'ket_igazsag'
    or prompt like '%NEM igaz?'
  );

-- The real figure is the whole point of Több vagy kevesebb?, and the correction
-- is the whole point of Két igazság. Neither may ship without one.
alter table public.quiz_questions
  add constraint quiz_questions_explanation_required check (
    category_id not in ('tobb_vagy_kevesebb', 'ket_igazsag')
    or explanation is not null
  );

-- The Hungarian group grows to eleven; every English category shifts down two.
-- display_order drives both the /metrics ordering and the menu order in
-- index.html, so the two have to be changed together.
update public.quiz_categories
set display_order = display_order + 2
where is_active and language_code = 'en';

insert into public.quiz_categories (
  id, display_name, description, language_code, display_order, is_active
) values
  (
    'tobb_vagy_kevesebb',
    'Több vagy kevesebb?',
    'Mennyiségek összehasonlítása — egy próbálkozás kérdésenként',
    'hu',
    10,
    true
  ),
  (
    'ket_igazsag',
    'Két igazság és egy hazugság',
    'Három állítás, kettő igaz — melyik a hazugság?',
    'hu',
    11,
    true
  );

create table public.tobb_vagy_kevesebb_quiz_results (
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
  constraint tobb_vagy_kevesebb_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint tobb_vagy_kevesebb_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  -- Two choices, so a second try would simply hand over the answer.
  constraint tobb_vagy_kevesebb_result_no_second_chances
    check (second_try_correct = 0),
  constraint tobb_vagy_kevesebb_result_valid_duration
    check (duration_seconds >= 0),
  constraint tobb_vagy_kevesebb_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint tobb_vagy_kevesebb_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create table public.ket_igazsag_quiz_results (
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
  constraint ket_igazsag_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint ket_igazsag_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint ket_igazsag_result_valid_duration
    check (duration_seconds >= 0),
  constraint ket_igazsag_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint ket_igazsag_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index tobb_vagy_kevesebb_results_user_completed_idx
  on public.tobb_vagy_kevesebb_quiz_results (user_id, completed_at desc);
create index ket_igazsag_results_user_completed_idx
  on public.ket_igazsag_quiz_results (user_id, completed_at desc);

alter table public.tobb_vagy_kevesebb_quiz_results enable row level security;
alter table public.ket_igazsag_quiz_results enable row level security;

create policy "Players can submit their own tobb_vagy_kevesebb results"
  on public.tobb_vagy_kevesebb_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Players can submit their own ket_igazsag results"
  on public.ket_igazsag_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.tobb_vagy_kevesebb_quiz_results from anon, authenticated;
revoke all on table public.ket_igazsag_quiz_results from anon, authenticated;
grant insert on table public.tobb_vagy_kevesebb_quiz_results to authenticated;
grant insert on table public.ket_igazsag_quiz_results to authenticated;
grant all on table public.tobb_vagy_kevesebb_quiz_results to service_role;
grant all on table public.ket_igazsag_quiz_results to service_role;

create trigger tobb_vagy_kevesebb_question_answer_stats_after_insert
  after insert on public.tobb_vagy_kevesebb_quiz_results
  for each row execute function private.update_question_answer_stats();
create trigger ket_igazsag_question_answer_stats_after_insert
  after insert on public.ket_igazsag_quiz_results
  for each row execute function private.update_question_answer_stats();

-- refresh_quiz_metrics reads this view, so a category missing from it records
-- rounds that never reach the dashboard. Recreated in full, as it must be.
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
from public.fifth_grader_quiz_results
union all
select id, user_id, 'magyar_foldrajz', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.magyar_foldrajz_quiz_results
union all
select id, user_id, 'foldrajz_magyarul', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.foldrajz_magyarul_quiz_results
union all
select id, user_id, 'magyar_irodalom', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.magyar_irodalom_quiz_results
union all
select id, user_id, 'magyar_tudomany', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.magyar_tudomany_quiz_results
union all
select id, user_id, 'magyar_nepmesek', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.magyar_nepmesek_quiz_results
union all
select id, user_id, 'magyar_konyha', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.magyar_konyha_quiz_results
union all
select id, user_id, 'magyar_zene', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.magyar_zene_quiz_results
union all
select id, user_id, 'regen_volt', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.regen_volt_quiz_results
union all
select id, user_id, 'tobb_vagy_kevesebb', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.tobb_vagy_kevesebb_quiz_results
union all
select id, user_id, 'ket_igazsag', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.ket_igazsag_quiz_results;

revoke all on table private.all_quiz_results_for_tracking
  from public, anon, authenticated, service_role;

create trigger tobb_vagy_kevesebb_quiz_tracking_after_change
  after insert or update or delete on public.tobb_vagy_kevesebb_quiz_results
  for each row execute function private.sync_quiz_tracking('tobb_vagy_kevesebb');
create trigger ket_igazsag_quiz_tracking_after_change
  after insert or update or delete on public.ket_igazsag_quiz_results
  for each row execute function private.sync_quiz_tracking('ket_igazsag');

comment on table public.tobb_vagy_kevesebb_quiz_results is
  'Results for Több vagy kevesebb?. Two choices, so second_try_correct is always zero.';
comment on table public.ket_igazsag_quiz_results is
  'Results for Két igazság és egy hazugság. Three statements per question, she picks the lie.';

do $validation$
begin
  if (
    select count(*) from public.quiz_categories
    where id in ('tobb_vagy_kevesebb', 'ket_igazsag') and is_active
  ) <> 2 then
    raise exception 'Both new Hungarian categories must be active';
  end if;

  -- Eleven Hungarian categories then six English ones, no gaps, no ties.
  if exists (
    select 1
    from (
      select display_order, count(*) as n
      from public.quiz_categories
      where is_active
      group by display_order
    ) as taken
    where taken.n > 1
  ) then
    raise exception 'Two active categories share a display_order';
  end if;

  if (
    select count(*) from public.quiz_categories where is_active
  ) <> 17 then
    raise exception 'Expected 17 active categories after the two additions';
  end if;

  if (
    select min(display_order) from public.quiz_categories
    where is_active and language_code = 'en'
  ) <> 12 then
    raise exception 'The English categories should start at display_order 12';
  end if;
end;
$validation$;
