-- The crime corner's first load: 8 stories and 93 videos.
--
-- Stories are written for reading at 22px and up: 900 to 1400 words, short
-- paragraphs, plain prose, no markdown. Two drafts were thrown away because
-- separate writers landed on the same two cases.
--
-- Every video id below returned 200 from https://www.youtube.com/oembed, and the
-- title and channel stored are YouTube's own, not a writer's recollection. A
-- hallucinated eleven-character id looks exactly like a real one and would leave
-- her tapping a dead link with no way to tell why.

insert into public.crime_stories (
  id, title, teaser, body, year_label, place, closing, minutes, display_order
) values
  ('crime_ezer_frank_a_harisny_ban', 'Ezer frank a harisnyában', 'Egy hágai bankpénztárnál bukott le a terv, amelyet egy herceg eszelt ki, és amelyről fél Európa beszélt.', 'A hágai bank pénztáránál csendes délelőtt volt. Egy jól öltözött, katonás tartású úr lépett az ablakhoz, és ezerfrankos bankjegyeket tett a pultra. Udvarias volt, nem sietett, és nem tűnt fel senkinek. A fiatal tisztviselő mégis megállt egy pillanatra, mert a papír tapintása nem az volt, amit a keze megszokott.

Szólt a főnökének, a főnöke pedig a rendőrségnek. Mire a rendőrök megérkeztek, az úr már idegesen matatott a ruhája alatt. A jelentés szerint további ezerfrankosokat próbált a harisnyájába gyömöszölni. Ez a jelenet adta később a magyar sajtóban az egész ügy becenevét: pénz a harisnyában.

Az ügynek egy mozzanata már itt is furcsa volt. Aki csak egy-két bankjegyet akar beváltani, az nem hoz magával többet, mint amennyit elbír. Ez az ember viszont annyi bankjegyet hozott, hogy már a rejtegetésükkel is gondja támadt. Nem közönséges csalónak tűnt, hanem olyasvalakinek, aki egy nagyobb terv szerint dolgozik.

Az urat Jankovich Arisztidnek hívták. Nyugalmazott huszártiszt volt, magyar állampolgár, és futárigazolvány lapult a zsebében. A táskájában nem egy-két gyanús bankjegy volt, hanem hamis frank, milliós értékben. 1925. december 14-én ezzel a hollandiai lebukással kezdődött Magyarország egyik legnagyobb közéleti botránya. A beszámolók a város nevében nem egyeznek: a legtöbb forrás Hágát említi, néhány viszont Amszterdamot. Abban viszont mind megegyeznek, hogy holland pénztárnál és ezen a napon történt.

Ahhoz, hogy érteni lehessen, mi történt, vissza kell menni néhány évet. Az első világháború után, az 1920-ban aláírt trianoni békeszerződéssel Magyarország területének és lakosságának nagy részét elvesztette. Az ország sokkot kapott. Sokan úgy érezték, hogy a döntés igazságtalan, és a felelősök közül Franciaországot tartották a legfőbbnek.

Ebben a hangulatban született meg a terv, valamikor 1923 körül. Eszerint hamis francia bankjegyeket kell gyártani, nagy mennyiségben. A hamis pénz gyengítené a francia gazdaságot, a haszonból pedig a határok felülvizsgálatáért dolgozó mozgalmakat lehetne támogatni. Ma ez az ötlet képtelenségnek hangzik. Akkor akadtak, akik halálosan komolyan vették.

A terv mögött Windischgrätz Lajos herceg állt. Nagy múltú arisztokrata családból származott, és 1918-ban rövid ideig közélelmezési miniszter volt. A sárospataki birtokai a határ túloldalára kerültek, kárpótlás nélkül. Az ismerősei szerint ez az ügy személyes sérelemként élt benne, és ez hajtotta.

Először a saját birtokán próbálkoztak, kőnyomtatással. Az eredmény reménytelen volt: olyan bankjegyek jöttek ki a gép alól, amelyekkel egy vak pénztáros sem dőlt volna be. A herceg ekkor szakembert keresett. Egy Arthur Schultze nevű német ismerőse értett a nyomdatechnikához, és elvállalta a munkát.

A műhely ezután Budapestre költözött, a Retek utcai Térképészeti Intézet épületébe. Az intézet a honvédelmi tárca felügyelete alatt működött, és jól őrzött hely volt. A hamis pénz tehát nem egy pincelakásban készült, hanem egy állami intézmény falai között. A katonai oldalról Gerő László tiszt segítette a munkát, a gépek egy részét Németországból és Ausztriából hozatták.

Amikor a nyomtatás véget ért, a gépeket és a nyomólemezeket megsemmisítették. A résztvevők úgy gondolták, hogy ezzel minden nyom eltűnt, és csak a kész pénz marad. Éppen ez volt a baj: a kész pénz volt az a bizonyíték, amelyet nem lehetett megsemmisíteni, mert éppen az volt az egész terv értelme.

A választás egy régi típusú ezerfrankosra esett, amelynek a rajza akkor már nyolc évtizede szolgált. A vízjelet mégsem sikerült rendesen utánozni, és a megfelelő papírt sem tudták beszerezni. Harmincezer bankjegy készült el. A szakértők szerint ebből mindössze négyezer-négyszáz volt elfogadható minőségű, kilencezer közepes, tizenhatezer pedig egyenesen rossz.

A hibák aprók voltak, de egy gyakorlott szem számára árulkodóak. A betűk szélei elmosódtak, a papír durvábbnak érződött a kelleténél, az árnyékolás sem stimmelt mindenütt. A készítők maguk is tudták, hogy Franciaországban azonnal lebuknának. Ezért úgy döntöttek, hogy a bankjegyeket másutt hozzák forgalomba: Hollandiában, Olaszországban, északi nagyvárosokban, ahol kevesebben ismerik jól a francia pénzt.

1925 decemberében futárok indultak el Budapestről, több irányba. Nem csempészként utaztak, hanem hivatalos papírokkal. Az útiokmányokat Nádosy Imre, a magyar rendőrség országos főkapitánya adta ki. Ez a részlet később minden másnál többet nyomott a latban: az ország első rendőre segítette az utazást.

Az akció az első napon összeomlott. Amit a hágai tisztviselő az ujjbegyével megérzett, azt néhány óra múlva a holland rendőrség is látta. Jankovich mellett két társát, Marsovszky Györgyöt és Mankovich Györgyöt is őrizetbe vették. A következő napokban Hamburgban, Koppenhágában és Milánóban is elfogtak terjesztőket. A háló egyetlen hét alatt szakadt szét.

December 19-én a Magyar Távirati Iroda is hírül adta az esetet, és ezzel a botrány kirobbant. Jankovichnál jegyzetfüzetet találtak, benne nevekkel. A szál Budapestre vezetett. A Térképészeti Intézet dolgozóit sorra hallgatták ki, letartóztatták a herceg titkárát, Rába Dezsőt, majd magát Windischgrätz Lajost és Nádosy Imrét is.

Az ügy ekkor már nem rendőrségi, hanem nemzetközi politikai kérdés volt. Francia nyomozók érkeztek Budapestre, és mindenki azt találgatta, hol a nyomozás felső határa. Az ellenzék azt állította, hogy a kormány tudott az egészről. Bethlen István miniszterelnök tagadta. Rába Dezső egy ponton Teleki Pál volt miniszterelnököt is említette, később azonban visszavonta ezt a vallomását, és a kormány elleni bizonyíték végül nem lett.

1926 márciusában az országgyűlés nagy többséggel utasította el az ellenzék indítványát, amely szélesebb körű vizsgálatot sürgetett. A többség tehát nem akarta megtudni, meddig ér fel a szál. Ez a szavazás sokat elárul arról, hogyan zárult le az ügy: nem az igazság kiderítésével, hanem a kérdés lezárásával.

A budapesti per 1926 májusában zajlott. A vádlottak nem tagadták a tetteiket, hanem hazafias indokokra hivatkoztak: szerintük az igazságtalan békeszerződés miatt jártak el így. A bíróság enyhébben ítélt, mint amire sokan számítottak. Windischgrätz Lajos négy évet kapott, Nádosy Imre a jogorvoslatok után három és felet, a többiek ennél kevesebbet. Hágában, még márciusban, Jankovich három évet kapott, két társa két-két évet.

A büntetéseket akkor sem töltötte le senki végig. A herceget két év után szabadon engedték, és az idejének jó részét nem is börtönben, hanem szanatóriumokban töltötte. Nádosy Imre 1928 tavaszán kormányzói kegyelmet kapott, és a nyugdíját is megtartotta az 1935-ben bekövetkezett haláláig. A résztvevők közül többen néhány hónap után visszatértek a régi életükbe.

A legfurcsább gesztus azonban a károsult oldaláról érkezett. A Francia Nemzeti Bank a kártérítési igényét egyetlen jelképes frankra mérsékelte. Ez nem nagylelkűség volt, hanem számítás: Párizs nem akarta megbuktatni a magyar kormányt, mert a helyére érkező bizonytalanság még rosszabbul jött volna. A pénzügyi követelés helyett a diplomáciai szégyen maradt.', '1925', 'Budapest és Hága', 'A hamis pénzből soha nem lett haszon, a felelősök néhány év alatt visszatértek a hétköznapjaikba, az ország tekintélye viszont sokkal lassabban gyógyult.', 8, 1),
  ('crime_h_t_k_p_egy_novemberi_jjelen', 'Hét kép egy novemberi éjjelen', 'Egy állványzat, egy kikapcsolt riasztó, és reggelre két Raffaello-kép hiányzott a Szépművészetiből.', 'November eleji szombat este volt, és a Hősök tere felől már csak a lámpák fénye szűrődött a múzeum ablakaira. A Szépművészeti Múzeum hátsó homlokzatán állványzat állt, mert az épületet éppen felújították. Fél tizenegy körül három ember mászott fel rajta az első emeleti ablakhoz. Kivágták az üveget, benyúltak, és belülről lenyomták a kilincset.

A riasztó nem szólalt meg. A rendszer augusztus óta akadozott, október 20-a óta pedig egyszerűen ki volt kapcsolva. Az emberek odabent nem kapkodtak. Tudták, merre menjenek, és tudták, mit keresnek.

Hét festményt emeltek le a falról. Köztük volt Raffaello két képe: az Esterházy Madonna és az Ifjú képmása. Elvitték a Giorgione nevéhez kötött férfiportrét, Tintoretto egy női és egy férfi képmását, valamint két Tiepolo-festményt. Az Esterházy Madonna a magyar gyűjtemények egyik legféltettebb darabja volt, és ma is az.

Erről a képről érdemes tudni, milyen kicsi. Alig huszonkilenc centiméter magas és nagyjából huszonegy centiméter széles fatábla, tehát nem nagyobb egy könyvnél. Raffaello 1508 körül festette, és soha nem fejezte be: a háttér egy része vázlat maradt. A kép évszázadokon át vándorolt Itáliától Bécsig, majd az Esterházy-gyűjtemény részeként, 1865-ben került Pestre.

Éppen ez a kis méret tette annyira sebezhetővé. Egy nagy vászonnal nehéz észrevétlenül elosonni, de egy ekkora fatáblát bárki elvihet a kabátja alatt. Azon az éjszakán a világ egyik legértékesebb festménye egyszerűen kifért egy ablakon.

A keretekkel nem bajlódtak. Kiszedték belőlük a vásznakat és a fatáblákat, a kereteket pedig otthagyták az ablak alatti párkányon. Az éjszakai őrök éjfél körül, a szokásos körútjukon vették észre a sort az üres falakon. Innentől kezdve mindenki futott.

Aznap éjjel átkutatták az épületet és a környéket, reggelre pedig megindult az ország addigi legnagyobb nyomozása. 1983-at írtak, és Magyarországon ilyesmi nem történt. Az eset napokon belül bejárta a világsajtót, és a New York Times az évszázad bűntényének nevezte. Az értékéről különböző becslések jelentek meg: dollármilliók tízeiről és forintban több mint egymilliárdról is írtak.

A nyomozók abból indultak ki, hogy ezt nem alkalmi tolvajok csinálták. Aki hét képet visz el, és pont ezt a hetet viszi el, az tudja, mit ér a fal. A múzeumot hetekig figyelhették: valakinek ismernie kellett az őrök útvonalát és az óráit. A gyanú hamar a külföldi szálra terelődött.

Végignézték, kik érkeztek az országba a lopás előtti és utáni napokban. Több mint ezer olasz állampolgár neve került a listára, ebből ötven maradt, majd öt. A nevek később ismerősen csengtek: Ivano Scianti, aki Carlo Paganelli néven utazott, Graziano Iori, aki Renato Marangoninak mondta magát, továbbá Giordano Incerti, Carmine Palmese és Giacomo Morini. December 2-án jött a döntő pillanat: egy a helyszínen rögzített ujjlenyomat egyezett Incertiével.

Magyar segítőik is voltak. Raffai József zöldséges adta az autót a budapesti szállításhoz, egy Trabantot. Kovács Gusztáv fizikai munkát végzett: ő adogatta a képeket az ablak és a párkány között. Mindkettőjüknek tízezer dollárt ígértek arra az esetre, ha a képeket sikerül eladni.

A társasághoz tartozott egy tizenhét éves lány is, Jónás Katalin. A lopás éjszakáján diszkóban volt, és nem tudta, mi történik a városban. Később Iorival Bukarestbe utazott. Amikor hazatért, a kihallgatása adta a nyomozóknak a legtöbbet: nevek, arcok, helyszínek és időpontok álltak össze a vallomásából.

December közepén Raffai József megtört, és mondott valamit, amire senki sem számított. Az egyik festményt, Raffaello Ifjú képmását nem vitték ki az országból. Törökbálint határában, a földbe ásva került elő. Egy Raffaello-kép feküdt magyar földben, néhány kilométerre a múzeumtól, amelyből elvitték.

A másik hat kép addigra régen külföldön volt. Morini november 7-én indult el velük, tehát alig két nappal a lopás után. Az útvonal Jugoszlávián át vezetett, autóval, Görögország felé. Az Interpol is dolgozott az ügyön, de a döntő fordulatot nem a nyomozás hozta, hanem egy névtelen telefon.

1984. január 20-án görög csendőrök mentek ki a jelzés nyomán az Aigion melletti Panagia Trypiti kolostorhoz. A kolostor kertjében egy zöld bőrönd hevert. Valaki átdobta a falon, és otthagyta. A bőröndben ott volt mind a hat festmény.

Az örömbe azonnal üröm vegyült. A képeket nem múzeumi gondossággal csomagolták, és az utazás meg a dobás nem múlt el nyomtalanul. Az Esterházy Madonna szenvedte a legnagyobb kárt: a fatáblája megrepedt, és hosszában kettéhasadt. A többi kép is sérült, bár nem ilyen súlyosan.

A festmények 1984. január 25-én, külön repülőgéppel érkeztek haza. Összesen hetvennyolc napig voltak távol. A restaurátorok munkája nemzetközi figyelem mellett folyt, és egy éven belül minden kép visszakerült a falra. Az Esterházy Madonna ma is látható, és ha valaki nem tudja a történetét, nem is sejti, min ment keresztül.

A bírósági eljárások két országban zajlottak. Magyarországon 1984 áprilisában hirdettek ítéletet: Kovács Gusztáv tizenkét évet kapott, Raffai József hetet, Jónás Katalin pedig hat hónapot, felfüggesztve, mert a vallomása érdemben segítette a nyomozást. Az olasz elkövetők ellen Olaszországban folyt az eljárás, és négy és fél, illetve közel öt év körüli büntetéseket kaptak.

Egy kérdés azonban nyitva maradt, méghozzá a legfontosabb. Ilyen képeket nem lehet eladni a piacon: minden komoly gyűjtő és minden múzeum tudja, hogy lopottak. Csak megrendelésre érdemes elvinni őket. A gyanú egy görög üzletemberre, Eftimiosz Moszkahlaidiszre terelődött, akiről a nyomozati iratok szerint szó esett egy kétmillió dolláros fizetségről.

Ő mindvégig tagadta, hogy köze lett volna az ügyhöz. Bizonyíték hiányában nem ítélték el. A képeket megszerezték, a végrehajtókat elítélték, a megrendelő személye pedig máig a feltételezések világába tartozik.

A múzeumban azért sok minden megváltozott. A biztonsági rendszert alaposan átalakították, és azóta senki nem engedheti meg magának, hogy hónapokig kikapcsolva hagyjon egy riasztót. Az eset tanulságait Európa több gyűjteményében is átgondolták.

Marad a kérdés, amit a nyomozók akkor sem tudtak megnyugtatóan megválaszolni: ha volt megrendelő, miért mondott le a zsákmányról? A névtelen telefon, amely a kolostorhoz vezette a görög csendőröket, valakitől érkezett. Lehet, hogy valaki megijedt a nemzetközi felhajtástól. Az is lehet, hogy valaki egyszerűen meggondolta magát.', '1983', 'Budapest, Magyarország', 'A hét festmény hetvennyolc nap után mind hazakerült, és ma is látható a múzeumban — de hogy ki rendelte meg a lopást, arra soha nem derült fény.', 8, 2),
  ('crime_a_bety_r_s_a_kir_lyi_biztos', 'A betyár és a királyi biztos', 'Egy grófot küldtek a pusztára, hogy véget vessen a betyárvilágnak, és nyolc nap alatt kézre kerítette a leghíresebb betyárt.', 'A szegedi vár kazamatáiban télen megállt a levegő. Vastag falak, nyirkos folyosók, és odabent nem lehetett tudni, nappal van-e vagy éjszaka. 1869 első heteiben ezek a cellák gyorsan megteltek. Olyan emberek kerültek oda, akiket az Alföldön addig évekig senki sem tudott kézre keríteni.

Odakint másféle rend uralkodott, mint a városokban. A tanyák messze estek egymástól, a puszta nagy volt, a csendbiztosok kevesen. Ha valakinek eltűnt a lova vagy a marhája, a hír sokszor csak napok múlva jutott el a hatósághoz. Mire odaért, az állat már rég túl volt a következő vásáron.

A „betyár” szó akkoriban nem egyetlen embert jelentett, hanem egy egész világot. Voltak köztük napszámosok, akik télen lopásból éltek, katonaszökevények, akiknek nem volt hova visszamenniük, és hivatásos lótolvajok. És voltak azok is, akik sosem ültek lóra: gazdák, mészárosok, kupecek, akik megvették a lopott jószágot, és hallgattak. Ez a hallgatás tartotta életben az egészet.

Ennek a világnak volt egy neve, amelyet mindenki ismert. Rózsa Sándor 1813-ban született a Szeged melletti tanyavilágban, Röszke környékén. Az apjáról a források nem egyeznek: az egyik szerint lólopásért akasztották fel, a másik szerint egy rablás közben verték agyon. Magyarul nem tudott írni és olvasni, de beszélt németül és szerbül. Az első eljárás 1836-ban indult ellene, marhalopás miatt.

Az élete ezután hosszú ideig ugyanazt a kört járta: bujdosás, elfogás, szökés, megint bujdosás. 1848 októberében a Honvédelmi Bizottmány amnesztiát adott neki, és ő lovas szabadcsapatot állított ki, mintegy százötven emberrel. A csapat azonban rövid idő alatt súlyos visszaéléseket követett el egy bánsági faluban, ezért feloszlatták. Ez a fejezet később minden róla szóló vitában visszatért.

1857-ben a saját sógora, egy Katona Pál nevű szegedi tanyás gazda adta ki a pandúroknak. 1859 februárjában halálra ítélték, de a kegyelmi kérvény nyomán az ítéletet életfogytiglanra változtatták. Éveket töltött Kufstein várában, később Theresienstadtban, majd Péterváradon. 1868-ban amnesztiával szabadult, és a szegedi elbeszélések szerint pandúrnak jelentkezett a hatóságnál. Ezt a kérést állítólag elutasították.

Eközben Pesten elfogyott a türelem. Wenckheim Béla belügyminiszter 1868 végén arra jutott, hogy a megyék külön-külön sosem fognak boldogulni ezzel a világgal, és teljhatalmú királyi biztost küld a Tisza mellékére. A választása gróf Ráday Gedeonra esett, aki 1829-ben született Pesten, 1848-ban minisztériumi segédfogalmazóként kezdte, a szabadságharcban lovas főhadnagy lett, 1868-tól pedig a belügyminisztérium rendőri osztályát vezette. A kinevezése 1869. január 4-én kelt.

Nyolc nappal később, január 12-én Rózsa Sándor már a szegedi várban ült. Az elterjedt elbeszélés szerint Ráday csellel hívatta magához, és mire a betyár megértette, mibe sétált bele, késő volt. A részletekben a beszámolók eltérnek egymástól, abban azonban nem: fegyver nélkül, csendben, egyetlen lövés nélkül fogták el. Ez volt a királyi biztosság első nagy híre, és pontosan úgy hatott, ahogy Ráday szerette volna.

A működési területe a Tisza mellékének egy része lett: Csongrád, Csanád, a Jászkunság kiskun vidéke, valamint Szeged és Kecskemét szabad királyi városa. Az első jelentéseiben leírta, miért bukott el minden addigi próbálkozás. Egy: a betyárok egy része nappal rendesen dolgozik, tehát nem lehet őket a foglalkozásuk alapján megtalálni. Kettő: a hatóságok féltik a hatáskörüket egymástól. Három: a közbiztonsági emberek és a büntető igazságszolgáltatás is megvesztegethető.

A módszere ezért nem a hajsza volt, hanem az iroda. 1870-ben harminchét saját alkalmazottal dolgozott: vizsgálóbírókkal, bírákkal, porkolábokkal, orvossal, írnokkal, levéltárossal. Napi jelentéseket követelt, álruhás nyomozókat küldött a vásárokra, és havi ezer forintot költött besúgókra. A helyettese Laucsik Máté székesfehérvári ügyvéd volt, gyakorlott betyárvadász hírében álló ember.

Az igazi célpont azonban nem a lovon ülő ember volt. Ráday hamar megértette, hogy egy lopott ménest nem lehet gyorsan eladni anélkül, hogy valaki ne kérdezne rá, és hogy ezt a valakit meg lehet fogni. Ezért kimutatásokat kért kereskedőktől és mészárosoktól arról, mit vettek és mit adtak el, és összevetette őket a bejelentett lopásokkal. A vizsgálat így egészen más körökbe ért fel, mint amire a közvélemény számított: orgazdákhoz, tehetős gazdákhoz, sőt hivatalt viselő emberekhez.

Ez volt az a pont, ahol a szegedi királyi biztosság több lett egy betyárhajszánál. A bandákat korábban is szét lehetett verni, csak mindig újranőttek, mert megmaradt a piac, amely megvette tőlük a jószágot. Ráday erre a piacra ment rá. A rablók egy része ettől kezdve nem azért bukott le, mert elkapták a pusztán, hanem mert a saját vevője ellen indult eljárás.

A számok mutatják, mekkora apparátus lett ebből. A kinevezése évében 554 bűnüggyel foglalkoztak, ezen belül 234 rablási üggyel, és összesen 834 személyt érintett a vizsgálat. A négy év alatt 1597 letartóztatás történt. És van egy adat, amely azóta is a szakirodalom legvitatottabb pontja: a fogva tartottak közül 415-en meghaltak a fogság ideje alatt.

Ekkor született a legenda, amelyet ma is sokan igaznak hisznek. A nép azt beszélte, hogy a várban van egy szerkezet, a „Ráday-bölcső”, és aki egyszer belekerül, az mindent bevall. Ilyen szerkezet a kutatások szerint nem létezett. A név egy fikció volt, amellyel a kívülállók megmagyarázták maguknak, hogy a puszta legkeményebb emberei miért kezdtek el egyszer csak beszélni.

A valóság ennél lassabb és hidegebb volt. Az embert hónapokig hagyták a kazamatában, magányban és bizonytalanságban, úgy, hogy nem tudta, mi vár rá. Aztán felvezették a vizsgálóbíróhoz, aki nem a bűneiről kérdezte, hanem a hogylétéről, az egészségéről, a családjáról. Meleg ruhát kapott, ételt, hírt otthonról. Amikor pedig a fogoly már maga kereste ezt a beszélgetést, a vizsgálóbíró váratni kezdte, és megvárta, amíg üzenget.

A kortársak nem voltak elnézőek ezzel. A módszerekről és a foglyokkal való bánásmódról többször is interpelláltak a parlamentben, és a sajtó évekig vitatkozott róla. A legsúlyosabb ellenérv nem az volt, hogy kegyetlen, hanem hogy megbízhatatlan: aki hónapokig ül egy nyirkos cellában, az olyat is bevallhat, amit el sem követett. Ártatlanok is odaveszhettek a rendszerben, és ezt már akkor is kimondták.

Rózsa Sándor pere 1872-ben zárult le. Huszonegy rablást, kilenc lopást és egy gyilkosságot tudtak rábizonyítani, és életfogytiglani fegyházat kapott. Másodfokon halálra ítélték, a Kúria azonban visszatért az első ítélethez. 1873. május 5-én szállították Szamosújvárra, ahol az 1267-es törzskönyvi számot kapta. Előbb szabóként, később romló egészsége miatt harisnyakötőként dolgozott, és 1878. november 22-én, hatvanöt évesen tüdővészben halt meg.

Ráday 1871-ben lemondott, és 1872 elején a királyi biztosság megszűnt. Ő maga Arad képviselőjeként ült be a parlamentbe, és 1901-ben halt meg Budapesten. A pusztán a rend valóban helyreállt, a nagy rablóbandák szétestek, és a csendőrség megszervezésének gondolata is az ő javaslataiból nőtt ki.

A történetnek mégis két arca maradt. Jókai Mór, aki ismerte őt, „A lélekidomár” című regényében Lándory Bertalan alakjában mintázta meg, és Ráday szájába adta azt a mondatot, hogy két régi várat töltött meg olyan emberekkel, akik minden reggel felébrednek, mégsem élnek — és lehetnek köztük ártatlanok is. Írt róla Tömörkény István is, Jancsó Miklós pedig a Szegénylegények című filmjében ugyanezt a lassú, néma nyomást vitte vászonra. A betyárvilágból ballada lett, a vizsgálatból pedig kérdés.', '1869–1872', 'Szeged, Magyarország', 'A betyárvilág Szeged körül valóban véget ért, de hogy hány ártatlan ember fizetett érte, azt a szegedi vár irataiból máig nem lehet biztosan kiolvasni.', 7, 3),
  ('crime_aki_els_t_lt_a_f_v_ros_p_nz_vel', 'Aki elsétált a főváros pénzével', 'Egy huszonkét éves hivatalnok elindult a városházára egy bőrtáska pénzzel, és soha többé nem látták Magyarországon.', 'A pesti belvárosi adóhivatalban november közepén mindig ideges volt a hangulat. Negyedévi zárás, hosszú sorok, tele pénztárfiókok. Akkoriban a befizetett adót nem utalták sehova: megszámolták, zsákba és bőrtáskába rakták, és egy tisztviselő meg egy altiszt bérkocsin átvitte a városházára. A rendszer évtizedek óta így működött, és évtizedek óta jól működött.

Budapest ekkor már nagyváros volt. Villamos járt, a körutakon esténként égtek a lámpák, a hivatalokban rend és iktatószám uralkodott. A pénz viszont még mindig úgy utazott a városban, ahogy ötven évvel korábban: emberi kézben, lovas kocsin, egy bőrtáskában. Ez a kettősség, a modern hivatal és a régi szállítás, pontosan az a rés volt, amelyben az egész történet megtörtént.

Éppen ezért nem gondolta senki, hogy ezen változtatni kellene. A pénzt kísérő tisztviselőt gondosan választották ki, óvadékot kellett letennie a hivatalnál, és a táska kulcsa nála volt. A biztosíték tehát nem zár volt és nem fegyver, hanem a bizalom. Egy fiatalember, akiről mindenki jót mondott, és aki tudta, hogy elveszíti az óvadékát, ha bármi hiányzik.

Kecskeméthy Győző huszonkét éves volt. Pénztári gyakorlatot szerzett, jogot tanult, és ezzel a háttérrel szokatlanul fiatalon jutott felelős beosztásba a fővárosnál. A kollégái pontos, gyors és udvarias embernek ismerték. Éppen olyannak, akire rá lehet bízni egy nehéz bőrtáskát.

1901. november 15-én, amikor a nap végén összeszámolták a bevételt, kerek hétszázhetvenhétezer koronát mutatott az összesítő. Ez akkor is hatalmas összeg volt, olyan, amit a hivatalban dolgozók soha életükben nem láttak egyben. A pénzt a szokott módon a táskába rakták, lezárták, és Kecskeméthy egy altiszt kíséretében elindult vele a városházára.

Útközben megállíttatta a kocsit egy emeletes ház előtt. Adott az altisztnek egy borítékot, és megkérte, vigye fel egy ügyvédhez az emeletre — a korabeli lapok a nevét csak kezdőbetűvel írták le. Az altiszt felment. Kecskeméthy egyedül maradt a kocsiban a táskával és a kulccsal.

Amikor a kísérője visszaért, semmi sem látszott másnak. A táska ugyanott volt, ugyanúgy lezárva, a fiatal tisztviselő ugyanolyan nyugodtan ült mellette. A városháza elé érve Kecskeméthy annyit mondott, hogy beugrik gyorsan a postára, és mindjárt jön. Ez volt az utolsó mondat, amelyet Magyarországon hallottak tőle.

Az altiszt körülbelül húsz percig várt a kapuban. Aztán bement, jelentette, hogy egyedül érkezett, és további fél óra telt el zavarodott kérdezősködéssel, mire valaki kimondta, amit senki sem akart: nyissák ki a táskát. Odabent a köteg jóval könnyebb volt, mint kellett volna. Hiányzott háromszáz darab ezerkoronás, és hiányzott mellőle még jó néhány köteg egyéb papírpénz.

A városházán ezután nem a nyomozás kezdődött, hanem a döbbenet. A korabeli leírás szerint kerek két órába telt, amíg a hivatal annyira összeszedte magát, hogy jelentést tudjon tenni. Két óra az a fajta előny, amelyet egy vasútállomásról induló ember soha többé nem ad vissza. Mire a rendőrség az első kérdéseket feltette, a vonat, amelyre a gyanú szerint felszállt, már rég elhagyta a várost.

A hiány pontos összegéről a beszámolók nem teljesen egyeznek. A leggyakrabban idézett szám ötszáznyolcvannyolcezer korona, ami akkoriban a magyar bűnügyi krónika legnagyobb sikkasztásává tette az ügyet. A mai értékéről csak becslések vannak, és ezek is messze járnak egymástól — annyi biztos, hogy több emberöltőnyi tisztviselői fizetésről volt szó.

A nyomozás azonnal indult, és egyetlen használható tanúja volt. A bérkocsis, aki a városháza elől elvitte, később elmondta a rendőrségnek, hogy a Keleti pályaudvarra fuvarozta. Onnantól semmi. Nem volt fényképes útlevél, nem volt határellenőrzés a mai értelemben, és egy nappal a tett után az ember bárhol lehetett a monarchiában — vagy azon is túl.

A hatóság azt tette, amit akkor lehetett: táviratozott. Ment az értesítés a nagyobb állomásokra, a határ menti rendőrségekre, a monarchia városaiba. Csakhogy nem volt fényképes útlevél, és nem volt olyan határellenőrzés, mint ma. Egy fiatal, jól öltözött, feltűnés nélküli férfi pedig éppen úgy nézett ki, mint ezer másik utas az első osztályon.

A rendőrség először négyezer, majd húszezer korona vérdíjat tűzött ki a fejére. Ez utóbbi önmagában is vagyon volt. Detektíveket küldtek külföldre, és nem csak hetekre: évekig jártak utána. A magyar sajtó pedig hónapokig másról sem írt.

A bejelentések özönlöttek. Látni vélték Velencében, ahol állítólag jókedvűen társaságba járt. Látni vélték Milánóban, a főtéren. Felbukkant a neve Monte-Carlo kaszinóiban, és egyszer azt is jelentették, hogy Korzikán kis híján elfogták. Egyik bejelentésből sem lett soha igazolt találkozás, és ma sem lehet tudni, melyik mögött volt bármi valóság.

Tíz évvel a tett után a Pesti Hírlap arról írt, hogy Kecskeméthy gúnyos leveleket küldözget a rendőrségnek. A hatóság ezt hevesen cáfolta. A történet mégis megmaradt, mert jól illett ahhoz a képhez, amelyet a közönség kialakított róla: a fiatalember, aki nemcsak elvitte a pénzt, hanem még mulat is rajta.

Az ügy közben lassan átalakult bűnesetből történetté. Az olvasók egy része titokban szurkolt neki, mert nem bántott senkit, nem emelt kezet senkire, csak elsétált. Mások azt látták benne, hogy a főváros pénze egyetlen délután alatt eltűnt, és ezért senki sem felelt. A rendőrség évekig kapott olyan leveleket, amelyek ismerni vélték a rejtekhelyét, és éveken át semmi sem lett belőlük.

1924 tavaszán aztán érkezett egy levél Dél-Amerikából. A cenzúra fogta el, és az ügyészséghez továbbította. A levél azt állította, hogy Kecskeméthy Győző él, jómódban, jelentős vagyonnal. Az ügyészségnek ekkor elő kellett vennie egy huszonkét éves nyomozati iratcsomót, és meg kellett válaszolnia egy jogi kérdést, amelyet addig senki nem tett fel: elévült-e egyáltalán az ügy.

Ebből sem lett elfogás. Kecskeméthy Győzőt soha nem állították bíróság elé, és hitelesen soha senki nem látta a szökése után. Vannak, akik szerint gazdagon élt még évtizedekig; mások szerint a pénz hamar elfogyott, és nyomtalanul eltűnt valahol Európában. Egyik változatra sincs bizonyíték.

Az ügynek mégis lett tartós következménye, csak nem az, amit a közönség várt. A sikkasztás után komolyan vitatkozni kezdtek arról, mire jó az a néhány száz koronás hivatalnoki óvadék, amely elméletileg a pénzt őrizte. Az érv egyszerű volt: akit nem tart vissza ötszáz korona elvesztése attól, hogy elvigyen ötszáznyolcvannyolcezret, azt semmi sem tartja vissza. Az óvadék rendszerét 1904-ben a pénzügyminiszter javaslatára eltörölték, és a pénz szállítását is átalakították.

Így a legnagyobb magyar sikkasztási ügy végül nem egy elfogással ért véget, hanem egy szabálymódosítással. A táska, a kulcs és a bizalom hármasát felváltotta a szigorúbb elszámolás. A nevet pedig az őrizte meg, ami a rendőrségnek sosem sikerült: az újságok címlapja.', '1901', 'Budapest, Magyarország', 'Kecskeméthy Győzőt soha nem fogták el, és máig nem tudni, hogy csakugyan gazdagon élt-e Dél-Amerikában, vagy már jóval korábban nyoma veszett.', 6, 4),
  ('crime_a_csatorn_k_fel_l_j_ttek', 'A csatornák felől jöttek', 'Egy nizzai bank széfterme hétfő reggel nem nyílt ki: valaki belülről hegesztette be az ajtót.', 'Nizzában júliusban már reggel forró a levegő, és a belváros délutánra kiürül. Az Avenue Jean-Médecin a város főutcája: üzletek, kávézók és bankok egymás mellett. Itt állt a Société Générale egyik fiókja is. A földszint alatt, mélyen a beton alá süllyesztve, széfterem volt, több száz bérelt fémdobozzal.

A bank védelmét a nehéz páncélajtóra és a vastag falakra építették. Arra nem gondolt senki, hogy alulról is lehet jönni. Egy széfterem alatt föld van, és a föld akkoriban elég biztonságosnak látszott.

1976 nyarán hosszú hétvége jött. A francia nemzeti ünnep, július tizennegyedike, szerdára esett, és sokan egészen vasárnapig szabadságot vettek ki. A bank pénteken bezárt, és csak hétfőn nyitott újra. Négy csendes nap telt el a széfterem fölött.

Hétfő reggel két alkalmazott lement, hogy kinyissa a páncélajtót. Az ajtó meg sem mozdult. Nem a zárral volt baj. Valakik belülről hegesztették be, és a varrat friss volt.

Órákba telt, mire átvágták magukat rajta. Odabent minden doboz ajtaja fel volt feszítve. A padlón papírok, dossziék és üres bársonytokok hevertek szanaszét. A terem egyik sarkában pedig lyuk tátongott a padlóban.

A lyuk szűk, kidúcolt alagútba vezetett. Az alagút néhány méter után egy nagy, boltozatos csatornába torkollott. Nizza alatt betonmederben fut a Paillon, és ehhez kapcsolódik a város csatornarendszere. Aki ide lejut, fél várost bejárhat anélkül, hogy egyszer is kilépne az utcára.

A széfterem falán felirat állt. Nagyjából ennyit jelentett: fegyver nélkül, gyűlölet nélkül, erőszak nélkül. A pontos szórendet a források ma sem adják meg egyformán. Abban viszont többen egyetértenek, hogy a betűket más-más kéz írta, hogy az írásszakértők ne tudjanak egyetlen emberre mutatni.

A nyomozók visszafelé kezdték kibontani az időt. Az alagút nem egy hétvége munkája volt. A csatorna fala és a széfterem padlója között nyolc méter hosszú járatot vájtak ki kézzel. Ehhez hetek kellettek, a legtöbb beszámoló szerint körülbelül két hónap.

A csapat gumicsónakon vitte le a szerszámokat a csatornába. Több száz méter kábelt húztak be, hogy legyen világítás odalent. Asztalt állítottak fel, ahol ettek, és felfújható matracokat, amiken aludtak. Nem egyetlen éjszakára rendezkedtek be.

A szerszámokat aztán egyszerűen otthagyták. A fúrók, a feszítővasak és a hegesztéshez használt gázpalackok mind a helyszínen maradtak. Csak a palackokból harminc körül volt. Ennyi holmit észrevétlenül levinni a föld alá önmagában is hetekig tartó, türelmes munka lehetett.

A hosszú hétvégén aztán bementek a terembe, és belülről lezárták maguk mögött az ajtót. Így kívülről senki nem tudott rájuk nyitni, és ők sem siettek. Két napjuk volt arra, hogy egyenként felfeszítsék a dobozokat. Hogy pontosan hányat bontottak fel, azt a beszámolók nem mondják egyformán: szerepel kétszáz körüli és háromszáz fölötti szám is.

A zsákmány értékét sem tudta senki biztosan megmondani. A leggyakrabban idézett összeg negyvenhatmillió frank. A nehézség az volt, hogy egy bérelt széfbe bárki bármit betehet, és nem kell bejelentenie. Több ügyfél valószínűleg el sem mondta, mit veszített.

A francia újságok hamar elnevezték az ügyet az évszázad rablásának. A csapatot csatornásoknak hívták. Az emberek egy részét szórakoztatta a történet, mert senki nem sérült meg, és a pénz egy nagy banktól tűnt el. A széfeket bérlő ügyfelek persze másképp gondolták.

Eleinte a rendőrség alig tudott hova nyúlni. A tetthelyen nem maradt használható ujjlenyomat, a szerszámok gazdátlanul hevertek. A csatornában a víz mindent elmosott. Hetekig úgy látszott, hogy a nyomozás megáll.

Ősszel fordult a helyzet, és nem nyomozati bravúr miatt. Egy régi ismeretség és egy elejtett mondat vezetett az első névhez. A rendőrség őrizetbe vett egy férfit, aki a csapathoz tartozott, ő pedig beszélni kezdett. Októberben sorra vitték be a többieket is.

A szálak egy nizzai fényképészhez futottak össze. Albert Spaggiarinak hívták, és 1932-ben született egy hegyvidéki kisvárosban. Tizenkilenc évesen ejtőernyősnek állt, és Indokínában szolgált. Katonaévei alatt egy fegyveres rablás miatt börtönbe került, később politikai ügyek miatt újra.

Nizzában látszólag nyugodt életet élt. Feleségével egy városon kívüli házban laktak, ahol baromfit tartottak. Fényképészként dolgozott, és forgott a helyi közéletben is. Egy alkalommal magának a polgármesternek a kíséretében utazott külföldre.

Spaggiarit október végén, a nizzai repülőtéren tartóztatták le. Éppen egy távol-keleti útról érkezett haza. A kihallgatáson eleinte mindent tagadott. Később elismerte, hogy benne volt, de olyan magyarázatot adott, amit senki nem tudott ellenőrizni.

Azt állította, hogy a pénz egy titkos politikai szervezetet szolgál, amelynek Catena a neve. Ilyen szervezetre a nyomozók soha nem találtak bizonyítékot. Spaggiari mégis kitartott a története mellett, és emlegetett egy rejtjelezett iratot is, amely állítólag mindent megmagyaráz. Ez az irat lett a szökésének az eszköze.

1977. március 10-én a vizsgálóbíró irodájába kísérték. Azt ígérte, hogy ott helyben megfejti a rejtjeles szöveget. Miközben a bíró az iratot nézte, Spaggiari az ablakhoz lépett, és kiugrott. Egy parkoló autó tetejére esett, majd egy motorra pattant, amely az utcán várt rá.

Az eset egyik részletét azóta is szívesen mesélik Franciaországban. Eszerint az autó tulajdonosa később postán kapott egy csekket, hogy megcsináltathassa a behorpadt tetőt. Ezt hitelesen soha senki nem igazolta, ezért ez a történet inkább legenda, mint tény. Az viszont tény, hogy Spaggiari kiugrott, és többé nem látta senki.

Soha többé nem került rendőrkézre. Távollétében életfogytiglani börtönre ítélték. A következő éveket a legtöbb forrás szerint Dél-Amerikában töltötte, és titokban néha hazalátogatott. Sokat írtak arról is, hogy megváltoztatta az arcát, de ezt bizonyítani senki nem tudta.

1989 nyarán halt meg, ötvenhat évesen, tüdőrákban. A holttestét az édesanyja háza elé vitték, egy autóban hagyva. Még a halála is maradt egy kicsit rejtély: hogy pontosan hol és mikor halt meg, arról a dokumentumok nem teljesen egyeznek. A pénzből gyakorlatilag semmi nem került elő.

Társai közül többeket bíróság elé állítottak. Abban viszont a források nem egyeznek, hányan is voltak valójában: tucatnyitól húsz fölöttiig szerepel szám. Ez önmagában sokat elmond arról, hogy egy ilyen ügyben mennyire nehéz a végére járni annak, ki mit csinált.

A történetnek van még egy furcsa fejezete. 2010-ben egy Jacques Cassandri nevű férfi könyvet adott ki, amelyben azt állította, hogy valójában ő szervezte a rablást, Spaggiari pedig csak mellékszereplő volt. Magáért a lopásért már nem lehetett felelősségre vonni, mert eltelt a törvényes határidő, de más ügyekben bíróság elé állt. Ott aztán azt mondta, hogy a könyv kitalált történet.

Ezért van, hogy a nizzai ügyet ma is kétféleképpen mesélik. Az egyik változatban egy magányos, hiú tervező áll a középpontban. A másikban egy jól szervezett, sokfős csapat, amelynek a fényképész csak az arca volt. A csatorna, az alagút és a behegesztett ajtó viszont mindkét változatban ugyanaz.', '1976', 'Nizza, Franciaország', 'A pénz soha nem került elő, Spaggiarit soha nem fogták el, és máig vitatják, ki volt valójában az agy a csatorna alatt.', 8, 5),
  ('crime_loms_r_t_az_aranyl_d_kban', 'Ólomsörét az aranyládákban', 'Három láda arany indult Londonból Párizsba, és útközben ólomsörét lett belőle.', 'Egy párizsi irodában 1855 májusában három faládát tettek az asztalra. Londonból érkeztek, és aranynak kellett lennie bennük. Amikor felnyitották őket, apró ólomgolyók gurultak szét a padlón. Sörét volt, amilyet a vadászok töltényébe töltenek.

Az arany az előző este indult el Londonból. A South Eastern Railway esti postavonata fél kilenckor hagyta el a London Bridge pályaudvart. Folkestone-ban hajóra rakták a ládákat, a hajó átvitte őket Boulogne-ba, onnan pedig vonat vitte tovább Párizsba. Az egész út egyetlen éjszaka alatt lezajlott.

A szállítmány három londoni aranykereskedő háztól származott. Összesen mintegy száz kilót nyomott, és tizenkétezer fontot ért. Ez akkoriban egész vagyon volt. Rúdarany és amerikai aranyérmék voltak benne.

A vasút komolyan vette a dolgot. A ládákat a poggyászkocsiban vastag falú vaskazettákba zárták, a korszak legjobb angol lakatosműhelyének a munkáiba. Minden kazettát két zár fogott, és a két kulcsot szándékosan nem tartották egy helyen. Az egyik London Bridge-ben volt, a másik Folkestone-ban, és csak néhány megbízható ember férhetett hozzájuk.

Ezért mondta mindkét vasúttársaság ugyanazt, amikor kiderült a lopás: ez lehetetlen. Angliában azt állították, hogy a rablás csak Franciaországban történhetett. A franciák azt felelték, hogy náluk a ládák súlya végig ugyanaz maradt, tehát a baj még a Csatorna túlsó partján esett meg.

A súlyokban volt is egy különös részlet. Boulogne-ban lemérték a ládákat. Az egyik jóval könnyebb volt, mint Londonban, a másik kettő viszont nehezebb. Aki elvitte az aranyat, pótolni is akarta a súlyát, csak nem mindenütt egyformán pontosan.

A vasút háromszáz font jutalmat hirdetett, és az újságok hónapokig írtak az ügyről. A nyomozás mégis megállt. Másfél évig senki nem tudott egyetlen nevet sem mondani.

Pedig a terv már évekkel korábban elkezdődött, és egyetlen kérdés körül forgott: hogyan lehet kulcsot szerezni.

Négy ember állt mögötte. William Pierce korábban a vasútnál dolgozott, de elbocsátották, mert szerencsejátékos volt. Ő találta ki az egészet. Edward Agar régi, tapasztalt betörő volt, aki évekig élt Ausztráliában és Amerikában, és kiválóan bánt a zárakkal.

A másik kettő bent volt a vasútnál. James Burgess vonatkísérő volt a folkestone-i vonalon, és gyakran kísért értékszállítmányt. William Tester a London Bridge-i forgalmi irodában dolgozott. Ő látta a beosztásokat, és tudta, mikor és mi indul.

A kulcsokhoz türelem kellett. Amikor a kazettákat javításra visszaküldték a gyártóhoz, új kulcsok készültek, és a levelezés Tester kezén ment át. Kivitte a kulcsokat az irodából egy rövid időre, és egy sörözőben találkozott a másik kettővel. Agar zöld viasszal vett lenyomatot róluk.

A lenyomat kevés volt. A kazettán két különböző zár volt, Tester pedig ijedtében két egyforma kulcsot hozott ki. A hiányzó kulcshoz Agar és Pierce a folkestone-i irodába ment be egy olyan pillanatban, amikor a személyzet a kikötőbe sietett a befutó hajóhoz.

Ezután hónapok teltek reszeléssel és próbálgatással. Agar többször végigutazta a vonalat, amikor Burgess volt szolgálatban, és csendben kipróbálta a kulcsokat. Addig igazította őket, amíg mind a két zárat könnyedén nyitották.

1855. május 15-én este minden a helyén volt. Burgess a pályaudvar előtt fehér zsebkendővel törölte meg az arcát. Ez volt a jel: ma este arany megy. Pierce és Agar első osztályú jegyet váltott, és a poggyászukat átadták Burgessnek.

Agar felszállt a poggyászkocsiba, és Burgess munkaruhájával takarta el magát. Amikor a vonat elindult, munkához látott. A ládákat nem elöl bontotta fel: fogóval kiszedte a vasabroncsokat tartó szegecseket. Így a zárak és a pecsétek sértetlenek maradtak.

Minden kivett aranyrudat lemért, és pontosan ugyanannyi ólomsörétet tett a helyére. A sörétet előre bekészítették egy londoni sörétöntő toronyból. A ládákat visszazárta, és saját maga készítette bélyegzővel pecsételte le újra. Az elsővel az első harmincöt perc alatt végzett, még Redhill előtt.

Redhillben Tester lépett oda egy pillanatra, átvett egy táskányi aranyat, és visszament az irodába. Így neki tanúi voltak arra, hogy a helyén volt. Pierce pedig ekkor ült át a poggyászkocsiba, és a maradék két ládán már együtt dolgoztak.

Folkestone-ban éjjel fél tizenegy körül kiemelték a kazettákat a vonatból. Agar és Pierce elbújt, majd visszaült az első osztályra, és Doverig utazott. Ott leszálltak a táskákkal, megvacsoráztak egy szállodában, a kulcsokat és a szerszámokat a tengerbe dobták, és a hajnali kettes vonattal visszamentek Londonba. Reggel öt körül értek haza.

Az aranyat beolvasztották. Egy részét egy hírhedt londoni orgazdának adták el, a pénzt pedig négyfelé osztották. Pierce fogadóirodát nyitott, és azt mesélte, hogy egy lóversenyen nyerte a tőkét. Burgess és Tester értékpapírba tette a részét.

Ezután másfél évig nem történt semmi. A rendőrség nem talált fogódzót. A rablókat végül nem a nyomozás buktatta le, hanem egy megszegett ígéret.

Agart 1855 őszén letartóztatták, de nem emiatt az ügy miatt. Egy csekkhamisítás miatt állították bíróság elé, és életfogytig tartó száműzetésre ítélték: Ausztráliába kellett mennie. Mielőtt elvitték, körülbelül háromezer fontot hagyott hátra. Azt kérte, hogy ebből tartsák el Fanny Kayt és a közös gyereküket.

A pénzt Pierce-re bízta. Pierce eleinte ígérgetett, aztán megtartotta magának. 1856 nyarán Fanny Kaynek már semmije nem maradt. Elment a newgate-i börtön igazgatójához, és elmondta, amit tudott.

A rendőrség ezután megnézte azt a házat, ahol Agar és Pierce dolgozott. A padló deszkái megégtek, a kandalló hamujában és a padló alatt apró aranyszemcséket találtak. Valaki ott nagy hőséggel dolgozott.

Agart a börtönben kihallgatták, és eleinte nem volt hajlandó megszólalni. Amikor megtudta, mi lett a rábízott pénz sorsa, megváltozott. Mindent elmondott, és vállalta, hogy a bíróságon is beszél. A vallomása olyan részletes volt, hogy a vasút emberei szinte percre pontosan végig tudták követni azt az éjszakát.

Pierce-t és Burgesst 1856 novemberében tartóztatták le. Tester akkor éppen Svédországban dolgozott. Amikor megtudta, mi történt, önként hazajött, és decemberben feladta magát.

A tárgyalás 1857 januárjában volt az Old Baileyn, London központi büntetőbíróságán. Mindhárman ártatlannak vallották magukat. Az esküdtszék tíz perc alatt döntött. Burgess és Tester tizennégy évre szóló száműzetést kapott, Pierce viszont csak kétévi kényszermunkát, mert ő nem volt a vasút alkalmazottja, és így csak enyhébb bűncselekménnyel lehetett vádolni.

Az aranyat soha nem szerezték vissza. Már rég nem volt arany: rudakból pénz lett, pénzből fogadóiroda és értékpapír. Egyetlen tárgy maradt belőle, ami ma is látható: az egyik láda, benne az ólomsöréttel, amit Agar tett bele.

Az eset később mesévé vált. Újságcikkek, könyvek és filmek dolgozták fel, és a szereplők egyre okosabbak, egyre elegánsabbak lettek. Érdemes emlékezni arra, hogy a valóságban négy ember hónapokig reszelt kulcsokat egy sörözőben és egy bérelt házban. A tökéletes tervet a végén az buktatta el, hogy egyikük nem adott oda egy pénzt, amit megígért.', '1855', 'London és Folkestone, Anglia', 'Az aranyat soha nem szerezték vissza, és a tökéletes tervet nem a rendőrség buktatta le, hanem egy megszegett ígéret.', 8, 6),
  ('crime_a_magyar_aki_picass_t_festett', 'A magyar, aki Picassót festett', 'Egy budapesti festő több mint ezer hamis remekművet csempészett be a világ gyűjteményeibe — és hamisításért soha nem ítélték el.', 'Egy dombtetőn álló fehér ház Ibiza szigetén. Odalent a tenger, a teraszon terített asztal, gyertyák, jó bor. A házigazda elegáns, ötven körüli férfi, tökéletes modorral és halk, idegenes akcentussal. Úgy mutatkozik be: Elmyr de Hory, magyar arisztokrata. A vendégek között filmcsillagok is akadnak, és senki nem sejti, hogy a ház egyik eldugott kis szobájában a huszadik század legszorgalmasabb műhamisítója dolgozik.

A valódi neve Hoffmann Elemér Albert volt. Budapesten született, a leggyakrabban idézett adat szerint 1906. április 14-én — de már ez is bizonytalan, mert ő maga élete végéig szívesen játszott az évszámokkal. Arisztokrata pedig nem volt. Az apját kézműves áruk nagykereskedőjeként tartották nyilván, a család zsidó és jómódú polgári volt, nem nemesi. A nagykövet apa, a kastély, a báróság: mind később kitalált díszlet.

Fiatalon festőnek készült, és komolyan vette. Tizenhat évesen a nagybányai művésztelepen tanult, tizennyolc évesen Münchenben, majd 1926-tól Párizsban, a Grande Chaumière nevű szabadiskolában, ahol Fernand Léger volt az egyik tanára. Tehetséges volt, de nem eredeti. A saját képei tisztes, kellemes, kicsit idejétmúlt munkák voltak éppen abban az évtizedben, amikor Párizsban mindenki az újat kereste. Kapott kiállításokat itt-ott, hírnevet soha.

A háborús éveiről ő maga több, egymásnak ellentmondó történetet mesélt. Zsidó származása miatt üldözték, ez biztos; később beszélt erdélyi fogolytáborról és német táborról is. Ezeket a részleteket a kutatók nem tudták megerősíteni, sőt: későbbi életrajzírója szerint az édesanyja és a testvére is a túlélők között szerepelt, noha Elmyr máskor azt állította, a szülei odavesztek. Annyi bizonyos, hogy 1945 után egyedül, vagyon nélkül kezdett újra Párizsban.

Aztán jött a véletlen, amiből az egész élete lett. 1946-ban egy angol ismerőse meglátott nála egy tollrajzot, és felkiáltott: ez egy Picasso! Elmyr nem javította ki.

A rajzot ő készítette, egyetlen délután alatt. A hölgy megvette. Így tudta meg negyvenévesen, hogy amihez igazán ért, az nem a saját stílusa, hanem a másoké.

Mert ahhoz tényleg értett. Volt szeme ahhoz, ahogyan egy festő a vonalat húzza — ahhoz a kézíráshoz, amit nagyon nehéz utánozni. És okosan csinálta: nem meglévő képeket másolt le, hanem újakat festett a mesterek modorában.

Ez sokkal veszélyesebb és sokkal meggyőzőbb, mert nincs eredeti, amivel össze lehetne hasonlítani. Modigliani hosszú nyakú asszonyai, Matisse könnyű rajzai, Derain, Van Dongen, Renoir, Picasso: mind megjelentek a keze alól. Régi papírt és régi vásznat szerzett hozzájuk, és állítólag néha egy óra alatt elkészült eggyel.

1947-ben áthajózott Amerikába, és tizenkét éven át járta New Yorkot, Los Angelest, Miamit, Chicagót. Galériáról galériára adta el a képeket, és közben álneveket cserélgetett: Louis Cassou, Joseph Dory, Elmyr Herzog és mások. A Harvard egyetem múzeuma is vásárolt tőle egy Matisse-nak hitt rajzot. Ott bukott meg először. Egy figyelmes kurátor észrevette, hogy a felkínált Modigliani és Renoir gyanúsan ugyanarra a kézre hasonlít, és szólt a többi galériának.

1959-ben Elmyr a mélypontra jutott, és megpróbált véget vetni az életének. Aki ápolta, egy fiatal francia férfi volt, Fernand Legros. Legros hamarosan üzlettársnak ajánlkozott: ő intézi az eladást, jutalékért. A jutalék előbb negyven, aztán ötven százalék lett.

Melléjük állt egy harmadik ember, Réal Lessard, és onnantól ketten járták a világot a képekkel. Elmyr a végén havi négyszáz dollár fizetségért festett nekik, miközben a képei ennek a sokszorosát hozták a kereskedőinek.

1962-ben végleg Ibizára költözött. Ez volt az élete legszebb korszaka. A sziget akkor még olcsó volt, és tele művészekkel, kalandorokkal és olyanokkal, akik nem szerették, ha kérdezgetik őket. Felépült a La Falaise nevű dombtetői ház, jöttek a vacsorák és a híres vendégek. Elmyr pedig festett tovább, csendben, egy nagyon jól fizető hazugság közepén.

A vég Texasból érkezett. Algur H. Meadows olajmilliomos évek alatt tekintélyes modern gyűjteményt vásárolt Legros-tól. 1967-ben kiderült, hogy a képek jelentős része hamis. A leggyakrabban negyven körüli darabot említenek, más beszámolók ennél is többet — a pontos szám máig vitatott.

Meadows viszont nem hallgatott, ahogy a megszégyenült vevők általában szoktak. Feljelentést tett, és a botrány bejárta az egész nemzetközi műkereskedelmet.

Elmyrt ekkor ismerte meg a világ. Ő pedig, meglepő módon, nem bujkált. Interjúkat adott, mosolygott a fényképezőgépekbe, és azt hajtogatta, hogy ő maga soha nem írta rá idegen festő nevét a képeire; szerinte a hamis kézjegyeket a kereskedői tették rájuk. Ezt a mai napig nem lehet teljes bizonyossággal eldönteni.

A spanyol bíróság 1968 nyarán két hónap börtönre ítélte — de nem hamisításért. Azt ugyanis nem tudták rábizonyítani, hogy spanyol földön festett volna akár egyetlen hamisítványt is. A vádpontok ezek voltak: homoszexualitás, ami akkoriban Spanyolországban büntetendő volt, továbbá hogy nincs látható megélhetése, és hogy bűnözőkkel tartja a kapcsolatot. Letöltötte a büntetést, aztán egy évre kitiltották a szigetről.

1969-ben egy ibizai ismerőse, Clifford Irving amerikai író könyvet írt róla. A történet itt kap egy pimasz csavart. Irving néhány évvel később maga is hamisított: 1971-ben elhitette egy nagy kiadóval, hogy a rejtőzködő milliárdos, Howard Hughes rábízta az önéletrajza megírását, és leveleket gyártott hozzá bizonyítéknak. Lebukott, és tizenhét hónapot ült érte. Orson Welles pedig 1973-ban mindkettőjükből filmet csinált, F for Fake címmel, ami nagyjából annyit tesz: H, mint hamisítás.

Franciaország közben nem felejtett. Az ottani hatóságok csalás miatt akarták bíróság elé állítani, és évekig kérték a kiadatását; Spanyolország sokáig nem adta ki.

1976. december 11-én a fiatal titkára, Mark Forgy azzal a hírrel érkezett haza, hogy a két kormány megegyezett. Elmyr még aznap altatót vett be. Forgy segítségért futott, de már késő volt; a hetvenéves festő az ő karjában halt meg. Clifford Irving később kétségbe vonta, hogy valódi öngyilkosság történt, Forgy viszont ezt mindig határozottan visszautasította.

A becslések szerint harminc év alatt több mint ezer hamisítványa került piacra. Hogy ezek közül ma hány lóg múzeumok és gyűjtők falán, más nevek alatt, azt senki sem tudja. A kutatók azóta megvizsgálták a festékeit, és találtak köztük olyan modern színeket, amelyeket a régi mesterek életében még nem is gyártottak — így ma már sok képről kimutatható a csalás, amit akkoriban a szem nem vett észre.

A legszebb fordulat viszont a végére maradt. Elmyr de Hory képeit ma a saját nevén gyűjtik és árverezik: ami hamisításnak készült, abból önálló érték lett. Sőt, néhány éve egy árverésen két olyan festményt kellett visszavonni, amelyeket de Hory hamisítványaiként kínáltak, mert kiderült, hogy azok sem tőle valók. Valaki a hamisítót hamisította.', '1946–1976', 'Budapest, Magyarország és Ibiza, Spanyolország', 'Hamisításért egyetlen bíróság sem ítélte el, és a képei közül több száz máig ott lóg a falakon — csak senki nem tudja, melyik az.', 7, 7),
  ('crime_az_ember_aki_eladta_az_eiffel_tornyot', 'Az ember, aki eladta az Eiffel-tornyot', 'Hamis minisztériumi levélpapír, hat ócskavas-kereskedő és Párizs leghíresebb vasszerkezete, ami éppen nem volt eladó.', '1925 tavaszán egy jól öltözött férfi újságot olvasott egy párizsi kávéházban. A cikk nem volt szenzációs. Arról szólt, hogy az Eiffel-torony sokba kerül: rozsdásodik, néhány évente újra kell festeni, és a városnak nehezére esik állni a számlát. A szerző megemlítette azt is, amit akkoriban sokan mondogattak: a tornyot eredetileg csak ideiglenesnek szánták, talán jobb lenne lebontani.

A férfi letette az újságot. Megvolt az ötlet.

Ennek a férfinak nagyon sok neve volt. A legismertebb: Victor Lustig, vagy ahogy magát hívatta, Lustig gróf. A szokásos adatok szerint 1890. január 4-én született a csehországi Hostinnében — németül Arnauban —, az Osztrák–Magyar Monarchia területén.

Csakhogy itt mindjárt gond van a történettel. Cseh kutatók átnézték a városka korabeli anyakönyveit, és nem találtak róla semmiféle bejegyzést. Lehet, hogy már a születése is hamis papír volt.

Fiatalon az óceánjárókon dolgozott, pontosabban az óceánjárók utasain. Franciaország és New York között hajózott oda-vissza, elegánsan és mosolyogva, és gazdag útitársaknak kínált részesedést nem létező színdarabokban. A hajó tökéletes terep az ilyesmihez: az áldozat egy hétig nem tud kiszállni, a kikötőben pedig mindenki eltűnik a tömegben. Öt nyelven beszélt, és a hatóságok szerint élete során több tucat különböző személyazonosságot használt.

Most viszont nagyobbat akart. Hamisítót fogadott, és csináltatott magának hivatalos külsejű minisztériumi levélpapírt. A rangot, amit választott, elég unalmasra vette ahhoz, hogy igaznak hangozzék: a Posta- és Távírdaügyi Minisztérium főigazgató-helyettese lett.

Hat párizsi ócskavas-kereskedőnek küldött levelet, és sürgős, bizalmas megbeszélésre hívta őket. A helyszín a legtöbb beszámoló szerint a Crillon szálloda volt a Concorde téren, a város egyik legelőkelőbb címe. Ilyen helyre nem hív bárki bárkit.

A szobában Lustig halkan és nyugodtan beszélt. Elmondta, hogy a kormány titkos döntést hozott: az Eiffel-torony fenntartása tovább nem vállalható, le fogják bontani, és a hétezer tonna vasat a legjobb ajánlatot tevő kapja meg. Aztán hangsúlyozta, hogy az ügy rendkívül kényes. A közvélemény háborogni fog, ezért mindent a legnagyobb titokban kell intézni, és amíg a szerződés alá nem íródik, senki egy szót sem szólhat róla.

Ez volt az egész csapda kulcsa. A titoktartás megakadályozta, hogy bárki utánakérdezzen — hiszen ha kérdezősködik, kiesik az üzletből. Bérelt autóval körbevitte a kereskedőket a torony körül, és közben figyelt. Nem a leggazdagabbat kereste, hanem a legbizonytalanabbat.

A választása André Poisson-ra esett. Tehetős ember volt, de új a párizsi üzleti körökben, és nagyon szeretett volna végre odatartozni. Egy ilyen szerződés egy csapásra befutottá tette volna. Poisson felesége viszont gyanakodott: miért ilyen sürgős, és miért egy szállodai szobában intézik?

Erre találta ki Lustig élete legjobb húzását. Négyszemközt „bevallotta” Poisson-nak, hogy ő bizony rosszul fizetett hivatalnok, és hát, ha az úr érti, mire gondol. Vagyis kenőpénzt kért. És ettől lett hirtelen minden hihető: egy csaló nem kér kenőpénzt, egy korrupt francia hivatalnok viszont igen. Poisson megnyugodott, és fizetett.

A beszámolók hetvenezer frankot említenek, ami mai pénzben több százezer dollárnak felel meg, bár a források eltérnek abban, hogy ebből mennyi volt a vételár és mennyi a kenőpénz. Lustig bőröndbe tette a köteget, és vonatra ült Ausztria felé. Aztán napokig olvasta az újságokat, és várta a botrányt. Nem jött semmi. Poisson annyira szégyellte magát, hogy soha nem ment a rendőrségre.

Ez pedig olyan tanulság volt, amit Lustig nem hagyhatott ki. Ha egyszer működött, és nem lett belőle feljelentés, akkor működhet még egyszer. Néhány hónap múlva visszatért Párizsba, új levelek mentek ki, új kereskedők ültek le ugyanabban a szalonban.

Ezúttal viszont valaki gyanút fogott, és elment a rendőrségre. A beszámolók itt szétválnak: egyes források szerint az új vevő már fizetett is egy előleget, mások szerint még idejében lelepleződött az egész. Abban mind egyetértenek, hogy Lustignak futnia kellett, és hajóra szállt Amerika felé.

Odaát volt egy másik kedves trükkje, amit román pénzdoboznak hívtak. Egy szép mahagóni láda volt, rézgombokkal és két nyílással. Lustig betett az egyikbe egy valódi százdollárost és egy üres papírlapot, majd komoly arccal közölte, hogy a gépnek hat óra kell a munkához. Hat óra múlva két százdolláros jött ki belőle — mert a másodikat előre elrejtette a dobozban.

Az áldozat rohant a bankba ellenőriztetni, a bank azt mondta, valódi, és ezután akár harmincezer dollárt is kifizetett a csodagépért. Mire kiderült, hogy a doboz üres fadarab, Lustig már rég máshol járt.

A leghíresebb amerikai története Al Caponéhoz köti. Eszerint ötvenezer dollárt kért a chicagói gengszterfőnöktől egy üzletre, a pénzt két hónapig érintetlenül tartotta egy széfben, majd visszavitte azzal, hogy a dolog nem jött össze. Capone annyira meglepődött a becsületességen, hogy ötezer dollárt ajándékozott neki — és pontosan ez volt az egész terv. Ezt a történetet szinte minden könyv elmeséli, de érdemes tudni, hogy független bizonyíték nem támasztja alá. Könnyen lehet, hogy Lustig maga terjesztette.

A vége viszont nagyon is dokumentált. Az 1930-as években Lustig nagyszabású pénzhamisító hálózatot épített ki. Két segítőtársa, egy gyógyszerész és egy vegyész készítette a nyomólemezeket, ő pedig futárok láncolatát szervezte, akik szétvitték a bankjegyeket az országban — úgy, hogy egyikük sem tudta, honnan jön az áru. A nyomozók egymás közt Lustig-pénznek nevezték a hamis dollárt. Évekig havonta ezrek kerültek forgalomba, és a Secret Service, amelynek az alapítása óta a pénzhamisítás elleni harc volt a fő feladata, lassan az egész amerikai valutát féltette tőle.

Nem szakmai hiba buktatta le, hanem egy megcsalt asszony. A barátnője megtudta, hogy fiatalabb szeretője van, és névtelenül felhívta a hatóságokat. 1935. május 10-én New Yorkban elfogták. A zsebében volt egy kulcs; a kulcs egy Times Square-i csomagmegőrző szekrényhez tartozott, a szekrényben pedig ötvenegyezer dollárnyi hamis bankjegy és maguk a nyomólemezek.

A tárgyalás előtti napon, 1935. szeptember 1-jén Lustig még egyszer megmutatta, mit tud. Betegnek tettette magát, lepedőkből kötelet font, és kimászott a New York-i szövetségi fogház ablakán. Huszonhét napig volt szabadlábon. Pittsburghben fogták el újra.

Ezután már nem tagadott. Bűnösnek vallotta magát, és 1935 decemberében tizenöt év börtönt kapott a pénzhamisításért, plusz ötöt a szökésért. Alcatrazba vitték, a San Franciscó-i öböl szigetére, ahonnan senkinek sem sikerült megszöknie. Ott töltötte az élete hátralevő részét.

1947. március 11-én halt meg tüdőgyulladásban, a missouri Springfieldben, a fogvatartottak szövetségi kórházában. Ötvenhét éves volt. A halotti bizonyítványára nem a gróf került, és nem is a Victor Lustig név, hanem az egyik álneve — a foglalkozás rovatba pedig ezt írták: kereskedősegéd.

Az Eiffel-torony persze áll. 1889-ben épült a világkiállításra, és eredetileg húsz év múlva lebontották volna; végül a tetejére szerelt rádióállomás mentette meg, mert az hasznosnak bizonyult. Amikor Lustig eladta, a torony már harminchat éves volt, és senkinek nem állt szándékában megválni tőle.', '1925', 'Párizs, Franciaország', 'Az Eiffel-torony azóta is áll, a vevő pedig szégyenében soha nem tett feljelentést — hogy ki volt valójában az eladó, arra az anyakönyvek máig nem adnak választ.', 7, 8);

insert into public.crime_videos (
  id, youtube_id, title, channel, summary, case_name, display_order
) values
  ('vid_ovBsyrqRItA', 'ovBsyrqRItA', 'A magyar Seuso-kincsek rejtélye', 'PAXEL', 'A Seuso-kincs egy késő római ezüst étkészlet, amely a hetvenes években került elő Magyarországon, majd csempészek útján Londonba jutott. A film végigköveti, hogyan lett belőle évtizedes nemzetközi műkincsper.', 'Seuso-kincs', 1),
  ('vid_jcSccF9sU7Y', 'jcSccF9sU7Y', 'A Seuso - kincsek rejtélye   (1996)', 'DOKUMENTUMFILMEK, RETRÓ ÉRDEKESSÉGEK', 'Archív magyar televíziós dokumentumfilm 1996-ból a Seuso-kincs ügyéről. Korabeli riportok és szakértők mesélik el, hogyan tűnt el az ezüstkincs az országból.', 'Seuso-kincs', 2),
  ('vid_ZLD5u6Kp954', 'ZLD5u6Kp954', 'A SEUSO-KINCSEK REJTÉLYE - MTV1 1997', 'SLEEP kézműves VHS digi', 'A Magyar Televízió 1997-es dokumentumfilmje a Seuso-kincsről, videókazettáról mentve. Régi hangulatú, alapos összeállítás a kincs útjáról és a körülötte zajló perekről.', 'Seuso-kincs', 3),
  ('vid_sqPKwPouxxw', 'sqPKwPouxxw', 'A Seuso-kincsek rejtélye', 'Patrik Süli', 'Dézsy Zoltán rendező dokumentumfilmje a Seuso-kincsről. A rendező húsz éven át kutatta az ügyet, filmjét maga bűnügyi riport-dokumentumfilmnek nevezte.', 'Seuso-kincs', 4),
  ('vid_x-WmfU34vGo', 'x-WmfU34vGo', 'Seuso-kincsek titka - 2. rész  (2017. 15. hét)', 'KisDuna TV', 'Dézsy Zoltán filmrendező vetítéses előadásának második része a Seuso-kincsről, a Laffert Kúriában rögzítve. Nyugodt tempójú, részletes beszámoló a kutatásairól.', 'Seuso-kincs', 5),
  ('vid_DYr8S6q-okg', 'DYr8S6q-okg', 'A Seuso kincs legendája (teljes - fejezetcímkézve)', 'Strange places, old castles, abandoned areas', 'Zele Richárd kutató teljes interjúanyaga a Seuso-kincsről: helyszíni bejárások, talajradar, szemtanúk. Hosszú, fejezetekre bontott összeállítás azoknak, akik minden részletre kíváncsiak.', 'Seuso-kincs', 6),
  ('vid_sUIcMaqC7tw', 'sUIcMaqC7tw', 'A Seuso kincs legendája - 2019', 'Strange places, old castles, abandoned areas', 'Dokumentumfilm arról, hogyan találhatott rá Sümegh József a hetvenes években a felbecsülhetetlen értékű római ezüstkészletre, és miért maradt máig nyitott kérdés a kincs sorsa.', 'Seuso-kincs', 7),
  ('vid_Kx-4xPeUSUk', 'Kx-4xPeUSUk', 'PATENT - A Seuso-kincs nyomában', 'hpluszmédia', 'Riportfilm a Seuso-kincs nyomában: honnan kerültek elő az ezüstök, kik kereskedtek velük, és hogyan jutott vissza egy részük Magyarországra.', 'A Seuso-kincs', 8),
  ('vid_15nZ3VLUI9I', '15nZ3VLUI9I', 'I. „Seuso Kedd” - a rejtélyek nyomában', 'Fehérvár Televízió', 'Kötetlen beszélgetés kutatókkal a Seuso-kincsről: mit tudunk a leletről, és mi az, ami körülötte máig vitatott.', 'A Seuso-kincs', 9),
  ('vid_HljuArqm9xE', 'HljuArqm9xE', 'Rózsa Sándor - mítoszok vs. valóság - M5 História, 2023. november 18.', 'M5', 'A közmédia történelmi műsora a leghíresebb magyar betyárról. Tényleg soha nem hazudott a betyárok vezére, vagy a népi emlékezet szépítette meg a történetét?', 'Rózsa Sándor', 10),
  ('vid_kCVeXKK5bts', 'kCVeXKK5bts', 'Betyárok, a magyar banditák - M5 História', 'M5', 'A hatóságok szemében törvényen kívüliek, a nép szemében hősök. Mátay Mónika történész mesél Sobri Jóskáról, Vidróczkiról és Rózsa Sándorról az M5 História adásában.', 'A magyar betyárvilág', 11),
  ('vid_7gF11jH6Rhw', '7gF11jH6Rhw', 'Csillagösvényen - Betyárvilág', 'boczy', 'Dokumentumfilm a betyárokról: közönséges bűnözők voltak, vagy a nép jótevői? Szó esik arról is, hogyan harcolt Rózsa Sándor a csapatával a szabadságharcban.', 'A magyar betyárvilág', 12),
  ('vid_d66_8AggYUI', 'd66_8AggYUI', 'Ultrahang történelem: Rózsa Sándor gyilkos vagy nemzeti hős volt? - Szentesi Zöldi László', 'Ultrahang Plusz', 'Hosszú, nyugodt beszélgetés Szentesi Zöldi László újságíróval arról, ki is volt valójában Rózsa Sándor, és miért lett belőle nemzeti legenda.', 'Rózsa Sándor', 13),
  ('vid_29temqeq128', '29temqeq128', 'Rózsa Sándor a legendás betyárkirály (teljes film)', 'madeinhungarysorozat', 'Ismeretterjesztő film a betyárkirály életéről: a szegényekről szóló történetek, a bujdosás évei és a legenda születése.', 'Rózsa Sándor, a betyárkirály', 14),
  ('vid_SYTeSfVvJlc', 'SYTeSfVvJlc', 'Rózsa Sándor nagy vonatrablása', 'Üveges Huba történész, író', 'Egy történész meséli el Rózsa Sándor híres vonatrablását: hogyan készültek rá a betyárok, és mi lett az ügy vége.', 'Rózsa Sándor vonatrablása', 15),
  ('vid_NG-8-u1-qKk', 'NG-8-u1-qKk', 'A MAGYAR BETYÁRSÁG TÖRTÉNETE - MÍTOSZOK, LEGENDÁK, és a VALÓSÁG', 'G.V. Cooper History', 'Hosszú ismeretterjesztő összeállítás a 18–19. századi magyar betyárvilágról: honnan eredt, hogyan lett valakiből betyár, kik voltak a leghíresebbek, és mikor ért véget ez a korszak.', 'A magyar betyárvilág', 16),
  ('vid_cV_mllc_q-I', 'cV_mllc_q-I', 'Jeges - dokumentumfilm', 'HÍR TV+', 'Az 1950-es években Székelyföld erdeiben betyárok bujkáltak a kommunista hatalom elől. A film szemtanúk és egykori fogolytársak visszaemlékezéseiből idézi föl Jeges, a kászonújfalui betyár életét.', 'Jeges, a székelyföldi betyár', 17),
  ('vid_HmwnPfQ0FDc', 'HmwnPfQ0FDc', 'Székelyföldi betyárok - teljes film', 'Berekméri Dalma', 'Egész estés dokumentumfilm a székelyföldi betyárokról, a rejtekhelyeikről és a róluk szóló legendákról, helyi elbeszélők tolmácsolásában.', 'Székelyföldi betyárok', 18),
  ('vid_jP7OcSuZNLc', 'jP7OcSuZNLc', 'Betyárok, ​pandúrok és egyéb régi hírességek 05', 'Ivan Joe', 'Régi történetek az alföldi puszták betyárjairól és az őket üldöző pandúrokról. Hosszú, mesélős összeállítás a nádasok és csárdák világából.', 'Betyárok és pandúrok', 19),
  ('vid_tuSF6SdTtiE', 'tuSF6SdTtiE', 'Betyárok, ​pandúrok és egyéb régi hírességek 04', 'Ivan Joe', 'A sorozat másik része a régi magyar betyárvilágról: hírhedt útonállók, a nyomukban járó pandúrok és a köréjük szőtt legendák.', 'Betyárok és pandúrok', 20),
  ('vid_njuUY5hGtDc', 'njuUY5hGtDc', 'A viszkis rabló balladája - Szökésben , dokumentum film', 'Karcsi N', 'Egész estés dokumentumfilm Ambrus Attiláról, a „viszkis rablóról”, aki egykor jégkorongozó volt, majd közel harminc bankot és postát rabolt ki álruhában. A film a nyomozást és a hírhedt szökését meséli el.', 'Ambrus Attila, a viszkis rabló', 21),
  ('vid_pXDIKwleMGI', 'pXDIKwleMGI', 'Újranyitott akták (2017-11-16) - Echo Tv', 'HÍR TV+', 'Az Echo Tv bűnügyi magazinjában maga Ambrus Attila, a „viszkis rabló” beszél a múltjáról. Elmondja, hogyan tervezte a rablásait, és hogyan maszkírozta el magát.', 'Ambrus Attila, a viszkis rabló', 22),
  ('vid_T9rxIErEtxQ', 'T9rxIErEtxQ', 'A legzordabb magyar börtönökből nincs menekvés? - Szökése titkairól beszél Ambrus Attila, a Viszkis', 'Blikk', 'A Blikk stábja bejárja a szegedi Csillag és a sátoraljaújhelyi fegyház zárt világát. Ambrus Attila elmeséli, hogyan sikerült megszöknie a Gyorskocsi utcából – száz év alatt rajta kívül senkinek sem sikerült.', 'Szökés a Gyorskocsi utcából', 23),
  ('vid_mW7Ro4Siorg', 'mW7Ro4Siorg', 'A viszkis utolsó bankrablásának és elfogásának története', 'Labanc Ferenc - Minden Zsaruszemmel', 'A viszkis rabló utolsó bankrablásának és az elfogásának a története, rendőri szemszögből elmesélve. Rövidebb, nyugodt tempójú visszaemlékezés a nyomozásra.', 'Ambrus Attila elfogása', 24),
  ('vid_yEk4YneqQzc', 'yEk4YneqQzc', 'Ambrus Attila: Hogyan lett egy hokis Magyarország leghíresebb bankrablója? Hihetetlen ügy', 'László Kovács – Köd a Dunán', 'Hosszú beszélgetés a Viszkis rabló életéről: a nehéz gyerekkorról, a jégkorongról, a bankrablások éveiről és a börtön utáni új életről.', 'A Viszkis rabló (Ambrus Attila)', 25),
  ('vid_aOmsT31V1mU', 'aOmsT31V1mU', 'Kékfény 2008 03 03', 'Film Archív', 'A legendás magyar bűnügyi magazin, a Kékfény egy teljes adása 2008-ból. Régi ügyek, körözések és nyomozati beszámolók a megszokott formában.', 'Kékfény archív adás', 26),
  ('vid_WZxJZFFRAfQ', 'WZxJZFFRAfQ', 'A KÉK FÉNY ÁRNYÉKÁBAN: Bűntények és a Kádár-kor sötét oldala', 'Régi szép idők', 'Korrajz a hetvenes-nyolcvanas évek Magyarországáról: tényleg olyan jó volt a közbiztonság, mint amilyennek mondták, vagy szépítették a statisztikákat? Sok korabeli fotóval.', 'Bűnözés a Kádár-korban', 27),
  ('vid_GEwLzxDjLN8', 'GEwLzxDjLN8', 'A magyar korona rejtélye', 'PAXEL', 'A Szent Korona kalandos története: rejtegetések, elrablások, országhatárokon átvitt titkos szállítmányok. Hogyan került a korona Amerikába, és hogyan jutott végül haza?', 'A Szent Korona viszontagságai', 28),
  ('vid_rn7wimY5Row', 'rn7wimY5Row', 'A KORONA ELRABLÁSA - KOTTANNER ILONA', 'Szilágyi Béla László IDŐVONAL', '1440 egyik legmerészebb lopása: hogyan emelte ki Kottanner Ilona udvarhölgy a Szent Koronát a visegrádi várból, és hogyan vitte át az országon.', 'A Szent Korona ellopása (1440)', 29),
  ('vid_OYIz3b3Eefk', 'OYIz3b3Eefk', 'Az Aranyvonat rejtélye: Hová tűnt Magyarország nemzeti kincse 1945-ben?', 'Csendes Tudás', '1945-ben hetven vagonnyi arany, ezüst és műkincs indult el Nyugat felé az úgynevezett Aranyvonaton. A film azt járja körül, mi lett a rakomány sorsa, és mi került vissza belőle Magyarországra.', 'Az Aranyvonat', 30),
  ('vid_Msi8wfGQO7E', 'Msi8wfGQO7E', 'Hová tűnt Petőfi Sándor?', 'PAXEL', 'Mi történt Petőfi Sándorral Segesvárnál? A videó sorra veszi az eltűnéséről szóló elméleteket, és azt, melyiket mi támasztja alá.', 'Petőfi Sándor eltűnése (1849)', 31),
  ('vid_P3sivhLWnKw', 'P3sivhLWnKw', 'PETŐFI SÁNDOR ÉLETE ÉS REJTÉLYES ELTŰNÉSE - 8 ÉRDEKES TÉNY A SZABADSÁGHARC KÖLTŐJÉRŐL', 'G.V. Cooper History', 'Petőfi Sándor élete és rejtélyes eltűnése nyolc érdekes tényen keresztül, a legendák és a fennmaradt források szétválasztásával.', 'Petőfi Sándor eltűnése (1849)', 32),
  ('vid_k2sZhr2Z744', 'k2sZhr2Z744', 'A Magyar olajmaffia, olajszőkítés, olajügyek', 'PAXEL', 'Ismeretterjesztő összeállítás a rendszerváltás utáni évek legnagyobb magyar gazdasági csalásáról, az olajszőkítésről. Hogyan lehetett a fűtőolajból egy vegyszerrel milliárdokat érő üzemanyag?', 'Olajszőkítés', 33),
  ('vid_10PgeIzSjy8', '10PgeIzSjy8', 'A tiszazugi arzénes asszonyok', 'PAXEL', 'Az 1920-as évek egyik legismertebb magyar bűnügye. A videó azt mutatja be, hogyan derült fény a tiszazugi esetekre, és hogyan zajlott a nyomozás és a per.', 'A tiszazugi arzénes asszonyok (1929)', 34),
  ('vid_PskkA7prdyA', 'PskkA7prdyA', 'Újranyitott akták (2017-11-23) - Echo Tv', 'HÍR TV+', 'Farkas Helga huszonhat éve tűnt el nyomtalanul. Ami eltűnési ügynek indult, abból emberrablási nyomozás lett – a magyar bűnügyi történet egyik legismertebb máig megoldatlan rejtélye.', 'Farkas Helga eltűnése', 35),
  ('vid_LVSvoSf-r6k', 'LVSvoSf-r6k', 'Farkas Helga eltűnése – 33 éve megoldatlan rejtély és zavaros teóriák', 'BŰNtények Podcast', 'Az 1991-ben elrabolt, akkor 18 éves lány ügye: mit tártak fel a nyomozók, milyen elméletek születtek, és miért maradt máig megoldatlan.', 'Farkas Helga eltűnése (1991)', 36),
  ('vid_edg8S5PdqD8', 'edg8S5PdqD8', 'A Farkas Helga-ügy (eredeti helyszíneken)', 'Magyar népi történelem', 'A Farkas Helga-ügy végigjárása az eredeti helyszíneken. 1991 nyarán tűnt el a lány Orosháza és Szeged között, autóját az algyői hídnál találták meg.', 'Farkas Helga eltűnése (1991)', 37),
  ('vid_gKg3jVjlDto', 'gKg3jVjlDto', 'A Csalókirály - eladta a Nyugati pályaudvart, gyógyított, és misézett a szélhámos álplébános', 'Blikk', 'Bósa István, a szélhámos álplébános története. Eladta a Nyugati pályaudvart, főorvosként tartott nagyvizitet, és papként misézett – mindenki bedőlt neki. A magyar „Kapj el, ha tudsz”.', 'Bósa István, a szélhámos álplébános', 38),
  ('vid_AcqzNIvFwTQ', 'AcqzNIvFwTQ', 'Így trükköznek a szerelem csalói! | A bűn kereskedői [TELJES FILM]', 'National Geographic Magyarország', 'A National Geographic magyar nyelvű sorozata a társkereső oldalak szélhámosairól. Mariana van Zeller riporter felkeresi a csalókat, és megmutatja, milyen trükkökkel szedik ki az emberekből a pénzt.', 'Online szerelmi csalások', 39),
  ('vid_QWKEVtOds_Y', 'QWKEVtOds_Y', 'MTV2 Kriminális 1996.12.05 (21:15)', 'BT VHS', 'A Magyar Televízió egykori bűnügyi magazinja, a Kriminális Juszt Lászlóval, 1996 decemberéből, videókazettáról mentve. Igazi korabeli hangulat, reklámokkal együtt.', 'Kriminális (MTV2) archív adás', 40),
  ('vid_zEZu-S7tKxw', 'zEZu-S7tKxw', 'Az elképesztő Gyatlov-rejtély - nagyon bővített verzió', 'Random', '1959-ben kilenc tapasztalt orosz túrázó veszett oda az Urál hegyeiben, tisztázatlan körülmények között. A film sorra veszi az összes máig élő magyarázatot a lavinától a titkosszolgálati elméletekig.', 'Gyatlov-hágó rejtélye', 41),
  ('vid_OHyX-vtZZ80', 'OHyX-vtZZ80', 'AZ ELSŐ MAGYAR BANKRABLÁS története', 'G.V. Cooper History', '1908 októberében két férfi lépett be a Pesti Magyar Kereskedelmi Bank újpesti fiókjába, és ezzel megtörtént az első bankrablás Magyarországon. A műsor elmeséli, kik voltak ők, hogyan zajlott a délelőtt, és mi lett a menekülésük vége.', 'Az első magyarországi bankrablás, Újpest, 1908', 42),
  ('vid_mk5t00M2XPE', 'mk5t00M2XPE', 'A szegedi boszorkányperek: a magyar történelem legbrutálisabb boszorkányüldözése', 'Nők a történelemben', 'Az 1728-as szegedi boszorkányperek története: hogyan indultak a vádak, hogyan folytak a tárgyalások, és miért maradtak meg a köztudatban.', 'A szegedi boszorkányperek (1728)', 43),
  ('vid_wYWxVgCnUnk', 'wYWxVgCnUnk', 'Magyar bankrablások, amiknél sok millió tűnhetett volna el', 'Tízes Lista', 'Rövid összefoglaló a leghíresebb magyar bankrablásokról: melyik hogyan zajlott, és hogyan bukott le a tettes.', 'Híres magyar bankrablások', 44),
  ('vid_Gho11jCqRFk', 'Gho11jCqRFk', 'Az ólommaszkos férfiak rejtélye', 'PAXEL', '1966-ban két férfit találtak egy brazil domboldalon, ólomból készült szemellenzővel és egy különös, kézzel írt cédulával. Az esetre azóta sincs elfogadott magyarázat.', 'Az ólommaszkos férfiak (1966)', 45),
  ('vid_FhbKPOKn_wA', 'FhbKPOKn_wA', 'A CSILLAG - Börtönfilm', 'DOKUMENTUMFILMEK, RETRÓ ÉRDEKESSÉGEK', 'Dokumentumfilm a szegedi Csillag börtön zárt világáról: a mindennapokról, az őrökről és a rabokról, csendes, megfigyelő hangvételben.', 'A szegedi Csillag börtön', 46),
  ('vid_aNbs_I545Ao', 'aNbs_I545Ao', 'A Kádár-korszak feketepiaca: Hogyan működött az illegális kereskedelem a szocializmusban?', 'Látens', 'Hogyan működött a szocializmus idején a feketepiac: csempészet, üzérkedés, farmer és kávé a pult alatt, és mit tett ellene a hatóság.', 'A Kádár-kori feketepiac', 47),
  ('vid_-QOifmJF0Bg', '-QOifmJF0Bg', 'Újranyitott akták (2017-12-28) - ECHO TV', 'HÍR TV+', 'Az Echo Tv bűnügyi magazinja két pénzszállítós rablás aktáját nyitja ki újra. Hogyan készültek a tettesek, és mi buktatta le őket végül?', 'Pénzszállító-rablások', 48),
  ('vid_pn34IeNE7jQ', 'pn34IeNE7jQ', 'LEGENDÁS NÁCI KINCSEK NYOMÁBAN - Rommel aranya, a Borostyánszoba, és egyéb történetek', 'G.V. Cooper History', 'A második világháború nagy műkincsrablásai és az azóta sem előkerült kincsek: Rommel aranya, a Borostyánszoba és egy százmillió dollárt érő festmény nyomában.', 'Náci műkincsrablások', 49),
  ('vid_EUae0J7v434', 'EUae0J7v434', 'KÁNIKULAI DÉLUTÁN - Egy hihetetlen bankrablás története', 'G.V. Cooper History', '1972 egyik forró augusztusi napján három férfi rontott be egy brooklyni bankba, a rablásból pedig órákon át tartó, a tévében élőben követett dráma lett. A történet arról szól, mi hajtotta őket, és hogyan lett az esetből világhír.', 'A brooklyni bankrablás, 1972', 50),
  ('vid_q6YN-fltSfI', 'q6YN-fltSfI', 'AMIBE BELEBUKOTT EGY KORMÁNY - A WATERGATE BOTRÁNY ELKÉPESZTŐ TÖRTÉNETE', 'G.V. Cooper History', '1972-ben öt betörőt fogtak el a Demokrata Párt washingtoni irodájában, lehallgatókészülékekkel és fényképezőgépekkel a zsebükben. Két riporter addig kutatott a szálak után, amíg az ügy az amerikai elnököt is megbuktatta.', 'A Watergate-botrány', 51),
  ('vid_EMp-Z7_LzAE', 'EMp-Z7_LzAE', 'BUTCH CASSIDY, a SUNDANCE KÖLYÖK és a VAD BANDA TÖRTÉNETE - A HÍRHEDT BANDITAPÁROS REJTÉLYES HALÁLA', 'G.V. Cooper History', 'Butch Cassidy bandája bankokat és vonatokat rabolt ki a vadnyugaton, gondosan megtervezett akciókkal, a vezetőjük pedig büszke volt rá, hogy sosem ölt. A film a legendájukról szól, és a máig vitatott halálukról.', 'Butch Cassidy és a Sundance Kölyök', 52),
  ('vid_y-S57TrubJ0', 'y-S57TrubJ0', 'BILLY, A KÖLYÖK, A HÍRHEDT VADNYUGATI BANDITA - TÉNYLEG VÉGZETT 21 EMBERREL? - Legendák és tények', 'G.V. Cooper History', 'Billy, a Kölyök alig huszonegy évet élt, mégis a vadnyugat leghíresebb törvényen kívülije lett. A műsor szétválasztja a legendát és a tényeket: valóban végzett-e huszonegy emberrel, és miért terjedt el róla, hogy nem is halt meg.', 'Billy, a Kölyök', 53),
  ('vid_np4bxMUso0k', 'np4bxMUso0k', 'A BEALE KÓD REJTÉLYE - SIKERÜL VALAHA MEGFEJTENI?', 'G.V. Cooper History', 'Egy virginiai fogadóban hagyott láda három, számokkal teleírt papírlapot rejtett, amelyek a legenda szerint egy elásott kincs helyét adják meg. Az egyik lapot megfejtették, a másik kettővel több mint száz éve senki nem boldogul.', 'A Beale-kódok', 54),
  ('vid_FT3jMNi7fg0', 'FT3jMNi7fg0', 'A TAMÁM SHUD AKTA - A SOMERTONI FÉRFI REJTÉLYE - A világ legbrutálabb 289. epizód', 'G.V. Cooper', '1948 decemberében egy elegánsan öltözött férfit találtak egy ausztrál tengerparton, és senki nem tudta megmondani, ki ő. A rejtett zsebében egy papírcetli lapult ezzel a két szóval: Tamám Shud. Az ügy azóta is foglalkoztatja a nyomozókat.', 'A somertoni férfi (Tamám Shud-ügy), 1948', 55),
  ('vid_c7kHupvjwM0', 'c7kHupvjwM0', 'Agatha Christie rejtélyes eltűnése', 'Random', '1926 decemberében a világ legismertebb krimiírója egyik napról a másikra eltűnt: az autóját megtalálták egy árokparton, őt magát tizenegy napig sehol. A film azt járja körül, mi történhetett valójában Agatha Christie-vel.', 'Agatha Christie eltűnése, 1926', 56),
  ('vid_j0q3tadgS5M', 'j0q3tadgS5M', 'D.B. Cooper és a tökéletes bűntény', 'Random', '1971-ben egy öltönyös, udvarias férfi eltérített egy utasszállító gépet, átvette a váltságdíjat, majd ejtőernyővel kiugrott az éjszakába. Soha nem került elő, és a nyomozás máig nem tudja, ki volt.', 'D. B. Cooper gépeltérítése, 1971', 57),
  ('vid_4pYjdzX-OdQ', '4pYjdzX-OdQ', 'Dorothy Arnold eltűnése és a rejtélyes utolsó levél', 'Random', '1910 karácsonya előtt egy jómódú fiatal New York-i nő elindult vásárolni az Ötödik sugárúton, és soha többé nem látták. A film a nyomozást követi végig, és a különös utolsó levelét.', 'Dorothy Arnold eltűnése, 1910', 58),
  ('vid_5UQXII9y7xU', '5UQXII9y7xU', 'A Mona Lisa elrablása', 'Félsötét', '1911 augusztusában eltűnt a Louvre faláról a Mona Lisa, és két évig nem került elő. A tolvaj nem profi bűnöző volt, hanem egy olasz szobafestő, Vincenzo Peruggia, aki úgy hitte, hazaviszi a festményt Olaszországba.', 'A Mona Lisa ellopása, 1911', 59),
  ('vid_9sJw86UrnCQ', '9sJw86UrnCQ', 'Glico-Morinaga eset /A 21 arcú szörnyeteg/', 'PiXiS', '1984-ben egy magát 21 arcú szörnyetegnek nevező csoport elrabolta a japán Glico édességgyár elnökét, majd hónapokon át zsarolta a céget és a rendőrséget gúnyos levelekkel. Az ügyet máig nem oldották meg.', 'A Glico-Morinaga-ügy, Japán, 1984', 60),
  ('vid_-Oz44HLvIMQ', '-Oz44HLvIMQ', 'Rejtély a 2805-ös szobában - Ki volt Jennifer Fairgate?', 'Petra Daniella', '1995-ben egy fiatal nő hamis névvel jelentkezett be az oslói Plaza Hotel 2805-ös szobájába, és néhány nap múlva holtan találták. Máig senki nem tudja, ki volt valójában és honnan érkezett.', 'Jennifer Fairgate, Oslo Plaza Hotel, 1995', 61),
  ('vid_fci6MiQUQhI', 'fci6MiQUQhI', 'Hitler naplói – A történelem legnagyobb csalásai', 'Érdekes Filmklub', '1983-ban a Stern magazin 9,3 millió márkát fizetett Hitler állítólagos naplóiért, és világszenzációt jelentett be. A hatvan füzetet valójában egy Konrad Kujau nevű férfi írta – ez lett a század egyik legnagyobb hamisítási botránya.', 'A Hitler-naplók hamisítása, 1983', 62),
  ('vid_UqmC8aBpC9Y', 'UqmC8aBpC9Y', 'A piltdowni ember – A történelem legnagyobb csalásai', 'Érdekes Filmklub', '1912-ben Angliában előkerült egy koponya, amelyet a hiányzó láncszemnek hittek, és évtizedekig félrevezette a tudományt. Csak 1953-ban derült ki, hogy az egész egy gondosan megtervezett hamisítvány volt.', 'A piltdowni ember', 63),
  ('vid_rq9hYmia51w', 'rq9hYmia51w', 'Világok harca – A történelem legnagyobb csalásai', 'Érdekes Filmklub', '1938-ban Orson Welles rádiójátéka állítólag pánikba kergette Amerikát a marslakók támadásának hírével. A film megmutatja, mi történt valójában aznap este, és mennyit tettek hozzá a másnapi újságok.', 'A Világok harca rádiójáték, 1938', 64),
  ('vid_3ONNMAwDJ98', '3ONNMAwDJ98', 'A Loch Ness-i szörny – A történelem legnagyobb csalásai', 'Érdekes Filmklub', 'A Loch Ness-i szörny modern legendája 1933-ban indult el néhány szemtanú beszámolójával és egy fényképpel. A film sorra veszi a fotókat és a vizsgálatokat, és megmutatja, melyikről derült ki, hogy átverés volt.', 'A Loch Ness-i szörny', 65),
  ('vid_JfAoy7TvTNo', 'JfAoy7TvTNo', 'Földönkívüli boncolása – A történelem legnagyobb csalásai', 'Érdekes Filmklub', '1995-ben harminckét ország tévéi mutattak be egy filmtekercset, amelyen állítólag egy földönkívüli boncolása látható. A film azt meséli el, hogyan készült a felvétel, és ki állt mögötte.', 'A földönkívüli boncolása című film, 1995', 66),
  ('vid_U0h2M4te12k', 'U0h2M4te12k', 'Pillangó – A történelem legnagyobb csalásai', 'Érdekes Filmklub', 'Henri Charrière Pillangó című könyve a francia fegyenctelepről való szökéseiről szól, és egy év alatt egymillió példányban fogyott el. A film azt vizsgálja, mennyi volt az egészből valóban az ő saját története.', 'Pillangó – Henri Charrière', 67),
  ('vid_SPC8cHmAmoM', 'SPC8cHmAmoM', 'Az Isabella Gardner Múzeum rejtélye', 'Karolina - magyarul', '1990 márciusában két rendőrnek öltözött férfi sétált be a bostoni Isabella Stewart Gardner Múzeumba, és tizenhárom műtárgyat vittek el. A világ legnagyobb megoldatlan műkincsrablása: a képek azóta sem kerültek elő.', 'Az Isabella Stewart Gardner Múzeum kirablása, 1990', 68),
  ('vid_4lCwuT8aA_U', '4lCwuT8aA_U', 'A Theranos botrány - Elizabeth Holmes és Ramesh “Sunny” Balwani esete', 'Karolina - magyarul', 'Elizabeth Holmes cége azt ígérte, egyetlen csepp vérből több száz betegséget képes kimutatni, és milliárdokat gyűjtött be rá. A készülék soha nem működött úgy, ahogy mondták – ez lett a Szilícium-völgy egyik legnagyobb csalása.', 'A Theranos-botrány', 69),
  ('vid_XfECUwVHPMY', 'XfECUwVHPMY', 'Energol-dosszié', 'SIRIAT', 'Dokumentumfilm az Energol-ügyről, a rendszerváltás utáni évek egyik legnagyobb pénzügyi botrányáról.', 'Az Energol-ügy', 70),
  ('vid_N01Brh4fD3c', 'N01Brh4fD3c', 'Rejtélyes gyilkosság az 1046-os szobában - nagyon bővített verzió', 'Random', '1935-ben egy Kansas City-i szálloda 1046-os szobájában olyan vendég szállt meg, akinek a kiléte körül máig vita van. A krimitörténet egyik klasszikus, lezáratlan ügye.', 'Az 1046-os szoba (1935)', 71),
  ('vid_FB4X9TuLpZc', 'FB4X9TuLpZc', 'A szamoai szellemhajó eltűnt legénysége', 'Random', 'Egy hajót legénység nélkül, sodródva találtak meg a Csendes-óceánon. Hogy mi történt a fedélzeten, máig nem tudni.', 'A Joyita szellemhajó (1955)', 72),
  ('vid_Hmcq3wyQQVY', 'Hmcq3wyQQVY', 'A három springfieldi nő hátborzongató eltűnése - nagyon bővített verzió', 'Random', '1992-ben három nő tűnt el egyetlen éjszaka alatt egy amerikai kisvárosi házból. A házban minden a helyén maradt, ők maguk viszont soha nem kerültek elő.', 'A springfieldi hármas eltűnés (1992)', 73),
  ('vid_sF4jB4SVjNk', 'sF4jB4SVjNk', 'Claudia Lawrence rejtélyes eltűnése - nagyon bővített verzió', 'Random', 'Egy angliai szakácsnő 2009-ben eltűnt a munkába vezető úton. A nyomozás évekig tartott, megnyugtató válasz azonban máig nincs.', 'Claudia Lawrence eltűnése (2009)', 74),
  ('vid_4B5UfRfGg9E', '4B5UfRfGg9E', 'Dorothy Scott döbbenetes elrablása', 'Random', '1980-ban egy fiatal nő hónapokon át fenyegető telefonokat kapott egy ismeretlentől, majd egy este eltűnt a kórház parkolójából. Az ügy máig megoldatlan.', 'Dorothy Jane Scott (1980)', 75),
  ('vid_zyE16-tt1z4', 'zyE16-tt1z4', 'A D.B. Cooper rejtély', 'PAXEL', 'A férfi, aki 1971-ben a váltságdíjjal a kezében ejtőernyővel ugrott ki az utasszállítóból, és nyomtalanul eltűnt. Rövidebb, végigmesélt összefoglaló az ügyről.', 'D. B. Cooper (1971)', 76),
  ('vid_6NGIUgTjafs', '6NGIUgTjafs', 'Voynich-kézirat: MEGOLDVA?', 'PAXEL', 'A Voynich-kézirat ismeretlen írással és furcsa rajzokkal teli könyv, amit száz éve senki nem tudott elolvasni. Ügyes hamisítvány vagy valódi titok?', 'A Voynich-kézirat', 77),
  ('vid_RDeizN-FzGM', 'RDeizN-FzGM', '5 különös és megoldatlan rejtély', 'PAXEL', 'Öt különös, máig megoldatlan eset egy csokorban, nyugodt tempóban végigmesélve.', 'Megoldatlan esetek – válogatás', 78),
  ('vid_7E7bvHNFh4U', '7E7bvHNFh4U', 'A tringi múzeumi rablás és az elveszett tollak rejtélye', 'Karolina - magyarul', 'Egy fiatal zenész éjjel betört egy angol természettudományi múzeumba, és ritka madárbőröket lopott el. A tollakat horgászlegyekhez adta el – különös, szinte hihetetlen bűnügy.', 'A tringi múzeum madárbőr-lopása (2009)', 79),
  ('vid_1iPw_ygwbfE', '1iPw_ygwbfE', 'Rejtély a metrón - Laetitia Toureaux gyilkossága', 'Karolina - magyarul', '1937-ben egy fiatal nőt holtan találtak egy párizsi metrókocsiban, ahová rajta kívül senki nem szállhatott be. A zárt kocsi rejtélye máig megoldatlan.', 'Laetitia Toureaux (Párizs, 1937)', 80),
  ('vid_5IQ_vJWcofM', '5IQ_vJWcofM', 'Interpol akták - A fáraó kincse', 'Dokumánia', 'Egy angol műtárgyszakértő értéktelen giccsnek álcázva csempészte ki Egyiptomból a fáraók kincseit. A Scotland Yard, az Interpol és az egyiptomi rendőrség együtt göngyölítette fel a hálózatot.', 'Egyiptomi műkincscsempészet – Interpol akták', 81),
  ('vid_k4-Baanh9TU', 'k4-Baanh9TU', 'Interpol akták - Az Albert Walker ügy', 'Dokumánia', 'Albert Walker milliókat csalt ki ügyfeleitől és kollégáitól, majd külföldre szökött, és más nevén élt tovább. A brit és a kanadai rendőrség közösen jutott a nyomára.', 'Albert Walker – Interpol akták', 82),
  ('vid_sHqU3yk0D7o', 'sHqU3yk0D7o', 'Interpol akták - Az áruló', 'Dokumánia', '1985-ben egy amerikai razzián lefoglalt, hatalmas értékű szállítmány egy részének nyoma veszett. A gyanú végül a saját ügynökökre terelődött.', 'Darnell Garcia ügye – Interpol akták', 83),
  ('vid_yz6geIoBYn8', 'yz6geIoBYn8', 'A tíz leghírhedtebb kém - Dokumentumfilm | Ten most famous spies - Documentary', 'Érdekes Filmklub', 'Tíz híres kém története: kik voltak, hogyan dolgoztak, és végül min buktak le.', 'Híres kémek', 84),
  ('vid_OLPTbuNhONY', 'OLPTbuNhONY', 'A történelem legnagyobb csalásai - Hitler naplói', 'TheMindennapok', '1983-ban egy német magazin világszenzációt jelentett be: megtalálták Hitler naplóit. Néhány hét múlva kiderült, hogy az egészet egy ügyes hamisító írta.', 'A Hitler-naplók hamisítása (1983)', 85),
  ('vid_NO9ofsMped4', 'NO9ofsMped4', 'A kettős élet mestere – Jean‑Claude Romand és a francia kriminalisztika legmegdöbbentőbb ügye', 'BŰNtények Podcast', 'Jean-Claude Romand tizennyolc éven át azt játszotta, hogy orvosként dolgozik egy nemzetközi szervezetnél. Valójában soha nem szerzett diplomát – a történet a lelepleződésig vezet.', 'Jean-Claude Romand (Franciaország)', 86),
  ('vid_VG36YAF9Clw', 'VG36YAF9Clw', 'A Grabbe‑ügy – A feleség, aki nyomtalanul eltűnt, és a szerető sokkoló vallomása', 'BŰNtények Podcast', 'Egy asszony nyomtalanul eltűnt otthonról, és sokáig semmi nem került elő. A fordulatot évekkel később egy vallomás hozta meg.', 'A Grabbe-ügy (Németország)', 87),
  ('vid_8-nltGWVExE', '8-nltGWVExE', 'A Sherri Rasmussen-ügy- 23 évig megoldatlan', 'Sötét oldal', 'Egy 1986-os Los Angeles-i ügy huszonhárom évig megoldatlan maradt. Egy régi bizonyíték újravizsgálata azután egészen meglepő irányba vitte a nyomozást.', 'Sherri Rasmussen (Los Angeles, 1986)', 88),
  ('vid_PuWy-GgxGGA', 'PuWy-GgxGGA', 'A nagy kommunista bankrablás', 'Channel Planet', '1959 augusztusában Bukarestben kirabolták a Román Nemzeti Bank pénzszállítóját, és a tettesek egy elkötött taxival menekültek el 1,6 millió lejjel. A kommunista Románia leghíresebb rablása.', 'A bukaresti bankrablás (1959)', 89),
  ('vid_0eDNXgw7KHk', '0eDNXgw7KHk', 'A Birodalom Elrabolt Kincsei: A Borostyánszoba Rejtélye | Dokumentumfilm', 'Der Rächer Magyar', 'A háború alatt eltűnt a világhírű Borostyánszoba, és soha nem került elő. A film levéltári iratok és listák alapján mutatja be a náci műkincsrablás gépezetét.', 'A Borostyánszoba eltűnése', 90),
  ('vid_9pnsfJcvTIk', '9pnsfJcvTIk', 'Az FBI 10 legkeresettebb bűnözője', 'Krisztian Magyar', 'Az FBI körözési listájának legismertebb neveit veszi sorra: kik kerültek fel rá, és hogyan akadtak a nyomukra.', 'Az FBI körözési listája', 91),
  ('vid_B60V-KKUz_w', 'B60V-KKUz_w', 'Aranyásó - A világ legnagyobb bankrablása - dokumentumfilm', 'Juhász Levente', 'Egészestés dokumentumfilm a világ egyik legnagyobb bankrablásáról, és a nyomozásról, amely a zsákmány után indult.', 'Nagy bankrablás – dokumentumfilm', 92),
  ('vid_MC3l81ZeDG8', 'MC3l81ZeDG8', 'Világrengető rablások S01E05', 'Robert Majors', 'A Világrengető rablások sorozat egyik része: egy nagyszabású rablás megtervezése és felderítése, lépésről lépésre.', 'Világrengető rablások – sorozat', 93);

do $validation$
begin
  if (select count(*) from public.crime_stories where is_active) <> 8 then
    raise exception 'Expected 8 active crime stories';
  end if;

  if (select count(*) from public.crime_videos where is_active) <> 93 then
    raise exception 'Expected 93 active crime videos';
  end if;

  -- Two stories about the same case is the failure this load already had once.
  if exists (
    select 1 from public.crime_stories
    group by lower(btrim(title))
    having count(*) > 1
  ) then
    raise exception 'Two crime stories share a title';
  end if;

  if exists (
    select 1 from public.crime_videos
    where youtube_id !~ '^[A-Za-z0-9_-]{11}$'
  ) then
    raise exception 'A crime video id is not a YouTube id';
  end if;
end;
$validation$;
