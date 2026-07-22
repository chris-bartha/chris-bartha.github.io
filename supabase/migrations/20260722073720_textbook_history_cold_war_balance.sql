-- Rebalance the first Tankönyvi történelem bank so its endpoint matches the
-- late-1970s and early-1980s curriculum encountered by the target age group.

begin;
set local statement_timeout = '10s';

with replacements (id, subject, prompt, correct_answer, wrong_answers) as (
  values
    (
      'textbook_0024',
      'A második világháború utáni világ',
      'Ki hirdette ki 1949. október 1-jén a Kínai Népköztársaság megalakulását?',
      'Mao Ce-tung',
      array['Csang Kaj-sek', 'Teng Hsziao-ping', 'Csou En-laj']::text[]
    ),
    (
      'textbook_0078',
      'A második világháború utáni világ',
      'Melyik évben kezdték meg a berlini fal felépítését?',
      '1961-ben',
      array['1948-ban', '1953-ban', '1968-ban']::text[]
    ),
    (
      'textbook_0080',
      'A második világháború utáni világ',
      'Mi váltotta ki közvetlenül az 1962-es kubai rakétaválságot?',
      'Szovjet atomrakéták kubai telepítése',
      array['A berlini fal felépítése', 'A Disznó-öböl amerikai megszállása', 'Kuba belépése a Varsói Szerződésbe']::text[]
    ),
    (
      'textbook_0187',
      'A két világháború közötti világ',
      'Melyik országra hárította a versailles-i békeszerződés a háborús felelősség fő terhét?',
      'Németországra',
      array['Olaszországra', 'Oroszországra', 'Belgiumra']::text[]
    ),
    (
      'textbook_0191',
      'A két világháború közötti világ',
      'Melyik nagyhatalom nem lett tagja saját elnöke kezdeményezése ellenére a Népszövetségnek?',
      'Az Egyesült Államok',
      array['Nagy-Britannia', 'Franciaország', 'Olaszország']::text[]
    ),
    (
      'textbook_0192',
      'A két világháború közötti világ',
      'Melyik 1922-es akció nyitotta meg Mussolini útját az olasz kormányfői hatalomhoz?',
      'A római menetelés',
      array['A sörpuccs', 'A hosszú kések éjszakája', 'A feketeingesek abesszíniai hadjárata']::text[]
    ),
    (
      'textbook_0194',
      'A két világháború közötti világ',
      'Melyik tisztségre nevezte ki Hindenburg Adolf Hitlert 1933. január 30-án?',
      'Birodalmi kancellárrá',
      array['Birodalmi elnökké', 'A hadsereg főparancsnokává', 'Porosz királlyá']::text[]
    ),
    (
      'textbook_0214',
      'A második világháború utáni világ',
      'Ki volt az 1968-as prágai tavasz emberarcú szocializmust hirdető vezetője?',
      'Alexander Dubček',
      array['Gustáv Husák', 'Antonín Novotný', 'Ludvík Svoboda']::text[]
    ),
    (
      'textbook_0226',
      'A második világháború utáni világ',
      'Melyik 1975-ös okmány lett az európai enyhülés és az emberi jogi vállalások fontos dokumentuma?',
      'A helsinki záróokmány',
      array['A potsdami nyilatkozat', 'A római szerződés', 'A genfi fegyverszünet']::text[]
    ),
    (
      'textbook_0267',
      'A második világháború utáni világ',
      'Melyik nemzetközi szervezet alapokmányát írták alá 1945-ben San Franciscóban?',
      'Az Egyesült Nemzetek Szervezetéét',
      array['A Népszövetségét', 'A NATO-ét', 'Az Európa Tanácsét']::text[]
    ),
    (
      'textbook_0268',
      'A második világháború utáni világ',
      'Milyen szövetségként hozták létre 1949-ben a NATO-t?',
      'Nyugati kollektív védelmi szövetségként',
      array['Keleti gazdasági együttműködésként', 'Semleges államok mozgalmaként', 'Világméretű kereskedelmi szervezetként']::text[]
    ),
    (
      'textbook_0269',
      'A második világháború utáni világ',
      'Mi volt az 1949-ben létrehozott KGST fő feladata?',
      'A szocialista országok gazdasági együttműködésének szervezése',
      array['A tagállamok közös katonai vezetése', 'A nyugat-európai integráció irányítása', 'Az ENSZ békefenntartó erőinek vezetése']::text[]
    ),
    (
      'textbook_0270',
      'A második világháború utáni világ',
      'Milyen szervezetként jött létre 1955-ben a Varsói Szerződés?',
      'A Szovjetunió vezette katonai szövetségként',
      array['Nyugat-európai vámunióként', 'Világméretű békemozgalomként', 'Semleges államok diplomáciai fórumaként']::text[]
    )
)
update public.quiz_questions as question
set
  subject = replacement.subject,
  prompt = replacement.prompt,
  correct_answer = replacement.correct_answer,
  wrong_answers = replacement.wrong_answers
from replacements as replacement
where question.id = replacement.id
  and question.category_id = 'textbook_history';

do $validation$
begin
  if (
    select count(*)
    from public.quiz_questions
    where category_id = 'textbook_history'
      and is_active
  ) <> 300 then
    raise exception 'Tankönyvi történelem must still contain exactly 300 active questions';
  end if;

  if (
    select count(*)
    from public.quiz_questions
    where category_id = 'textbook_history'
      and subject in (
        'A két világháború közötti világ',
        'A második világháború utáni világ'
      )
  ) <> 13 then
    raise exception 'All 13 interwar and Cold War replacements must be present';
  end if;
end;
$validation$;

commit;
