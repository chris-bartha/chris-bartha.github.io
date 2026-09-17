-- Eight new Hungarian-language categories.
--
-- Hungarian is the language she reads fastest and goes deepest in: her average
-- Hungarian run is 155 questions and she has cleared an entire 430-question
-- bank without a double miss ten times over. Until now both Hungarian
-- categories were history. These open up geography, literature, science,
-- folklore, cooking, music and everyday life.
--
-- The menu groups them behind one "Magyar kvízek" button, so display_order 1-9
-- is the Hungarian group and 10+ is the English group.

update public.quiz_categories
set display_order = case id
  when 'history' then 10
  when 'geography' then 11
  when 'time_traveler' then 12
  when 'tricky_true_false' then 13
  when 'psychology' then 14
  when 'fifth_grader' then 15
  when 'mix' then 99
end
where id in ('history', 'geography', 'time_traveler', 'tricky_true_false',
             'psychology', 'fifth_grader', 'mix');

-- ---------------------------------------------------------------- magyar_foldrajz
insert into public.quiz_categories (
  id, display_name, description, language_code, display_order, is_active
) values (
  'magyar_foldrajz', 'Magyarország földrajza', 'Folyók, hegyek, megyék és városok', 'hu', 2, true
);

create table public.magyar_foldrajz_quiz_results (
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
  constraint magyar_foldrajz_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint magyar_foldrajz_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint magyar_foldrajz_result_valid_duration
    check (duration_seconds >= 0),
  constraint magyar_foldrajz_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint magyar_foldrajz_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index magyar_foldrajz_results_user_completed_idx
  on public.magyar_foldrajz_quiz_results (user_id, completed_at desc);

alter table public.magyar_foldrajz_quiz_results enable row level security;

create policy "Players can submit their own magyar_foldrajz results"
  on public.magyar_foldrajz_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.magyar_foldrajz_quiz_results from anon, authenticated;
grant insert on table public.magyar_foldrajz_quiz_results to authenticated;
grant all on table public.magyar_foldrajz_quiz_results to service_role;

create trigger magyar_foldrajz_question_answer_stats_after_insert
  after insert on public.magyar_foldrajz_quiz_results
  for each row execute function private.update_question_answer_stats();

create trigger magyar_foldrajz_quiz_tracking_after_change
  after insert or update or delete on public.magyar_foldrajz_quiz_results
  for each row execute function private.sync_quiz_tracking('magyar_foldrajz');

comment on table public.magyar_foldrajz_quiz_results is
  'Source-of-truth results for the Magyarország földrajza quiz category.';

-- ---------------------------------------------------------------- foldrajz_magyarul
insert into public.quiz_categories (
  id, display_name, description, language_code, display_order, is_active
) values (
  'foldrajz_magyarul', 'Földrajz magyarul', 'Országok, fővárosok, folyók és hegyek', 'hu', 3, true
);

create table public.foldrajz_magyarul_quiz_results (
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
  constraint foldrajz_magyarul_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint foldrajz_magyarul_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint foldrajz_magyarul_result_valid_duration
    check (duration_seconds >= 0),
  constraint foldrajz_magyarul_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint foldrajz_magyarul_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index foldrajz_magyarul_results_user_completed_idx
  on public.foldrajz_magyarul_quiz_results (user_id, completed_at desc);

alter table public.foldrajz_magyarul_quiz_results enable row level security;

create policy "Players can submit their own foldrajz_magyarul results"
  on public.foldrajz_magyarul_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.foldrajz_magyarul_quiz_results from anon, authenticated;
grant insert on table public.foldrajz_magyarul_quiz_results to authenticated;
grant all on table public.foldrajz_magyarul_quiz_results to service_role;

create trigger foldrajz_magyarul_question_answer_stats_after_insert
  after insert on public.foldrajz_magyarul_quiz_results
  for each row execute function private.update_question_answer_stats();

create trigger foldrajz_magyarul_quiz_tracking_after_change
  after insert or update or delete on public.foldrajz_magyarul_quiz_results
  for each row execute function private.sync_quiz_tracking('foldrajz_magyarul');

comment on table public.foldrajz_magyarul_quiz_results is
  'Source-of-truth results for the Földrajz magyarul quiz category.';

-- ---------------------------------------------------------------- magyar_irodalom
insert into public.quiz_categories (
  id, display_name, description, language_code, display_order, is_active
) values (
  'magyar_irodalom', 'Magyar irodalom', 'Költők, regények és híres sorok', 'hu', 4, true
);

create table public.magyar_irodalom_quiz_results (
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
  constraint magyar_irodalom_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint magyar_irodalom_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint magyar_irodalom_result_valid_duration
    check (duration_seconds >= 0),
  constraint magyar_irodalom_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint magyar_irodalom_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index magyar_irodalom_results_user_completed_idx
  on public.magyar_irodalom_quiz_results (user_id, completed_at desc);

alter table public.magyar_irodalom_quiz_results enable row level security;

create policy "Players can submit their own magyar_irodalom results"
  on public.magyar_irodalom_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.magyar_irodalom_quiz_results from anon, authenticated;
grant insert on table public.magyar_irodalom_quiz_results to authenticated;
grant all on table public.magyar_irodalom_quiz_results to service_role;

create trigger magyar_irodalom_question_answer_stats_after_insert
  after insert on public.magyar_irodalom_quiz_results
  for each row execute function private.update_question_answer_stats();

create trigger magyar_irodalom_quiz_tracking_after_change
  after insert or update or delete on public.magyar_irodalom_quiz_results
  for each row execute function private.sync_quiz_tracking('magyar_irodalom');

comment on table public.magyar_irodalom_quiz_results is
  'Source-of-truth results for the Magyar irodalom quiz category.';

-- ---------------------------------------------------------------- magyar_tudomany
insert into public.quiz_categories (
  id, display_name, description, language_code, display_order, is_active
) values (
  'magyar_tudomany', 'Természet és tudomány', 'Állatok, növények, az emberi test és a világűr', 'hu', 5, true
);

create table public.magyar_tudomany_quiz_results (
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
  constraint magyar_tudomany_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint magyar_tudomany_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint magyar_tudomany_result_valid_duration
    check (duration_seconds >= 0),
  constraint magyar_tudomany_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint magyar_tudomany_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index magyar_tudomany_results_user_completed_idx
  on public.magyar_tudomany_quiz_results (user_id, completed_at desc);

alter table public.magyar_tudomany_quiz_results enable row level security;

create policy "Players can submit their own magyar_tudomany results"
  on public.magyar_tudomany_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.magyar_tudomany_quiz_results from anon, authenticated;
grant insert on table public.magyar_tudomany_quiz_results to authenticated;
grant all on table public.magyar_tudomany_quiz_results to service_role;

create trigger magyar_tudomany_question_answer_stats_after_insert
  after insert on public.magyar_tudomany_quiz_results
  for each row execute function private.update_question_answer_stats();

create trigger magyar_tudomany_quiz_tracking_after_change
  after insert or update or delete on public.magyar_tudomany_quiz_results
  for each row execute function private.sync_quiz_tracking('magyar_tudomany');

comment on table public.magyar_tudomany_quiz_results is
  'Source-of-truth results for the Természet és tudomány quiz category.';

-- ---------------------------------------------------------------- magyar_nepmesek
insert into public.quiz_categories (
  id, display_name, description, language_code, display_order, is_active
) values (
  'magyar_nepmesek', 'Népmesék és közmondások', 'Mesék, szólások és közmondások', 'hu', 6, true
);

create table public.magyar_nepmesek_quiz_results (
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
  constraint magyar_nepmesek_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint magyar_nepmesek_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint magyar_nepmesek_result_valid_duration
    check (duration_seconds >= 0),
  constraint magyar_nepmesek_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint magyar_nepmesek_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index magyar_nepmesek_results_user_completed_idx
  on public.magyar_nepmesek_quiz_results (user_id, completed_at desc);

alter table public.magyar_nepmesek_quiz_results enable row level security;

create policy "Players can submit their own magyar_nepmesek results"
  on public.magyar_nepmesek_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.magyar_nepmesek_quiz_results from anon, authenticated;
grant insert on table public.magyar_nepmesek_quiz_results to authenticated;
grant all on table public.magyar_nepmesek_quiz_results to service_role;

create trigger magyar_nepmesek_question_answer_stats_after_insert
  after insert on public.magyar_nepmesek_quiz_results
  for each row execute function private.update_question_answer_stats();

create trigger magyar_nepmesek_quiz_tracking_after_change
  after insert or update or delete on public.magyar_nepmesek_quiz_results
  for each row execute function private.sync_quiz_tracking('magyar_nepmesek');

comment on table public.magyar_nepmesek_quiz_results is
  'Source-of-truth results for the Népmesék és közmondások quiz category.';

-- ---------------------------------------------------------------- magyar_konyha
insert into public.quiz_categories (
  id, display_name, description, language_code, display_order, is_active
) values (
  'magyar_konyha', 'Magyar konyha', 'Ételek, fűszerek és hagyományok', 'hu', 7, true
);

create table public.magyar_konyha_quiz_results (
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
  constraint magyar_konyha_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint magyar_konyha_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint magyar_konyha_result_valid_duration
    check (duration_seconds >= 0),
  constraint magyar_konyha_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint magyar_konyha_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index magyar_konyha_results_user_completed_idx
  on public.magyar_konyha_quiz_results (user_id, completed_at desc);

alter table public.magyar_konyha_quiz_results enable row level security;

create policy "Players can submit their own magyar_konyha results"
  on public.magyar_konyha_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.magyar_konyha_quiz_results from anon, authenticated;
grant insert on table public.magyar_konyha_quiz_results to authenticated;
grant all on table public.magyar_konyha_quiz_results to service_role;

create trigger magyar_konyha_question_answer_stats_after_insert
  after insert on public.magyar_konyha_quiz_results
  for each row execute function private.update_question_answer_stats();

create trigger magyar_konyha_quiz_tracking_after_change
  after insert or update or delete on public.magyar_konyha_quiz_results
  for each row execute function private.sync_quiz_tracking('magyar_konyha');

comment on table public.magyar_konyha_quiz_results is
  'Source-of-truth results for the Magyar konyha quiz category.';

-- ---------------------------------------------------------------- magyar_zene
insert into public.quiz_categories (
  id, display_name, description, language_code, display_order, is_active
) values (
  'magyar_zene', 'Magyar zene 1970–1989', 'Együttesek, énekesek és slágerek', 'hu', 8, true
);

create table public.magyar_zene_quiz_results (
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
  constraint magyar_zene_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint magyar_zene_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint magyar_zene_result_valid_duration
    check (duration_seconds >= 0),
  constraint magyar_zene_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint magyar_zene_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index magyar_zene_results_user_completed_idx
  on public.magyar_zene_quiz_results (user_id, completed_at desc);

alter table public.magyar_zene_quiz_results enable row level security;

create policy "Players can submit their own magyar_zene results"
  on public.magyar_zene_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.magyar_zene_quiz_results from anon, authenticated;
grant insert on table public.magyar_zene_quiz_results to authenticated;
grant all on table public.magyar_zene_quiz_results to service_role;

create trigger magyar_zene_question_answer_stats_after_insert
  after insert on public.magyar_zene_quiz_results
  for each row execute function private.update_question_answer_stats();

create trigger magyar_zene_quiz_tracking_after_change
  after insert or update or delete on public.magyar_zene_quiz_results
  for each row execute function private.sync_quiz_tracking('magyar_zene');

comment on table public.magyar_zene_quiz_results is
  'Source-of-truth results for the Magyar zene 1970–1989 quiz category.';

-- ---------------------------------------------------------------- regen_volt
insert into public.quiz_categories (
  id, display_name, description, language_code, display_order, is_active
) values (
  'regen_volt', 'Ahogy régen volt', 'Boltok, márkák, iskola és tévé', 'hu', 9, true
);

create table public.regen_volt_quiz_results (
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
  constraint regen_volt_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint regen_volt_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint regen_volt_result_valid_duration
    check (duration_seconds >= 0),
  constraint regen_volt_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint regen_volt_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index regen_volt_results_user_completed_idx
  on public.regen_volt_quiz_results (user_id, completed_at desc);

alter table public.regen_volt_quiz_results enable row level security;

create policy "Players can submit their own regen_volt results"
  on public.regen_volt_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.regen_volt_quiz_results from anon, authenticated;
grant insert on table public.regen_volt_quiz_results to authenticated;
grant all on table public.regen_volt_quiz_results to service_role;

create trigger regen_volt_question_answer_stats_after_insert
  after insert on public.regen_volt_quiz_results
  for each row execute function private.update_question_answer_stats();

create trigger regen_volt_quiz_tracking_after_change
  after insert or update or delete on public.regen_volt_quiz_results
  for each row execute function private.sync_quiz_tracking('regen_volt');

comment on table public.regen_volt_quiz_results is
  'Source-of-truth results for the Ahogy régen volt quiz category.';

-- ------------------------------------------------------------------ tracking
-- Rebuild the source-of-truth projection in full. Every result table must be
-- listed here or refresh_quiz_metrics silently returns nothing for the missing
-- category -- the one step in adding a category that fails quietly.
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
from public.regen_volt_quiz_results;

revoke all on table private.all_quiz_results_for_tracking
  from public, anon, authenticated, service_role;

do $validation$
begin
  if (
    select count(*) from public.quiz_categories
    where is_active and language_code = 'hu'
  ) <> 9 then
    raise exception 'There must be nine active Hungarian categories';
  end if;
end;
$validation$;
