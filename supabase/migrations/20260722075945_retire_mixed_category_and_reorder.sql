-- Retire the redundant mixed quiz. It never had its own questions: the browser
-- loaded the existing History and Geography banks together. Preserve its old
-- result rows so aggregate activity remains historically accurate.

begin;
set local statement_timeout = '30s';

update public.quiz_categories
set
  display_order = case id
    when 'textbook_history' then 1
    when 'history' then 2
    when 'hungarian' then 3
    when 'geography' then 4
    when 'fifth_grader' then 5
    when 'mix' then 6
  end,
  is_active = case when id = 'mix' then false else is_active end
where id in (
  'textbook_history',
  'history',
  'hungarian',
  'geography',
  'fifth_grader',
  'mix'
);

do $validation$
begin
  if exists (
    select 1
    from public.quiz_categories as category
    where (category.id = 'mix' and category.is_active)
       or (category.id = 'textbook_history' and category.display_order <> 1)
       or (category.id = 'history' and category.display_order <> 2)
       or (category.id = 'hungarian' and category.display_order <> 3)
       or (category.id = 'geography' and category.display_order <> 4)
       or (category.id = 'fifth_grader' and category.display_order <> 5)
  ) then
    raise exception 'Quiz category retirement or ordering did not apply correctly';
  end if;
end;
$validation$;

comment on table public.mixed_quiz_results is
  'Historical results for the retired mixed quiz; retained for accurate aggregate metrics.';

commit;
