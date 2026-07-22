-- Tankönyvi történelem: a 1970-es és kora 1980-as évek magyar iskolai
-- történelemanyagát felidéző, külön követett magyar nyelvű kvíz.

begin;
set local statement_timeout = '30s';

-- Keep the two Hungarian-language history choices together in the menu.
update public.quiz_categories
set display_order = 6
where id = 'fifth_grader';

insert into public.quiz_categories (
  id,
  display_name,
  description,
  language_code,
  display_order,
  is_active
) values (
  'textbook_history',
  'Tankönyvi történelem',
  'Az 1970-es és 1980-as évek magyar iskolai történelemanyagának felidézése',
  'hu',
  5,
  true
);

create table public.textbook_history_quiz_results (
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
  constraint textbook_history_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint textbook_history_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint textbook_history_result_valid_duration
    check (duration_seconds >= 0),
  constraint textbook_history_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint textbook_history_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index textbook_history_results_user_completed_idx
  on public.textbook_history_quiz_results (user_id, completed_at desc);

alter table public.textbook_history_quiz_results enable row level security;

create policy "Players can submit their own textbook-history results"
  on public.textbook_history_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.textbook_history_quiz_results
  from anon, authenticated;
grant insert on table public.textbook_history_quiz_results
  to authenticated;
grant all on table public.textbook_history_quiz_results
  to service_role;

create trigger textbook_history_question_answer_stats_after_insert
  after insert on public.textbook_history_quiz_results
  for each row execute function private.update_question_answer_stats();

-- Extend the source-of-truth projection used by score synchronization.
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
select
  id,
  user_id,
  'geography',
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds,
  is_unlimited
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
  duration_seconds,
  is_unlimited
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
  duration_seconds,
  is_unlimited
from public.hungarian_quiz_results
union all
select
  id,
  user_id,
  'textbook_history',
  score,
  total_questions,
  first_try_correct,
  second_try_correct,
  completed_at,
  duration_seconds,
  is_unlimited
from public.textbook_history_quiz_results
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
  duration_seconds,
  is_unlimited
from public.fifth_grader_quiz_results;

revoke all on table private.all_quiz_results_for_tracking
  from public, anon, authenticated, service_role;

-- Accept any known category instead of maintaining another hard-coded list.
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
     or not exists (
       select 1
       from public.quiz_categories as category
       where category.id = target_category_id
     ) then
    raise exception 'Invalid quiz tracking target'
      using errcode = '22023';
  end if;

  select
    count(*)::integer as attempts_taken,
    count(*) filter (where not result.is_unlimited)::integer as quizzes_taken,
    count(*) filter (where result.is_unlimited)::integer as unlimited_quizzes_taken,
    coalesce(sum(result.score), 0)::integer as total_correct,
    coalesce(sum(result.total_questions), 0)::integer as total_questions,
    coalesce(sum(result.score) filter (
      where not result.is_unlimited
    ), 0)::integer as standard_total_correct,
    coalesce(sum(result.total_questions) filter (
      where not result.is_unlimited
    ), 0)::integer as standard_total_questions,
    coalesce(
      round(max(
        result.score::numeric * 100 / result.total_questions
      ) filter (where not result.is_unlimited), 2),
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

  if summary.attempts_taken = 0 then
    delete from public.quiz_metrics
    where user_id = target_user_id
      and category_id = target_category_id;
    return;
  end if;

  insert into public.quiz_metrics (
    user_id,
    category_id,
    quizzes_taken,
    unlimited_quizzes_taken,
    total_correct,
    total_questions,
    standard_total_correct,
    standard_total_questions,
    best_percentage,
    last_score,
    last_total,
    last_played_at,
    updated_at
  ) values (
    target_user_id,
    target_category_id,
    summary.quizzes_taken,
    summary.unlimited_quizzes_taken,
    summary.total_correct,
    summary.total_questions,
    summary.standard_total_correct,
    summary.standard_total_questions,
    summary.best_percentage,
    summary.last_score,
    summary.last_total,
    summary.last_played_at,
    now()
  )
  on conflict (user_id, category_id) do update set
    quizzes_taken = excluded.quizzes_taken,
    unlimited_quizzes_taken = excluded.unlimited_quizzes_taken,
    total_correct = excluded.total_correct,
    total_questions = excluded.total_questions,
    standard_total_correct = excluded.standard_total_correct,
    standard_total_questions = excluded.standard_total_questions,
    best_percentage = excluded.best_percentage,
    last_score = excluded.last_score,
    last_total = excluded.last_total,
    last_played_at = excluded.last_played_at,
    updated_at = now();
end;
$$;

revoke all on function private.refresh_quiz_metrics(uuid, text)
  from public, anon, authenticated, service_role;

create trigger textbook_history_quiz_tracking_after_change
  after insert or update or delete on public.textbook_history_quiz_results
  for each row execute function private.sync_quiz_tracking('textbook_history');

-- Questions are inserted below as one batch for a single round trip.
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
)
select
  'textbook_' || lpad(question.ordinality::text, 4, '0'),
  'textbook_history',
  question.item ->> 'p',
  question.item ->> 'a',
  array(
    select jsonb_array_elements_text(question.item -> 'w')
  ),
  'hu',
  null,
  question.item ->> 's',
  question.ordinality::integer,
  true
from jsonb_array_elements($questions$
[
  {"s":"Őskor és ókori Kelet","p":"Melyik forrástípusból dolgozik elsősorban a régészet?","a":"Tárgyi emlékekből","w":["Csak szájhagyományból","Kizárólag törvénykönyvekből","Csak szépirodalmi művekből"]},
  {"s":"Őskor és ókori Kelet","p":"Mit jelent a paleolitikum elnevezés?","a":"Őskőkort","w":["Újkőkort","Rézkort","Vaskort"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik változás jellemezte leginkább az újkőkori forradalmat?","a":"Az élelemtermelésre való áttérés","w":["A gőzgép elterjedése","Az írásbeliség megszűnése","A tengeri nagyhatalmak kialakulása"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik két tevékenység alkotta a termelő gazdálkodás alapját?","a":"A földművelés és az állattenyésztés","w":["A vadászat és a gyűjtögetés","A bányászat és a hajózás","A kereskedelem és a pénzverés"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik két fém ötvözete a bronz?","a":"A rézé és az óné","w":["A vasé és az ólomé","Az aranyé és az ezüsté","A rézé és a cinké"]},
  {"s":"Őskor és ókori Kelet","p":"Mit nevezünk termékeny félholdnak?","a":"A Közel-Kelet korai földművelő civilizációinak ívét","w":["A Nílus deltájának egyiptomi nevét","A kínai nagy fal körüli vidéket","A görög gyarmatok összességét"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik két folyó között feküdt Mezopotámia?","a":"A Tigris és az Eufrátesz között","w":["A Nílus és a Jordán között","Az Indus és a Gangesz között","A Rajna és a Duna között"]},
  {"s":"Őskor és ókori Kelet","p":"Milyen politikai egységekben éltek a korai sumérok?","a":"Önálló városállamokban","w":["Egységes világbirodalomban","Nomád törzsszövetségben","Hűbéri királyságokban"]},
  {"s":"Őskor és ókori Kelet","p":"Milyen írást alakítottak ki a sumérok?","a":"Ékírást","w":["Hieroglif írást","Rovásírást","Cirill írást"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik ókori uralkodó törvényoszlopa vált híressé?","a":"Hammurapi babiloni királyé","w":["Periklész athéni államférfié","Augustus római császáré","Nagy Károly frank uralkodóé"]},
  {"s":"Őskor és ókori Kelet","p":"Mi volt a zikkurat Mezopotámiában?","a":"Lépcsőzetes templomtorony","w":["Királyi sírkamra","Öntözőcsatorna","Városkaput védő faltorony"]},
  {"s":"Őskor és ókori Kelet","p":"Mi tette kiszámíthatóvá az ókori egyiptomi földművelést?","a":"A Nílus rendszeres áradása","w":["A monszuneső","A tengervíz sótalanítása","Az Eufrátesz befagyása"]},
  {"s":"Őskor és ókori Kelet","p":"Milyen szerepet töltött be a fáraó Egyiptomban?","a":"Isteni eredetűnek tekintett uralkodó volt","w":["Évente választott néptribunus volt","Csak a hadsereg főparancsnoka volt","A városi kézművesek vezetője volt"]},
  {"s":"Őskor és ókori Kelet","p":"Mit nevezünk hieroglif írásnak?","a":"Az ókori egyiptomi kép- és jelírást","w":["A föníciaiak hangjelölő ábécéjét","A római számírást","A középkori szerzetesek gyorsírását"]},
  {"s":"Őskor és ókori Kelet","p":"Mi volt az egyiptomi mumifikálás célja?","a":"A test megőrzése a túlvilági élet számára","w":["A holttest nyilvános bemutatása","Az uralkodó megkoronázása","A papok orvosi oktatása"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik egyiptomi korszakban épültek a gízai nagy piramisok?","a":"Az Óbirodalom idején","w":["Az Újbirodalom végén","A hellenisztikus korban","A római uralom után"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik isten kizárólagos tiszteletét próbálta bevezetni Ehnaton fáraó?","a":"Atonét","w":["Oziriszét","Amonét","Hóruszét"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik ókori néphez kapcsolják a vasfeldolgozás korai elterjesztését Kis-Ázsiában?","a":"A hettitákhoz","w":["A föníciaiakhoz","A spártaiakhoz","A latinokhoz"]},
  {"s":"Őskor és ókori Kelet","p":"Mi volt a föníciaiak legmaradandóbb művelődéstörténeti újítása?","a":"A hangjelölő ábécé elterjesztése","w":["A tízes számrendszer feltalálása","A papírpénz bevezetése","A gőzhajó megépítése"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik vallási sajátosság különböztette meg az ókori zsidóságot sok környező néptől?","a":"Az egyistenhit","w":["A császárkultusz","A természetistenek teljes hiánya minden korban","Az uralkodók múmiává alakítása"]},
  {"s":"Őskor és ókori Kelet","p":"Ki alapozta meg a Perzsa Birodalmat a Kr. e. 6. században?","a":"II. Kürosz","w":["Xerxész","Hammurapi","Nagy Sándor"]},
  {"s":"Őskor és ókori Kelet","p":"Mi volt a szatrapia a Perzsa Birodalomban?","a":"Kormányzóság, vagyis tartomány","w":["Katonai hajótípus","Vallási ünnep","Adósrabszolga"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik perzsa uralkodó szervezte újjá a birodalmat tartományokra és építtette a Királyi utat?","a":"I. Dareiosz","w":["II. Kürosz","III. Alexandrosz","Nebukadneccar"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik két város volt az Indus-völgyi civilizáció fontos központja?","a":"Harappa és Mohendzsodáro","w":["Ur és Uruk","Athén és Spárta","Memphisz és Théba"]},
  {"s":"Őskor és ókori Kelet","p":"Mit jelentett a kasztrendszer az ókori Indiában?","a":"Születésen alapuló, zárt társadalmi csoportokat","w":["Évente sorsolt hivatalokat","Szabadon választható mesterségeket","Katonai tartományokat"]},
  {"s":"Őskor és ókori Kelet","p":"Kihez köti a hagyomány a buddhizmus tanításának kezdetét?","a":"Gautama Sziddhárthához","w":["Konfuciuszhoz","Lao-ce császárhoz","Asóka hadvezérhez"]},
  {"s":"Őskor és ókori Kelet","p":"Melyik folyó völgyében alakult ki a korai kínai civilizáció egyik magterülete?","a":"A Huangho völgyében","w":["A Volga völgyében","A Nílus deltájában","A Rajna vidékén"]},
  {"s":"Őskor és ókori Kelet","p":"Ki egyesítette először tartósan Kínát, és lett az első császár?","a":"Csin Si Huang-ti","w":["Konfuciusz","Kubla kán","Szun Jat-szen"]},
  {"s":"Őskor és ókori Kelet","p":"Mely területeket kötötte össze a selyemút fő szárazföldi útvonala?","a":"Kínát Közép-Ázsián át a mediterrán világgal","w":["Skandináviát Észak-Amerikával","Egyiptomot Dél-Afrikával","Indiát Ausztráliával"]},
  {"s":"Őskor és ókori Kelet","p":"Mi követte a korabeli marxista tankönyvi korszakolásban a rabszolgatartó társadalmat?","a":"A feudális társadalom","w":["Az ősközösség","A kapitalista társadalom","A szocialista társadalom"]},

  {"s":"Ókori Görögország és Róma","p":"Mit jelentett a polisz az ókori görög világban?","a":"Városállamot és polgárközösségét","w":["Egységes görög császárságot","Kereskedelmi hajót","Templomi adót"]},
  {"s":"Ókori Görögország és Róma","p":"Kik vehettek részt teljes joggal a klasszikus athéni népgyűlésen?","a":"A nagykorú, szabad athéni férfi polgárok","w":["A város minden lakója","Csak a papok és hadvezérek","A rabszolgák és a betelepültek"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik athéni törvényhozó törölte el az adósrabszolgaságot?","a":"Szolón","w":["Drakón","Kleiszthenész","Periklész"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik államférfi reformjai teremtették meg az athéni demokrácia területi alapját?","a":"Kleiszthenészé","w":["Leónidaszé","Miltiadészé","Démoszthenészé"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik csatában győztek az athéniak a perzsák felett Kr. e. 490-ben?","a":"Marathónnál","w":["Thermopülainál","Khairóneiánál","Gaugamélánál"]},
  {"s":"Ókori Görögország és Róma","p":"Ki vezette a spártaiakat a thermopülai szoros védelmében?","a":"Leónidasz király","w":["Themisztoklész","Periklész","Philipposz"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik ütközetben aratott döntő tengeri győzelmet a görög flotta a perzsák felett?","a":"A szalamiszi csatában","w":["A marathóni csatában","A plataiai csatában","A peloponnészoszi csatában"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik athéni politikus korát nevezik gyakran az athéni demokrácia fénykorának?","a":"Periklész korát","w":["Drakón korát","Peiszisztratosz korát","Alkibiadész korát"]},
  {"s":"Ókori Görögország és Róma","p":"Kik voltak a helóták Spártában?","a":"Alávetett, földművelő népesség","w":["Teljes jogú spártai harcosok","Választott bírák","Tengeri kereskedők"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik két görög hatalom állt egymással szemben a peloponnészoszi háborúban?","a":"Athén és Spárta","w":["Athén és Róma","Spárta és Perzsia","Théba és Egyiptom"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik filozófust ítélte halálra az athéni bíróság Kr. e. 399-ben?","a":"Szókratészt","w":["Platónt","Arisztotelészt","Hérodotoszt"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik iskolát alapította Platón Athénban?","a":"Az Akadémiát","w":["A Lükeiont","A Sztóát","A Museiont"]},
  {"s":"Ókori Görögország és Róma","p":"Ki volt Nagy Sándor nevelője?","a":"Arisztotelész","w":["Szókratész","Püthagorasz","Hérodotosz"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik makedón uralkodó teremtette meg a görög poliszok feletti hegemóniát Nagy Sándor előtt?","a":"II. Philipposz","w":["I. Dareiosz","Leónidasz","Ptolemaiosz"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik csatában győzte le Nagy Sándor döntően III. Dareiosz seregét?","a":"Gaugamélánál","w":["Marathónnál","Cannae-nál","Actiumnál"]},
  {"s":"Ókori Görögország és Róma","p":"Mit nevezünk hellenizmusnak?","a":"A görög és keleti kultúrák Nagy Sándor utáni keveredését","w":["A görög poliszok perzsa uralmát","A római köztársaság kezdetét","A kereszténység államvallássá válását"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik hagyományos évszámhoz kötik Róma alapítását?","a":"Kr. e. 753-hoz","w":["Kr. e. 509-hez","Kr. e. 44-hez","Kr. u. 476-hoz"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik két főtisztviselő vezette évente a római köztársaságot?","a":"A két consul","w":["A két császár","A két néptribunus kizárólagosan","A két pontifex maximus"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik két társadalmi csoport küzdelme jellemezte a korai római köztársaságot?","a":"A patríciusoké és a plebejusoké","w":["A spártaiaké és az athéniaké","A helótáké és a metoikoszoké","A hunoké és a gótoké"]},
  {"s":"Ókori Görögország és Róma","p":"Mi volt a XII táblás törvények jelentősége?","a":"Írásba foglalták a római jog alapvető szabályait","w":["Megszüntették a köztársaságot","Bevezették a kereszténységet","Felosztották a birodalmat"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik városállam volt Róma ellenfele a pun háborúkban?","a":"Karthágó","w":["Athén","Alexandria","Bizánc"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik csatában mért Hannibál súlyos vereséget a rómaiakra Kr. e. 216-ban?","a":"Cannae-nál","w":["Zamánál","Actiumnál","Pharszalosznál"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik folyón kelt át Julius Caesar Kr. e. 49-ben, polgárháborút indítva?","a":"A Rubiconon","w":["A Tiberisen","A Pón","A Rajnán"]},
  {"s":"Ókori Görögország és Róma","p":"Milyen új államformát alapozott meg Augustus?","a":"A principatust, vagyis a császárkort","w":["A türanniszt","A feudális királyságot","A közvetlen demokráciát"]},
  {"s":"Ókori Görögország és Róma","p":"Mit jelent a Pax Romana kifejezés?","a":"A császárkor első századainak viszonylagos római békéjét","w":["Róma békeszerződését Karthágóval","A keresztényüldözések korszakát","A nyugatrómai birodalom bukását"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik római provincia foglalta magába a Dunántúl nagy részét?","a":"Pannonia","w":["Dacia","Gallia","Hispania"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik római település romjai találhatók a mai Óbuda területén?","a":"Aquincumé","w":["Savariáé","Sopianae-é","Gorsiumé"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik császár engedélyezte a keresztény vallás szabad gyakorlását a milánói ediktumban?","a":"Constantinus","w":["Nero","Diocletianus","Traianus"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik évben vált végleg külön a Nyugatrómai és a Keletrómai Birodalom?","a":"395-ben","w":["313-ban","476-ban","800-ban"]},
  {"s":"Ókori Görögország és Róma","p":"Melyik eseményhez kötik hagyományosan az ókor végét?","a":"A Nyugatrómai Birodalom bukásához 476-ban","w":["Róma alapításához","A kereszténység születéséhez","Konstantinápoly elfoglalásához 1453-ban"]},

  {"s":"Középkor és kora újkor","p":"Mit neveztek hűbérbirtoknak a középkorban?","a":"Szolgálat fejében használatra átadott földbirtokot","w":["Szabad paraszti közös földet","Városi piacteret","Egyházi ünnepnapot"]},
  {"s":"Középkor és kora újkor","p":"Mi volt a jobbágy egyik jellemző kötelezettsége földesurával szemben?","a":"A robot teljesítése","w":["A consul megválasztása","A tengeri vám eltörlése","A céhmester kinevezése"]},
  {"s":"Középkor és kora újkor","p":"Mit jelentett a középkori uradalom önellátó jellege?","a":"Szükségleteinek nagy részét maga állította elő","w":["Nem használt földet","Csak távolsági kereskedelemből élt","Minden lakója nemes volt"]},
  {"s":"Középkor és kora újkor","p":"Mi volt a nyomásos gazdálkodás lényege?","a":"A szántóföldet vetésforgó jelleggel részekre osztották","w":["Minden földet állandóan parlagon hagytak","Csak öntözött rizst termesztettek","A földeket kizárólag kolostorok birtokolták"]},
  {"s":"Középkor és kora újkor","p":"Mi volt a céhek legfontosabb gazdasági feladata?","a":"Az azonos mesterségű kézművesek termelésének szabályozása","w":["A királyi hadsereg vezetése","A jobbágyok földhöz kötése","A püspökök megválasztása"]},
  {"s":"Középkor és kora újkor","p":"Mit biztosított egy középkori város kiváltságlevele?","a":"Meghatározott önkormányzati és gazdasági jogokat","w":["Automatikus királyválasztási jogot","Minden lakónak nemesi címet","A pénzhasználat tilalmát"]},
  {"s":"Középkor és kora újkor","p":"Miről szólt az invesztitúraharc?","a":"A pápa és a császár küzdelméről az egyházi méltóságok kinevezéséért","w":["A kereskedők és céhek vámvitájáról","A keresztesek és mongolok háborújáról","A jobbágyok örökösödési jogáról"]},
  {"s":"Középkor és kora újkor","p":"Melyik évben következett be a nyugati és keleti kereszténység nagy egyházszakadása?","a":"1054-ben","w":["800-ban","1215-ben","1453-ban"]},
  {"s":"Középkor és kora újkor","p":"Melyik évben indult az első keresztes hadjárat?","a":"1096-ban","w":["962-ben","1204-ben","1291-ben"]},
  {"s":"Középkor és kora újkor","p":"Melyik angol oklevél korlátozta 1215-ben a király hatalmát?","a":"A Magna Carta","w":["A Domesday Book","A Bill of Rights","A Habeas Corpus Act"]},
  {"s":"Középkor és kora újkor","p":"Melyik két királyság harcolt a százéves háborúban?","a":"Anglia és Franciaország","w":["Franciaország és Spanyolország","Anglia és Skócia","Németország és Itália"]},
  {"s":"Középkor és kora újkor","p":"Milyen betegség volt a 14. századi fekete halál?","a":"Pestis","w":["Himlő","Kolera","Tífusz"]},
  {"s":"Középkor és kora újkor","p":"Mi volt a Keletrómai, más néven Bizánci Birodalom fővárosa?","a":"Konstantinápoly","w":["Ravenna","Alexandria","Antiochia"]},
  {"s":"Középkor és kora újkor","p":"Melyik bizánci császár nevéhez fűződik a római jog nagy összefoglalása?","a":"I. Justinianuséhoz","w":["I. Constantinuséhoz","Nagy Theodosiuséhoz","Herakleioszéhoz"]},
  {"s":"Középkor és kora újkor","p":"Kit koronázott császárrá III. Leó pápa 800 karácsonyán?","a":"Nagy Károlyt","w":["I. Ottót","Hódító Vilmost","Barbarossa Frigyest"]},
  {"s":"Középkor és kora újkor","p":"Melyik uralkodót koronázták német-római császárrá 962-ben?","a":"I. Ottót","w":["Nagy Károlyt","IV. Henriket","I. Frigyest"]},
  {"s":"Középkor és kora újkor","p":"Melyik térségből indultak a viking hajósok?","a":"Skandináviából","w":["Az Ibériai-félszigetről","A Balkánról","Kis-Ázsiából"]},
  {"s":"Középkor és kora újkor","p":"Melyik kijevi fejedelem vette fel a kereszténységet 988-ban?","a":"Vlagyimir","w":["Rurik","Jaroszláv","Dmitrij Donszkoj"]},
  {"s":"Középkor és kora újkor","p":"Ki egyesítette a mongol törzseket a 13. század elején?","a":"Dzsingisz kán","w":["Batu kán","Timur Lenk","Kubla kán"]},
  {"s":"Középkor és kora újkor","p":"Melyik mongol utódállam gyakorolt hosszú ideig fennhatóságot az orosz fejedelemségek felett?","a":"Az Arany Horda","w":["Az Ilhánida állam","A Csagatáj Kánság","A Krími Köztársaság"]},
  {"s":"Középkor és kora újkor","p":"Melyik évben foglalta el II. Mehmed szultán Konstantinápolyt?","a":"1453-ban","w":["1389-ben","1492-ben","1526-ban"]},
  {"s":"Középkor és kora újkor","p":"Melyik itáliai várost tekintik a reneszánsz egyik legfontosabb bölcsőjének?","a":"Firenzét","w":["Nápolyt","Palermót","Torinót"]},
  {"s":"Középkor és kora újkor","p":"Mit állított középpontba a reneszánsz humanizmus?","a":"Az embert és az antik műveltséget","w":["A hűbéri esküt és a lovagi szolgálatot","A gépi nagyipart","A gyarmati közigazgatást"]},
  {"s":"Középkor és kora újkor","p":"Melyik technikai újítással forradalmasította Gutenberg az európai könyvkiadást?","a":"A mozgatható fémbetűs könyvnyomtatással","w":["A papirusz feltalálásával","A gőzhajtású sajtóval","A fényképezéssel"]},
  {"s":"Középkor és kora újkor","p":"Melyik évben érte el Kolumbusz Kristóf Amerika szigeteit?","a":"1492-ben","w":["1453-ban","1498-ban","1519-ben"]},
  {"s":"Középkor és kora újkor","p":"Ki jutott el tengeri úton Indiába Afrika megkerülésével 1498-ban?","a":"Vasco da Gama","w":["Bartolomeu Dias","Amerigo Vespucci","Pedro Cabral"]},
  {"s":"Középkor és kora újkor","p":"Melyik expedíció hajózta körül először a Földet?","a":"Magellán expedíciója","w":["Kolumbusz első útja","Vasco da Gama indiai útja","Cook első csendes-óceáni útja"]},
  {"s":"Középkor és kora újkor","p":"Melyik két hatalom osztotta fel egymás között a felfedezendő világot a tordesillasi szerződésben?","a":"Spanyolország és Portugália","w":["Anglia és Franciaország","Hollandia és Dánia","Velence és Genova"]},
  {"s":"Középkor és kora újkor","p":"Melyik esemény indította el jelképesen a reformációt 1517-ben?","a":"Luther Márton közzétette 95 tételét","w":["Kálvin János elfoglalta Rómát","VIII. Henrik feloszlatta a parlamentet","A tridenti zsinat kihirdette a vallásszabadságot"]},
  {"s":"Középkor és kora újkor","p":"Melyik zsinat fogalmazta meg a katolikus megújulás fő tanításait a 16. században?","a":"A tridenti zsinat","w":["A niceai zsinat","A konstanzi zsinat","A clermont-i zsinat"]},

  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik nyelvcsalád uráli ágához tartozik a magyar nyelv?","a":"A finnugor nyelvekhez","w":["A szláv nyelvekhez","A germán nyelvekhez","A török nyelvekhez"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik szerzetes indult a 13. században a keleten maradt magyarok felkutatására?","a":"Julianus barát","w":["Gellért püspök","Kőrösi Csoma Sándor","László Gyula"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik szállásterületről költöztek a honfoglaló magyar törzsek a Kárpát-medencébe?","a":"Etelközből","w":["Levédia nyugati feléből közvetlenül","Magna Hungariából közvetlenül","Pannoniából"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Mit jelképezett a hagyomány szerint a vérszerződés?","a":"A magyar törzsek politikai szövetségét","w":["A kereszténység felvételét","A német-római császárral kötött békét","A jobbágyság felszabadítását"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Kit választottak a hagyomány szerint a hét magyar törzs vezetőjévé a vérszerződéskor?","a":"Álmost","w":["Kurszánt","Lehelt","Bulcsút"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik fejedelem nevéhez köti a hagyomány a honfoglalás vezetését?","a":"Árpádéhoz","w":["Gézáéhoz","Taksonyéhoz","Koppányéhoz"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik időszakban zajlott a magyar honfoglalás fő szakasza?","a":"895 és 900 között","w":["800 és 805 között","955 és 960 között","1000 és 1005 között"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik 955-ös vereség vetett véget a nyugati magyar kalandozásoknak?","a":"Az augsburgi, Lech-mezei vereség","w":["A muhi vereség","A pozsonyi vereség","A nikápolyi vereség"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik fejedelem kezdte meg határozottan a keresztény magyar állam megszervezését István előtt?","a":"Géza fejedelem","w":["Álmos fejedelem","Taksony fejedelem","Kurszán fejedelem"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Mi volt I. István pogány neve?","a":"Vajk","w":["Koppány","Vata","Ajtony"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Mikor koronázták királlyá I. Istvánt?","a":"1000 karácsonyán vagy 1001 első napján","w":["955 húsvétján","997 pünkösdjén","1038 augusztusában"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Hol szervezte meg István király az ország első érsekségét?","a":"Esztergomban","w":["Veszprémben","Pécsett","Győrben"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Ki állt az István-kori királyi vármegye élén?","a":"Az ispán","w":["A nádor kizárólag","A céhmester","A jobbágybíró"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Milyen egyházi adót írt elő István törvénye?","a":"A tizedet","w":["A kilencedet","A kapuadót","A harmincadot"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Ki követte közvetlenül I. Istvánt a magyar trónon?","a":"Orseolo Péter","w":["I. András","Aba Sámuel","I. Béla"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Ki vezette az 1046-os pogánylázadást?","a":"Vata","w":["Koppány","Ajtony","Tonuzoba"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik király uralkodása alatt alapították a tihanyi apátságot 1055-ben?","a":"I. András alatt","w":["I. Béla alatt","Szent László alatt","Könyves Kálmán alatt"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Miért különösen fontos nyelvemlék a tihanyi alapítólevél?","a":"Latin szövegében magyar szavak és szórványok maradtak fenn","w":["Teljes egészében magyarul írták","Ez az első nyomtatott magyar könyv","Rovásírással készült"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik Árpád-házi király szigorú törvényei erősítették meg a magántulajdon védelmét?","a":"Szent Lászlóéi","w":["II. Andráséi","IV. Béláéi","III. Andráséi"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik király engedte át békésen az országon az első keresztes hadjárat rendezett seregeit?","a":"Könyves Kálmán","w":["Szent István","II. Géza","III. Béla"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Mit jelentett II. András új berendezkedésnek nevezett birtokpolitikája?","a":"Királyi birtokok nagyarányú eladományozását","w":["A nemesi birtokok teljes államosítását","A vármegyerendszer felszámolását","A jobbágytelkek örökös királyi tulajdonát"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik nevezetes jogot tartalmazta az Aranybulla?","a":"Az ellenállási jogot","w":["Az általános választójogot","A jobbágyfelszabadítást","A vallásszabadság teljes elvét"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik társadalmi csoport jogait erősítette meg elsősorban az Aranybulla?","a":"A királyi szerviensekét","w":["A várjobbágyokét kizárólag","A városi céhlegényekét","A kun előkelőkét"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Mikor pusztította végig a tatárjárás a Magyar Királyságot?","a":"1241–1242-ben","w":["1211–1212-ben","1278–1279-ben","1301–1302-ben"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik folyó közelében szenvedett döntő vereséget IV. Béla serege 1241-ben?","a":"A Sajó mellett, Muhinál","w":["A Duna mellett, Visegrádnál","A Tisza mellett, Szolnoknál","A Dráva mellett, Eszéknél"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Ki vezette a Magyarországra törő mongol főerőket 1241-ben?","a":"Batu kán","w":["Dzsingisz kán","Kubla kán","Timur Lenk"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik keleti eredetű népet telepítette vissza IV. Béla a tatárjárás után az országba?","a":"A kunokat","w":["A besenyőket","A jászokat kizárólag","A szászokat"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Milyen várak építését ösztönözte IV. Béla a tatárjárás után?","a":"Kővárakét","w":["Csak földvárakét","Fából készült palánkvárakét kizárólag","Római típusú légiótáborokét"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Melyik király alapította a tatárjárás után a budai Várhegyen az új királyi központot?","a":"IV. Béla","w":["III. Béla","II. András","V. István"]},
  {"s":"Magyar történelem az államalapításig és az Árpád-korban","p":"Kinek a halálával halt ki az Árpád-ház férfiága 1301-ben?","a":"III. Andráséval","w":["IV. Lászlóéval","V. Istvánéval","I. Károlyéval"]},

  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik évben koronázták meg szabályosan, a Szent Koronával I. Károlyt?","a":"1310-ben","w":["1301-ben","1312-ben","1325-ben"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik csatában törte meg I. Károly az Aba nemzetség és szövetségesei hatalmát?","a":"A rozgonyi csatában","w":["A nikápolyi csatában","A várnai csatában","A mohácsi csatában"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik évben találkozott Visegrádon a magyar, a cseh és a lengyel király?","a":"1335-ben","w":["1308-ban","1351-ben","1387-ben"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik I. Károly által bevezetett adót vetették ki a jobbágyporták után?","a":"A kapuadót","w":["A kilencedet","A rendkívüli hadiadót","A füstpénzt"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik erőforrás tette a 14. századi Magyarországot Európa egyik jelentős nemesfémbányászati központjává?","a":"A gazdag arany- és ezüstbányák","w":["A tengeri sólepárlók","A gyapotültetvények","A kőolajmezők"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Mit jelentett a banderiális hadszervezet?","a":"A főurak és méltóságok saját zászló alatt kiállított csapatait","w":["A városok zsoldos rendőrségét","A jobbágyok önkéntes céheit","A király személyes testőrségét kizárólag"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik ország trónját örökölte meg 1370-ben Nagy Lajos?","a":"Lengyelországét","w":["Csehországét","Nápolyét","Szerbiáét"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik birtokjogi elvet erősítette meg az 1351-es törvény az ősiség kimondásával?","a":"A nemesi birtok nemzetségen belüli öröklését","w":["A föld szabad eladását bárkinek","A jobbágytelkek állami tulajdonát","Az egyházi birtokok teljes felszámolását"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Milyen földesúri szolgáltatást tett általánossá az 1351-es törvény?","a":"A kilencedet","w":["A tizedet","A harmincadot","A füstpénzt"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik egyetemes zsinat munkájában játszott meghatározó szerepet Luxemburgi Zsigmond?","a":"A konstanzi zsinatéban","w":["A tridenti zsinatéban","A niceai zsinatéban","A lateráni zsinatéban"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik 1396-os csatában szenvedett vereséget Zsigmond keresztes serege az oszmánoktól?","a":"Nikápolynál","w":["Várnánál","Rigómezőn","Nándorfehérvárnál"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Mit nevezünk Hunyadi János hosszú hadjáratának?","a":"Az 1443–1444-es balkáni hadjáratot az oszmánok ellen","w":["A csehek elleni 1468-as hadjáratot","A Dózsa-felkelés leverését","A tatárjárás utáni várépítést"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Mikor aratott Hunyadi János és Kapisztrán János serege győzelmet Nándorfehérvárnál?","a":"1456-ban","w":["1444-ben","1458-ban","1479-ben"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik harangszó kapcsolódott Európa-szerte a nándorfehérvári küzdelemhez?","a":"A déli harangszó","w":["A hajnali harangszó","Az esti takarodó","A koronázási harangszó"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik ferences hitszónok mozgósította a kereszteseket Nándorfehérvár védelmére?","a":"Kapisztrán János","w":["Temesvári Pelbárt","Bakócz Tamás","Fráter György"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik évben választották királlyá Hunyadi Mátyást?","a":"1458-ban","w":["1456-ban","1464-ben","1490-ben"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Mi volt Mátyás király híres zsoldosseregének neve?","a":"Fekete sereg","w":["Fehér sereg","Aranybulla had","Végvári liga"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik rendszeresített adó növelte jelentősen Mátyás király bevételeit?","a":"A rendkívüli hadiadó","w":["A kilenced eltörlése","A pápai tized","A sóadó teljes megszüntetése"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Mi volt a Bibliotheca Corviniana?","a":"Mátyás király híres reneszánsz könyvtára","w":["A Fekete sereg hadiszabályzata","A visegrádi békeszerződés","Egy budai céhszövetség"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik várost foglalta el Mátyás király 1485-ben, és tette udvara egyik központjává?","a":"Bécset","w":["Prágát","Velencét","Krakkót"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Milyen hadjáratra gyülekezett eredetileg az 1514-ben felkelő parasztsereg?","a":"A török elleni keresztes hadjáratra","w":["A csehek elleni huszita hadjáratra","A Habsburgok elleni örökösödési háborúra","A velenceiek elleni tengeri hadjáratra"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Mi volt Werbőczy István Tripartituma?","a":"A magyar szokásjog háromrészes összefoglalása","w":["Mátyás király adókönyve","A végvári katonák zsoldjegyzéke","Erdély első alkotmánya"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik napon zajlott a mohácsi csata?","a":"1526. augusztus 29-én","w":["1456. július 22-én","1541. augusztus 29-én","1566. szeptember 7-én"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik magyar király vesztette életét a mohácsi csata után?","a":"II. Lajos","w":["II. Ulászló","I. Ferdinánd","Szapolyai János"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik évben foglalta el az Oszmán Birodalom Budát?","a":"1541-ben","w":["1526-ban","1552-ben","1566-ban"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik három politikai részre szakadt Magyarország a 16. század közepére?","a":"Királyi Magyarországra, török hódoltságra és Erdélyre","w":["Dunántúlra, Alföldre és Felvidékre","Horvátországra, Szlavóniára és Dalmáciára","Bánságra, Vajdaságra és Partiumra"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik dinasztia uralkodott a Királyi Magyarországon 1526 után?","a":"A Habsburg-dinasztia","w":["A Jagelló-dinasztia","Az Anjou-dinasztia","Az Árpád-ház"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Melyik országrészből alakult ki az önálló Erdélyi Fejedelemség?","a":"A keleti magyar királyságból és a Partiumból","w":["A nyugati határőrvidékből","A török hódoltság központi részéből","A horvát tengermellékből"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Ki volt Eger várkapitánya az 1552-es ostrom idején?","a":"Dobó István","w":["Losonczy István","Zrínyi Miklós","Jurisics Miklós"]},
  {"s":"Magyarország az Anjouktól a három részre szakadásig","p":"Ki vezette Szigetvár védelmét 1566-ban?","a":"Zrínyi Miklós","w":["Dobó István","Thury György","Kinizsi Pál"]},

  {"s":"Magyarország a 17. századtól 1849-ig","p":"Ki vezette az 1604-ben kezdődő Habsburg-ellenes felkelést?","a":"Bocskai István","w":["Bethlen Gábor","Thököly Imre","II. Rákóczi Ferenc"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik béke biztosította 1606-ban a magyar rendek jogainak és vallásszabadságának egy részét?","a":"A bécsi béke","w":["A zsitvatoroki béke","A vasvári béke","A szatmári béke"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik erdélyi fejedelem uralkodott 1613 és 1629 között?","a":"Bethlen Gábor","w":["Bocskai István","I. Rákóczi György","Apafi Mihály"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik európai háborúba kapcsolódott be Bethlen Gábor a protestáns hatalmak oldalán?","a":"A harmincéves háborúba","w":["A hétéves háborúba","A spanyol örökösödési háborúba","A krími háborúba"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik főúri szervezkedés megtorlása vezetett kivégzésekhez 1671-ben?","a":"A Wesselényi-összeesküvésé","w":["A Martinovics-mozgalomé","A jakobinus klubé","A Védegyleté"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Kiket neveztek kurucoknak a 17–18. század fordulóján?","a":"A Habsburg-ellenes felkelőket","w":["A császári hadsereg katonáit","A török végvári őrséget","A hajdúvárosok bíráit"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik kiáltvánnyal hívta fegyverbe II. Rákóczi Ferenc 1703-ban a magyarországi rendeket és népet?","a":"A brezáni kiáltvánnyal","w":["A kassai kiáltvánnyal","Az ónodi végzéssel","A szatmári levéllel"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Mettől meddig tartott a Rákóczi-szabadságharc?","a":"1703-tól 1711-ig","w":["1686-tól 1699-ig","1711-től 1723-ig","1740-től 1748-ig"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Ki volt a Rákóczi-szabadságharc politikai és katonai vezetője?","a":"II. Rákóczi Ferenc","w":["Bercsényi Miklós kizárólag","Károlyi Sándor","Bottyán János"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik béke zárta le 1711-ben a Rákóczi-szabadságharcot?","a":"A szatmári béke","w":["A karlócai béke","A pozsareváci béke","A linzi béke"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Mit fogadott el a magyar országgyűlés az 1723-as Pragmatica Sanctióval?","a":"A Habsburg-ház nőági örökösödését és a birodalom együtt birtoklását","w":["Magyarország teljes függetlenségét","Az általános jobbágyfelszabadítást","A protestáns államvallást"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik évben lépett trónra Mária Terézia?","a":"1740-ben","w":["1711-ben","1765-ben","1780-ban"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Mit szabályozott Mária Terézia 1767-es úrbéri rendelete?","a":"A jobbágytelkeket és a földesúri szolgáltatásokat","w":["A városi céhek megszüntetését","A katonai határőrvidék felszámolását","A nemesi adókötelezettséget"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik területet szabályozta Mária Terézia 1777-es Ratio Educationisa?","a":"Az oktatásügyet","w":["A hadsereg ellátását","A bányák működését","A jobbágyok költözését"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Miért nevezték II. Józsefet kalapos királynak?","a":"Mert nem koronáztatta meg magát a Szent Koronával","w":["Mert kalapos céhet alapított","Mert mindig katonai sisakot viselt","Mert eltörölte a királyságot"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Mit biztosított II. József 1781-es türelmi rendelete?","a":"Szélesebb vallásgyakorlatot a protestánsoknak és az ortodoxoknak","w":["Teljes politikai egyenjogúságot minden alattvalónak","A jobbágyság azonnali eltörlését","A magyar nyelv kizárólagosságát"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik nyelvet tette II. József hivatali nyelvvé birodalmában?","a":"A németet","w":["A magyart","A latint","A franciát"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Mikor hozták vissza Budára a Szent Koronát II. József rendeleteinek visszavonása után?","a":"1790-ben","w":["1781-ben","1795-ben","1804-ben"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Ki szervezte meg az 1790-es évek magyar jakobinus mozgalmát?","a":"Martinovics Ignác","w":["Kazinczy Ferenc","Hajnóczy József","Batsányi János"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik országgyűlést tekintjük a magyar reformkor kezdetének?","a":"Az 1825–1827-es pozsonyi országgyűlést","w":["Az 1790–1791-es budai országgyűlést","Az 1832–1836-os pesti országgyűlést","Az 1847–1848-as debreceni országgyűlést"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Ki ajánlotta fel birtokainak egyévi jövedelmét a Magyar Tudós Társaság megalapítására?","a":"Széchenyi István","w":["Wesselényi Miklós","Kölcsey Ferenc","Deák Ferenc"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik művében sürgette Széchenyi István a hitelviszonyok korszerűsítését?","a":"A Hitelben","w":["A Világban","A Stádiumban","A Kelet népében"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Ki írta a Balítéletekről című reformkori művet?","a":"Wesselényi Miklós","w":["Széchenyi István","Kossuth Lajos","Eötvös József"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik lapot szerkesztette Kossuth Lajos 1841-től?","a":"A Pesti Hírlapot","w":["A Honderűt","A Budapesti Szemlét","A Vasárnapi Ujságot"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Mi volt a Védegylet célja?","a":"A hazai ipar támogatása magyar áruk vásárlásával","w":["A nemesi adómentesség védelme","A céhek kizárólagos jogainak bővítése","A Habsburg-hadsereg toborzása"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik dokumentumban foglalták össze a pesti forradalmárok 1848. március 15-i követeléseit?","a":"A tizenkét pontban","w":["Az áprilisi törvényekben","A Függetlenségi nyilatkozatban","Az olmützi alkotmányban"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Ki lett az első felelős magyar kormány miniszterelnöke 1848-ban?","a":"Batthyány Lajos","w":["Kossuth Lajos","Deák Ferenc","Szemere Bertalan"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik törvénycsomag számolta fel 1848-ban a rendi rendszer alapjait Magyarországon?","a":"Az áprilisi törvények","w":["Az úrbéri rendelet","A Pragmatica Sanctio","A kiegyezési törvények"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik csatában állította meg a honvédsereg Jellasics támadását 1848. szeptember 29-én?","a":"Pákozdnál","w":["Isaszegnél","Kápolnánál","Temesvárnál"]},
  {"s":"Magyarország a 17. századtól 1849-ig","p":"Melyik városban mondta ki az országgyűlés a Habsburg-ház trónfosztását 1849. április 14-én?","a":"Debrecenben","w":["Szegeden","Pozsonyban","Aradon"]},

  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik nagyhatalom hadserege avatkozott be 1849-ben a magyar szabadságharc leverésére?","a":"Az Orosz Birodalomé","w":["A Francia Köztársaságé","Az Oszmán Birodalomé","Nagy-Britanniáé"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Mikor tette le Görgei Artúr a honvédsereg főerőinek fegyverét Világosnál?","a":"1849. augusztus 13-án","w":["1848. szeptember 29-én","1849. április 14-én","1849. október 6-án"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Hány honvédtisztet végeztek ki Aradon 1849. október 6-án?","a":"Tizenhármat","w":["Tizenkettőt","Kilencet","Tizenötöt"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Mit nevezünk Bach-rendszernek?","a":"Az 1849 utáni központosított neoabszolutista kormányzást","w":["A reformkori vármegyei önkormányzatot","A dualizmus parlamenti váltógazdaságát","A Tanácsköztársaság gazdaságpolitikáját"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik megállapodás hozta létre 1867-ben az Osztrák–Magyar Monarchiát?","a":"Az osztrák–magyar kiegyezés","w":["A Pragmatica Sanctio","A szatmári béke","Az októberi diploma"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Mikor robbant ki az angol polgárháború a király és a parlament között?","a":"1642-ben","w":["1603-ban","1688-ban","1714-ben"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Milyen címmel állt Oliver Cromwell az angol köztársaság élén?","a":"Lordprotektorként","w":["Királyként","Néptribunusként","Kancellárként"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Mit nevezünk dicsőséges forradalomnak az angol történelemben?","a":"Az 1688-as hatalomváltást, amely megszilárdította az alkotmányos monarchiát","w":["A király 1649-es kivégzését","Az amerikai gyarmatok elvesztését","A chartista mozgalom kezdetét"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik 1689-es angol dokumentum korlátozta a király hatalmát?","a":"A Jognyilatkozat, vagyis Bill of Rights","w":["A Magna Carta új kiadása","A Függetlenségi nyilatkozat","A Habeas Corpus eltörlése"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik francia uralkodó építtette ki versailles-i udvarát az abszolutizmus jelképévé?","a":"XIV. Lajos","w":["XIII. Lajos","XV. Lajos","XVI. Lajos"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Mi volt a merkantilista gazdaságpolitika egyik fő célja?","a":"Az állami bevételek és a kivitel növelése","w":["A vámok teljes eltörlése","A gyarmatok azonnali függetlenítése","A pénzgazdálkodás megszüntetése"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik természetes jogokat hangsúlyozta John Locke?","a":"Az élethez, szabadsághoz és tulajdonhoz való jogot","w":["A hűbérúrnak járó robot jogát","A király korlátlan isteni jogát","A céhek monopóliumának jogát"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik felvilágosodás kori gondolkodó fejtette ki a hatalmi ágak megosztásának elvét?","a":"Montesquieu","w":["Voltaire","Rousseau","Diderot"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik fogalom áll Rousseau A társadalmi szerződés című művének középpontjában?","a":"A népszuverenitás és a közakarat","w":["Az uralkodó isteni joga","A rendi kiváltságok változatlansága","A gyarmati monopólium"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik városban fogadták el 1776-ban az amerikai Függetlenségi nyilatkozatot?","a":"Philadelphiában","w":["Bostonban","New Yorkban","Washingtonban"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Milyen államszerkezetet hozott létre az Egyesült Államok 1787-es alkotmánya?","a":"Szövetségi köztársaságot","w":["Abszolút monarchiát","Városállamok laza vallási szövetségét","Katonai diktatúrát"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik rendi gyűlés összehívása jelezte a francia forradalom kezdetét 1789-ben?","a":"A rendi gyűlésé","w":["A bécsi kongresszusé","A Direktóriumé","A párizsi kommüné"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik erőd-börtönt foglalta el a párizsi nép 1789. július 14-én?","a":"A Bastille-t","w":["A Louvre-t","A Tuileriákat","A Temple-t"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik dokumentum hirdette meg 1789-ben Franciaországban a jogegyenlőség alapelveit?","a":"Az Emberi és polgári jogok nyilatkozata","w":["A Polgári törvénykönyv","A kontinentális zárlat","A Szent Szövetség okirata"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Ki volt a jakobinus diktatúra legismertebb vezetője?","a":"Maximilien Robespierre","w":["Georges Danton kizárólag","Jean-Paul Marat kizárólag","Lafayette márki"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik államcsínnyel ragadta magához Napóleon a hatalmat 1799-ben?","a":"A brumaire 18-i államcsínnyel","w":["A thermidori fordulattal","A júliusi forradalommal","A chartista petícióval"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Mi volt a Code civil?","a":"Napóleon polgári törvénykönyve","w":["A francia hadsereg szolgálati szabályzata","A Szent Szövetség alapokmánya","A brit parlament házszabálya"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik ország gazdaságát akarta megbénítani Napóleon a kontinentális zárlattal?","a":"Nagy-Britanniáét","w":["Oroszországét","Ausztriáét","Spanyolországét"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik évben indította Napóleon oroszországi hadjáratát?","a":"1812-ben","w":["1804-ben","1809-ben","1815-ben"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik 1805-ös győzelmét nevezik Napóleon három császár csatájának?","a":"Az austerlitzi csatát","w":["A waterlooi csatát","A lipcsei csatát","A borogyinói csatát"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Mi volt az 1814–1815-ös bécsi kongresszus egyik fő célja?","a":"A dinasztikus rend és az európai hatalmi egyensúly helyreállítása","w":["A gyarmati rendszer felszámolása","Az általános választójog bevezetése","A Német Császárság azonnali létrehozása"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik országban kezdődött az ipari forradalom?","a":"Nagy-Britanniában","w":["Franciaországban","Oroszországban","Itáliában"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Ki tökéletesítette a gőzgépet a 18. század második felében?","a":"James Watt","w":["George Stephenson","James Hargreaves","Robert Fulton"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Kik írták az 1848-ban megjelent Kommunista kiáltványt?","a":"Karl Marx és Friedrich Engels","w":["Robert Owen és Saint-Simon","Lenin és Trockij","Bakunyin és Proudhon"]},
  {"s":"A polgári átalakulás Magyarországon és Európában","p":"Melyik porosz államférfi irányításával jött létre 1871-ben a Német Császárság?","a":"Otto von Bismarckéval","w":["Klemens von Metternichével","Giuseppe Garibaldiéval","Adolphe Thiers-ével"]},

  {"s":"Oroszország története 1917-ig","p":"Melyik város volt a Kijevi Rusz politikai központja?","a":"Kijev","w":["Moszkva","Novgorod","Szentpétervár"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik dinasztia eredetét vezette vissza az orosz hagyomány Rurik fejedelemhez?","a":"A Rurik-dinasztiáét","w":["A Romanov-dinasztiáét","A Jagelló-dinasztiáét","A Habsburg-dinasztiáét"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik vallást vette fel Vlagyimir kijevi fejedelem 988-ban?","a":"A bizánci kereszténységet","w":["A római katolicizmust","Az iszlámot","A buddhizmust"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik kijevi fejedelem nevéhez kapcsolódik a Ruszka Pravda törvénygyűjteménye?","a":"Bölcs Jaroszlávéhoz","w":["Vlagyimir Monomahéhoz","Alekszandr Nyevszkijéhez","Dmitrij Donszkojéhoz"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik mongol utódállam szedett adót az orosz fejedelemségektől?","a":"Az Arany Horda","w":["A Kazáni Köztársaság","A Szibériai Kormányzóság","A Livóniai Rend"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik orosz fejedelemség vált a központosítás magjává?","a":"A moszkvai fejedelemség","w":["A kijevi fejedelemség","A halicsi fejedelemség","A polocki fejedelemség"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik moszkvai uralkodó idején szűnt meg 1480-ban az Arany Hordának fizetett adó?","a":"III. Iván idején","w":["IV. Iván idején","I. Péter idején","II. Miklós idején"]},
  {"s":"Oroszország története 1917-ig","p":"Ki koronáztatta magát 1547-ben elsőként egész Oroszország cárjává?","a":"IV. Iván","w":["III. Iván","Borisz Godunov","Mihail Romanov"]},
  {"s":"Oroszország története 1917-ig","p":"Mi volt az opricsnyina IV. Iván uralkodása alatt?","a":"A cár külön területe és terrorra is használt külön szervezete","w":["A parasztok választott gyűlése","A pravoszláv egyház zsinata","A szibériai vasút igazgatósága"]},
  {"s":"Oroszország története 1917-ig","p":"Mit nevez az orosz történelem zavaros időszaknak?","a":"A 16–17. század fordulójának dinasztikus és társadalmi válságát","w":["Az 1812-es honvédő háborút","Az 1905-ös forradalmat","Az 1918 utáni hadikommunizmust"]},
  {"s":"Oroszország története 1917-ig","p":"Ki lett az első Romanov-házi cár 1613-ban?","a":"Mihail Romanov","w":["Alekszej Romanov","I. Péter","Borisz Godunov"]},
  {"s":"Oroszország története 1917-ig","p":"Mi volt I. Péter reformjainak egyik fő célja?","a":"Oroszország katonai és állami modernizálása nyugati mintára","w":["A jobbágyság azonnali megszüntetése","A cári hatalom felszámolása","A külkereskedelem betiltása"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik várost alapította I. Péter 1703-ban?","a":"Szentpétervárt","w":["Moszkvát","Odesszát","Vlagyivosztokot"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik állam ellen vívta Oroszország az északi háborút?","a":"Svédország ellen","w":["Poroszország ellen","Oszmán Birodalom ellen kizárólag","Franciaország ellen"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik 1709-es csatában győzte le I. Péter XII. Károly svéd seregét?","a":"Poltavánál","w":["Narvánál","Borogyinónál","Szevasztopolnál"]},
  {"s":"Oroszország története 1917-ig","p":"Mit szabályozott I. Péter rangtáblázata?","a":"Az állami és katonai szolgálati előmenetelt","w":["A jobbágytelkek nagyságát","A kolostorok liturgiáját","A faluközösségek földosztását"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik uralkodónőt sorolják a felvilágosult abszolutizmus orosz képviselői közé?","a":"II. Katalint","w":["I. Erzsébetet","Anna Ivanovnát","Alekszandra Fjodorovnát"]},
  {"s":"Oroszország története 1917-ig","p":"Ki vezette az 1773–1775-ös nagy orosz parasztfelkelést?","a":"Jemeljan Pugacsov","w":["Sztyepan Razin","Alekszandr Radiscsev","Alekszandr Herzen"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik három hatalom vett részt Lengyelország 18. századi felosztásaiban?","a":"Oroszország, Poroszország és Ausztria","w":["Oroszország, Franciaország és Anglia","Poroszország, Svédország és Dánia","Ausztria, Itália és az Oszmán Birodalom"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik hadvezér alkalmazta az orosz fősereg megőrzésére irányuló visszavonuló stratégiát 1812-ben?","a":"Mihail Kutuzov","w":["Alekszandr Szuvorov","Grigorij Potyomkin","Mihail Szkobelev"]},
  {"s":"Oroszország története 1917-ig","p":"Kik indítottak felkelést 1825 decemberében az önkényuralom ellen?","a":"A dekabristák","w":["A narodnyikok","A bolsevikok","A kadetok"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik cár uralmát jellemezte a hivatalos népiesség hármas jelszava: pravoszlávia, önkényuralom, népiség?","a":"I. Miklósét","w":["I. Sándorét","II. Sándorét","III. Sándorét"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik háborúban szenvedett vereséget Oroszország 1853–1856 között?","a":"A krími háborúban","w":["Az orosz–japán háborúban","A kaukázusi háborúban","Az északi háborúban"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik cár rendelte el a jobbágyfelszabadítást 1861-ben?","a":"II. Sándor","w":["I. Miklós","III. Sándor","II. Miklós"]},
  {"s":"Oroszország története 1917-ig","p":"Mik voltak az 1864-től létrehozott zemsztvók?","a":"Helyi önkormányzati testületek","w":["Titkosrendőri egységek","Állami nagyüzemek","Katonai gyarmatok"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik forradalmi szervezet tagjai gyilkolták meg II. Sándor cárt 1881-ben?","a":"A Narodnaja Volja tagjai","w":["A bolsevik párt tagjai","A dekabristák","A feketeszázasok"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik nagy vasútvonal építését kezdték meg 1891-ben?","a":"A transzszibériai vasútét","w":["A Bajkál–Amur fővonalét","A turkesztáni körvasútét","A varsói gyorsvasútét"]},
  {"s":"Oroszország története 1917-ig","p":"Melyik eseményt nevezik véres vasárnapnak az 1905-ös orosz forradalomban?","a":"A békés pétervári tüntetés fegyveres szétverését","w":["A cári család kivégzését","A Potyomkin páncélos elsüllyesztését","A moszkvai duma feloszlatását"]},
  {"s":"Oroszország története 1917-ig","p":"Milyen képviseleti intézmény felállítására kényszerült a cár 1905-ben?","a":"Az Állami Dumáéra","w":["Az Alkotmányozó Nemzetgyűlésére","A Népbiztosok Tanácsára","A Legfelsőbb Szovjetére"]},
  {"s":"Oroszország története 1917-ig","p":"Mi volt Pjotr Sztolipin agrárreformjának egyik célja?","a":"Önálló, módos paraszti gazdaságok kialakítása","w":["Minden föld azonnali államosítása","A kolhozrendszer bevezetése","A jobbágyság visszaállítása"]},

  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik 1917-es forradalom kényszerítette lemondásra II. Miklós cárt?","a":"A februári forradalom","w":["Az októberi forradalom","Az 1905-ös felkelés","A kronstadti lázadás"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Mit jelentett a kettős hatalom Oroszországban 1917 tavaszán?","a":"Az Ideiglenes Kormány és a szovjetek párhuzamos befolyását","w":["Két cár egyidejű uralmát","Oroszország és Németország közös kormányát","A hadsereg és az egyház koalícióját"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik dokumentumban hirdette meg Lenin 1917-ben a minden hatalmat a szovjeteknek jelszavát?","a":"Az áprilisi tézisekben","w":["A Kommunista kiáltványban","A breszt-litovszki békében","A NEP-rendeletben"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik párt élén állt Lenin 1917-ben?","a":"A bolsevik párt élén","w":["A kadet párt élén","Az eszer párt élén","A mensevik párt élén"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"A mai naptár szerint mikor győzött a bolsevik hatalomátvétel Petrográdban?","a":"1917. november 7-én","w":["1917. február 23-án","1918. március 3-án","1922. december 30-án"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik épület elfoglalása lett az októberi forradalom jelképes eseménye?","a":"A Téli Palotáé","w":["A Kremlé","A Tauriai Palotáé","A Szmolnij kolostoré"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik békével lépett ki Szovjet-Oroszország az első világháborúból?","a":"A breszt-litovszki békével","w":["A rigai békével","A versailles-i békével","A rapallói szerződéssel"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik két fő tábor harcolt az orosz polgárháborúban?","a":"A vörösök és a fehérek","w":["A bolsevikok és a német császári hadsereg kizárólag","A cáriak és a franciák","A kozákok és a lengyelek kizárólag"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Mit jelentett a hadikommunizmus gazdaságpolitikája?","a":"Központosítást, államosítást és kényszerű terménybeszolgáltatást","w":["Szabadpiacot és külföldi tőkebeáramlást","A földesúri birtokrendszer visszaállítását","A kolhozok önkéntes feloszlatását"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik gazdaságpolitikát vezette be Lenin 1921-ben részleges piaci engedményekkel?","a":"Az új gazdaságpolitikát, a NEP-et","w":["A hadikommunizmust","Az első ötéves tervet","A peresztrojkát"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik évben alakult meg hivatalosan a Szovjetunió?","a":"1922-ben","w":["1917-ben","1924-ben","1928-ban"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik párttisztség segítette Sztálint hatalmi bázisa kiépítésében?","a":"A párt főtitkári tisztsége","w":["Az Állami Duma elnöksége","A cári miniszterelnökség","A pravoszláv pátriárkai cím"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Mit jelentett a mezőgazdaság kollektivizálása a Szovjetunióban?","a":"A paraszti gazdaságok erőszakos közös gazdaságokba terelését","w":["A földek magántulajdonának megerősítését","A jobbágyrendszer visszaállítását","A mezőgazdasági adók eltörlését"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Mi volt a kolhoz?","a":"Kollektív mezőgazdasági üzem","w":["Állami nehézipari tröszt","Politikai fogolytábor","Városi munkástanács"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Mi volt a sztálini ötéves tervek elsődleges gazdasági célja?","a":"A gyorsított iparosítás, különösen a nehézipar fejlesztése","w":["A magánkereskedelem teljes szabaddá tétele","A könnyűipar kizárólagos fejlesztése","A katonai kiadások megszüntetése"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Kiket bélyegzett a sztálini rendszer kuláknak?","a":"A módosabbnak minősített parasztokat","w":["A városi gyári munkásokat","A hivatásos katonatiszteket","A külföldi diplomatákat"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik munkás nevéről kapta nevét a szovjet munkaverseny egyik legismertebb mozgalma?","a":"Alekszej Sztahanovéról","w":["Szergej Kirovéról","Georgij Zsukovéról","Mihail Kalinyinéról"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik nemzetközi szervezetet hozták létre 1919-ben Moszkvában a kommunista pártok összefogására?","a":"A Kommunista Internacionálét, vagyis a Kominternt","w":["A Népszövetséget","A Varsói Szerződést","A Kölcsönös Gazdasági Segítség Tanácsát"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik program szolgálta Szovjet-Oroszország átfogó villamosítását?","a":"A GOELRO-terv","w":["A Dawes-terv","A Marshall-terv","A Schlieffen-terv"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Mit tartalmazott az 1939-es Molotov–Ribbentrop-paktum titkos jegyzőkönyve?","a":"Kelet-Európa német és szovjet érdekszférákra osztását","w":["A Németország elleni közös haditervet","A Szovjetunió belépését a Népszövetségbe","A lengyel–szovjet katonai szövetséget"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Mi volt a Barbarossa-hadművelet?","a":"Németország 1941-es támadása a Szovjetunió ellen","w":["A szovjet támadás Finnország ellen","A normandiai szövetséges partraszállás","Berlin szovjet ostroma"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Meddig tartott Leningrád német blokádja hozzávetőleg?","a":"Közel 900 napig","w":["Hat hétig","Pontosan száz napig","Öt évig"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik 1941 végi csata állította meg a német előrenyomulást a szovjet fővárosnál?","a":"A moszkvai csata","w":["A kurszki csata","A kijevi csata","A berlini csata"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik csata zárult a német 6. hadsereg kapitulációjával 1943 februárjában?","a":"A sztálingrádi csata","w":["A leningrádi csata","A szmolenszki csata","A harkovi csata"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik 1943-as ütközetet tartják a történelem egyik legnagyobb páncéloscsatájának?","a":"A kurszki csatát","w":["A moszkvai csatát","A szevasztopoli csatát","A varsói csatát"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik hadsereg foglalta el Berlint 1945 májusában?","a":"A szovjet Vörös Hadsereg","w":["Az amerikai hadsereg","A brit hadsereg","A francia hadsereg"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik békeszerződés rendezte Németország helyzetét az első világháború után?","a":"A versailles-i békeszerződés","w":["A saint-germaini békeszerződés","A trianoni békeszerződés","A sèvres-i békeszerződés"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik nemzetközi szervezetet hozták létre az első világháború után a béke fenntartására?","a":"A Népszövetséget","w":["Az Egyesült Nemzetek Szervezetét","A Varsói Szerződést","Az Európa Tanácsot"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik országban jutott először hatalomra fasiszta mozgalom?","a":"Olaszországban","w":["Németországban","Spanyolországban","Portugáliában"]},
  {"s":"Forradalmak, Szovjetunió és a világháborúk","p":"Melyik fajelméleti fogalom állt a náci ideológia középpontjában?","a":"Az árja felsőbbrendűség hamis tana","w":["A népek teljes jogegyenlősége","A vallási türelem elve","A gyarmatok önrendelkezése"]},

  {"s":"Magyarország és a világ 1918 után","p":"Melyik támadással kezdődött meg a második világháború Európában 1939. szeptember 1-jén?","a":"Németország Lengyelország elleni támadásával","w":["Japán Pearl Harbor elleni támadásával","Olaszország Etiópia elleni támadásával","A Szovjetunió Finnország elleni támadásával"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mit jelent a holokauszt fogalma?","a":"Az európai zsidóság és más üldözött csoportok náci Németország által végrehajtott tervszerű üldözését és tömeges meggyilkolását","w":["A második világháború valamennyi katonai veszteségét","A német városok szövetséges bombázását","A Szovjetunió elleni német hadjárat katonai fedőnevét"]},
  {"s":"Magyarország és a világ 1918 után","p":"Melyik forradalom győzött Budapesten 1918. október 31-én?","a":"Az őszirózsás forradalom","w":["A polgári demokratikus forradalom 1848-ban","A Tanácsköztársaság forradalma","Az 1956-os forradalom"]},
  {"s":"Magyarország és a világ 1918 után","p":"Ki lett az őszirózsás forradalom után Magyarország miniszterelnöke, majd köztársasági elnöke?","a":"Károlyi Mihály","w":["Jászi Oszkár","Garami Ernő","Kun Béla"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor kiáltották ki az első Magyar Népköztársaságot?","a":"1918. november 16-án","w":["1919. március 21-én","1920. március 1-jén","1946. február 1-jén"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor kiáltották ki a Magyarországi Tanácsköztársaságot?","a":"1919. március 21-én","w":["1918. október 31-én","1919. augusztus 1-jén","1920. június 4-én"]},
  {"s":"Magyarország és a világ 1918 után","p":"Ki volt a Tanácsköztársaság külügyi népbiztosa és legismertebb politikai vezetője?","a":"Kun Béla","w":["Landler Jenő","Böhm Vilmos","Garbai Sándor"]},
  {"s":"Magyarország és a világ 1918 után","p":"Milyen államfői tisztséget töltött be Horthy Miklós 1920 és 1944 között?","a":"Kormányzó volt","w":["Király volt","Köztársasági elnök volt","Miniszterelnök volt mindvégig"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor írták alá a trianoni békeszerződést?","a":"1920. június 4-én","w":["1918. november 3-án","1919. március 21-én","1921. november 6-án"]},
  {"s":"Magyarország és a világ 1918 után","p":"Ki volt a húszas évek politikai és gazdasági konszolidációjának meghatározó miniszterelnöke?","a":"Bethlen István","w":["Teleki Pál","Gömbös Gyula","Kállay Miklós"]},
  {"s":"Magyarország és a világ 1918 után","p":"Melyik pénznemet vezették be Magyarországon 1927-ben a korona helyett?","a":"A pengőt","w":["A forintot","A koronát új címletekkel","A dinárt"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mely területek kerültek vissza Magyarországhoz az első, illetve a második bécsi döntéssel?","a":"A Felvidék déli része, illetve Észak-Erdély","w":["Kárpátalja, illetve a Bánság egésze","Burgenland, illetve Horvátország","Dél-Erdély, illetve a Székelyföld nélküli Partium"]},
  {"s":"Magyarország és a világ 1918 után","p":"Melyik állam ellen lépett hadba Magyarország 1941. június 27-én?","a":"A Szovjetunió ellen","w":["Nagy-Britannia ellen","Az Egyesült Államok ellen","Románia ellen"]},
  {"s":"Magyarország és a világ 1918 után","p":"Hol szenvedett katasztrofális vereséget a 2. magyar hadsereg 1943 januárjában?","a":"A Don-kanyarnál","w":["Sztálingrádnál","A Krím félszigeten","Varsónál"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor szállta meg a német hadsereg Magyarországot?","a":"1944. március 19-én","w":["1941. június 27-én","1944. október 15-én","1945. február 13-án"]},
  {"s":"Magyarország és a világ 1918 után","p":"Ki került hatalomra a nyilas puccsal 1944 októberében?","a":"Szálasi Ferenc","w":["Bárdossy László","Sztójay Döme","Imrédy Béla"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor deportálták a magyar hatóságok német irányítással a vidéki magyar zsidóság nagy részét Auschwitz-Birkenauba?","a":"1944 tavaszán és nyarán","w":["1938 őszén","1941 telén","1945 őszén"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor ért véget Budapest ostroma?","a":"1945. február 13-án","w":["1944. március 19-én","1944. december 24-én","1945. május 9-én"]},
  {"s":"Magyarország és a világ 1918 után","p":"Melyik 1945-ös intézkedés számolta fel a nagybirtokrendszer jelentős részét?","a":"A földreform","w":["A hároméves terv","A bankok államosítása","A beszolgáltatási rendszer"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor kiáltották ki a második Magyar Köztársaságot?","a":"1946. február 1-jén","w":["1945. április 4-én","1947. augusztus 31-én","1949. augusztus 20-án"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor vezették be a forintot a hiperinflációtól elértéktelenedett pengő helyett?","a":"1946. augusztus 1-jén","w":["1945. január 1-jén","1947. január 1-jén","1949. augusztus 20-án"]},
  {"s":"Magyarország és a világ 1918 után","p":"Melyik választást nevezték el a visszaélésekben használt szavazócédulákról kékcédulás választásnak?","a":"Az 1947-es országgyűlési választást","w":["Az 1945-ös nemzetgyűlési választást","Az 1949-es egypárti választást","Az 1953-as tanácsválasztást"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mi jellemezte az 1948–1949-es kommunista hatalomátvétel gazdasági oldalát?","a":"Az államosítások és a központi tervgazdaság kiépítése","w":["A nagybirtokrendszer visszaállítása","A teljes szabadpiac bevezetése","Az állami ipar privatizációja"]},
  {"s":"Magyarország és a világ 1918 után","p":"Milyen államformát rögzített az 1949. augusztus 20-án hatályba lépett alkotmány?","a":"A Magyar Népköztársaságot","w":["A Magyar Királyságot","A Magyar Szövetségi Köztársaságot","A Magyar Tanácsköztársaságot"]},
  {"s":"Magyarország és a világ 1918 után","p":"Melyik politikus nevéhez kötik az ötvenes évek eleji személyi kultuszt és diktatúrát Magyarországon?","a":"Rákosi Mátyáséhoz","w":["Gerő Ernőéhez kizárólag","Nagy Imrééhez","Kádár Jánoséhoz"]},
  {"s":"Magyarország és a világ 1918 után","p":"Melyik miniszterelnök hirdetett új szakaszt 1953-ban, enyhítve a korábbi gazdaságpolitikán és terroron?","a":"Nagy Imre","w":["Rákosi Mátyás","Gerő Ernő","Hegedüs András"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor kezdődött az 1956-os magyar forradalom?","a":"1956. október 23-án","w":["1956. október 6-án","1956. november 4-én","1958. június 16-án"]},
  {"s":"Magyarország és a világ 1918 után","p":"Mikor indult meg a forradalmat leverő általános szovjet támadás?","a":"1956. november 4-én","w":["1956. október 23-án","1956. október 28-án","1957. május 1-jén"]},
  {"s":"Magyarország és a világ 1918 után","p":"Hogyan nevezte az 1956-os forradalmat a Kádár-korszak hivatalos tananyaga?","a":"Ellenforradalomnak","w":["Polgári forradalomnak","Nemzeti szabadságharcnak","Békés rendszerváltásnak"]},
  {"s":"Magyarország és a világ 1918 után","p":"Melyik évben vezették be Magyarországon az új gazdasági mechanizmust?","a":"1968-ban","w":["1957-ben","1963-ban","1972-ben"]}
]
$questions$::jsonb) with ordinality as question(item, ordinality);

do $validation$
begin
  if (
    select count(*)
    from public.quiz_questions
    where category_id = 'textbook_history'
      and is_active
  ) <> 300 then
    raise exception 'Tankönyvi történelem must contain exactly 300 active questions';
  end if;
end;
$validation$;

comment on table public.textbook_history_quiz_results is
  'Source-of-truth results for the Hungarian Tankönyvi történelem category.';
comment on column public.quiz_questions.subject is
  'Optional curriculum chapter label; populated for Tankönyvi történelem and fifth-grader questions.';

commit;
