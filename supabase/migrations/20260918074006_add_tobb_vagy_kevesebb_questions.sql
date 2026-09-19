-- Több vagy kevesebb?: 250 new questions, taking it to 250.
--
-- Two fixed choices, so there is no option length to give the answer away.
-- Split: 128 Több to 122 Kevesebb, so the answer is never the safer guess.

insert into public.quiz_questions (
  id,
  category_id,
  prompt,
  correct_answer,
  wrong_answers,
  explanation,
  language_code,
  grade_level,
  subject,
  display_order,
  is_active
)
select
  'tobb_' || lpad(question.ordinality::text, 4, '0'),
  'tobb_vagy_kevesebb',
  question.item ->> 'p',
  question.item ->> 'a',
  array(select jsonb_array_elements_text(question.item -> 'w')),
  question.item ->> 'e',
  'hu',
  null,
  question.item ->> 's',
  (
    select coalesce(max(existing.display_order), 0)
    from public.quiz_questions as existing
    where existing.category_id = 'tobb_vagy_kevesebb'
  ) + question.ordinality::integer,
  true
from jsonb_array_elements($questions$
[
  {"a": "Több", "e": "A százéves háború valójában 116 évig tartott, 1337-től 1453-ig.", "p": "A százéves háború hossza — több vagy kevesebb, mint 100 év?", "s": "Háborúk és csaták", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A második világháború hat évig tartott, 1939-től 1945-ig.", "p": "A második világháború hossza — több vagy kevesebb, mint 8 év?", "s": "Háborúk és csaták", "w": ["Több"]},
  {"a": "Több", "e": "Az első világháború négy évnél is tovább tartott, 1914-től 1918-ig.", "p": "Az első világháború hossza — több vagy kevesebb, mint 3 év?", "s": "Háborúk és csaták", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A mohácsi csata alig két óra alatt eldőlt 1526-ban.", "p": "A mohácsi csata hossza — több vagy kevesebb, mint 5 óra?", "s": "Háborúk és csaták", "w": ["Több"]},
  {"a": "Több", "e": "A szabadságharc csaknem másfél évig tartott, 1848 márciusától 1849 augusztusáig.", "p": "Az 1848–49-es szabadságharc hossza — több vagy kevesebb, mint 1 év?", "s": "Háborúk és csaták", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az egri vár ostroma nagyjából öt hétig, mintegy 39 napig tartott.", "p": "Az egri vár 1552-es ostroma — több vagy kevesebb, mint 100 nap?", "s": "Háborúk és csaták", "w": ["Több"]},
  {"a": "Több", "e": "A török hódoltság nagyjából 150 évig tartott, Buda 1541-es elestétől 1686-ig.", "p": "A török hódoltság hossza Magyarországon — több vagy kevesebb, mint 100 év?", "s": "Háborúk és csaták", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A napóleoni háborúk tizenkét évig, 1803-tól 1815-ig tartottak.", "p": "A napóleoni háborúk hossza — több vagy kevesebb, mint 20 év?", "s": "Háborúk és csaták", "w": ["Több"]},
  {"a": "Több", "e": "Ferenc József 68 évig uralkodott, 1848-tól 1916-ig.", "p": "Ferenc József uralkodása — több vagy kevesebb, mint 50 év?", "s": "Uralkodók", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az amerikai polgárháború négy évig tartott, 1861-től 1865-ig.", "p": "Az amerikai polgárháború hossza — több vagy kevesebb, mint 10 év?", "s": "Háborúk és csaták", "w": ["Több"]},
  {"a": "Több", "e": "Mátyás 32 éven át uralkodott, 1458-tól 1490-ig.", "p": "Mátyás király uralkodása — több vagy kevesebb, mint 20 év?", "s": "Uralkodók", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Szent István 38 évig volt Magyarország királya, 1000-től 1038-ig.", "p": "Szent István uralkodása — több vagy kevesebb, mint 50 év?", "s": "Uralkodók", "w": ["Több"]},
  {"a": "Több", "e": "XIV. Lajos 72 évig uralkodott, tovább, mint bármely más európai király.", "p": "XIV. Lajos francia király uralkodása — több vagy kevesebb, mint 50 év?", "s": "Uralkodók", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Viktória királynő 63 évig uralkodott, 1837-től 1901-ig.", "p": "Viktória királynő uralkodása — több vagy kevesebb, mint 80 év?", "s": "Uralkodók", "w": ["Több"]},
  {"a": "Több", "e": "II. Erzsébet 70 évig uralkodott, 1952-től 2022-ig.", "p": "II. Erzsébet királynő uralkodása — több vagy kevesebb, mint 60 év?", "s": "Uralkodók", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Tutanhamon körülbelül kilenc évig uralkodott, és nagyon fiatalon halt meg.", "p": "Tutanhamon uralkodása — több vagy kevesebb, mint 30 év?", "s": "Uralkodók", "w": ["Több"]},
  {"a": "Több", "e": "Nagy Lajos 40 évig uralkodott Magyarországon, 1342-től 1382-ig.", "p": "Nagy Lajos király uralkodása — több vagy kevesebb, mint 25 év?", "s": "Uralkodók", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Napóleon nagyjából tíz évig volt francia császár, 1804-től 1814-ig.", "p": "Napóleon császársága — több vagy kevesebb, mint 25 év?", "s": "Uralkodók", "w": ["Több"]},
  {"a": "Több", "e": "A Colosseum i. sz. 80-ban készült el, tehát csaknem 2000 éves.", "p": "A Colosseum kora — több vagy kevesebb, mint 1000 év?", "s": "Épületek kora", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Szabadság-szobrot 1886-ban avatták fel New Yorkban.", "p": "A Szabadság-szobor kora — több vagy kevesebb, mint 200 év?", "s": "Épületek kora", "w": ["Több"]},
  {"a": "Több", "e": "A Nagy Piramis körülbelül 4500 éves.", "p": "A gízai Nagy Piramis kora — több vagy kevesebb, mint 3000 év?", "s": "Épületek kora", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Halászbástya csak 1902-ben készült el, bár középkorinak látszik.", "p": "A Halászbástya kora — több vagy kevesebb, mint 500 év?", "s": "Épületek kora", "w": ["Több"]},
  {"a": "Több", "e": "Az Eiffel-torony 1889-ben készült el, több mint 130 éve.", "p": "Az Eiffel-torony kora — több vagy kevesebb, mint 100 év?", "s": "Épületek kora", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Stonehenge köveit nagyjából 4500 éve állították fel.", "p": "A Stonehenge kora — több vagy kevesebb, mint 10 000 év?", "s": "Épületek kora", "w": ["Több"]},
  {"a": "Több", "e": "A Lánchíd 1849-ben nyílt meg, több mint 175 éve.", "p": "A budapesti Lánchíd kora — több vagy kevesebb, mint 100 év?", "s": "Épületek kora", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az Empire State Building 1931-ben készült el.", "p": "Az Empire State Building kora — több vagy kevesebb, mint 150 év?", "s": "Épületek kora", "w": ["Több"]},
  {"a": "Több", "e": "A pisai torony építése 1173-ban kezdődött, tehát több mint 800 éve.", "p": "A pisai ferde torony kora — több vagy kevesebb, mint 300 év?", "s": "Épületek kora", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az Eiffel-torony alig több mint két év alatt épült fel.", "p": "Az Eiffel-torony építésének ideje — több vagy kevesebb, mint 10 év?", "s": "Építkezések", "w": ["Több"]},
  {"a": "Több", "e": "A kölni dóm építése több mint 600 évig húzódott, 1248-tól 1880-ig.", "p": "A kölni dóm építésének ideje — több vagy kevesebb, mint 300 év?", "s": "Építkezések", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Szuezi-csatorna tíz év alatt készült el, 1859 és 1869 között.", "p": "A Szuezi-csatorna építésének ideje — több vagy kevesebb, mint 30 év?", "s": "Építkezések", "w": ["Több"]},
  {"a": "Több", "e": "A budapesti Országház építése csaknem húsz évig tartott.", "p": "Az Országház építésének ideje — több vagy kevesebb, mint 5 év?", "s": "Építkezések", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Michelangelo négy év alatt festette meg a mennyezetet.", "p": "A Sixtus-kápolna mennyezetének megfestése — több vagy kevesebb, mint 10 év?", "s": "Építkezések", "w": ["Több"]},
  {"a": "Több", "e": "A Szent Péter-bazilika építése 120 évig tartott, 1506-tól 1626-ig.", "p": "A Szent Péter-bazilika építésének ideje — több vagy kevesebb, mint 50 év?", "s": "Építkezések", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Taj Mahal körülbelül húsz év alatt épült fel.", "p": "A Taj Mahal építésének ideje — több vagy kevesebb, mint 50 év?", "s": "Építkezések", "w": ["Több"]},
  {"a": "Több", "e": "A Notre-Dame építése közel 200 évig tartott.", "p": "A párizsi Notre-Dame építésének ideje — több vagy kevesebb, mint 50 év?", "s": "Építkezések", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A honfoglalás 895 körül volt, tehát nagyjából 1130 éve.", "p": "A honfoglalás óta eltelt idő — több vagy kevesebb, mint 1500 év?", "s": "Hány éve történt", "w": ["Több"]},
  {"a": "Több", "e": "A Lánchíd építése tíz évig tartott, 1839-től 1849-ig.", "p": "A Lánchíd építésének ideje — több vagy kevesebb, mint 3 év?", "s": "Építkezések", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A francia forradalom 1789-ben tört ki, alig több mint 230 éve.", "p": "A francia forradalom óta eltelt idő — több vagy kevesebb, mint 300 év?", "s": "Hány éve történt", "w": ["Több"]},
  {"a": "Több", "e": "A mohácsi csata 1526-ban volt, csaknem 500 éve.", "p": "A mohácsi csata óta eltelt idő — több vagy kevesebb, mint 400 év?", "s": "Hány éve történt", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az első holdra szállás 1969-ben volt.", "p": "Az első holdra szállás óta eltelt idő — több vagy kevesebb, mint 100 év?", "s": "Hány éve történt", "w": ["Több"]},
  {"a": "Több", "e": "Kolumbusz 1492-ben ért Amerikába, több mint 500 éve.", "p": "Amerika felfedezése óta eltelt idő — több vagy kevesebb, mint 400 év?", "s": "Hány éve történt", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Gutenberg az 1450-es években kezdte el a könyvnyomtatást.", "p": "A könyvnyomtatás feltalálása óta eltelt idő — több vagy kevesebb, mint 1000 év?", "s": "Hány éve történt", "w": ["Több"]},
  {"a": "Több", "e": "Az első újkori olimpiát 1896-ban rendezték Athénban.", "p": "Az első újkori olimpia óta eltelt idő — több vagy kevesebb, mint 100 év?", "s": "Hány éve történt", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Wright fivérek 1903-ban repültek először.", "p": "A Wright fivérek első repülése óta eltelt idő — több vagy kevesebb, mint 200 év?", "s": "Hány éve történt", "w": ["Több"]},
  {"a": "Több", "e": "A Nyugatrómai Birodalom 476-ban bukott el, több mint 1500 éve.", "p": "A Római Birodalom bukása óta eltelt idő — több vagy kevesebb, mint 1000 év?", "s": "Hány éve történt", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Egy átlagos tyúktojás nagyjából 60 gramm.", "p": "Egy tyúktojás súlya — több vagy kevesebb, mint 100 gramm?", "s": "Hétköznapi tárgyak", "w": ["Több"]},
  {"a": "Több", "e": "Egy átlagos személyautó másfél tonna körül van.", "p": "Egy átlagos személyautó súlya — több vagy kevesebb, mint 500 kilogramm?", "s": "Hétköznapi tárgyak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az utasszállítók általában 10-11 kilométer magasan repülnek.", "p": "Egy utasszállító repülőgép utazómagassága — több vagy kevesebb, mint 30 kilométer?", "s": "Hétköznapi tárgyak", "w": ["Több"]},
  {"a": "Több", "e": "Egy utasszállító repülőgép nagyjából 900 km/óra sebességgel halad.", "p": "Egy utasszállító repülőgép sebessége — több vagy kevesebb, mint 500 km/óra?", "s": "Hétköznapi tárgyak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Egy liter víz körülbelül egy kilogramm.", "p": "Egy liter víz súlya — több vagy kevesebb, mint 2 kilogramm?", "s": "Hétköznapi tárgyak", "w": ["Több"]},
  {"a": "Több", "e": "A szabványos nyomtáv 1435 milliméter.", "p": "A szabványos vasúti nyomtáv — több vagy kevesebb, mint 1 méter?", "s": "Hétköznapi tárgyak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az A4-es lap 21-szer 29,7 centiméteres.", "p": "Egy A4-es papírlap hosszabbik oldala — több vagy kevesebb, mint 50 centiméter?", "s": "Hétköznapi tárgyak", "w": ["Több"]},
  {"a": "Több", "e": "Egy hordó kőolaj 159 liter.", "p": "Egy hordó kőolaj mennyisége — több vagy kevesebb, mint 100 liter?", "s": "Hétköznapi tárgyak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Egy hét 168 órából áll.", "p": "Egy hét órái — több vagy kevesebb, mint 200 óra?", "s": "Idő és számok", "w": ["Több"]},
  {"a": "Több", "e": "Egy mérföld 1609 méter.", "p": "Egy mérföld hossza — több vagy kevesebb, mint 1000 méter?", "s": "Hétköznapi tárgyak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A tanóra Magyarországon 45 perces.", "p": "Egy magyar iskolai tanóra hossza — több vagy kevesebb, mint 1 óra?", "s": "Idő és számok", "w": ["Több"]},
  {"a": "Több", "e": "Egy nap 1440 percből áll.", "p": "Egy nap percei — több vagy kevesebb, mint 1000 perc?", "s": "Idő és számok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Tíz év körülbelül 3650 napból áll.", "p": "Egy évtized napjai — több vagy kevesebb, mint 5000 nap?", "s": "Idő és számok", "w": ["Több"]},
  {"a": "Több", "e": "Egy év körülbelül 8760 óra.", "p": "Egy év órái — több vagy kevesebb, mint 5000 óra?", "s": "Idő és számok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A sakktáblán 64 mező van.", "p": "A sakktábla mezőinek száma — több vagy kevesebb, mint 100?", "s": "Idő és számok", "w": ["Több"]},
  {"a": "Több", "e": "Száz év 1200 hónapból áll.", "p": "Egy évszázad hónapjai — több vagy kevesebb, mint 1000 hónap?", "s": "Idő és számok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A magyar kártya 32 lapból áll.", "p": "A magyar kártyapakli lapjainak száma — több vagy kevesebb, mint 50?", "s": "Idő és számok", "w": ["Több"]},
  {"a": "Több", "e": "A maraton 42 kilométer 195 méter hosszú.", "p": "A maratoni futás távja — több vagy kevesebb, mint 30 kilométer?", "s": "Idő és számok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Budapesten körülbelül 1,7 millió ember él.", "p": "Budapest lakossága — több vagy kevesebb, mint 3 millió?", "s": "Népesség", "w": ["Több"]},
  {"a": "Több", "e": "Magyarország lakossága körülbelül 9,6 millió.", "p": "Magyarország lakossága — több vagy kevesebb, mint 5 millió?", "s": "Népesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Debrecennek körülbelül 200 ezer lakosa van.", "p": "Debrecen lakossága — több vagy kevesebb, mint 500 ezer?", "s": "Népesség", "w": ["Több"]},
  {"a": "Több", "e": "Szegeden körülbelül 160 ezer ember él.", "p": "Szeged lakossága — több vagy kevesebb, mint 50 ezer?", "s": "Népesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Pécsnek körülbelül 140 ezer lakosa van.", "p": "Pécs lakossága — több vagy kevesebb, mint 500 ezer?", "s": "Népesség", "w": ["Több"]},
  {"a": "Több", "e": "Nyíregyházán körülbelül 115 ezer ember él.", "p": "Nyíregyháza lakossága — több vagy kevesebb, mint 50 ezer?", "s": "Népesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Sopronnak körülbelül 60 ezer lakosa van.", "p": "Sopron lakossága — több vagy kevesebb, mint 200 ezer?", "s": "Népesség", "w": ["Több"]},
  {"a": "Több", "e": "Magyarországon több mint 3100 település van.", "p": "Magyarország településeinek száma — több vagy kevesebb, mint 1000?", "s": "Népesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Budapestnek 23 kerülete van.", "p": "Budapest kerületeinek száma — több vagy kevesebb, mint 50?", "s": "Városok és megyék", "w": ["Több"]},
  {"a": "Több", "e": "Magyarországon több mint 300 városi rangú település van.", "p": "Magyarország városainak száma — több vagy kevesebb, mint 100?", "s": "Népesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Budapest területe körülbelül 525 négyzetkilométer.", "p": "Budapest területe — több vagy kevesebb, mint 1000 négyzetkilométer?", "s": "Városok és megyék", "w": ["Több"]},
  {"a": "Több", "e": "Az országnak 19 megyéje van, Budapest mellett.", "p": "Magyarország megyéinek száma — több vagy kevesebb, mint 10?", "s": "Városok és megyék", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Kecskemétnek körülbelül 110 ezer lakosa van.", "p": "Kecskemét lakossága — több vagy kevesebb, mint 500 ezer?", "s": "Városok és megyék", "w": ["Több"]},
  {"a": "Több", "e": "Az ország területe körülbelül 93 ezer négyzetkilométer.", "p": "Magyarország területe — több vagy kevesebb, mint 50 ezer négyzetkilométer?", "s": "Városok és megyék", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Nyolc magyar helyszín szerepel a világörökségi listán.", "p": "Magyarország világörökségi helyszíneinek száma — több vagy kevesebb, mint 20?", "s": "Városok és megyék", "w": ["Több"]},
  {"a": "Több", "e": "Bács-Kiskun a legnagyobb megye, körülbelül 8400 négyzetkilométer.", "p": "Bács-Kiskun megye területe — több vagy kevesebb, mint 1000 négyzetkilométer?", "s": "Városok és megyék", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A tó területe körülbelül 594 négyzetkilométer.", "p": "A Balaton területe — több vagy kevesebb, mint 1000 négyzetkilométer?", "s": "Folyók és tavak", "w": ["Több"]},
  {"a": "Több", "e": "Hét ország határos Magyarországgal.", "p": "Magyarország szomszédos országainak száma — több vagy kevesebb, mint 5?", "s": "Városok és megyék", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Balaton átlagosan csak körülbelül 3 méter mély.", "p": "A Balaton átlagos mélysége — több vagy kevesebb, mint 10 méter?", "s": "Folyók és tavak", "w": ["Több"]},
  {"a": "Több", "e": "Tíz nemzeti park van az országban.", "p": "Magyarország nemzeti parkjainak száma — több vagy kevesebb, mint 3?", "s": "Városok és megyék", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Velencei-tó körülbelül 26 négyzetkilométer.", "p": "A Velencei-tó területe — több vagy kevesebb, mint 100 négyzetkilométer?", "s": "Folyók és tavak", "w": ["Több"]},
  {"a": "Több", "e": "A Balaton körülbelül 77 kilométer hosszú.", "p": "A Balaton hossza — több vagy kevesebb, mint 50 kilométer?", "s": "Folyók és tavak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A folyó magyar szakasza 417 kilométer.", "p": "A Duna magyarországi szakasza — több vagy kevesebb, mint 1000 kilométer?", "s": "Folyók és tavak", "w": ["Több"]},
  {"a": "Több", "e": "A Duna körülbelül 2850 kilométer hosszú.", "p": "A Duna teljes hossza — több vagy kevesebb, mint 1000 kilométer?", "s": "Folyók és tavak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az ország legmagasabb pontja 1014 méter.", "p": "A Kékes magassága — több vagy kevesebb, mint 2000 méter?", "s": "Természet és tájak", "w": ["Több"]},
  {"a": "Több", "e": "A Tisza körülbelül 960 kilométer hosszú.", "p": "A Tisza teljes hossza — több vagy kevesebb, mint 500 kilométer?", "s": "Folyók és tavak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A legalacsonyabb pont Gyálarétnél 76 méter magasan van.", "p": "Magyarország legalacsonyabb pontja — több vagy kevesebb, mint 200 méter?", "s": "Természet és tájak", "w": ["Több"]},
  {"a": "Több", "e": "A Duna tíz országon folyik keresztül.", "p": "A Duna által érintett országok száma — több vagy kevesebb, mint 5?", "s": "Folyók és tavak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Gellért-hegy 235 méter magas.", "p": "A Gellért-hegy magassága — több vagy kevesebb, mint 500 méter?", "s": "Természet és tájak", "w": ["Több"]},
  {"a": "Több", "e": "A tó vize télen sem hűl 22 fok alá.", "p": "A Hévízi-tó vizének hőmérséklete télen — több vagy kevesebb, mint 20 fok?", "s": "Folyók és tavak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az ország körülbelül ötöde erdő.", "p": "Magyarország erdővel borított része — több vagy kevesebb, mint 50 százalék?", "s": "Természet és tájak", "w": ["Több"]},
  {"a": "Több", "e": "A Dobogókő körülbelül 700 méter magas.", "p": "A Dobogókő magassága — több vagy kevesebb, mint 500 méter?", "s": "Természet és tájak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A kupola 96 méter magas.", "p": "Az Országház magassága — több vagy kevesebb, mint 200 méter?", "s": "Várak és épületek", "w": ["Több"]},
  {"a": "Több", "e": "A Hortobágy körülbelül 800 négyzetkilométer.", "p": "A Hortobágyi Nemzeti Park területe — több vagy kevesebb, mint 100 négyzetkilométer?", "s": "Természet és tájak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az ország legnagyobb temploma körülbelül 100 méter magas.", "p": "Az esztergomi bazilika magassága — több vagy kevesebb, mint 200 méter?", "s": "Várak és épületek", "w": ["Több"]},
  {"a": "Több", "e": "A barlangrendszer több mint 20 kilométer hosszú.", "p": "A Baradla-barlang hossza — több vagy kevesebb, mint 5 kilométer?", "s": "Természet és tájak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az oszlop 36 méter magas, a tetején Gábriel arkangyallal.", "p": "A Hősök terén álló emlékoszlop magassága — több vagy kevesebb, mint 100 méter?", "s": "Várak és épületek", "w": ["Több"]},
  {"a": "Több", "e": "A Tisza-tó körülbelül 127 négyzetkilométer.", "p": "A Tisza-tó területe — több vagy kevesebb, mint 50 négyzetkilométer?", "s": "Természet és tájak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Körülbelül kétezren védték a várat.", "p": "Az egri vár védőinek száma 1552-ben — több vagy kevesebb, mint 10 ezer?", "s": "Várak és épületek", "w": ["Több"]},
  {"a": "Több", "e": "Huszonkét borvidék van az országban.", "p": "Magyarország borvidékeinek száma — több vagy kevesebb, mint 5?", "s": "Természet és tájak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A fürdőben körülbelül húsz medence van.", "p": "A Széchenyi fürdő medencéinek száma — több vagy kevesebb, mint 50?", "s": "Várak és épületek", "w": ["Több"]},
  {"a": "Több", "e": "Az Országház 268 méter hosszú.", "p": "Az Országház hossza — több vagy kevesebb, mint 100 méter?", "s": "Várak és épületek", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Budapesten négy metróvonal jár.", "p": "A budapesti metróvonalak száma — több vagy kevesebb, mint 10?", "s": "Budapest", "w": ["Több"]},
  {"a": "Több", "e": "Az épületben 691 helyiség van.", "p": "Az Országház helyiségeinek száma — több vagy kevesebb, mint 100?", "s": "Várak és épületek", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A négy vonal együtt körülbelül 40 kilométer.", "p": "A budapesti metró teljes hossza — több vagy kevesebb, mint 100 kilométer?", "s": "Budapest", "w": ["Több"]},
  {"a": "Több", "e": "A bazilika 96 méter magas, akárcsak az Országház.", "p": "A Szent István-bazilika magassága — több vagy kevesebb, mint 50 méter?", "s": "Várak és épületek", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A sziget körülbelül 2,5 kilométer hosszú.", "p": "A Margit-sziget hossza — több vagy kevesebb, mint 10 kilométer?", "s": "Budapest", "w": ["Több"]},
  {"a": "Több", "e": "Hét torony áll ott, a hét honfoglaló törzs emlékére.", "p": "A Halászbástya tornyainak száma — több vagy kevesebb, mint 3?", "s": "Várak és épületek", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az Andrássy út körülbelül 2,5 kilométer hosszú.", "p": "Az Andrássy út hossza — több vagy kevesebb, mint 10 kilométer?", "s": "Budapest", "w": ["Több"]},
  {"a": "Több", "e": "Az 1-es metrónak 11 megállója van.", "p": "A kisföldalatti megállóinak száma — több vagy kevesebb, mint 5?", "s": "Budapest", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az ország első vasútvonala 1846-ban nyílt meg, 33 kilométeren.", "p": "A Pest–Vác vasútvonal hossza — több vagy kevesebb, mint 100 kilométer?", "s": "Közlekedés", "w": ["Több"]},
  {"a": "Több", "e": "Körülbelül tíz híd ível át a Dunán a városban.", "p": "A budapesti Duna-hidak száma — több vagy kevesebb, mint 3?", "s": "Budapest", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Szeged körülbelül 170 kilométerre van Budapesttől.", "p": "Budapest és Szeged távolsága — több vagy kevesebb, mint 500 kilométer?", "s": "Közlekedés", "w": ["Több"]},
  {"a": "Több", "e": "A Lánchíd körülbelül 375 méter hosszú.", "p": "A Lánchíd hossza — több vagy kevesebb, mint 100 méter?", "s": "Budapest", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Miskolc körülbelül 180 kilométerre van Budapesttől.", "p": "Budapest és Miskolc távolsága — több vagy kevesebb, mint 500 kilométer?", "s": "Közlekedés", "w": ["Több"]},
  {"a": "Több", "e": "A város alatt több mint száz hévízforrás fakad.", "p": "Budapest hévízforrásainak száma — több vagy kevesebb, mint 10?", "s": "Budapest", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Gyermekvasút körülbelül 12 kilométer hosszú.", "p": "A budapesti Gyermekvasút hossza — több vagy kevesebb, mint 50 kilométer?", "s": "Közlekedés", "w": ["Több"]},
  {"a": "Több", "e": "A villamoshálózat több mint 100 kilométer hosszú.", "p": "A budapesti villamoshálózat hossza — több vagy kevesebb, mint 10 kilométer?", "s": "Budapest", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A sikló pályája mindössze 95 méter.", "p": "A budavári sikló hossza — több vagy kevesebb, mint 1 kilométer?", "s": "Közlekedés", "w": ["Több"]},
  {"a": "Több", "e": "A hálózat körülbelül 7000 kilométer hosszú.", "p": "A magyar vasúthálózat hossza — több vagy kevesebb, mint 1000 kilométer?", "s": "Közlekedés", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A felnőtt emberi testben 206 csont van.", "p": "A felnőtt ember csontjainak száma — több vagy kevesebb, mint 300?", "s": "Emberi test", "w": ["Több"]},
  {"a": "Több", "e": "Több mint 1500 kilométer autópálya épült meg.", "p": "A magyar autópályák hossza — több vagy kevesebb, mint 500 kilométer?", "s": "Közlekedés", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A felnőttnek 32 foga van, a bölcsességfogakkal együtt.", "p": "A felnőtt ember fogainak száma — több vagy kevesebb, mint 50?", "s": "Emberi test", "w": ["Több"]},
  {"a": "Több", "e": "A két város körülbelül 230 kilométerre van egymástól.", "p": "Budapest és Debrecen távolsága — több vagy kevesebb, mint 100 kilométer?", "s": "Közlekedés", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A felnőtt emberben körülbelül 5 liter vér van.", "p": "A felnőtt ember vérének mennyisége — több vagy kevesebb, mint 20 liter?", "s": "Emberi test", "w": ["Több"]},
  {"a": "Több", "e": "A tó körüli kerékpárút körülbelül 200 kilométer.", "p": "A Balatoni Bringakör hossza — több vagy kevesebb, mint 50 kilométer?", "s": "Közlekedés", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az emberi agy körülbelül 1,4 kilogramm.", "p": "Az emberi agy súlya — több vagy kevesebb, mint 5 kilogramm?", "s": "Emberi test", "w": ["Több"]},
  {"a": "Több", "e": "A szív naponta körülbelül 100 ezret dobban.", "p": "A szív dobbanásai egy nap alatt — több vagy kevesebb, mint 10 ezer?", "s": "Emberi test", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az emberi gerincet 33 csigolya alkotja.", "p": "Az emberi gerinc csigolyáinak száma — több vagy kevesebb, mint 50?", "s": "Emberi test", "w": ["Több"]},
  {"a": "Több", "e": "Az emberi testben több mint 600 vázizom van.", "p": "Az emberi test izmainak száma — több vagy kevesebb, mint 100?", "s": "Emberi test", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Percenként körülbelül 15-20-szor pislogunk.", "p": "A pislogások száma egy perc alatt — több vagy kevesebb, mint 100?", "s": "Emberi test", "w": ["Több"]},
  {"a": "Több", "e": "A vékonybél körülbelül 6 méter hosszú.", "p": "Az ember vékonybelének hossza — több vagy kevesebb, mint 2 méter?", "s": "Emberi test", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A strucctojás körülbelül 1,5 kilogramm.", "p": "A strucctojás súlya — több vagy kevesebb, mint 5 kilogramm?", "s": "Állatok teste", "w": ["Több"]},
  {"a": "Több", "e": "Az újszülöttnek körülbelül 300 csontja van, ezek később összenőnek.", "p": "Az újszülött csontjainak száma — több vagy kevesebb, mint 200?", "s": "Emberi test", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A legtöbb kolibri csak néhány grammot nyom.", "p": "A kolibri súlya — több vagy kevesebb, mint 100 gramm?", "s": "Állatok teste", "w": ["Több"]},
  {"a": "Több", "e": "Egy ember fején körülbelül 100 ezer hajszál van.", "p": "A hajszálak száma egy ember fején — több vagy kevesebb, mint 10 ezer?", "s": "Emberi test", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A házi macska általában 4-5 kilogramm.", "p": "A házi macska súlya — több vagy kevesebb, mint 10 kilogramm?", "s": "Állatok teste", "w": ["Több"]},
  {"a": "Több", "e": "A kék bálna akár 30 méter hosszú is lehet.", "p": "A kék bálna hossza — több vagy kevesebb, mint 10 méter?", "s": "Állatok teste", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A zsiráfnak hét nyakcsigolyája van, ugyanannyi, mint az embernek.", "p": "A zsiráf nyakcsigolyáinak száma — több vagy kevesebb, mint 10?", "s": "Állatok teste", "w": ["Több"]},
  {"a": "Több", "e": "A kék bálna súlya elérheti a 150 tonnát.", "p": "A kék bálna súlya — több vagy kevesebb, mint 50 tonna?", "s": "Állatok teste", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A kék bálna szíve percenként csak néhányszor dobban.", "p": "A kék bálna szívdobbanásai egy perc alatt — több vagy kevesebb, mint 100?", "s": "Állatok teste", "w": ["Több"]},
  {"a": "Több", "e": "A felnőtt afrikai elefánt akár 6 tonna is lehet.", "p": "Az afrikai elefánt súlya — több vagy kevesebb, mint 1 tonna?", "s": "Állatok teste", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A tehén gyomra négy részből áll.", "p": "A tehén gyomrának rekeszei — több vagy kevesebb, mint 10?", "s": "Állatok teste", "w": ["Több"]},
  {"a": "Több", "e": "A zsiráf körülbelül 5 méter magas.", "p": "A zsiráf magassága — több vagy kevesebb, mint 3 méter?", "s": "Állatok teste", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A házi egér általában 1-3 évig él.", "p": "A házi egér élettartama — több vagy kevesebb, mint 10 év?", "s": "Élettartam", "w": ["Több"]},
  {"a": "Több", "e": "A polipnak három szíve van.", "p": "A polip szíveinek száma — több vagy kevesebb, mint 2?", "s": "Állatok teste", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A nyári munkásméh körülbelül hat hétig él.", "p": "A munkásméh élete nyáron — több vagy kevesebb, mint 1 év?", "s": "Élettartam", "w": ["Több"]},
  {"a": "Több", "e": "Az elefánt 60-70 évig is élhet.", "p": "Az elefánt élettartama — több vagy kevesebb, mint 20 év?", "s": "Élettartam", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A tiszavirág felnőttként csak néhány órát él.", "p": "A tiszavirág felnőtt élete — több vagy kevesebb, mint 1 hét?", "s": "Élettartam", "w": ["Több"]},
  {"a": "Több", "e": "Az óriásteknős több mint 100 évig is élhet.", "p": "Az óriásteknős élettartama — több vagy kevesebb, mint 50 év?", "s": "Élettartam", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A kutyák általában 10-13 évig élnek.", "p": "A kutya élettartama — több vagy kevesebb, mint 30 év?", "s": "Élettartam", "w": ["Több"]},
  {"a": "Több", "e": "A ló általában 25-30 évig él.", "p": "A ló élettartama — több vagy kevesebb, mint 10 év?", "s": "Élettartam", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A csiga óránként csak néhány métert tesz meg.", "p": "A csiga sebessége — több vagy kevesebb, mint 10 km/óra?", "s": "Sebesség", "w": ["Több"]},
  {"a": "Több", "e": "A méhkirálynő több évig is élhet, míg a munkásméh csak hetekig.", "p": "A méhkirálynő élete — több vagy kevesebb, mint 1 év?", "s": "Élettartam", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A lajhár a földön percenként alig néhány métert halad.", "p": "A lajhár sebessége a földön — több vagy kevesebb, mint 10 km/óra?", "s": "Sebesség", "w": ["Több"]},
  {"a": "Több", "e": "A csimpánz a természetben körülbelül 40 évig él.", "p": "A csimpánz élettartama a természetben — több vagy kevesebb, mint 10 év?", "s": "Élettartam", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A leggyorsabb futó csúcssebessége 45 km/óra körül van.", "p": "A leggyorsabb ember futása — több vagy kevesebb, mint 60 km/óra?", "s": "Sebesség", "w": ["Több"]},
  {"a": "Több", "e": "Az elefánt vemhessége körülbelül 22 hónap.", "p": "Az elefánt vemhessége — több vagy kevesebb, mint 1 év?", "s": "Élettartam", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A postagalamb körülbelül 80 km/órával repül.", "p": "A postagalamb repülése — több vagy kevesebb, mint 200 km/óra?", "s": "Sebesség", "w": ["Több"]},
  {"a": "Több", "e": "A gepárd akár 110 km/órával is futhat.", "p": "A gepárd sebessége — több vagy kevesebb, mint 50 km/óra?", "s": "Sebesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A delfin körülbelül 35-40 km/órával úszik.", "p": "A delfin úszása — több vagy kevesebb, mint 60 km/óra?", "s": "Sebesség", "w": ["Több"]},
  {"a": "Több", "e": "A vándorsólyom zuhanás közben 300 km/óránál is gyorsabb.", "p": "A vándorsólyom zuhanó repülése — több vagy kevesebb, mint 200 km/óra?", "s": "Sebesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A méhnek, mint minden rovarnak, hat lába van.", "p": "A méh lábainak száma — több vagy kevesebb, mint 8?", "s": "Rovarok és madarak", "w": ["Több"]},
  {"a": "Több", "e": "A strucc körülbelül 70 km/órával fut.", "p": "A strucc futása — több vagy kevesebb, mint 30 km/óra?", "s": "Sebesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A pókoknak nyolc lábuk van.", "p": "A pók lábainak száma — több vagy kevesebb, mint 10?", "s": "Rovarok és madarak", "w": ["Több"]},
  {"a": "Több", "e": "A házi légy másodpercenként körülbelül 200-at csap a szárnyával.", "p": "A házi légy szárnycsapásai egy másodperc alatt — több vagy kevesebb, mint 50?", "s": "Sebesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A kolibri tojása egy grammnál is könnyebb.", "p": "A kolibri tojásának súlya — több vagy kevesebb, mint 10 gramm?", "s": "Rovarok és madarak", "w": ["Több"]},
  {"a": "Több", "e": "A kolibri másodpercenként 50-80-szor csapkod a szárnyával.", "p": "A kolibri szárnycsapásai egy másodperc alatt — több vagy kevesebb, mint 10?", "s": "Sebesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A tyúktojásból 21 nap alatt kel ki a csibe.", "p": "A tyúktojás kikelésének ideje — több vagy kevesebb, mint 40 nap?", "s": "Rovarok és madarak", "w": ["Több"]},
  {"a": "Több", "e": "Egy erős méhcsaládban nyáron 40-60 ezer méh él.", "p": "A méhek száma egy kaptárban nyáron — több vagy kevesebb, mint 1000?", "s": "Rovarok és madarak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A bagoly a fejét körülbelül 270 fokban tudja elfordítani.", "p": "A bagoly fejfordítása — több vagy kevesebb, mint 360 fok?", "s": "Rovarok és madarak", "w": ["Több"]},
  {"a": "Több", "e": "A füsti fecske akár 10 ezer kilométert is repül a telelőhelyéig.", "p": "A fecske útja Afrikáig — több vagy kevesebb, mint 1000 kilométer?", "s": "Rovarok és madarak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A napraforgó általában 2-3 méter magas.", "p": "A napraforgó magassága — több vagy kevesebb, mint 10 méter?", "s": "Növények és fák", "w": ["Több"]},
  {"a": "Több", "e": "A sarki csér évente több tízezer kilométert repül.", "p": "A sarki csér évi vonulása — több vagy kevesebb, mint 10 ezer kilométer?", "s": "Rovarok és madarak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A fa törzsében évente egy évgyűrű keletkezik.", "p": "A fa évgyűrűinek száma egy év alatt — több vagy kevesebb, mint 2?", "s": "Növények és fák", "w": ["Több"]},
  {"a": "Több", "e": "A szúnyog másodpercenként több százszor csap a szárnyával.", "p": "A szúnyog szárnycsapásai egy másodperc alatt — több vagy kevesebb, mint 50?", "s": "Rovarok és madarak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Egy kókuszdió általában másfél kilogramm körüli.", "p": "Egy kókuszdió súlya — több vagy kevesebb, mint 10 kilogramm?", "s": "Növények és fák", "w": ["Több"]},
  {"a": "Több", "e": "A méhnek öt szeme van: két összetett és három egyszerű.", "p": "A méh szemeinek száma — több vagy kevesebb, mint 2?", "s": "Rovarok és madarak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A tulipán általában 30-60 centiméter magas.", "p": "A tulipán magassága — több vagy kevesebb, mint 1 méter?", "s": "Növények és fák", "w": ["Több"]},
  {"a": "Több", "e": "Egy jó tojó tyúk évente 250-300 tojást tojik.", "p": "Egy tyúk tojásai egy évben — több vagy kevesebb, mint 100?", "s": "Rovarok és madarak", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Európa legmagasabb hegye 5642 méter magas.", "p": "Az Elbrusz magassága — több vagy kevesebb, mint 7000 méter?", "s": "hegyek", "w": ["Több"]},
  {"a": "Több", "e": "A legmagasabb ismert fa több mint 115 méter magas.", "p": "A világ legmagasabb fája — több vagy kevesebb, mint 50 méter?", "s": "Növények és fák", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A híres tűzhányó csak 1281 méter magas.", "p": "A Vezúv magassága — több vagy kevesebb, mint 2000 méter?", "s": "hegyek", "w": ["Több"]},
  {"a": "Több", "e": "A tölgy több száz évig is élhet.", "p": "A tölgyfa élettartama — több vagy kevesebb, mint 100 év?", "s": "Növények és fák", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Denali 6190 méter magas, ez Észak-Amerika legmagasabb hegye.", "p": "Az észak-amerikai Denali magassága — több vagy kevesebb, mint 8000 méter?", "s": "hegyek", "w": ["Több"]},
  {"a": "Több", "e": "A leggyorsabban növő bambusz naponta akár 90 centimétert is nő.", "p": "A bambusz növekedése egy nap alatt — több vagy kevesebb, mint 10 centiméter?", "s": "Növények és fák", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Matterhorn 4478 méter magas.", "p": "A Matterhorn magassága — több vagy kevesebb, mint 6000 méter?", "s": "hegyek", "w": ["Több"]},
  {"a": "Több", "e": "A legidősebb óriás mamutfenyők több mint kétezer évesek.", "p": "A legidősebb óriás mamutfenyők kora — több vagy kevesebb, mint 1000 év?", "s": "Növények és fák", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az Amazonas körülbelül 6400 kilométer hosszú.", "p": "Az Amazonas hossza — több vagy kevesebb, mint 10 000 kilométer?", "s": "folyók", "w": ["Több"]},
  {"a": "Több", "e": "A rafflézia virága akár egy méter átmérőjű is lehet.", "p": "A rafflézia virágának átmérője — több vagy kevesebb, mint 10 centiméter?", "s": "Növények és fák", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Európa leghosszabb folyója 3530 kilométer hosszú.", "p": "A Volga hossza — több vagy kevesebb, mint 5000 kilométer?", "s": "folyók", "w": ["Több"]},
  {"a": "Több", "e": "A kókuszpálma 20-30 méter magasra is megnő.", "p": "A kókuszpálma magassága — több vagy kevesebb, mint 5 méter?", "s": "Növények és fák", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Rajna körülbelül 1230 kilométer hosszú.", "p": "A Rajna hossza — több vagy kevesebb, mint 2000 kilométer?", "s": "folyók", "w": ["Több"]},
  {"a": "Több", "e": "A Mount Everest 8849 méter magas, ez a Föld legmagasabb hegye.", "p": "A Mount Everest magassága — több vagy kevesebb, mint 7000 méter?", "s": "hegyek", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Temze mindössze 346 kilométer hosszú.", "p": "A Temze hossza — több vagy kevesebb, mint 1000 kilométer?", "s": "folyók", "w": ["Több"]},
  {"a": "Több", "e": "A Mont Blanc 4808 méter magas.", "p": "A Mont Blanc magassága — több vagy kevesebb, mint 4000 méter?", "s": "hegyek", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Balti-tenger átlagosan csak 55 méter mély.", "p": "A Balti-tenger átlagos mélysége — több vagy kevesebb, mint 200 méter?", "s": "tengerek és óceánok", "w": ["Több"]},
  {"a": "Több", "e": "A Kilimandzsáró csúcsa 5895 méter magasan van.", "p": "A Kilimandzsáró magassága — több vagy kevesebb, mint 5000 méter?", "s": "hegyek", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Föld felszínének csak körülbelül 29 százaléka szárazföld.", "p": "A Föld felszínének szárazföldi része — több vagy kevesebb, mint 50 százalék?", "s": "tengerek és óceánok", "w": ["Több"]},
  {"a": "Több", "e": "A Fudzsi 3776 méter magas.", "p": "A Fudzsi magassága — több vagy kevesebb, mint 3000 méter?", "s": "hegyek", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Panama-csatorna 82 kilométer hosszú.", "p": "A Panama-csatorna hossza — több vagy kevesebb, mint 200 kilométer?", "s": "tengerek és óceánok", "w": ["Több"]},
  {"a": "Több", "e": "A Nílus körülbelül 6650 kilométer hosszú.", "p": "A Nílus hossza — több vagy kevesebb, mint 5000 kilométer?", "s": "folyók", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Szuezi-csatorna körülbelül 193 kilométer hosszú.", "p": "A Szuezi-csatorna hossza — több vagy kevesebb, mint 500 kilométer?", "s": "tengerek és óceánok", "w": ["Több"]},
  {"a": "Több", "e": "Ázsia leghosszabb folyója körülbelül 6300 kilométer hosszú.", "p": "A Jangce hossza — több vagy kevesebb, mint 4000 kilométer?", "s": "folyók", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Ausztrália területe körülbelül 7,7 millió négyzetkilométer.", "p": "Ausztrália területe — több vagy kevesebb, mint 10 millió négyzetkilométer?", "s": "országok területe", "w": ["Több"]},
  {"a": "Több", "e": "A Szajna 777 kilométer hosszú.", "p": "A Szajna hossza — több vagy kevesebb, mint 500 kilométer?", "s": "folyók", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Franciaország európai területe körülbelül 550 ezer négyzetkilométer.", "p": "Franciaország területe — több vagy kevesebb, mint 1 millió négyzetkilométer?", "s": "országok területe", "w": ["Több"]},
  {"a": "Több", "e": "A Mississippi körülbelül 3770 kilométer hosszú.", "p": "A Mississippi hossza — több vagy kevesebb, mint 3000 kilométer?", "s": "folyók", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Japán területe körülbelül 378 ezer négyzetkilométer.", "p": "Japán területe — több vagy kevesebb, mint 1 millió négyzetkilométer?", "s": "országok területe", "w": ["Több"]},
  {"a": "Több", "e": "A Mariana-árok legmélyebb pontja csaknem 11 000 méter.", "p": "A Mariana-árok mélysége — több vagy kevesebb, mint 5000 méter?", "s": "tengerek és óceánok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Monaco területe mindössze 2 négyzetkilométer.", "p": "Monaco területe — több vagy kevesebb, mint 10 négyzetkilométer?", "s": "országok területe", "w": ["Több"]},
  {"a": "Több", "e": "Az óceánok átlagosan körülbelül 3700 méter mélyek.", "p": "Az óceánok átlagos mélysége — több vagy kevesebb, mint 1000 méter?", "s": "tengerek és óceánok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az Egyesült Államokban körülbelül 340 millióan élnek.", "p": "Az Egyesült Államok népessége — több vagy kevesebb, mint 500 millió?", "s": "népesség", "w": ["Több"]},
  {"a": "Több", "e": "A Bajkál-tó 1642 méter mély, ez a világ legmélyebb tava.", "p": "A Bajkál-tó mélysége — több vagy kevesebb, mint 1000 méter?", "s": "tengerek és óceánok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Kanadában csak körülbelül 41 millióan élnek, pedig az ország hatalmas.", "p": "Kanada népessége — több vagy kevesebb, mint 100 millió?", "s": "népesség", "w": ["Több"]},
  {"a": "Több", "e": "A Holt-tenger vizének körülbelül 34 százaléka só, a tengervízé csak 3,5 százalék.", "p": "A Holt-tenger sótartalma — több vagy kevesebb, mint 10 százalék?", "s": "tengerek és óceánok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Ausztráliában körülbelül 27 millióan élnek.", "p": "Ausztrália népessége — több vagy kevesebb, mint 50 millió?", "s": "népesség", "w": ["Több"]},
  {"a": "Több", "e": "Oroszország területe több mint 17 millió négyzetkilométer.", "p": "Oroszország területe — több vagy kevesebb, mint 10 millió négyzetkilométer?", "s": "országok területe", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Izlandon körülbelül 390 ezren élnek.", "p": "Izland népessége — több vagy kevesebb, mint 1 millió?", "s": "népesség", "w": ["Több"]},
  {"a": "Több", "e": "Kanada területe csaknem 10 millió négyzetkilométer.", "p": "Kanada területe — több vagy kevesebb, mint 5 millió négyzetkilométer?", "s": "országok területe", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A két főváros légvonalban körülbelül 215 kilométerre van egymástól.", "p": "Budapest és Bécs távolsága — több vagy kevesebb, mint 500 kilométer?", "s": "távolságok", "w": ["Több"]},
  {"a": "Több", "e": "Kína területe körülbelül 9,6 millió négyzetkilométer.", "p": "Kína területe — több vagy kevesebb, mint 5 millió négyzetkilométer?", "s": "országok területe", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A két várost légvonalban körülbelül 340 kilométer választja el.", "p": "London és Párizs távolsága — több vagy kevesebb, mint 1000 kilométer?", "s": "távolságok", "w": ["Több"]},
  {"a": "Több", "e": "Izland területe körülbelül 103 ezer négyzetkilométer.", "p": "Izland területe — több vagy kevesebb, mint 50 ezer négyzetkilométer?", "s": "országok területe", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A két főváros légvonalban körülbelül 1050 kilométerre van egymástól.", "p": "Párizs és Madrid távolsága — több vagy kevesebb, mint 2000 kilométer?", "s": "távolságok", "w": ["Több"]},
  {"a": "Több", "e": "A Földön ma több mint 8 milliárd ember él.", "p": "A Föld népessége — több vagy kevesebb, mint 5 milliárd?", "s": "népesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Vatikánban körülbelül 800-an élnek.", "p": "A Vatikán lakossága — több vagy kevesebb, mint 5000 fő?", "s": "távolságok", "w": ["Több"]},
  {"a": "Több", "e": "Indiában körülbelül 1,4 milliárd ember él.", "p": "India népessége — több vagy kevesebb, mint 1 milliárd?", "s": "népesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Madagaszkár területe körülbelül 587 ezer négyzetkilométer.", "p": "Madagaszkár területe — több vagy kevesebb, mint 1 millió négyzetkilométer?", "s": "szigetek és sivatagok", "w": ["Több"]},
  {"a": "Több", "e": "Afrikában körülbelül 1,5 milliárd ember él.", "p": "Afrika népessége — több vagy kevesebb, mint 1 milliárd?", "s": "népesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Görögországnak körülbelül 200 lakott szigete van, de a szigetek száma sokkal több.", "p": "Görögország lakott szigeteinek száma — több vagy kevesebb, mint 1000?", "s": "szigetek és sivatagok", "w": ["Több"]},
  {"a": "Több", "e": "Japánban körülbelül 123 millióan élnek.", "p": "Japán népessége — több vagy kevesebb, mint 100 millió?", "s": "népesség", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A Góbi körülbelül 1,3 millió négyzetkilométer.", "p": "A Góbi sivatag területe — több vagy kevesebb, mint 5 millió négyzetkilométer?", "s": "szigetek és sivatagok", "w": ["Több"]},
  {"a": "Több", "e": "A két várost légvonalban körülbelül 5570 kilométer választja el.", "p": "New York és London távolsága — több vagy kevesebb, mint 3000 kilométer?", "s": "távolságok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Nagy-Britannia szigete körülbelül 209 ezer négyzetkilométer.", "p": "Nagy-Britannia területe — több vagy kevesebb, mint 500 ezer négyzetkilométer?", "s": "szigetek és sivatagok", "w": ["Több"]},
  {"a": "Több", "e": "Tokió légvonalban körülbelül 9000 kilométerre van Budapesttől.", "p": "Budapest és Tokió távolsága — több vagy kevesebb, mint 5000 kilométer?", "s": "távolságok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "Az Eiffel-torony 330 méter magas.", "p": "Az Eiffel-torony magassága — több vagy kevesebb, mint 500 méter?", "s": "híres épületek", "w": ["Több"]},
  {"a": "Több", "e": "A két várost több mint 2000 kilométer választja el.", "p": "Sydney és Auckland távolsága — több vagy kevesebb, mint 1000 kilométer?", "s": "távolságok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A pisai torony körülbelül 57 méter magas.", "p": "A pisai ferde torony magassága — több vagy kevesebb, mint 100 méter?", "s": "híres épületek", "w": ["Több"]},
  {"a": "Több", "e": "A Moszkva és Vlagyivosztok közötti vonal 9289 kilométer hosszú.", "p": "A transzszibériai vasút hossza — több vagy kevesebb, mint 5000 kilométer?", "s": "távolságok", "w": ["Kevesebb"]},
  {"a": "Kevesebb", "e": "A szobor a talapzattal együtt 93 méter magas.", "p": "A Szabadság-szobor magassága talapzattal — több vagy kevesebb, mint 200 méter?", "s": "híres épületek", "w": ["Több"]},
  {"a": "Több", "e": "Grönland több mint 2 millió négyzetkilométer, ez a világ legnagyobb szigete.", "p": "Grönland területe — több vagy kevesebb, mint 1 millió négyzetkilométer?", "s": "szigetek és sivatagok", "w": ["Kevesebb"]},
  {"a": "Több", "e": "Indonézia körülbelül 17 ezer szigetből áll.", "p": "Indonézia szigeteinek száma — több vagy kevesebb, mint 5000?", "s": "szigetek és sivatagok", "w": ["Kevesebb"]},
  {"a": "Több", "e": "A Szahara körülbelül 9 millió négyzetkilométer.", "p": "A Szahara területe — több vagy kevesebb, mint 5 millió négyzetkilométer?", "s": "szigetek és sivatagok", "w": ["Kevesebb"]},
  {"a": "Több", "e": "Az Antarktiszt borító jég átlagosan körülbelül 2000 méter vastag.", "p": "Az antarktiszi jég átlagos vastagsága — több vagy kevesebb, mint 1000 méter?", "s": "szigetek és sivatagok", "w": ["Kevesebb"]},
  {"a": "Több", "e": "A dubaji Burdzs Kalifa 828 méter magas.", "p": "A Burdzs Kalifa magassága — több vagy kevesebb, mint 500 méter?", "s": "híres épületek", "w": ["Kevesebb"]},
  {"a": "Több", "e": "A Nagy Piramis ma 139 méter magas, eredetileg 147 méter volt.", "p": "A gízai Nagy Piramis magassága — több vagy kevesebb, mint 100 méter?", "s": "híres épületek", "w": ["Kevesebb"]}
]
$questions$::jsonb)
  with ordinality as question(item, ordinality);

do $validation$
begin
  if (
    select count(*) from public.quiz_questions
    where category_id = 'tobb_vagy_kevesebb' and is_active
  ) <> 250 then
    raise exception 'Több vagy kevesebb? must contain exactly 250 active questions';
  end if;

  if exists (
    select 1
    from public.quiz_questions as question
    where question.category_id = 'tobb_vagy_kevesebb'
      and (
        cardinality(question.wrong_answers) <> 1
        or (
          select count(distinct lower(trim(answer)))
          from unnest(question.wrong_answers) as answer
        ) <> 1
        or exists (
          select 1
          from unnest(question.wrong_answers) as answer
          where lower(trim(answer)) = lower(trim(question.correct_answer))
        )
      )
  ) then
    raise exception 'Több vagy kevesebb?: every question needs 1 distinct wrong answer(s)';
  end if;

  -- Scoped to the rows this migration inserts. The unscoped form also fires on
  -- a duplicate that was already in the bank -- "What was the Hanseatic League?"
  -- sits in both History and Time Traveler and has since August -- which says
  -- nothing about whether this batch is clean.
  if exists (
    select 1
    from public.quiz_questions as proposed
    join public.quiz_questions as existing
      on lower(trim(existing.prompt)) = lower(trim(proposed.prompt))
     and existing.id <> proposed.id
    where proposed.id like 'tobb\_%'
  ) then
    raise exception 'Több vagy kevesebb?: a new prompt is already used by another question';
  end if;

  -- A lopsided split turns the category into a coin she can call.
  if (
    select abs(
      count(*) filter (where correct_answer = 'Több')::numeric
        / nullif(count(*), 0) - 0.5
    )
    from public.quiz_questions
    where category_id = 'tobb_vagy_kevesebb' and is_active
  ) > 0.08 then
    raise exception 'Több vagy kevesebb?: Több and Kevesebb must stay near an even split';
  end if;
end;
$validation$;
