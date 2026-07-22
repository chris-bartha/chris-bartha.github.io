-- Keep derived tracking data aligned when an administrator edits or deletes
-- a source quiz result. The five source result tables remain the source of truth.

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
  duration_seconds
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
  duration_seconds
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
  duration_seconds
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
  duration_seconds
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
  duration_seconds
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
    count(*)::integer as quizzes_taken,
    coalesce(sum(result.score), 0)::integer as total_correct,
    coalesce(sum(result.total_questions), 0)::integer as total_questions,
    coalesce(
      round(max(result.score::numeric * 100 / result.total_questions), 2),
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

  if summary.quizzes_taken = 0 then
    delete from public.quiz_metrics
    where user_id = target_user_id
      and category_id = target_category_id;
    return;
  end if;

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
    target_user_id,
    target_category_id,
    summary.quizzes_taken,
    summary.total_correct,
    summary.total_questions,
    summary.best_percentage,
    summary.last_score,
    summary.last_total,
    summary.last_played_at,
    now()
  )
  on conflict (user_id, category_id) do update set
    quizzes_taken = excluded.quizzes_taken,
    total_correct = excluded.total_correct,
    total_questions = excluded.total_questions,
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
  on conflict (source_id) do update set
    category_id = excluded.category_id,
    score = excluded.score,
    total_questions = excluded.total_questions,
    first_try_correct = excluded.first_try_correct,
    second_try_correct = excluded.second_try_correct,
    completed_at = excluded.completed_at,
    duration_seconds = excluded.duration_seconds;

  if tg_op = 'UPDATE' and old.user_id <> new.user_id then
    perform private.refresh_quiz_metrics(old.user_id, tg_argv[0]);
  end if;
  perform private.refresh_quiz_metrics(new.user_id, tg_argv[0]);

  return new;
end;
$$;

revoke all on function private.sync_quiz_tracking()
  from public, anon, authenticated, service_role;

drop trigger history_quiz_metrics_after_insert
  on public.history_quiz_results;
drop trigger geography_quiz_metrics_after_insert
  on public.geography_quiz_results;
drop trigger mixed_quiz_metrics_after_insert
  on public.mixed_quiz_results;
drop trigger hungarian_quiz_metrics_after_insert
  on public.hungarian_quiz_results;
drop trigger fifth_grader_quiz_metrics_after_insert
  on public.fifth_grader_quiz_results;

drop trigger history_public_metrics_after_insert
  on public.history_quiz_results;
drop trigger geography_public_metrics_after_insert
  on public.geography_quiz_results;
drop trigger mixed_public_metrics_after_insert
  on public.mixed_quiz_results;
drop trigger hungarian_public_metrics_after_insert
  on public.hungarian_quiz_results;
drop trigger fifth_grader_public_metrics_after_insert
  on public.fifth_grader_quiz_results;

create trigger history_quiz_tracking_after_change
  after insert or update or delete on public.history_quiz_results
  for each row execute function private.sync_quiz_tracking('history');
create trigger geography_quiz_tracking_after_change
  after insert or update or delete on public.geography_quiz_results
  for each row execute function private.sync_quiz_tracking('geography');
create trigger mixed_quiz_tracking_after_change
  after insert or update or delete on public.mixed_quiz_results
  for each row execute function private.sync_quiz_tracking('mix');
create trigger hungarian_quiz_tracking_after_change
  after insert or update or delete on public.hungarian_quiz_results
  for each row execute function private.sync_quiz_tracking('hungarian');
create trigger fifth_grader_quiz_tracking_after_change
  after insert or update or delete on public.fifth_grader_quiz_results
  for each row execute function private.sync_quiz_tracking('fifth_grader');

drop function private.update_quiz_metrics();
drop function private.copy_quiz_result_to_public_attempts();

-- Reconcile the public mirror with the genuine source rows. Existing matching
-- rows are left untouched; missing tracking rows are restored, changed mirrors
-- are corrected, and orphaned mirrors are removed.
insert into public.quiz_public_attempts (
  source_id,
  category_id,
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds
)
select
  source_id,
  category_id,
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds
from private.all_quiz_results_for_tracking
on conflict (source_id) do update set
  category_id = excluded.category_id,
  score = excluded.score,
  total_questions = excluded.total_questions,
  first_try_correct = excluded.first_try_correct,
  second_try_correct = excluded.second_try_correct,
  completed_at = excluded.completed_at,
  duration_seconds = excluded.duration_seconds
where (
  public.quiz_public_attempts.category_id,
  public.quiz_public_attempts.score,
  public.quiz_public_attempts.total_questions,
  public.quiz_public_attempts.first_try_correct,
  public.quiz_public_attempts.second_try_correct,
  public.quiz_public_attempts.completed_at,
  public.quiz_public_attempts.duration_seconds
) is distinct from (
  excluded.category_id,
  excluded.score,
  excluded.total_questions,
  excluded.first_try_correct,
  excluded.second_try_correct,
  excluded.completed_at,
  excluded.duration_seconds
);

delete from public.quiz_public_attempts as attempt
where not exists (
  select 1
  from private.all_quiz_results_for_tracking as result
  where result.source_id = attempt.source_id
);

-- Reconcile per-player aggregates. The WHERE clause avoids rewriting metrics
-- that already match their source rows.
with source_metrics as (
  select
    result.user_id,
    result.category_id,
    count(*)::integer as quizzes_taken,
    sum(result.score)::integer as total_correct,
    sum(result.total_questions)::integer as total_questions,
    round(
      max(result.score::numeric * 100 / result.total_questions),
      2
    ) as best_percentage,
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
  total_correct,
  total_questions,
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
  total_correct,
  total_questions,
  best_percentage,
  last_score,
  last_total,
  last_played_at,
  now()
from source_metrics
on conflict (user_id, category_id) do update set
  quizzes_taken = excluded.quizzes_taken,
  total_correct = excluded.total_correct,
  total_questions = excluded.total_questions,
  best_percentage = excluded.best_percentage,
  last_score = excluded.last_score,
  last_total = excluded.last_total,
  last_played_at = excluded.last_played_at,
  updated_at = now()
where (
  public.quiz_metrics.quizzes_taken,
  public.quiz_metrics.total_correct,
  public.quiz_metrics.total_questions,
  public.quiz_metrics.best_percentage,
  public.quiz_metrics.last_score,
  public.quiz_metrics.last_total,
  public.quiz_metrics.last_played_at
) is distinct from (
  excluded.quizzes_taken,
  excluded.total_correct,
  excluded.total_questions,
  excluded.best_percentage,
  excluded.last_score,
  excluded.last_total,
  excluded.last_played_at
);

delete from public.quiz_metrics as metric
where not exists (
  select 1
  from private.all_quiz_results_for_tracking as result
  where result.user_id = metric.user_id
    and result.category_id = metric.category_id
);

comment on view private.all_quiz_results_for_tracking is
  'Private source-of-truth projection used to reconcile derived quiz tracking.';
comment on function private.sync_quiz_tracking() is
  'Synchronizes public attempt summaries and per-player metrics after source result changes.';
