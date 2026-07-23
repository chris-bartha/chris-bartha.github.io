-- Time Traveler: everyday life, inventions, culture, and discovery across the centuries.

begin;
set local statement_timeout = '30s';

-- Keep Fifth Grader as the special final choice and move the retired mix aside.
update public.quiz_categories
set display_order = case id
  when 'fifth_grader' then 6
  when 'mix' then 7
end
where id in ('fifth_grader', 'mix');

insert into public.quiz_categories (
  id,
  display_name,
  description,
  language_code,
  display_order,
  is_active
) values (
  'time_traveler',
  'Time Traveler',
  'Everyday life, inventions, culture, and discovery across the centuries',
  'en',
  5,
  true
);

create table public.time_traveler_quiz_results (
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
  constraint time_traveler_result_valid_score
    check (total_questions > 0 and score between 0 and total_questions),
  constraint time_traveler_result_valid_counts
    check (
      first_try_correct >= 0
      and second_try_correct >= 0
      and first_try_correct + second_try_correct = score
    ),
  constraint time_traveler_result_valid_duration
    check (duration_seconds >= 0),
  constraint time_traveler_result_answers_array
    check (jsonb_typeof(answers) = 'array'),
  constraint time_traveler_result_lifelines_object
    check (jsonb_typeof(lifelines_used) = 'object')
);

create index time_traveler_results_user_completed_idx
  on public.time_traveler_quiz_results (user_id, completed_at desc);

alter table public.time_traveler_quiz_results enable row level security;

create policy "Players can submit their own time-traveler results"
  on public.time_traveler_quiz_results for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on table public.time_traveler_quiz_results
  from anon, authenticated;
grant insert on table public.time_traveler_quiz_results
  to authenticated;
grant all on table public.time_traveler_quiz_results
  to service_role;

create trigger time_traveler_question_answer_stats_after_insert
  after insert on public.time_traveler_quiz_results
  for each row execute function private.update_question_answer_stats();

-- Extend the source-of-truth projection used by private and public metrics.
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
select id, user_id, 'fifth_grader', score, total_questions, first_try_correct,
  second_try_correct, completed_at, duration_seconds, is_unlimited
from public.fifth_grader_quiz_results;

revoke all on table private.all_quiz_results_for_tracking
  from public, anon, authenticated, service_role;

create trigger time_traveler_quiz_tracking_after_change
  after insert or update or delete on public.time_traveler_quiz_results
  for each row execute function private.sync_quiz_tracking('time_traveler');

-- Insert the complete library in one batch. The subject labels make later
-- review and balancing straightforward without adding anything to the UI.
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
  'time_traveler_' || lpad(question.ordinality::text, 4, '0'),
  'time_traveler',
  question.item ->> 'p',
  question.item ->> 'a',
  array(select jsonb_array_elements_text(question.item -> 'w')),
  'en',
  null,
  question.item ->> 's',
  question.ordinality::integer,
  true
from jsonb_array_elements($questions$
[
  {"s":"Homes and Daily Life","p":"In ancient Rome, what was a domus?","a":"A private house for a well-to-do family","w":["A public bathhouse","A military barracks","A grain warehouse"]},
  {"s":"Homes and Daily Life","p":"What kind of Roman building was an insula?","a":"A multi-story apartment building","w":["A country temple","A covered marketplace","A naval watchtower"]},
  {"s":"Homes and Daily Life","p":"What was the atrium in many ancient Roman houses?","a":"A central reception space often open to the sky","w":["An underground prison cell","A rooftop stable","A room used only for cooking"]},
  {"s":"Homes and Daily Life","p":"How did a Roman hypocaust warm a building?","a":"Hot air circulated beneath floors and through walls","w":["Sunlight was reflected through crystal mirrors","Wool blankets were heated in ovens","Steam was piped directly into furniture"]},
  {"s":"Homes and Daily Life","p":"What was a longhouse in Viking-age Scandinavia?","a":"A long timber home shared by a household","w":["A stone lighthouse","A royal courthouse","A covered bridge"]},
  {"s":"Homes and Daily Life","p":"What usually happened in a medieval castle's great hall?","a":"Meals, meetings, and ceremonies","w":["Ships were repaired","Coins were minted in every castle","Farm animals were auctioned daily"]},
  {"s":"Homes and Daily Life","p":"In castle architecture, what was the keep?","a":"The strong central tower or fortified residence","w":["The kitchen garden","The drawbridge chain","The village churchyard"]},
  {"s":"Homes and Daily Life","p":"Why was a moat built around some castles?","a":"To make an attack on the walls more difficult","w":["To supply salt for cooking","To power clocks in the towers","To mark the boundary of a market"]},
  {"s":"Homes and Daily Life","p":"What was common land in many medieval villages?","a":"Land villagers shared for grazing or gathering resources","w":["The lord's private bedroom","A road owned by foreign merchants","Land reserved only for tournaments"]},
  {"s":"Homes and Daily Life","p":"What material formed a traditional thatched roof?","a":"Bundles of dried straw or reeds","w":["Sheets of hammered iron","Layers of glass tiles","Blocks of carved marble"]},
  {"s":"Homes and Daily Life","p":"What was a rushlight used for in earlier homes?","a":"Providing inexpensive light","w":["Polishing wooden floors","Measuring rainfall","Keeping milk cold"]},
  {"s":"Homes and Daily Life","p":"Before indoor plumbing, what was a chamber pot used for?","a":"As a portable toilet kept indoors","w":["As a bowl for kneading bread","As a heater for bathwater","As a container for lamp oil"]},
  {"s":"Homes and Daily Life","p":"What was a garderobe in a medieval castle?","a":"A simple toilet built into the structure","w":["A room for storing armor","A musician's gallery","A cabinet for royal documents"]},
  {"s":"Homes and Daily Life","p":"How did an icehouse help a household before electric refrigeration?","a":"It stored winter ice in an insulated space","w":["It froze food with compressed gas","It made artificial snow for gardens","It cooled rooms with electric fans"]},
  {"s":"Homes and Daily Life","p":"Why were root cellars useful to earlier households?","a":"Their cool, steady temperature helped preserve produce","w":["They increased the sweetness of flour","They kept fireplaces free of smoke","They provided daylight for sewing"]},
  {"s":"Homes and Daily Life","p":"What household chore was done with a washboard?","a":"Scrubbing laundry","w":["Sharpening knives","Churning butter","Carding wool"]},
  {"s":"Homes and Daily Life","p":"How was a traditional flatiron heated?","a":"It was warmed on a stove or near a fire","w":["It used a small windmill","It was filled with dry ice","It absorbed heat from moonlight"]},
  {"s":"Homes and Daily Life","p":"What was placed inside a bed warmer?","a":"Hot coals or heated material","w":["Fresh flowers","Blocks of soap","Wet linen"]},
  {"s":"Homes and Daily Life","p":"What was the purpose of a dumbwaiter in a large house?","a":"Moving food and small items between floors","w":["Calling servants with a bell","Lifting carriages for repair","Ventilating the kitchen chimney"]},
  {"s":"Homes and Daily Life","p":"Which lighting system became common in cities before electric light?","a":"Gas lighting","w":["Laser lighting","Battery-powered lighting","Solar-panel lighting"]},
  {"s":"Homes and Daily Life","p":"What did a household keep in a coal scuttle?","a":"Coal for the fire","w":["Letters waiting to be posted","Freshly baked bread","Water for washing clothes"]},
  {"s":"Homes and Daily Life","p":"Why might a Victorian visitor leave a calling card?","a":"To announce or record a social visit","w":["To pay a household tax","To reserve a railway seat","To request a medical prescription"]},
  {"s":"Homes and Daily Life","p":"What did a servant-bell system allow household members to do?","a":"Summon help from another room","w":["Lock every outside door at once","Measure the temperature upstairs","Send messages to another town"]},
  {"s":"Homes and Daily Life","p":"What did the word tenement often describe in a growing industrial city?","a":"A crowded multi-family rental building","w":["A rural manor with farmland","A railway freight depot","A school for apprentices"]},
  {"s":"Homes and Daily Life","p":"The English word bungalow came from a term for houses in which region?","a":"Bengal in South Asia","w":["Bavaria in Central Europe","Andalusia in Spain","Quebec in Canada"]},

  {"s":"Food and the Table","p":"What was garum at an ancient Roman table?","a":"A fermented fish sauce","w":["A honey cake","A type of cheese","A barley porridge"]},
  {"s":"Food and the Table","p":"At a medieval feast, what could a trencher be?","a":"A thick slice of bread used as a plate","w":["A two-pronged carving fork","A pitcher for washing hands","A bench reserved for musicians"]},
  {"s":"Food and the Table","p":"Why were spices such as pepper costly in medieval Europe?","a":"They traveled long distances through many traders","w":["They could grow only in royal gardens","Their use required a church license","They were mined from deep underground"]},
  {"s":"Food and the Table","p":"In which country did tea cultivation and tea culture first develop?","a":"China","w":["Brazil","Norway","Mexico"]},
  {"s":"Food and the Table","p":"The coffee plant is native to the highlands of which African country?","a":"Ethiopia","w":["Morocco","Nigeria","Botswana"]},
  {"s":"Food and the Table","p":"Which part of the world first cultivated cacao for food and drink?","a":"Mesoamerica","w":["Scandinavia","Central Australia","The Canadian Arctic"]},
  {"s":"Food and the Table","p":"Where was the potato first domesticated?","a":"The Andes of South America","w":["The Alps of Europe","The Nile Delta","The islands of Japan"]},
  {"s":"Food and the Table","p":"Tomatoes reached Europe after contact with which part of the world?","a":"The Americas","w":["Antarctica","Western Siberia","New Zealand"]},
  {"s":"Food and the Table","p":"Maize, also called corn, was first domesticated in which region?","a":"Mexico and Central America","w":["Northern Europe","Southern Africa","The Arabian Peninsula"]},
  {"s":"Food and the Table","p":"Sugarcane was first domesticated in which broad region?","a":"New Guinea and nearby Southeast Asia","w":["The Canadian prairies","The Sahara Desert","The British Isles"]},
  {"s":"Food and the Table","p":"What food-preservation method did Nicolas Appert pioneer around 1800?","a":"Sealing and heating food in containers","w":["Freeze-drying food in a vacuum","Wrapping food in aluminum foil","Treating food with ultraviolet lamps"]},
  {"s":"Food and the Table","p":"What does pasteurization do to milk?","a":"It uses controlled heat to reduce harmful microbes","w":["It removes every mineral","It turns milk into powdered sugar","It adds natural carbonation"]},
  {"s":"Food and the Table","p":"What did families place inside an icebox to keep food cool?","a":"A block of ice","w":["A tray of hot bricks","A spinning fan powered by steam","A sack of dry grain"]},
  {"s":"Food and the Table","p":"Which American inventor made condensed milk a widely practical product?","a":"Gail Borden","w":["Samuel Morse","Cyrus McCormick","Robert Fulton"]},
  {"s":"Food and the Table","p":"Who developed the first successful modern margarine in 19th-century France?","a":"Hippolyte Mège-Mouriès","w":["Louis Braille","Antoine Lavoisier","Louis Daguerre"]},
  {"s":"Food and the Table","p":"The sandwich is traditionally named for a British holder of which title?","a":"Earl of Sandwich","w":["Duke of Wellington","Baron of Dover","Prince of Wales"]},
  {"s":"Food and the Table","p":"Who is often credited with making afternoon tea fashionable in Victorian Britain?","a":"Anna Russell, Duchess of Bedford","w":["Florence Nightingale","Mary Anning","Ada Lovelace"]},
  {"s":"Food and the Table","p":"Which eating utensils have been used in China for thousands of years?","a":"Chopsticks","w":["Silver steak knives","Three-pronged forks","Drinking straws made of glass"]},
  {"s":"Food and the Table","p":"Which shape is most closely associated with a traditional pretzel?","a":"A twisted knot","w":["A five-pointed star","A hollow cube","A flat spiral disk"]},
  {"s":"Food and the Table","p":"What cargo made the fastest 19th-century tea clippers famous?","a":"New-season tea from China","w":["Frozen beef from Argentina","Coffee from Iceland","Olive oil from Canada"]},
  {"s":"Food and the Table","p":"What is molasses?","a":"A thick syrup left from refining sugar","w":["A powder made from dried milk","A vinegar made only from apples","A salt gathered from mountain caves"]},
  {"s":"Food and the Table","p":"What was pemmican, traditionally made by Indigenous peoples of North America?","a":"A concentrated mixture of dried meat and fat","w":["A fermented corn drink","A soft bread baked in leaves","A soup made from seaweed"]},
  {"s":"Food and the Table","p":"Why did sailors and soldiers carry hardtack?","a":"The dry biscuit kept for a long time","w":["It purified drinking water","It prevented clothing from tearing","It could be burned as lamp fuel"]},
  {"s":"Food and the Table","p":"During wartime rationing, what did coupons control?","a":"How much of scarce goods a person could buy","w":["Which radio programs a person could hear","How many letters a person could send","Where children could attend school"]},
  {"s":"Food and the Table","p":"In which decade did the packaged TV dinner become a famous American convenience food?","a":"The 1950s","w":["The 1880s","The 1910s","The 1990s"]},

  {"s":"Clothing and Fashion","p":"What was a chiton in ancient Greece?","a":"A garment made from draped and fastened cloth","w":["A bronze battle helmet","A leather coin purse","A wreath worn by athletes"]},
  {"s":"Clothing and Fashion","p":"In ancient Rome, which garment became a symbol of male citizenship?","a":"The toga","w":["The kimono","The poncho","The doublet"]},
  {"s":"Clothing and Fashion","p":"Which country is the traditional home of the kimono?","a":"Japan","w":["Portugal","Egypt","Peru"]},
  {"s":"Clothing and Fashion","p":"A sari is traditionally worn in which part of the world?","a":"South Asia","w":["Scandinavia","The Andes","Polynesia"]},
  {"s":"Clothing and Fashion","p":"Which region is most strongly associated with the tartan kilt?","a":"The Scottish Highlands","w":["The Dutch lowlands","The Sahara","The Baltic coast"]},
  {"s":"Clothing and Fashion","p":"What were sabots traditionally worn in parts of Europe?","a":"Wooden shoes or clogs","w":["Feathered hats","Chain-mail gloves","Silk neckties"]},
  {"s":"Clothing and Fashion","p":"What was the main purpose of a corset?","a":"Shaping and supporting the torso","w":["Protecting shoes from mud","Keeping a hat in place","Holding tools at the waist"]},
  {"s":"Clothing and Fashion","p":"What gave a 19th-century crinoline skirt its wide shape?","a":"A framework or cage worn underneath","w":["Pockets filled with wool","Wooden panels sewn into the hem","A belt attached to the shoes"]},
  {"s":"Clothing and Fashion","p":"Where did a bustle add fullness to a woman's dress?","a":"At the back of the skirt","w":["At the shoulders","Around the wrists","Across the front of the bodice"]},
  {"s":"Clothing and Fashion","p":"Bloomers were named after which American women's-rights advocate?","a":"Amelia Bloomer","w":["Lucretia Mott","Sojourner Truth","Elizabeth Blackwell"]},
  {"s":"Clothing and Fashion","p":"Which hat became a formal symbol of 19th-century men's dress?","a":"The top hat","w":["The baseball cap","The sombrero","The knitted beanie"]},
  {"s":"Clothing and Fashion","p":"Why was the sturdy bowler hat originally useful to gamekeepers?","a":"It protected their heads from branches","w":["It carried drinking water","It frightened birds from crops","It unfolded into a raincoat"]},
  {"s":"Clothing and Fashion","p":"Who improved the design that became the modern zipper?","a":"Gideon Sundback","w":["Eli Whitney","John Deere","Alexander Graham Bell"]},
  {"s":"Clothing and Fashion","p":"What inspired Georges de Mestral to invent Velcro?","a":"Burrs clinging to clothing and animal fur","w":["Fish scales reflecting light","Snowflakes sticking to glass","Shells locking together on a beach"]},
  {"s":"Clothing and Fashion","p":"Who worked with Levi Strauss to patent riveted work pants?","a":"Jacob Davis","w":["Isaac Singer","Samuel Colt","George Pullman"]},
  {"s":"Clothing and Fashion","p":"When did nylon stockings first go on widespread public sale in the United States?","a":"1940","w":["1870","1910","1975"]},
  {"s":"Clothing and Fashion","p":"The short hair, loose dresses, and energetic dancing of a flapper evoke which decade?","a":"The 1920s","w":["The 1760s","The 1850s","The 1960s"]},
  {"s":"Clothing and Fashion","p":"What did Britain's wartime Make Do and Mend campaign encourage?","a":"Repairing and reusing clothing","w":["Buying a new outfit every week","Wearing only military uniforms","Sending all wool overseas"]},
  {"s":"Clothing and Fashion","p":"Which color was strongly associated with mourning dress in Victorian Britain?","a":"Black","w":["Orange","Turquoise","Gold"]},
  {"s":"Clothing and Fashion","p":"Ancient Tyrian purple dye came from what source?","a":"Murex sea snails","w":["Crushed amethyst","Purple grapes","Lavender petals"]},
  {"s":"Clothing and Fashion","p":"Which deep-blue dye was traditionally produced from plants?","a":"Indigo","w":["Vermilion","Ochre","Charcoal"]},
  {"s":"Clothing and Fashion","p":"What does sericulture produce?","a":"Silk","w":["Linen","Leather","Felt"]},
  {"s":"Clothing and Fashion","p":"What does a spinning wheel turn fiber into?","a":"Yarn or thread","w":["Finished shoes","Metal buttons","Paper patterns"]},
  {"s":"Clothing and Fashion","p":"What is the basic job of a loom?","a":"Interlacing threads to make cloth","w":["Cutting hides into straps","Polishing gems for jewelry","Pressing hats into shape"]},
  {"s":"Clothing and Fashion","p":"What does a thimble protect while sewing?","a":"A fingertip","w":["The spool of thread","The eye of the needle","The fabric's edge"]},

  {"s":"Work, Trade, and Money","p":"What does barter mean?","a":"Exchanging goods or services without money","w":["Borrowing money from a bank","Charging tax at a harbor","Paying workers with printed checks"]},
  {"s":"Work, Trade, and Money","p":"Which shells served as money in many societies?","a":"Cowrie shells","w":["Oyster shells only","Nautilus shells only","Fossilized shells only"]},
  {"s":"Work, Trade, and Money","p":"Which ancient people are often credited with issuing the first standardized metal coins?","a":"The Lydians","w":["The Vikings","The Aztecs","The Phoenicians of Carthage only"]},
  {"s":"Work, Trade, and Money","p":"What was a denarius?","a":"A Roman silver coin","w":["A medieval farming tool","An Egyptian tax record","A Greek merchant ship"]},
  {"s":"Work, Trade, and Money","p":"The florin took its name from which Italian city?","a":"Florence","w":["Venice","Milan","Naples"]},
  {"s":"Work, Trade, and Money","p":"Which coin was commonly called a piece of eight?","a":"The Spanish dollar","w":["The British farthing","The Roman aureus","The French franc"]},
  {"s":"Work, Trade, and Money","p":"How did medieval tally sticks help people keep accounts?","a":"Notches recorded payments or debts","w":["Their color set the price of grain","Their length measured a workday","Their weight determined a worker's wage"]},
  {"s":"Work, Trade, and Money","p":"What was a craft guild in a medieval town?","a":"An association that regulated a trade","w":["A monastery for traveling monks","A court for royal marriages","A warehouse owned by every farmer"]},
  {"s":"Work, Trade, and Money","p":"What was an apprentice expected to do?","a":"Learn a skilled trade from a master","w":["Collect customs duties at sea","Command a town's militia","Judge disputes between nobles"]},
  {"s":"Work, Trade, and Money","p":"In the old craft system, who was a journeyman?","a":"A trained worker not yet established as a master","w":["A merchant who never stayed in one town","A beginner working without instruction","A noble who financed cathedrals"]},
  {"s":"Work, Trade, and Money","p":"Why did a craft worker create a masterpiece?","a":"To demonstrate skill worthy of master status","w":["To pay a road toll","To announce retirement","To replace the guild's rulebook"]},
  {"s":"Work, Trade, and Money","p":"What could a medieval market charter grant a town?","a":"The legal right to hold a market","w":["Ownership of every nearby village","Freedom from all laws","A permanent royal army"]},
  {"s":"Work, Trade, and Money","p":"What was the Hanseatic League?","a":"A network of northern European trading cities","w":["A group of Italian painters","A French order of knights","A chain of Spanish monasteries"]},
  {"s":"Work, Trade, and Money","p":"What did the Silk Road connect?","a":"Trade routes between East Asia and lands farther west","w":["Only the cities of ancient Greece","The islands of the Caribbean","Mining towns in South Africa"]},
  {"s":"Work, Trade, and Money","p":"Which city became home to an early modern stock exchange trading company shares?","a":"Amsterdam","w":["Reykjavik","Jerusalem","Lisbon"]},
  {"s":"Work, Trade, and Money","p":"Where did government-issued paper money first appear on a large scale?","a":"China","w":["Ancient Sparta","The Inca Empire","Victorian Canada"]},
  {"s":"Work, Trade, and Money","p":"What is recorded by double-entry bookkeeping?","a":"Each transaction as both a debit and a credit","w":["Every sale in two different currencies","Only transactions involving two merchants","Wages twice before they are paid"]},
  {"s":"Work, Trade, and Money","p":"What is an abacus used to do?","a":"Perform calculations","w":["Weigh precious metals","Stamp designs on coins","Measure fabric"]},
  {"s":"Work, Trade, and Money","p":"What powered many early grain and textile mills beside rivers?","a":"Waterwheels","w":["Electric batteries","Gasoline engines","Solar panels"]},
  {"s":"Work, Trade, and Money","p":"Besides pumping water, what common task did traditional windmills perform?","a":"Grinding grain","w":["Printing books","Blowing glass","Dyeing cloth"]},
  {"s":"Work, Trade, and Money","p":"What production method is Henry Ford famous for greatly expanding?","a":"The moving assembly line","w":["Hand-copying each design","Building one car in one home","Transporting cars only by canal"]},
  {"s":"Work, Trade, and Money","p":"Why did factory workers punch a time clock?","a":"To record when they started and ended work","w":["To choose the day's foreman","To order lunch from the office","To count finished products"]},
  {"s":"Work, Trade, and Money","p":"What was a company town?","a":"A settlement where one employer owned much of the housing and stores","w":["A capital governed by several companies","A temporary camp for traveling actors","A village that banned all factories"]},
  {"s":"Work, Trade, and Money","p":"What did a cooper traditionally make?","a":"Barrels and wooden casks","w":["Horseshoes","Window glass","Rope and sails"]},
  {"s":"Work, Trade, and Money","p":"What did a chandler traditionally make or sell?","a":"Candles","w":["Books","Clocks","Ceramic tiles"]},

  {"s":"Travel and Transportation","p":"Why were many Roman roads built with several carefully prepared layers?","a":"To create a durable, well-drained surface","w":["To hide treasure beneath every road","To warm the road during winter","To make the route visible from space"]},
  {"s":"Travel and Transportation","p":"What information did a roadside milestone traditionally give?","a":"Distance along a route","w":["The depth of nearby wells","The local price of bread","The height of every bridge"]},
  {"s":"Travel and Transportation","p":"Why was it called a stagecoach?","a":"Horses were changed at stages along the route","w":["Actors performed inside it","It traveled only to theaters","Its seats were arranged like a stage"]},
  {"s":"Travel and Transportation","p":"How did a sedan chair move through a town?","a":"People carried it on poles","w":["A sail pulled it along rails","Dogs turned wheels beneath it","A steam engine pushed it"]},
  {"s":"Travel and Transportation","p":"What does a canal lock allow a boat to do?","a":"Move between different water levels","w":["Travel without a crew","Fold its mast automatically","Cross a road without a bridge"]},
  {"s":"Travel and Transportation","p":"What was a towpath beside a canal used for?","a":"People or animals pulled boats from it","w":["Passengers slept there overnight","Boatbuilders tested anchors there","It collected rainwater for the canal"]},
  {"s":"Travel and Transportation","p":"What was a turnpike road?","a":"A road on which travelers paid a toll","w":["A road reserved for soldiers","A street that ended at a windmill","A path used only in winter"]},
  {"s":"Travel and Transportation","p":"What did Pony Express riders carry across the American West?","a":"Mail","w":["Railway tracks","Gold-mine machinery","Passenger coaches"]},
  {"s":"Travel and Transportation","p":"What distinguished a 19th-century clipper ship?","a":"It was designed for speed under sail","w":["It traveled entirely underwater","It was powered only by oars","It carried trains across oceans"]},
  {"s":"Travel and Transportation","p":"What was Stephenson's Rocket?","a":"An influential early steam locomotive","w":["The first weather balloon","A naval cannon","A horse-drawn fire engine"]},
  {"s":"Travel and Transportation","p":"What did the Golden Spike ceremony of 1869 celebrate?","a":"Completion of the first U.S. transcontinental railroad","w":["Opening of the Panama Canal","Launch of the first subway","Completion of the Brooklyn Bridge"]},
  {"s":"Travel and Transportation","p":"Which two famous destinations were linked by the classic Orient Express route?","a":"Paris and Constantinople, now Istanbul","w":["London and New York","Rome and Cairo","Moscow and Beijing"]},
  {"s":"Travel and Transportation","p":"What did Karl Benz patent in 1886?","a":"A practical gasoline-powered automobile","w":["A steam-powered airplane","An electric subway train","A diesel ocean liner"]},
  {"s":"Travel and Transportation","p":"Why was Ford's Model T historically important?","a":"Mass production made automobile ownership more affordable","w":["It was the first car to fly","It ran without any fuel","It was built entirely from wood"]},
  {"s":"Travel and Transportation","p":"What feature made a penny-farthing bicycle easy to recognize?","a":"One very large front wheel","w":["Three seats in a row","A sail above the rider","Skis instead of a rear wheel"]},
  {"s":"Travel and Transportation","p":"Why was the safety bicycle safer than a penny-farthing?","a":"Its wheels were similar in size and the rider sat lower","w":["It had four wheels","It could not travel downhill","It was ridden only indoors"]},
  {"s":"Travel and Transportation","p":"What did the Wright brothers achieve at Kitty Hawk in 1903?","a":"Controlled, sustained powered flight","w":["The first parachute jump","The first Atlantic balloon crossing","The first helicopter rescue"]},
  {"s":"Travel and Transportation","p":"What kind of craft was a Zeppelin?","a":"A rigid airship","w":["A steam locomotive","A racing yacht","A cable car"]},
  {"s":"Travel and Transportation","p":"Before long-distance jet travel, what was an ocean liner chiefly designed to carry?","a":"Passengers on scheduled ocean routes","w":["Only fresh fish","River barges over mountains","Aircraft between airports"]},
  {"s":"Travel and Transportation","p":"What body of water does the Channel Tunnel pass beneath?","a":"The English Channel","w":["The Baltic Sea","The Strait of Gibraltar","The Irish Sea"]},
  {"s":"Travel and Transportation","p":"What is Japan's Shinkansen best known as?","a":"A high-speed bullet train","w":["A traditional sailing ship","A mountain cable railway","A city bicycle system"]},
  {"s":"Travel and Transportation","p":"What made Concorde different from ordinary passenger jets?","a":"It carried passengers faster than the speed of sound","w":["It landed on water only","It had no windows","It was powered by propellers"]},
  {"s":"Travel and Transportation","p":"Which city opened the world's first underground railway in 1863?","a":"London","w":["Tokyo","Toronto","Buenos Aires"]},
  {"s":"Travel and Transportation","p":"What lifted the Montgolfier brothers' pioneering balloon?","a":"Heated air","w":["Compressed steam","Hydrogen made by batteries","A flock of birds"]},
  {"s":"Travel and Transportation","p":"Why did the caravel suit Portuguese ocean exploration?","a":"It was maneuverable and could sail effectively in varied winds","w":["It carried a railway engine","It needed no crew","It was made entirely of iron"]},

  {"s":"Messages and Media","p":"On what surface was Mesopotamian cuneiform commonly written?","a":"Wet clay tablets","w":["Sheets of rubber","Silk banners","Sheets of tin"]},
  {"s":"Messages and Media","p":"What plant supplied the material for ancient Egyptian papyrus sheets?","a":"The papyrus reed","w":["The olive tree","The date palm","The lotus flower"]},
  {"s":"Messages and Media","p":"What was traditional parchment made from?","a":"Prepared animal skin","w":["Pressed flower petals","Thin sheets of bronze","Woven cotton thread"]},
  {"s":"Messages and Media","p":"How did a codex differ from a scroll?","a":"Its pages were bound along one edge","w":["It could contain only pictures","It was always carved in stone","It had to be read outdoors"]},
  {"s":"Messages and Media","p":"What made Gutenberg's printing process revolutionary in Europe?","a":"Reusable movable metal type","w":["Ink that disappeared after reading","Paper that folded itself","Books printed without a press"]},
  {"s":"Messages and Media","p":"Why were carrier pigeons useful messengers?","a":"They could fly back to their home loft","w":["They could read written maps","They traveled safely underwater","They could imitate spoken sentences"]},
  {"s":"Messages and Media","p":"How did an optical semaphore system send messages over distance?","a":"Visible arms, flags, or signals formed coded positions","w":["Buried pipes carried spoken words","Mirrors projected printed pages","Horses rang bells in a fixed rhythm"]},
  {"s":"Messages and Media","p":"What did the electric telegraph send through wires?","a":"Coded electrical signals","w":["Printed newspapers","Human voices in full fidelity","Photographic film"]},
  {"s":"Messages and Media","p":"What are the basic elements of Morse code?","a":"Dots and dashes","w":["Colors and shapes","Numbers and maps","Musical notes and chords"]},
  {"s":"Messages and Media","p":"Alexander Graham Bell received an important 1876 patent for which device?","a":"The telephone","w":["The phonograph","The telegraph","The typewriter"]},
  {"s":"Messages and Media","p":"What could Edison's phonograph do that amazed listeners?","a":"Record and reproduce sound","w":["Transmit live pictures","Print photographs in color","Translate speech automatically"]},
  {"s":"Messages and Media","p":"Why was the QWERTY layout created?","a":"To arrange letters on a typewriter keyboard","w":["To encode telegraph messages","To organize books in libraries","To label piano keys"]},
  {"s":"Messages and Media","p":"What was the key idea of Britain's 1840 Uniform Penny Post?","a":"A low standard rate for prepaid letters","w":["Free newspapers for every household","Mail carried only by railway","One delivery each month"]},
  {"s":"Messages and Media","p":"How did a postcard differ from an ordinary letter?","a":"Its message could be mailed without an envelope","w":["It could travel only within one town","It was written exclusively by officials","It always contained a photograph"]},
  {"s":"Messages and Media","p":"Guglielmo Marconi is closely associated with the development of what technology?","a":"Wireless radio communication","w":["Color television","Mechanical printing","Motion-picture film"]},
  {"s":"Messages and Media","p":"What did the Lumière brothers famously present to paying audiences in 1895?","a":"Projected motion pictures","w":["Live satellite television","Recorded stereo music","A talking computer"]},
  {"s":"Messages and Media","p":"What was the penny press of the 19th century?","a":"Inexpensive newspapers for a mass readership","w":["A machine that minted one-cent coins","A tax on printed books","A school newspaper written by children"]},
  {"s":"Messages and Media","p":"What did the Linotype machine speed up?","a":"Setting type for newspapers and books","w":["Delivering telegrams","Developing photographs","Binding leather covers"]},
  {"s":"Messages and Media","p":"What did a teleprinter do?","a":"Sent typed messages over communication lines","w":["Projected films onto a wall","Recorded music on wax cylinders","Printed maps from aerial photographs"]},
  {"s":"Messages and Media","p":"Why did transistor radios become popular in the 1950s and 1960s?","a":"They were small and portable","w":["They needed no broadcast signal","They showed moving pictures","They printed song lyrics automatically"]},
  {"s":"Messages and Media","p":"Which company introduced the compact cassette format in 1963?","a":"Philips","w":["Kodak","Boeing","Xerox"]},
  {"s":"Messages and Media","p":"What does a fax machine transmit?","a":"A scanned copy of a document","w":["A physical parcel","A live stage performance","A roll of undeveloped film"]},
  {"s":"Messages and Media","p":"What was ARPANET?","a":"An early computer network and precursor to the internet","w":["A television satellite","A mechanical calculator","A global telephone directory"]},
  {"s":"Messages and Media","p":"Why did Ray Tomlinson choose the @ symbol for email addresses?","a":"It separated a user's name from the host computer","w":["It meant a message was urgent","It marked a message as free","It showed that a file contained a picture"]},
  {"s":"Messages and Media","p":"Who invented the World Wide Web?","a":"Tim Berners-Lee","w":["Steve Wozniak","Grace Hopper","Douglas Engelbart"]},

  {"s":"Medicine and Public Health","p":"What is the Hippocratic Oath associated with?","a":"Ethical promises made by physicians","w":["The licensing of pharmacists only","A method for setting broken bones","A tax collected by hospitals"]},
  {"s":"Medicine and Public Health","p":"What was trepanation?","a":"Making an opening in the skull","w":["Removing a damaged tooth","Setting a broken arm","Testing a person's eyesight"]},
  {"s":"Medicine and Public Health","p":"What did an apothecary traditionally prepare and sell?","a":"Medicines and remedies","w":["Maps and navigation tools","Shoes and leather goods","Candles and lamp oil only"]},
  {"s":"Medicine and Public Health","p":"Why were some medieval and early modern practitioners called barber-surgeons?","a":"They performed both grooming and minor surgical work","w":["They treated only injured barbers","They cut hair to diagnose every illness","They worked exclusively aboard ships"]},
  {"s":"Medicine and Public Health","p":"What did Edward Jenner use to develop protection against smallpox?","a":"Exposure to cowpox","w":["Powdered quinine","Boiled seawater","A weakened influenza virus"]},
  {"s":"Medicine and Public Health","p":"What simple hospital practice did Ignaz Semmelweis strongly promote?","a":"Handwashing between patients","w":["Keeping every window closed","Serving only cold meals","Painting all wards white"]},
  {"s":"Medicine and Public Health","p":"What central idea did germ theory establish?","a":"Microorganisms can cause disease","w":["All disease comes from cold weather","Illness is always inherited","Only visible parasites cause infection"]},
  {"s":"Medicine and Public Health","p":"Robert Koch's research helped scientists do what?","a":"Link particular microbes to particular diseases","w":["Replace surgery with exercise","Measure blood pressure by touch alone","Prove that all bacteria are harmless"]},
  {"s":"Medicine and Public Health","p":"Why did Joseph Lister use antiseptics during surgery?","a":"To reduce infection","w":["To keep patients awake","To speed up bone growth","To replace surgical instruments"]},
  {"s":"Medicine and Public Health","p":"Why was the public ether demonstration of 1846 a medical milestone?","a":"It showed surgery could be performed under effective anesthesia","w":["It introduced the first vaccine","It produced the first X-ray","It demonstrated artificial respiration"]},
  {"s":"Medicine and Public Health","p":"Why did René Laennec invent the stethoscope?","a":"To listen to sounds inside the chest","w":["To examine the back of the eye","To measure body temperature","To test knee reflexes"]},
  {"s":"Medicine and Public Health","p":"What did Wilhelm Röntgen discover in 1895?","a":"X-rays","w":["Penicillin","Blood circulation","Vitamin C"]},
  {"s":"Medicine and Public Health","p":"Which accidental observation led Alexander Fleming to penicillin?","a":"Mold was killing bacteria in a culture dish","w":["A plant closed its leaves at night","Salt prevented water from freezing","A magnet moved a surgical needle"]},
  {"s":"Medicine and Public Health","p":"Which hormone did Frederick Banting and Charles Best help make available as a diabetes treatment?","a":"Insulin","w":["Adrenaline","Melatonin","Thyroxine"]},
  {"s":"Medicine and Public Health","p":"Karl Landsteiner's work made blood transfusions safer by identifying what?","a":"Human blood groups","w":["The bones of the inner ear","Different types of fever","The structure of insulin"]},
  {"s":"Medicine and Public Health","p":"What did Florence Nightingale use alongside nursing reform to improve hospitals?","a":"Statistics and careful records","w":["Astrology charts","Steam-powered beds","Military drills"]},
  {"s":"Medicine and Public Health","p":"What did John Snow map during London's 1854 cholera outbreak?","a":"Cases clustered around a public water pump","w":["The city's hospitals by height","Every pharmacy's medicine prices","The routes of migrating birds"]},
  {"s":"Medicine and Public Health","p":"What food helped sailors prevent scurvy?","a":"Citrus fruit","w":["Salted beef","White rice","Hard cheese"]},
  {"s":"Medicine and Public Health","p":"The word quarantine comes from an Italian term referring to how many days?","a":"Forty","w":["Seven","Twelve","One hundred"]},
  {"s":"Medicine and Public Health","p":"What was Baron Larrey's flying ambulance during the Napoleonic Wars?","a":"A fast horse-drawn vehicle for removing wounded soldiers","w":["A balloon used as a field hospital","A ship carrying only surgeons","A tent that could be lifted by cranes"]},
  {"s":"Medicine and Public Health","p":"Which scientist developed a practical mercury thermometer scale in the early 1700s?","a":"Daniel Gabriel Fahrenheit","w":["Gregor Mendel","Michael Faraday","Edward Jenner"]},
  {"s":"Medicine and Public Health","p":"What does a sphygmomanometer measure?","a":"Blood pressure","w":["Hearing range","Blood type","Lung volume only"]},
  {"s":"Medicine and Public Health","p":"Why is a plaster cast placed around a broken limb?","a":"To keep the bones still while they heal","w":["To increase blood flow by squeezing","To cool the skin continuously","To make the limb lighter"]},
  {"s":"Medicine and Public Health","p":"Jonas Salk developed a vaccine against which disease?","a":"Polio","w":["Malaria","Tuberculosis","Measles"]},
  {"s":"Medicine and Public Health","p":"In which year was the World Health Organization established?","a":"1948","w":["1898","1918","1978"]},

  {"s":"Inventions at Home","p":"What did a candle snuffer help a person do?","a":"Extinguish a candle flame safely","w":["Make a candle burn brighter","Cut a wick into equal pieces","Melt wax into a mold"]},
  {"s":"Inventions at Home","p":"Who invented the first successful friction match in 1826?","a":"John Walker","w":["James Watt","Elias Howe","George Stephenson"]},
  {"s":"Inventions at Home","p":"Elias Howe's famous sewing-machine patent used which kind of stitch?","a":"A lockstitch","w":["A crochet loop","A hand-tied knot","A chain made of wire"]},
  {"s":"Inventions at Home","p":"What physical action does a vacuum cleaner use to remove dirt?","a":"Suction created by moving air","w":["Magnetic attraction","Freezing the dust","Dissolving dirt with steam only"]},
  {"s":"Inventions at Home","p":"What did Melville and Anna Bissell manufacture for cleaning floors?","a":"Carpet sweepers","w":["Electric polishers","Steam mops","Pressure washers"]},
  {"s":"Inventions at Home","p":"What did early hand-powered washing machines reduce?","a":"The labor of agitating and scrubbing clothes","w":["The need to dry clothing","The amount of thread in fabric","The weight of an iron"]},
  {"s":"Inventions at Home","p":"Why did Josephine Cochrane develop a practical dishwasher?","a":"She wanted dishes washed without being chipped by hand","w":["She needed a machine to make plates","She wanted to freeze leftovers","She was designing a restaurant elevator"]},
  {"s":"Inventions at Home","p":"What replaced stove heating in an electric iron?","a":"An internal electrical heating element","w":["A chamber filled with hot sand","A tiny kerosene lamp","A chemical ice pack"]},
  {"s":"Inventions at Home","p":"What useful action did the automatic pop-up toaster add?","a":"It raised the toast when heating was finished","w":["It sliced the loaf","It spread butter automatically","It refrigerated unused bread"]},
  {"s":"Inventions at Home","p":"What does a thermostat control?","a":"Temperature","w":["Water pressure","Electric voltage only","The speed of a clock"]},
  {"s":"Inventions at Home","p":"What safety feature did Elisha Otis demonstrate for elevators?","a":"A brake that stopped the car if the cable failed","w":["A parachute stored in the ceiling","A second engine beneath every passenger","Doors that opened during a fall"]},
  {"s":"Inventions at Home","p":"Thomas Edison and Joseph Swan both helped make which household technology practical?","a":"Incandescent electric lighting","w":["Gas cooking","Central vacuum systems","Solar water heating"]},
  {"s":"Inventions at Home","p":"What did telephone switchboard operators do?","a":"Connected callers by plugging lines into circuits","w":["Delivered telephones by bicycle","Read every telegram aloud","Repaired wires inside private homes only"]},
  {"s":"Inventions at Home","p":"How did Emile Berliner's gramophone differ from Edison's early phonograph?","a":"It played flat discs rather than cylinders","w":["It recorded color pictures","It required no sound recording","It worked only through telephone wires"]},
  {"s":"Inventions at Home","p":"How did George Eastman's Kodak camera change photography?","a":"It made picture-taking easier for ordinary consumers","w":["It eliminated the need for light","It produced only moving images","It printed photographs on metal plates"]},
  {"s":"Inventions at Home","p":"What does a fountain pen carry inside itself?","a":"A reservoir of ink","w":["A roll of paper","A stick of chalk","A spare metal nib only"]},
  {"s":"Inventions at Home","p":"Which inventor gave his name to a widely used modern ballpoint pen?","a":"László Bíró","w":["John Logie Baird","Guglielmo Marconi","Alessandro Volta"]},
  {"s":"Inventions at Home","p":"What simple job does a paper clip perform?","a":"Holding sheets together without piercing them","w":["Cutting paper into equal sizes","Sealing an envelope permanently","Measuring the thickness of a book"]},
  {"s":"Inventions at Home","p":"How does a stapler fasten sheets?","a":"It bends a small metal staple through them","w":["It melts their edges together","It stitches them with cotton thread","It presses wax between the pages"]},
  {"s":"Inventions at Home","p":"Which came first: the food can or the can opener?","a":"The food can, by several decades","w":["The can opener, by a century","They were patented on the same day","Neither existed before refrigeration"]},
  {"s":"Inventions at Home","p":"What observation helped Percy Spencer develop the microwave oven?","a":"Microwave energy melted food in his pocket","w":["A radio froze a glass of water","A magnet baked a loaf of bread","A light bulb boiled milk"]},
  {"s":"Inventions at Home","p":"What feature helped make Tupperware famous?","a":"Airtight plastic seals","w":["Containers made entirely of glass","Self-heating serving bowls","Disposable metal lids"]},
  {"s":"Inventions at Home","p":"What was the Flash-Matic of the 1950s?","a":"An early wireless television remote control","w":["A pocket camera flash","A home fire alarm","A battery-powered typewriter"]},
  {"s":"Inventions at Home","p":"What product carried the first barcode scanned at a supermarket checkout in 1974?","a":"A pack of chewing gum","w":["A carton of milk","A television set","A bag of flour"]},
  {"s":"Inventions at Home","p":"What keeps time in a quartz clock?","a":"The steady vibration of a quartz crystal","w":["A candle burning at a fixed rate","A falling stream of sand only","A pendulum driven by steam"]},

  {"s":"Arts and Entertainment","p":"What can a visitor see in the caves at Lascaux, France?","a":"Prehistoric paintings of animals","w":["Roman marble theaters","Viking ship burials","Medieval printing presses"]},
  {"s":"Arts and Entertainment","p":"Why did actors in ancient Greek theater use large masks?","a":"To show character and emotion clearly to an audience","w":["To protect themselves from stage fires","To prove they were citizens","To hide written scripts inside"]},
  {"s":"Arts and Entertainment","p":"What entertainment was strongly associated with a Roman amphitheater?","a":"Gladiatorial contests and public spectacles","w":["Opera sung with an orchestra","Ice-skating tournaments","Silent motion pictures"]},
  {"s":"Arts and Entertainment","p":"Why was stained glass especially effective in a medieval cathedral?","a":"Colored light helped tell sacred stories visually","w":["It heated the building","It amplified the church bells","It made the roof lighter"]},
  {"s":"Arts and Entertainment","p":"What made a medieval manuscript illuminated?","a":"Decorated initials and pictures, often with gold or bright color","w":["A lamp was attached to every page","The text glowed in darkness","It was printed on transparent glass"]},
  {"s":"Arts and Entertainment","p":"How is a true fresco painted?","a":"Pigment is applied to fresh wet plaster","w":["Oil paint is spread on polished metal","Colored wax is poured onto cloth","Charcoal is rubbed into dry wood"]},
  {"s":"Arts and Entertainment","p":"What did linear perspective help Renaissance artists create?","a":"A convincing illusion of depth","w":["Paint that dried instantly","Sculptures that could move","Perfectly circular canvases"]},
  {"s":"Arts and Entertainment","p":"Why did layers of oil glaze appeal to Renaissance painters?","a":"They could build rich color and fine detail","w":["They made paintings weigh almost nothing","They erased mistakes by themselves","They turned every surface into marble"]},
  {"s":"Arts and Entertainment","p":"What did printing make easier for musicians during the Renaissance?","a":"Sharing the same written music widely","w":["Playing without instruments","Writing songs with no notes","Performing only for royal courts"]},
  {"s":"Arts and Entertainment","p":"What was a hallmark of Italian commedia dell'arte?","a":"Improvised comedy using familiar stock characters","w":["Silent religious processions","Operas performed underwater","Plays written entirely in Latin verse"]},
  {"s":"Arts and Entertainment","p":"In which country did opera emerge around 1600?","a":"Italy","w":["Sweden","Ireland","India"]},
  {"s":"Arts and Entertainment","p":"Which royal court helped turn ballet into a formal art in the 17th century?","a":"The French court","w":["The Aztec court","The Ottoman court","The Japanese imperial court"]},
  {"s":"Arts and Entertainment","p":"Which playwright's company performed at London's Globe Theatre?","a":"William Shakespeare","w":["Molière","Henrik Ibsen","Anton Chekhov"]},
  {"s":"Arts and Entertainment","p":"How does a harpsichord produce sound?","a":"Its strings are plucked by a mechanism","w":["Air is blown through metal pipes","Hammers strike bells","A bow rubs glass rods"]},
  {"s":"Arts and Entertainment","p":"Who is credited with inventing the piano around 1700?","a":"Bartolomeo Cristofori","w":["Antonio Stradivari","Claudio Monteverdi","Niccolò Paganini"]},
  {"s":"Arts and Entertainment","p":"What was a daguerreotype?","a":"An early photograph made on a silvered metal plate","w":["A mechanical music box","A portable stage curtain","A colored glass lantern"]},
  {"s":"Arts and Entertainment","p":"What could an audience expect at a vaudeville show?","a":"A variety of short comedy, music, dance, and novelty acts","w":["One unbroken five-hour tragedy","Only scientific lectures","A single silent painting exhibition"]},
  {"s":"Arts and Entertainment","p":"What was a nickelodeon in the early 1900s?","a":"A small theater showing inexpensive motion pictures","w":["A coin-operated piano factory","A radio station for children","A shop selling five-cent books"]},
  {"s":"Arts and Entertainment","p":"How did silent films present spoken dialogue to viewers?","a":"With written intertitles between scenes","w":["Through headphones at every seat","With speech printed on the actors' clothing","By broadcasting dialogue on radio"]},
  {"s":"Arts and Entertainment","p":"Which American city is widely recognized as a birthplace of jazz?","a":"New Orleans","w":["Seattle","Boston","Denver"]},
  {"s":"Arts and Entertainment","p":"How did a player piano perform music automatically?","a":"A perforated paper roll controlled the notes","w":["A radio signal moved every key","A hidden violin played beneath it","Magnets read handwritten sheet music"]},
  {"s":"Arts and Entertainment","p":"How did radio dramas create scenes listeners could not see?","a":"Through dialogue, music, and sound effects","w":["By mailing pictures during the program","With subtitles on the radio cabinet","By using only a narrator and no sound"]},
  {"s":"Arts and Entertainment","p":"What did Technicolor bring to motion pictures?","a":"A vivid color-film process","w":["Synchronized smell effects","Three-dimensional sound only","Films that developed during projection"]},
  {"s":"Arts and Entertainment","p":"At what speed does a traditional long-playing vinyl record turn?","a":"33⅓ revolutions per minute","w":["12 revolutions per minute","60 revolutions per minute","100 revolutions per minute"]},
  {"s":"Arts and Entertainment","p":"What happens when a customer selects a song on a jukebox?","a":"The machine plays the chosen recording","w":["A live musician receives a signal","The machine prints the sheet music","A radio station changes its schedule"]},

  {"s":"Exploration and Discovery","p":"What natural clues helped traditional Polynesian navigators cross the Pacific?","a":"Stars, ocean swells, winds, and wildlife","w":["Railway timetables","Magnetic road signs","Printed satellite photographs"]},
  {"s":"Exploration and Discovery","p":"What could a mariner estimate with an astrolabe?","a":"Latitude from the height of a celestial object","w":["Ocean depth from water color","Longitude from the ship's weight","Wind speed from the anchor chain"]},
  {"s":"Exploration and Discovery","p":"Which property makes a magnetic compass useful?","a":"Its needle aligns with Earth's magnetic field","w":["Its case predicts storms","Its glass measures sea level","Its dial changes with the tides"]},
  {"s":"Exploration and Discovery","p":"What did medieval portolan charts show especially well?","a":"Coastlines, ports, and sailing directions","w":["The interiors of every continent","The depth of underground mines","The paths of future hurricanes"]},
  {"s":"Exploration and Discovery","p":"How did John Harrison's marine chronometer improve navigation?","a":"Accurate time at sea helped determine longitude","w":["It measured the salt in seawater","It kept a ship from rolling","It predicted the exact height of waves"]},
  {"s":"Exploration and Discovery","p":"Whose account described a long journey through Asia in the 13th century?","a":"Marco Polo's","w":["Christopher Wren's","Nicolaus Copernicus's","Amerigo Vespucci's only voyage log"]},
  {"s":"Exploration and Discovery","p":"What did Zheng He's treasure fleets demonstrate in the early 1400s?","a":"The reach of Ming China's maritime power","w":["Portugal's control of the Pacific","The invention of the steamship","The first settlement of Australia"]},
  {"s":"Exploration and Discovery","p":"What southern African landmark did Bartolomeu Dias round in 1488?","a":"The Cape of Good Hope","w":["Cape Horn","The Cape of St. Vincent","The Cape York Peninsula"]},
  {"s":"Exploration and Discovery","p":"What route did Vasco da Gama complete in 1498?","a":"A sea route from Europe around Africa to India","w":["A land route across Siberia to China","A sea route through the Panama Canal","A river route from Egypt to Spain"]},
  {"s":"Exploration and Discovery","p":"Where did Christopher Columbus first arrive during his 1492 Atlantic voyage?","a":"Islands in the Caribbean","w":["The mainland of India","The coast of Australia","The island of Madagascar"]},
  {"s":"Exploration and Discovery","p":"What did the expedition begun by Ferdinand Magellan accomplish?","a":"The first circumnavigation of the world","w":["The first climb of Mount Everest","The first crossing of Antarctica","The first voyage through the Suez Canal"]},
  {"s":"Exploration and Discovery","p":"What kind of work made James Cook's Pacific voyages especially valuable?","a":"Detailed mapping and scientific observation","w":["Building transcontinental railways","Digging deep-sea tunnels","Inventing the steam engine"]},
  {"s":"Exploration and Discovery","p":"What territory were Lewis and Clark sent to explore?","a":"The Louisiana Purchase and lands toward the Pacific","w":["The Florida Keys only","The Canadian Arctic islands","The Amazon rainforest"]},
  {"s":"Exploration and Discovery","p":"Why is Alexander von Humboldt remembered as a scientific explorer?","a":"He studied how climate, geography, and living things are connected","w":["He searched only for buried gold","He mapped roads without recording nature","He invented the first telescope"]},
  {"s":"Exploration and Discovery","p":"Which ship carried Charles Darwin on the voyage that shaped his ideas about evolution?","a":"HMS Beagle","w":["HMS Victory","Endeavour","Santa María"]},
  {"s":"Exploration and Discovery","p":"Which continent became central to David Livingstone's travels and missionary work?","a":"Africa","w":["Antarctica","North America","Australia"]},
  {"s":"Exploration and Discovery","p":"What record did journalist Nellie Bly set in 1889–1890?","a":"She traveled around the world in about 72 days","w":["She crossed the Atlantic alone by airplane","She reached the South Pole first","She climbed Everest without oxygen"]},
  {"s":"Exploration and Discovery","p":"Which Norwegian explorer's team arrived at the South Pole first, in 1911?","a":"Roald Amundsen","w":["Robert Falcon Scott","Ernest Shackleton","Fridtjof Nansen"]},
  {"s":"Exploration and Discovery","p":"What made Ernest Shackleton's Endurance expedition famous despite failing to cross Antarctica?","a":"The entire stranded crew was rescued","w":["It discovered the South Pole","It built a permanent railway","It completed the first flight over Antarctica"]},
  {"s":"Exploration and Discovery","p":"What was the bathysphere designed to explore?","a":"The deep ocean","w":["The upper atmosphere","Underground caves","Volcanic craters"]},
  {"s":"Exploration and Discovery","p":"Where did the bathyscaphe Trieste descend in 1960?","a":"The Challenger Deep in the Mariana Trench","w":["The floor of the Baltic Sea","Lake Baikal's shoreline","The Great Barrier Reef lagoon"]},
  {"s":"Exploration and Discovery","p":"What was Sputnik 1?","a":"The first artificial satellite to orbit Earth","w":["The first reusable space shuttle","A Soviet lunar rover","The first crewed space station"]},
  {"s":"Exploration and Discovery","p":"Who became the first human in space?","a":"Yuri Gagarin","w":["Alan Shepard","John Glenn","Valentina Tereshkova"]},
  {"s":"Exploration and Discovery","p":"What did Apollo 11 achieve in July 1969?","a":"The first crewed landing on the Moon","w":["The first orbit of Mars","The first spacewalk","The launch of the first satellite"]},
  {"s":"Exploration and Discovery","p":"Why was a Golden Record placed aboard each Voyager spacecraft?","a":"To carry sounds and images representing Earth","w":["To store navigation fuel","To repair the spacecraft's antenna","To measure the Sun's temperature"]},

  {"s":"Games, Customs, and Firsts","p":"Which ancient civilization gave us the names of many months and the basic shape of the modern Western calendar?","a":"The Romans","w":["The Maya","The Inca","The Phoenicians"]},
  {"s":"Games, Customs, and Firsts","p":"Which ruler introduced the Julian calendar?","a":"Julius Caesar","w":["Charlemagne","Alexander the Great","Constantine XI"]},
  {"s":"Games, Customs, and Firsts","p":"For whom was the Gregorian calendar named?","a":"Pope Gregory XIII","w":["Saint George","King George III","Gregor Mendel"]},
  {"s":"Games, Customs, and Firsts","p":"Under Gregorian calendar rules, which century year is a leap year?","a":"A century year divisible by 400","w":["Every century year","A century year divisible by 300","No century year can be a leap year"]},
  {"s":"Games, Customs, and Firsts","p":"January is named after Janus, the Roman god associated with what?","a":"Beginnings, endings, and doorways","w":["The sea and earthquakes","Harvest and wine","Music and poetry"]},
  {"s":"Games, Customs, and Firsts","p":"Where were the ancient Olympic Games held?","a":"Olympia in Greece","w":["Rome in Italy","Troy in Anatolia","Alexandria in Egypt"]},
  {"s":"Games, Customs, and Firsts","p":"How long is a modern marathon?","a":"26.2 miles, or about 42.2 kilometers","w":["10 miles, or about 16 kilometers","20 miles, or about 32 kilometers","50 miles, or about 80 kilometers"]},
  {"s":"Games, Customs, and Firsts","p":"Which city hosted the first modern Olympic Games in 1896?","a":"Athens","w":["Paris","London","Rome"]},
  {"s":"Games, Customs, and Firsts","p":"In which country were the modern rules of association football first codified?","a":"England","w":["Brazil","Italy","Argentina"]},
  {"s":"Games, Customs, and Firsts","p":"What distinction does Wimbledon hold in tennis history?","a":"It is the oldest tennis tournament","w":["It was the first tournament played indoors","It uses no rackets","It is held every four years"]},
  {"s":"Games, Customs, and Firsts","p":"How many innings are scheduled in a standard major-league baseball game?","a":"Nine","w":["Five","Seven","Twelve"]},
  {"s":"Games, Customs, and Firsts","p":"In which year was the first Tour de France held?","a":"1903","w":["1863","1933","1963"]},
  {"s":"Games, Customs, and Firsts","p":"What does the yellow jersey identify in the Tour de France?","a":"The overall race leader","w":["The youngest rider","The best mountain descender","The previous year's champion only"]},
  {"s":"Games, Customs, and Firsts","p":"In which country did chess develop from an earlier game called chaturanga?","a":"India","w":["Norway","Egypt","Mexico"]},
  {"s":"Games, Customs, and Firsts","p":"Where did the earliest known playing cards appear?","a":"China","w":["Iceland","Peru","Canada"]},
  {"s":"Games, Customs, and Firsts","p":"Where did the earliest known domino sets develop?","a":"China","w":["Scotland","Brazil","Ancient Egypt"]},
  {"s":"Games, Customs, and Firsts","p":"Who created the first modern newspaper crossword puzzle in 1913?","a":"Arthur Wynne","w":["Lewis Carroll","H. G. Wells","A. A. Milne"]},
  {"s":"Games, Customs, and Firsts","p":"What did early jigsaw puzzles often teach?","a":"Geography through dissected maps","w":["Music through punched rolls","Astronomy through glass slides","Arithmetic through coin collecting"]},
  {"s":"Games, Customs, and Firsts","p":"Which simple toy has existed in various forms since ancient times?","a":"The yo-yo","w":["The electronic game console","The plastic flying disc","The battery-powered robot"]},
  {"s":"Games, Customs, and Firsts","p":"Which civilization is usually credited with inventing the kite?","a":"Ancient China","w":["Ancient Rome","The Aztec Empire","The Viking kingdoms"]},
  {"s":"Games, Customs, and Firsts","p":"Origami is the art of doing what?","a":"Folding paper","w":["Carving ivory","Painting silk","Weaving baskets"]},
  {"s":"Games, Customs, and Firsts","p":"What was the Penny Black of 1840?","a":"The first adhesive postage stamp used in a public postal system","w":["A one-cent newspaper","A popular board game","A British silver coin"]},
  {"s":"Games, Customs, and Firsts","p":"Who commissioned the first commercial Christmas card in 1843?","a":"Sir Henry Cole","w":["Charles Dickens","Prince Albert","William Morris"]},
  {"s":"Games, Customs, and Firsts","p":"Which major public museum opened in London in 1759?","a":"The British Museum","w":["The Victoria and Albert Museum","The Science Museum","The Tate Modern"]},
  {"s":"Games, Customs, and Firsts","p":"Which glass-and-iron building housed London's Great Exhibition of 1851?","a":"The Crystal Palace","w":["The Royal Albert Hall","The Tower of London","Somerset House"]}
]
$questions$::jsonb) with ordinality as question(item, ordinality);

do $validation$
begin
  if (
    select count(*)
    from public.quiz_questions
    where category_id = 'time_traveler'
      and is_active
  ) <> 275 then
    raise exception 'Time Traveler must contain exactly 275 active questions';
  end if;

  if exists (
    select 1
    from public.quiz_questions as question
    where question.category_id = 'time_traveler'
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
    raise exception 'Every Time Traveler question must have three distinct wrong answers';
  end if;

  if exists (
    select 1
    from public.quiz_questions as proposed
    join public.quiz_questions as existing
      on lower(trim(existing.prompt)) = lower(trim(proposed.prompt))
     and existing.id <> proposed.id
    where proposed.category_id = 'time_traveler'
  ) then
    raise exception 'Time Traveler contains a prompt already used by another question';
  end if;
end;
$validation$;

comment on table public.time_traveler_quiz_results is
  'Source-of-truth results for the Time Traveler quiz category.';

commit;
