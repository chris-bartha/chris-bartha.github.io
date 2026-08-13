-- Add 600 reviewed, non-duplicate questions to the English history quiz.
-- This filename matches the migration version recorded by the linked project.
-- The category upsert keeps a fresh local reset reproducible because seed.sql
-- runs after migrations and contains the original history category and bank.
begin;

insert into public.quiz_categories (
  id,
  display_name,
  description,
  language_code,
  display_order,
  is_active
)
values (
  'history',
  'History',
  'Kings, presidents, discoveries, and days gone by',
  'en',
  2,
  true
)
on conflict (id) do nothing;

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
  'hist_' || lpad((430 + question.ordinality)::text, 4, '0'),
  'history',
  question.item ->> 'p',
  question.item ->> 'a',
  array(select jsonb_array_elements_text(question.item -> 'w')),
  'en',
  null,
  question.item ->> 's',
  430 + question.ordinality::integer,
  true
from jsonb_array_elements($questions$
[
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What do historians call the time before written records?",
    "a": "Prehistory",
    "w": [
      "The Middle Ages",
      "Antiquity",
      "The Renaissance"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Which material was used for most tools during the Paleolithic Age?",
    "a": "Stone",
    "w": [
      "Iron",
      "Bronze",
      "Steel"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What major change marked the beginning of the Neolithic Revolution?",
    "a": "The development of farming",
    "w": [
      "The invention of steam power",
      "The fall of Rome",
      "The use of gunpowder"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What did early farmers begin to do with animals such as sheep and goats?",
    "a": "Domesticate them",
    "w": [
      "Drive them to extinction",
      "Use them only in warfare",
      "Release them into cities"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Why did many early permanent settlements grow near rivers?",
    "a": "Rivers provided water and fertile soil",
    "w": [
      "Rivers prevented all invasions",
      "Rivers contained iron tools",
      "Rivers made winters warmer"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What is a society with cities, government, and specialized work commonly called?",
    "a": "A civilization",
    "w": [
      "A clan",
      "A colony",
      "A guild"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Between which two rivers did Mesopotamia develop?",
    "a": "The Tigris and Euphrates",
    "w": [
      "The Nile and Congo",
      "The Indus and Ganges",
      "The Rhine and Danube"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What does the name Mesopotamia mean?",
    "a": "Land between the rivers",
    "w": [
      "Gift of the Nile",
      "Kingdom of the sun",
      "City on seven hills"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "In which modern country was most of ancient Mesopotamia located?",
    "a": "Iraq",
    "w": [
      "Greece",
      "Egypt",
      "Italy"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What wedge-shaped writing system was used in Mesopotamia?",
    "a": "Cuneiform",
    "w": [
      "Hieroglyphics",
      "Sanskrit",
      "Latin"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "On what did Mesopotamian scribes commonly write?",
    "a": "Clay tablets",
    "w": [
      "Silk scrolls",
      "Paper books",
      "Wooden walls"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What was a stepped temple tower in a Sumerian city called?",
    "a": "A ziggurat",
    "w": [
      "A pyramid",
      "A pagoda",
      "An aqueduct"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Which Mesopotamian people built city-states such as Ur and Uruk?",
    "a": "The Sumerians",
    "w": [
      "The Spartans",
      "The Hittites",
      "The Etruscans"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What is the Epic of Gilgamesh?",
    "a": "An ancient Mesopotamian poem",
    "w": [
      "A Roman law code",
      "An Egyptian temple",
      "A Greek peace treaty"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Which Babylonian king issued one of the earliest surviving written law codes?",
    "a": "Hammurabi",
    "w": [
      "Nebuchadnezzar II",
      "Sargon",
      "Cyrus"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "The phrase ‘an eye for an eye’ is associated with whose law code?",
    "a": "Hammurabi's",
    "w": [
      "Solon's",
      "Justinian's",
      "Napoleon's"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Who created the Akkadian Empire, often called the first empire in history?",
    "a": "Sargon of Akkad",
    "w": [
      "Hammurabi",
      "Darius I",
      "Ashoka"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Which warlike Mesopotamian empire had a capital at Nineveh?",
    "a": "The Assyrian Empire",
    "w": [
      "The Minoan Empire",
      "The Gupta Empire",
      "The Mauryan Empire"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Which Babylonian king is associated with rebuilding Babylon and its Ishtar Gate?",
    "a": "Nebuchadnezzar II",
    "w": [
      "Hammurabi",
      "Sargon",
      "Xerxes"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Which metal gave the Bronze Age its name?",
    "a": "Bronze",
    "w": [
      "Iron",
      "Silver",
      "Steel"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Bronze is mainly an alloy of copper and which other metal?",
    "a": "Tin",
    "w": [
      "Gold",
      "Lead",
      "Iron"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Which age followed the Bronze Age in much of Eurasia?",
    "a": "The Iron Age",
    "w": [
      "The Stone Age",
      "The Steam Age",
      "The Atomic Age"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What was one major advantage of irrigation?",
    "a": "It brought water to crops",
    "w": [
      "It created written laws",
      "It ended warfare",
      "It produced bronze"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What job did a scribe perform in an ancient city?",
    "a": "Reading and writing records",
    "w": [
      "Leading cavalry",
      "Building ships",
      "Making glass"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What is an artifact?",
    "a": "An object made or used by people",
    "w": [
      "A layer of natural rock",
      "A written language only",
      "A type of ancient ruler"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What do archaeologists study to learn about past human life?",
    "a": "Material remains",
    "w": [
      "Future weather",
      "Only royal family trees",
      "Modern voting records"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What discovery allowed early humans to cook food and keep warm?",
    "a": "Control of fire",
    "w": [
      "The compass",
      "The wheelbarrow",
      "The telescope"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "What does a nomadic group do?",
    "a": "Moves from place to place",
    "w": [
      "Lives permanently in one city",
      "Rules an overseas empire",
      "Writes laws on stone"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Which invention helped move heavy goods in early civilizations?",
    "a": "The wheel",
    "w": [
      "The printing press",
      "The steam engine",
      "The airplane"
    ]
  },
  {
    "s": "Prehistory And Mesopotamia",
    "p": "Why was the invention of writing important to early states?",
    "a": "It allowed records and laws to be preserved",
    "w": [
      "It ended social classes",
      "It replaced agriculture",
      "It prevented natural disasters"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "What title was used for the rulers of ancient Egypt?",
    "a": "Pharaoh",
    "w": [
      "Consul",
      "Tsar",
      "Shogun"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which ancient Egyptian ruler promoted worship of the sun disk Aten?",
    "a": "Akhenaten",
    "w": [
      "Khufu",
      "Ramses II",
      "Tutankhamun"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which queen was Akhenaten's famous wife?",
    "a": "Nefertiti",
    "w": [
      "Cleopatra",
      "Hatshepsut",
      "Boudica"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "What was the purpose of canopic jars in ancient Egypt?",
    "a": "To store organs removed during mummification",
    "w": [
      "To measure the annual Nile flood",
      "To hold ink for royal scribes",
      "To preserve grain for temple workers"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which pharaoh's tomb was found nearly intact in the Valley of the Kings?",
    "a": "Tutankhamun's",
    "w": [
      "Khufu's",
      "Akhenaten's",
      "Ramses I's"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which pharaoh is linked with the Great Pyramid at Giza?",
    "a": "Khufu",
    "w": [
      "Tutankhamun",
      "Akhenaten",
      "Cleopatra"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "What was the purpose of most Egyptian pyramids?",
    "a": "They were royal tombs",
    "w": [
      "They were public markets",
      "They were military forts",
      "They were sports arenas"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "What Egyptian belief explains why tombs were filled with food and possessions?",
    "a": "Life continued after death",
    "w": [
      "The dead would become soldiers",
      "Grave goods paid taxes",
      "Tombs served as shops"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which Egyptian god was associated with the dead and the afterlife?",
    "a": "Osiris",
    "w": [
      "Ares",
      "Jupiter",
      "Thor"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which Egyptian god was commonly shown with a jackal's head?",
    "a": "Anubis",
    "w": [
      "Horus",
      "Ra",
      "Ptah"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which Egyptian god was commonly shown with a falcon's head?",
    "a": "Horus",
    "w": [
      "Anubis",
      "Osiris",
      "Bes"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "What was the Egyptian Book of the Dead?",
    "a": "A collection of funerary texts",
    "w": [
      "A census of soldiers",
      "A history of Greece",
      "A law code for merchants"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Why was the annual flooding of the Nile valuable?",
    "a": "It left fertile soil for farming",
    "w": [
      "It exposed gold roads",
      "It froze stored grain",
      "It destroyed all insects"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "What did the Rosetta Stone contain that made it useful to scholars?",
    "a": "The same text in multiple scripts",
    "w": [
      "A map of every pyramid",
      "A list of all pharaohs",
      "Instructions for mummification"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Who deciphered Egyptian hieroglyphs with help from the Rosetta Stone?",
    "a": "Jean-François Champollion",
    "w": [
      "Howard Carter",
      "Heinrich Schliemann",
      "Arthur Evans"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which people established a trading civilization along the eastern Mediterranean coast?",
    "a": "The Phoenicians",
    "w": [
      "The Huns",
      "The Gauls",
      "The Saxons"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which important system did Phoenician traders spread around the Mediterranean?",
    "a": "An alphabet",
    "w": [
      "Roman numerals",
      "Paper money",
      "Movable type"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which Phoenician city founded the colony of Carthage?",
    "a": "Tyre",
    "w": [
      "Sparta",
      "Babylon",
      "Memphis"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which ancient people established the kingdoms of Israel and Judah?",
    "a": "The Hebrews",
    "w": [
      "The Etruscans",
      "The Minoans",
      "The Vandals"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which king is traditionally credited with building the First Temple in Jerusalem?",
    "a": "Solomon",
    "w": [
      "David",
      "Saul",
      "Herod"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which Persian king founded the Achaemenid Empire?",
    "a": "Cyrus the Great",
    "w": [
      "Darius III",
      "Xerxes",
      "Cambyses II"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Cyrus the Great is remembered for allowing many conquered peoples to do what?",
    "a": "Keep their customs and religions",
    "w": [
      "Elect the Persian king",
      "Avoid all taxation",
      "Control the royal army"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which Persian ruler organized the empire into provinces called satrapies?",
    "a": "Darius I",
    "w": [
      "Cyrus the Great",
      "Xerxes",
      "Artaxerxes III"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "What was the Persian Royal Road used for?",
    "a": "Travel, trade, and royal messages",
    "w": [
      "Religious pilgrimages only",
      "Holding chariot races",
      "Dividing Egypt from Nubia"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which religion of ancient Persia taught a struggle between good and evil?",
    "a": "Zoroastrianism",
    "w": [
      "Shinto",
      "Jainism",
      "Druidism"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Who is the traditional founder of Zoroastrianism?",
    "a": "Zoroaster",
    "w": [
      "Confucius",
      "Socrates",
      "Ashoka"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "At which battle did a Greek fleet defeat Persia in 480 BC?",
    "a": "Salamis",
    "w": [
      "Cannae",
      "Actium",
      "Gaugamela"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which Persian king invaded Greece and fought at Thermopylae?",
    "a": "Xerxes I",
    "w": [
      "Cyrus the Great",
      "Darius III",
      "Artaxerxes I"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "Which conqueror defeated the Persian king Darius III?",
    "a": "Alexander the Great",
    "w": [
      "Julius Caesar",
      "Hannibal",
      "Cyrus the Great"
    ]
  },
  {
    "s": "Egypt, Persia And The Ancient Levant",
    "p": "The ancient region of Nubia lay mainly south of Egypt in what is now which country?",
    "a": "Sudan",
    "w": [
      "Libya",
      "Turkey",
      "Lebanon"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "What was an independent city-state in ancient Greece called?",
    "a": "A polis",
    "w": [
      "A satrapy",
      "A duchy",
      "A commune"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "What was the central fortified hill of an ancient Greek city called?",
    "a": "The acropolis",
    "w": [
      "The forum",
      "The citadel gate",
      "The hippodrome"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "What was the public marketplace of a Greek city called?",
    "a": "The agora",
    "w": [
      "The senate",
      "The basilica",
      "The ziggurat"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which Athenian leader is closely associated with the city's Golden Age?",
    "a": "Pericles",
    "w": [
      "Leonidas",
      "Solon",
      "Philip II"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which form of government allowed male citizens of Athens to vote directly?",
    "a": "Direct democracy",
    "w": [
      "Absolute monarchy",
      "Military dictatorship",
      "Feudalism"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which residents of ancient Athens were excluded from citizenship?",
    "a": "Women, enslaved people, and foreigners",
    "w": [
      "All landowners",
      "All soldiers",
      "All adult men"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "What was the main focus of education for boys in Sparta?",
    "a": "Military training",
    "w": [
      "Painting and sculpture",
      "Sea trade",
      "Priestly ritual"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Who were the helots of Sparta?",
    "a": "An unfree farming population",
    "w": [
      "Elected magistrates",
      "Foreign ambassadors",
      "Elite cavalry officers"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which lawgiver is associated with early democratic reforms in Athens?",
    "a": "Solon",
    "w": [
      "Homer",
      "Leonidas",
      "Ptolemy"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Who established a tyranny in Athens after Solon's reforms?",
    "a": "Peisistratus",
    "w": [
      "Pericles",
      "Miltiades",
      "Themistocles"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which battle in 490 BC ended with an Athenian victory over Persia?",
    "a": "Marathon",
    "w": [
      "Thermopylae",
      "Salamis",
      "Chaeronea"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which Athenian leader persuaded the city to build a powerful navy before Xerxes invaded?",
    "a": "Themistocles",
    "w": [
      "Pericles",
      "Socrates",
      "Alcibiades"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "At which battle did King Leonidas lead a famous Spartan defense?",
    "a": "Thermopylae",
    "w": [
      "Marathon",
      "Salamis",
      "Plataea"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which battle ended the Persian invasion of Greece in 479 BC?",
    "a": "Plataea",
    "w": [
      "Actium",
      "Cannae",
      "Granicus"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which league of Greek city-states was led by Athens after the Persian Wars?",
    "a": "The Delian League",
    "w": [
      "The Peloponnesian League",
      "The Hanseatic League",
      "The Achaean Empire"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which league of Greek states was led by Sparta?",
    "a": "The Peloponnesian League",
    "w": [
      "The Delian League",
      "The Latin League",
      "The Ionian League"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "The Peloponnesian War was fought mainly between Athens and which rival?",
    "a": "Sparta",
    "w": [
      "Thebes",
      "Persia",
      "Macedonia"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Who recorded a famous history of the Peloponnesian War?",
    "a": "Thucydides",
    "w": [
      "Herodotus",
      "Homer",
      "Sophocles"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Who is often called the father of history?",
    "a": "Herodotus",
    "w": [
      "Plato",
      "Pythagoras",
      "Euripides"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which philosopher founded the Academy in Athens?",
    "a": "Plato",
    "w": [
      "Aristotle",
      "Socrates",
      "Epicurus"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which philosopher founded the Lyceum in Athens?",
    "a": "Aristotle",
    "w": [
      "Plato",
      "Socrates",
      "Zeno"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which work by Plato describes an ideal state?",
    "a": "The Republic",
    "w": [
      "The Histories",
      "The Politics",
      "The Iliad"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which Greek mathematician is associated with a theorem about right triangles?",
    "a": "Pythagoras",
    "w": [
      "Euclid",
      "Archimedes",
      "Eratosthenes"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Who made an impressively accurate ancient estimate of Earth's circumference?",
    "a": "Eratosthenes",
    "w": [
      "Ptolemy",
      "Hippocrates",
      "Democritus"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which Greek physician is associated with an oath still linked to medical ethics?",
    "a": "Hippocrates",
    "w": [
      "Galen",
      "Herodotus",
      "Aeschylus"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which playwright wrote the tragedy Oedipus Rex?",
    "a": "Sophocles",
    "w": [
      "Aristophanes",
      "Homer",
      "Plutarch"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which ancient Greek playwright was famous for comedies such as Lysistrata?",
    "a": "Aristophanes",
    "w": [
      "Sophocles",
      "Euripides",
      "Aeschylus"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Who united Macedonia and defeated the Greek city-states at Chaeronea?",
    "a": "Philip II",
    "w": [
      "Alexander the Great",
      "Pericles",
      "Leonidas"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "What name is given to the spread of Greek culture after Alexander's conquests?",
    "a": "Hellenism",
    "w": [
      "Humanism",
      "Feudalism",
      "Mercantilism"
    ]
  },
  {
    "s": "Ancient Greece",
    "p": "Which Egyptian city became a major center of Hellenistic learning?",
    "a": "Alexandria",
    "w": [
      "Memphis",
      "Thebes",
      "Giza"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "According to Roman tradition, who founded Rome with his twin brother?",
    "a": "Romulus",
    "w": [
      "Aeneas",
      "Julius Caesar",
      "Augustus"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "In which year does Roman tradition place the founding of Rome?",
    "a": "753 BC",
    "w": [
      "509 BC",
      "44 BC",
      "AD 476"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which people ruled Rome before the Roman Republic was established?",
    "a": "The Etruscans",
    "w": [
      "The Persians",
      "The Huns",
      "The Phoenicians"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "What form of government did Rome establish after expelling its last king?",
    "a": "A republic",
    "w": [
      "A democracy with no officials",
      "A feudal monarchy",
      "A military empire"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "How many consuls normally headed the Roman Republic at one time?",
    "a": "Two",
    "w": [
      "One",
      "Three",
      "Twelve"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "What was the Roman Senate?",
    "a": "A council of leading citizens",
    "w": [
      "A unit of cavalry",
      "A public grain market",
      "A school for priests"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "What were the ordinary citizens of ancient Rome called?",
    "a": "Plebeians",
    "w": [
      "Patricians",
      "Consuls",
      "Satraps"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "What were members of Rome's old aristocratic families called?",
    "a": "Patricians",
    "w": [
      "Plebeians",
      "Helots",
      "Tribunes"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which Roman officials were elected to defend plebeian interests?",
    "a": "Tribunes",
    "w": [
      "Censors",
      "Praetors",
      "Quaestors"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "What were the Twelve Tables?",
    "a": "Rome's early written laws",
    "w": [
      "A set of military maps",
      "Twelve temples",
      "The calendar of Augustus"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which wars were fought between Rome and Carthage?",
    "a": "The Punic Wars",
    "w": [
      "The Persian Wars",
      "The Gallic Wars",
      "The Samnite Revolts"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which island was a major prize in the First Punic War?",
    "a": "Sicily",
    "w": [
      "Crete",
      "Cyprus",
      "Britain"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "At which battle did Hannibal crush a much larger Roman army in 216 BC?",
    "a": "Cannae",
    "w": [
      "Zama",
      "Actium",
      "Pharsalus"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which Roman general finally defeated Hannibal at Zama?",
    "a": "Scipio Africanus",
    "w": [
      "Pompey",
      "Marius",
      "Sulla"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "What happened to Carthage at the end of the Third Punic War?",
    "a": "Rome destroyed it",
    "w": [
      "It conquered Rome",
      "It joined Persia",
      "It moved its capital to Spain"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which brothers proposed land reforms and were killed during the late Republic?",
    "a": "The Gracchi brothers",
    "w": [
      "The Scipio brothers",
      "The Caesar brothers",
      "The Horatii brothers"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which Roman general reformed the army and recruited landless citizens?",
    "a": "Gaius Marius",
    "w": [
      "Cicero",
      "Brutus",
      "Cato"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which Roman dictator marched his army on Rome in the first century BC?",
    "a": "Sulla",
    "w": [
      "Virgil",
      "Trajan",
      "Hadrian"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which three men formed the First Triumvirate?",
    "a": "Caesar, Pompey, and Crassus",
    "w": [
      "Augustus, Antony, and Lepidus",
      "Marius, Sulla, and Cato",
      "Brutus, Cassius, and Cicero"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which region did Julius Caesar conquer before crossing the Rubicon?",
    "a": "Gaul",
    "w": [
      "Egypt",
      "Greece",
      "Mesopotamia"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Who were the two best-known leaders of the plot to assassinate Julius Caesar?",
    "a": "Brutus and Cassius",
    "w": [
      "Antony and Octavian",
      "Marius and Sulla",
      "Pompey and Crassus"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which battle gave Octavian victory over Mark Antony and Cleopatra?",
    "a": "Actium",
    "w": [
      "Cannae",
      "Zama",
      "Teutoburg Forest"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which Roman officials were elected to defend the interests of the plebeians?",
    "a": "Tribunes of the plebs",
    "w": [
      "Consuls",
      "Censors",
      "Praetors"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which Roman emperor was ruling when Mount Vesuvius erupted in AD 79?",
    "a": "Titus",
    "w": [
      "Nero",
      "Augustus",
      "Constantine"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Under which emperor did the Roman Empire reach its greatest territorial size?",
    "a": "Trajan",
    "w": [
      "Hadrian",
      "Nero",
      "Diocletian"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which emperor divided imperial administration into a tetrarchy?",
    "a": "Diocletian",
    "w": [
      "Trajan",
      "Claudius",
      "Marcus Aurelius"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "What did Constantine establish at the site of Byzantium?",
    "a": "Constantinople",
    "w": [
      "Alexandria",
      "Antioch",
      "Ravenna"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which emperor extended Roman citizenship to nearly all free inhabitants of the empire in 212?",
    "a": "Caracalla",
    "w": [
      "Diocletian",
      "Hadrian",
      "Constantine I"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "What language became dominant in the Eastern Roman Empire?",
    "a": "Greek",
    "w": [
      "Latin",
      "Arabic",
      "Persian"
    ]
  },
  {
    "s": "Ancient Rome",
    "p": "Which Germanic leader deposed the last western Roman emperor in AD 476?",
    "a": "Odoacer",
    "w": [
      "Alaric",
      "Theodoric",
      "Clovis"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Along which river did the earliest known Indian urban civilization develop?",
    "a": "The Indus",
    "w": [
      "The Ganges",
      "The Mekong",
      "The Yangtze"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which two cities are famous sites of the Indus Valley civilization?",
    "a": "Harappa and Mohenjo-daro",
    "w": [
      "Delhi and Agra",
      "Sparta and Athens",
      "Ur and Babylon"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "What feature showed the advanced planning of Indus Valley cities?",
    "a": "Grid streets and drainage systems",
    "w": [
      "Gothic cathedrals",
      "Railway stations",
      "Stone amphitheaters"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which ancient sacred texts form an early foundation of Hindu tradition?",
    "a": "The Vedas",
    "w": [
      "The Analects",
      "The Torah",
      "The Avesta"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "What social hierarchy developed in ancient India?",
    "a": "The caste system",
    "w": [
      "The feudal estates",
      "The polis system",
      "The mandarin system"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Who founded Buddhism in ancient India?",
    "a": "Siddhartha Gautama",
    "w": [
      "Ashoka",
      "Chandragupta Maurya",
      "Confucius"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "What title means the Enlightened One?",
    "a": "Buddha",
    "w": [
      "Pharaoh",
      "Caesar",
      "Caliph"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "What do Buddhism's Four Noble Truths address?",
    "a": "Suffering and how to overcome it",
    "w": [
      "The organization of armies",
      "The building of temples",
      "The selection of kings"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which ancient university in India became a major center of Buddhist learning?",
    "a": "Nalanda",
    "w": [
      "Angkor Wat",
      "Chang'an",
      "Persepolis"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "What did Ashoka have carved on pillars and rocks across his empire?",
    "a": "Edicts",
    "w": [
      "Epic poems only",
      "Tax receipts",
      "Battle maps"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which dynasty is often associated with a golden age of classical Indian culture?",
    "a": "The Gupta dynasty",
    "w": [
      "The Qin dynasty",
      "The Tokugawa dynasty",
      "The Safavid dynasty"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which number concept was developed by Indian mathematicians and later spread west?",
    "a": "Zero",
    "w": [
      "Roman V",
      "The abacus",
      "The calendar year"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which Chinese dynasty is the earliest supported by extensive written records?",
    "a": "The Shang dynasty",
    "w": [
      "The Qin dynasty",
      "The Han dynasty",
      "The Ming dynasty"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "On what did Shang diviners write some of China's earliest known characters?",
    "a": "Oracle bones",
    "w": [
      "Papyrus",
      "Clay tablets",
      "Silk flags only"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which dynasty introduced the idea of the Mandate of Heaven?",
    "a": "The Zhou dynasty",
    "w": [
      "The Shang dynasty",
      "The Qin dynasty",
      "The Qing dynasty"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "What did the Mandate of Heaven claim?",
    "a": "A ruler's right depended on just rule",
    "w": [
      "Every ruler was elected",
      "Only priests could own land",
      "China must have two emperors"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which thinker emphasized family duty, education, and proper conduct?",
    "a": "Confucius",
    "w": [
      "Laozi",
      "Sun Tzu",
      "Han Fei"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which book preserves sayings associated with Confucius?",
    "a": "The Analects",
    "w": [
      "The Art of War",
      "The Vedas",
      "The Kojiki"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which Chinese philosophy stresses harmony with the Dao, or Way?",
    "a": "Daoism",
    "w": [
      "Legalism",
      "Zoroastrianism",
      "Stoicism"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Who is traditionally associated with the Dao De Jing?",
    "a": "Laozi",
    "w": [
      "Confucius",
      "Mencius",
      "Sun Tzu"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which Chinese philosophy favored strict laws and harsh punishments?",
    "a": "Legalism",
    "w": [
      "Daoism",
      "Buddhism",
      "Stoicism"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which ruler unified China in 221 BC?",
    "a": "Qin Shi Huang",
    "w": [
      "Liu Bang",
      "Wu of Han",
      "Kublai Khan"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "What major building project joined earlier frontier walls under the Qin?",
    "a": "The Great Wall",
    "w": [
      "The Grand Canal",
      "The Forbidden City",
      "The Summer Palace"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which dynasty followed the Qin and ruled China for about four centuries?",
    "a": "The Han dynasty",
    "w": [
      "The Tang dynasty",
      "The Song dynasty",
      "The Yuan dynasty"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Who founded the Han dynasty?",
    "a": "Liu Bang",
    "w": [
      "Qin Shi Huang",
      "Emperor Wu",
      "Cao Cao"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which trade route expanded greatly under the Han dynasty?",
    "a": "The Silk Road",
    "w": [
      "The Amber Road",
      "The Royal Road",
      "The Incense Route only"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which Chinese invention allowed officials to record information on a light surface?",
    "a": "Paper",
    "w": [
      "Concrete",
      "Glass",
      "Parchment"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Who wrote The Art of War?",
    "a": "Sun Tzu",
    "w": [
      "Confucius",
      "Laozi",
      "Sima Qian"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Who is often called the father of Chinese history?",
    "a": "Sima Qian",
    "w": [
      "Sun Tzu",
      "Mencius",
      "Liu Bang"
    ]
  },
  {
    "s": "Ancient South And East Asia",
    "p": "Which ancient Korean kingdom became known for tomb murals and military power?",
    "a": "Goguryeo",
    "w": [
      "Silla",
      "Joseon",
      "Goryeo"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which Frankish king converted to Christianity around AD 500?",
    "a": "Clovis",
    "w": [
      "Charlemagne",
      "Pepin",
      "Charles Martel"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which city was Charlemagne's main royal center?",
    "a": "Aachen",
    "w": [
      "Paris",
      "Rome",
      "Vienna"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which treaty divided Charlemagne's empire among his grandsons in 843?",
    "a": "The Treaty of Verdun",
    "w": [
      "The Treaty of Troyes",
      "The Treaty of Paris",
      "The Concordat of Worms"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "What was a vassal expected to provide to a feudal lord?",
    "a": "Loyalty and service",
    "w": [
      "A printing press",
      "Free elections",
      "A naval fleet only"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "What was a fief in medieval Europe?",
    "a": "Land granted in return for service",
    "w": [
      "A church tax",
      "A knight's helmet",
      "A city market"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "What was the economic center of many feudal estates?",
    "a": "The manor",
    "w": [
      "The senate",
      "The factory",
      "The colony"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Who were serfs?",
    "a": "Peasants bound to a lord's land",
    "w": [
      "Traveling merchants",
      "Mounted nobles",
      "University teachers"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Where did many medieval monks live and work?",
    "a": "Monasteries",
    "w": [
      "Guildhalls",
      "Castles",
      "Parliaments"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which saint wrote a widely followed rule for Western monasteries?",
    "a": "Saint Benedict",
    "w": [
      "Saint Patrick",
      "Saint Francis",
      "Saint George"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "What major split in 1054 divided Christianity in Europe?",
    "a": "The Great Schism",
    "w": [
      "The Reformation",
      "The Avignon Papacy",
      "The Investiture Peace"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which two main churches emerged from the Great Schism?",
    "a": "Roman Catholic and Eastern Orthodox",
    "w": [
      "Lutheran and Calvinist",
      "Anglican and Methodist",
      "Coptic and Baptist"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "What survey of English landholding did William I order?",
    "a": "The Domesday Book",
    "w": [
      "The Magna Carta",
      "The Anglo-Saxon Chronicle",
      "The Book of Common Prayer"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which dynasty began ruling England with Henry II in 1154?",
    "a": "The Plantagenets",
    "w": [
      "The Tudors",
      "The Stuarts",
      "The Hanoverians"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which English king developed royal courts and helped establish common law?",
    "a": "Henry II",
    "w": [
      "King John",
      "Edward II",
      "Richard III"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which archbishop was murdered in Canterbury Cathedral after quarreling with Henry II?",
    "a": "Thomas Becket",
    "w": [
      "Anselm",
      "Thomas More",
      "Stephen Langton"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which pope called the First Crusade in 1095?",
    "a": "Urban II",
    "w": [
      "Gregory VII",
      "Innocent III",
      "Leo X"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "What city did crusaders capture in 1099?",
    "a": "Jerusalem",
    "w": [
      "Constantinople",
      "Rome",
      "Alexandria"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which Muslim leader recaptured Jerusalem in 1187?",
    "a": "Saladin",
    "w": [
      "Suleiman",
      "Mehmed II",
      "Harun al-Rashid"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which Christian city was sacked by the Fourth Crusade in 1204?",
    "a": "Constantinople",
    "w": [
      "Rome",
      "Paris",
      "Canterbury"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "The Investiture Controversy was mainly a dispute over who could appoint whom?",
    "a": "Bishops",
    "w": [
      "Merchants",
      "Knights",
      "University rectors"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which emperor stood at Canossa seeking forgiveness from Pope Gregory VII?",
    "a": "Henry IV",
    "w": [
      "Frederick II",
      "Otto I",
      "Charles IV"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which agreement settled the Investiture Controversy in 1122?",
    "a": "The Concordat of Worms",
    "w": [
      "The Treaty of Verdun",
      "The Peace of Augsburg",
      "The Golden Bull"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "What was the Hanseatic League?",
    "a": "An alliance of northern trading cities",
    "w": [
      "An order of crusading monks",
      "A French peasant army",
      "A group of Italian universities"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "What did medieval craft guilds regulate?",
    "a": "Training, quality, and trade",
    "w": [
      "Royal marriages",
      "Church doctrine",
      "Village elections"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "What was the usual first stage of training in a medieval craft?",
    "a": "Apprentice",
    "w": [
      "Master",
      "Journeyman",
      "Freeman"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which city is home to Europe's oldest continuously operating university, founded in 1088?",
    "a": "Bologna",
    "w": [
      "Oxford",
      "Paris",
      "Prague"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which scholar tried to reconcile Christian theology with Aristotle's philosophy?",
    "a": "Thomas Aquinas",
    "w": [
      "Francis Bacon",
      "Martin Luther",
      "Dante Alighieri"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which weapon helped English armies win at Crécy and Agincourt?",
    "a": "The longbow",
    "w": [
      "The musket",
      "The crossbow alone",
      "The cannon only"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which French city did Joan of Arc help relieve from English siege in 1429?",
    "a": "Orléans",
    "w": [
      "Paris",
      "Calais",
      "Rouen"
    ]
  },
  {
    "s": "Medieval Europe",
    "p": "Which two houses fought England's Wars of the Roses?",
    "a": "Lancaster and York",
    "w": [
      "Tudor and Stuart",
      "Normandy and Anjou",
      "Wessex and Mercia"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which church was built in Constantinople under Emperor Justinian?",
    "a": "Hagia Sophia",
    "w": [
      "Saint Peter's Basilica",
      "Notre-Dame",
      "Westminster Abbey"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which empress was Justinian's influential wife and adviser?",
    "a": "Theodora",
    "w": [
      "Irene",
      "Helena",
      "Sophia"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "What name is given to the debate over religious images in Byzantium?",
    "a": "Iconoclasm",
    "w": [
      "Scholasticism",
      "Simony",
      "Humanism"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which missionary brothers created an alphabet for Slavic languages?",
    "a": "Cyril and Methodius",
    "w": [
      "Benedict and Dominic",
      "Peter and Paul",
      "Romulus and Remus"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which ruler brought Orthodox Christianity to Kievan Rus in 988?",
    "a": "Vladimir the Great",
    "w": [
      "Ivan the Terrible",
      "Yaroslav II",
      "Rurik"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "In which Arabian city was Muhammad born?",
    "a": "Mecca",
    "w": [
      "Medina",
      "Damascus",
      "Jerusalem"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "What was the Hijra?",
    "a": "Muhammad's migration from Mecca to Medina",
    "w": [
      "The conquest of Spain",
      "A pilgrimage to Jerusalem",
      "The division of the Roman Empire"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which year begins the Islamic calendar?",
    "a": "AD 622",
    "w": [
      "AD 476",
      "AD 800",
      "AD 1066"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "What is the holy book of Islam?",
    "a": "The Quran",
    "w": [
      "The Vedas",
      "The Torah",
      "The Analects"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "What title was used by Muhammad's political and religious successors?",
    "a": "Caliph",
    "w": [
      "Consul",
      "Shogun",
      "Patriarch"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which city was the capital of the Umayyad Caliphate?",
    "a": "Damascus",
    "w": [
      "Baghdad",
      "Cairo",
      "Mecca"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which city was the capital of the Abbasid Caliphate?",
    "a": "Baghdad",
    "w": [
      "Damascus",
      "Jerusalem",
      "Cordoba"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "What was Baghdad's House of Wisdom?",
    "a": "A major center of scholarship and translation",
    "w": [
      "A royal fortress",
      "A military academy only",
      "A mosque reserved for caliphs"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "The word algebra comes from the work of which scholar?",
    "a": "Al-Khwarizmi",
    "w": [
      "Avicenna",
      "Averroes",
      "Al-Razi"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which Persian scholar wrote the influential Canon of Medicine?",
    "a": "Avicenna",
    "w": [
      "Al-Khwarizmi",
      "Ibn Battuta",
      "Omar Khayyam"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which Muslim traveler described journeys across Africa and Asia in the 1300s?",
    "a": "Ibn Battuta",
    "w": [
      "Ibn Sina",
      "Al-Khwarizmi",
      "Saladin"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which city became a brilliant center of Islamic learning in medieval Spain?",
    "a": "Cordoba",
    "w": [
      "Madrid",
      "Lisbon",
      "Toledo only after 1492"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "What was the Reconquista?",
    "a": "The Christian conquest of Muslim-ruled Iberia",
    "w": [
      "The Mongol invasion of China",
      "The Viking settlement of Iceland",
      "The Crusader capture of Jerusalem only"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which West African empire grew wealthy from gold and salt trade before Mali?",
    "a": "Ghana",
    "w": [
      "Songhai",
      "Axum",
      "Benin"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which West African city became famous for its manuscript libraries and Islamic scholarship?",
    "a": "Timbuktu",
    "w": [
      "Great Zimbabwe",
      "Kilwa",
      "Axum"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which city of Mali became famous for scholarship and trade?",
    "a": "Timbuktu",
    "w": [
      "Carthage",
      "Mombasa",
      "Lagos"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Who founded the Mali Empire after victory at the Battle of Kirina?",
    "a": "Sundiata Keita",
    "w": [
      "Mansa Musa",
      "Askia Muhammad",
      "Shaka Zulu"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which empire replaced Mali as the largest power in the western Sudan?",
    "a": "Songhai",
    "w": [
      "Axum",
      "Ghana",
      "Kongo"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "The stone ruins of Great Zimbabwe are in which modern country?",
    "a": "Zimbabwe",
    "w": [
      "Ethiopia",
      "Egypt",
      "Ghana"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which ancient African kingdom adopted Christianity in the fourth century?",
    "a": "Axum",
    "w": [
      "Songhai",
      "Mali",
      "Zulu"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "What was Genghis Khan's birth name?",
    "a": "Temujin",
    "w": [
      "Batu",
      "Ogedei",
      "Timur"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which empire became the largest contiguous land empire in history?",
    "a": "The Mongol Empire",
    "w": [
      "The Roman Empire",
      "The British Empire",
      "The Ottoman Empire"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "What does Pax Mongolica describe?",
    "a": "Relative security across Mongol trade routes",
    "w": [
      "A Mongol civil war",
      "The conversion of Mongolia to Islam",
      "A peace treaty with Japan"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which Mongol ruler founded China's Yuan dynasty?",
    "a": "Kublai Khan",
    "w": [
      "Genghis Khan",
      "Batu Khan",
      "Hulagu Khan"
    ]
  },
  {
    "s": "Byzantium, Islam, The Mongols And Africa",
    "p": "Which Mongol state ruled much of Russia after the invasions?",
    "a": "The Golden Horde",
    "w": [
      "The Ilkhanate",
      "The Chagatai Khanate",
      "The Yuan dynasty"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "What intellectual movement placed renewed emphasis on classical learning and human potential?",
    "a": "Humanism",
    "w": [
      "Mercantilism",
      "Feudalism",
      "Absolutism"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Who is often called the father of Renaissance humanism?",
    "a": "Petrarch",
    "w": [
      "Dante",
      "Boccaccio",
      "Machiavelli"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which wealthy family was a leading patron of Renaissance Florence?",
    "a": "The Medici",
    "w": [
      "The Borgia",
      "The Sforza",
      "The Habsburg"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Who designed the great dome of Florence Cathedral?",
    "a": "Filippo Brunelleschi",
    "w": [
      "Donatello",
      "Raphael",
      "Titian"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which artistic technique creates the illusion of depth on a flat surface?",
    "a": "Linear perspective",
    "w": [
      "Mosaic",
      "Fresco",
      "Woodcut"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Who wrote The Prince?",
    "a": "Niccolò Machiavelli",
    "w": [
      "Petrarch",
      "Castiglione",
      "Thomas More"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which artist painted The School of Athens?",
    "a": "Raphael",
    "w": [
      "Michelangelo",
      "Leonardo da Vinci",
      "Botticelli"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which Florentine artist painted The Birth of Venus?",
    "a": "Sandro Botticelli",
    "w": [
      "Titian",
      "Raphael",
      "Donatello"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which Dutch humanist wrote In Praise of Folly?",
    "a": "Erasmus",
    "w": [
      "Thomas More",
      "Martin Luther",
      "John Calvin"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Who wrote Utopia about an imaginary ideal society?",
    "a": "Thomas More",
    "w": [
      "Erasmus",
      "Francis Bacon",
      "William Shakespeare"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which German artist created famous prints and a detailed self-portrait?",
    "a": "Albrecht Dürer",
    "w": [
      "Hans Holbein",
      "Lucas Cranach",
      "Jan van Eyck"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "In which German city did Gutenberg develop movable-type printing?",
    "a": "Mainz",
    "w": [
      "Wittenberg",
      "Augsburg",
      "Nuremberg"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "What church practice involving reductions of punishment did Luther criticize?",
    "a": "The sale of indulgences",
    "w": [
      "Infant baptism",
      "Sunday worship",
      "Monastic education"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "At which imperial assembly was Luther asked to recant in 1521?",
    "a": "The Diet of Worms",
    "w": [
      "The Council of Trent",
      "The Peace of Augsburg",
      "The Diet of Speyer"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Who protected Luther at Wartburg Castle?",
    "a": "Frederick the Wise",
    "w": [
      "Charles V",
      "Henry VIII",
      "Pope Leo X"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Into which language did Luther translate the New Testament at Wartburg?",
    "a": "German",
    "w": [
      "Latin",
      "French",
      "Dutch"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which Holy Roman emperor opposed Luther at the Diet of Worms?",
    "a": "Charles V",
    "w": [
      "Maximilian II",
      "Ferdinand III",
      "Frederick III"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which radical social conflict shook German lands in 1524–25?",
    "a": "The German Peasants' War",
    "w": [
      "The Thirty Years' War",
      "The Schmalkaldic War",
      "The War of Austrian Succession"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which reformer made Geneva a center of Protestantism?",
    "a": "John Calvin",
    "w": [
      "Huldrych Zwingli",
      "John Knox",
      "Jan Hus"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which doctrine is especially associated with Calvinism?",
    "a": "Predestination",
    "w": [
      "Papal infallibility",
      "Divine right of kings",
      "Transubstantiation only"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which reformer led the Protestant movement in Zürich?",
    "a": "Huldrych Zwingli",
    "w": [
      "John Calvin",
      "Martin Luther",
      "Ignatius Loyola"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which law declared Henry VIII supreme head of the Church of England?",
    "a": "The Act of Supremacy",
    "w": [
      "The Act of Settlement",
      "The Test Act",
      "The Bill of Rights"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which English monarch restored Roman Catholic worship after Edward VI?",
    "a": "Mary I",
    "w": [
      "Elizabeth I",
      "Anne",
      "Mary II"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which settlement under Elizabeth I shaped the Church of England?",
    "a": "The Elizabethan Religious Settlement",
    "w": [
      "The Peace of Augsburg",
      "The Edict of Nantes",
      "The Concordat of Worms"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which council clarified Catholic teaching during the Counter-Reformation?",
    "a": "The Council of Trent",
    "w": [
      "The Council of Constance",
      "The Council of Nicaea",
      "The Lateran Council of 1215"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Who founded the Society of Jesus, or Jesuits?",
    "a": "Ignatius of Loyola",
    "w": [
      "Francis of Assisi",
      "Dominic",
      "Thomas Aquinas"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which 1572 massacre targeted French Protestants in Paris and beyond?",
    "a": "The St. Bartholomew's Day Massacre",
    "w": [
      "The Peterloo Massacre",
      "The Boston Massacre",
      "The Sicilian Vespers"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which French king issued the Edict of Nantes?",
    "a": "Henry IV",
    "w": [
      "Louis XIV",
      "Francis I",
      "Charles IX"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "What event in Prague helped ignite the Thirty Years' War?",
    "a": "The Defenestration of Prague",
    "w": [
      "The storming of the Bastille",
      "The execution of Jan Hus",
      "The siege of Vienna"
    ]
  },
  {
    "s": "Renaissance And Reformation",
    "p": "Which 1555 agreement allowed rulers in the Holy Roman Empire to choose Lutheranism or Catholicism?",
    "a": "The Peace of Augsburg",
    "w": [
      "The Edict of Nantes",
      "The Treaty of Utrecht",
      "The Concordat of Worms"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Portuguese explorer rounded the Cape of Good Hope in 1488?",
    "a": "Bartolomeu Dias",
    "w": [
      "Vasco da Gama",
      "Pedro Cabral",
      "Henry the Navigator"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which treaty divided newly claimed overseas lands between Spain and Portugal?",
    "a": "The Treaty of Tordesillas",
    "w": [
      "The Treaty of Utrecht",
      "The Treaty of Zaragoza only",
      "The Peace of Westphalia"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Portuguese navigator claimed Brazil in 1500?",
    "a": "Pedro Álvares Cabral",
    "w": [
      "Bartolomeu Dias",
      "Vasco da Gama",
      "Amerigo Vespucci"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Who crossed Panama and saw the Pacific Ocean in 1513?",
    "a": "Vasco Núñez de Balboa",
    "w": [
      "Hernán Cortés",
      "Francisco Pizarro",
      "Juan Ponce de León"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which strait at South America's tip is named after Magellan?",
    "a": "The Strait of Magellan",
    "w": [
      "The Drake Passage",
      "The Bering Strait",
      "The Strait of Hormuz"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Who completed the first circumnavigation after Magellan was killed?",
    "a": "Juan Sebastián Elcano",
    "w": [
      "Vasco da Gama",
      "Amerigo Vespucci",
      "Pedro Cabral"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "What was a Spanish conqueror in the Americas called?",
    "a": "A conquistador",
    "w": [
      "A viceroy",
      "A gaucho",
      "A hidalgo only in Spain"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "What was the encomienda system?",
    "a": "A grant of Indigenous labor and tribute to colonists",
    "w": [
      "A free public school system",
      "A naval convoy",
      "An elected town council"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "What does the Columbian Exchange describe?",
    "a": "Movement of crops, animals, diseases, and people between hemispheres",
    "w": [
      "A treaty between Columbus and Portugal",
      "Trade only between China and Europe",
      "The exchange of royal ambassadors"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which American crop became a major food staple in Europe?",
    "a": "The potato",
    "w": [
      "Wheat",
      "Barley",
      "Rice"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which disease devastated Indigenous American populations after European contact?",
    "a": "Smallpox",
    "w": [
      "Scurvy",
      "Rickets",
      "Black lung"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "What was the Middle Passage?",
    "a": "The forced Atlantic voyage of enslaved Africans",
    "w": [
      "A route through the Alps",
      "The voyage from India to China",
      "A canal across Panama"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "What was triangular trade?",
    "a": "Atlantic trade linking Europe, Africa, and the Americas",
    "w": [
      "Trade among three Italian cities",
      "A Silk Road tax system",
      "A medieval guild agreement"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Spanish priest condemned the abuse of Indigenous Americans?",
    "a": "Bartolomé de las Casas",
    "w": [
      "Ignatius of Loyola",
      "Francis Xavier",
      "Torquemada"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Aztec emperor met Cortés in 1519?",
    "a": "Moctezuma II",
    "w": [
      "Atahualpa",
      "Pachacuti",
      "Cuauhtémoc I"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Indigenous interpreter and adviser helped Cortés?",
    "a": "Malintzin",
    "w": [
      "Pocahontas",
      "Sacagawea",
      "Anacaona"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Inca ruler was captured by Pizarro at Cajamarca?",
    "a": "Atahualpa",
    "w": [
      "Pachacuti",
      "Huayna Capac",
      "Manco Capac"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which silver-mining city became enormously important to Spain's empire?",
    "a": "Potosí",
    "w": [
      "Lima",
      "Havana",
      "Cartagena"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which economic idea held that states should accumulate bullion and export more than they imported?",
    "a": "Mercantilism",
    "w": [
      "Socialism",
      "Feudalism",
      "Laissez-faire"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which company, founded in 1602, dominated much Asian spice trade?",
    "a": "The Dutch East India Company",
    "w": [
      "The Hudson's Bay Company",
      "The Hanseatic League",
      "The Royal African Company"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which European country colonized the Philippines?",
    "a": "Spain",
    "w": [
      "Portugal",
      "The Netherlands",
      "France"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "What did the Manila galleons carry across the Pacific?",
    "a": "Goods between Asia and Spanish America",
    "w": [
      "Pilgrims to North America",
      "Enslaved Romans",
      "Russian furs to France only"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Indian port became the center of Portuguese power in Asia?",
    "a": "Goa",
    "w": [
      "Bombay",
      "Calcutta",
      "Madras"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Ottoman sultan captured Constantinople in 1453?",
    "a": "Mehmed II",
    "w": [
      "Suleiman I",
      "Selim I",
      "Osman I"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Under which sultan did the Ottoman Empire reach a peak of power in the 1500s?",
    "a": "Suleiman the Magnificent",
    "w": [
      "Mehmed II",
      "Murad I",
      "Abdulhamid II"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Who were the janissaries?",
    "a": "Elite infantry serving the Ottoman sultan",
    "w": [
      "Venetian merchants",
      "Persian priests",
      "Russian cavalry nobles"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which dynasty made Twelver Shi'a Islam the state religion of Persia?",
    "a": "The Safavids",
    "w": [
      "The Mughals",
      "The Abbasids",
      "The Umayyads"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Who founded the Mughal Empire in India?",
    "a": "Babur",
    "w": [
      "Akbar",
      "Shah Jahan",
      "Aurangzeb"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Mughal emperor became known for religious tolerance and administrative reform?",
    "a": "Akbar",
    "w": [
      "Babur",
      "Aurangzeb",
      "Shah Jahan"
    ]
  },
  {
    "s": "Exploration And Early Global Empires",
    "p": "Which Japanese leader won at Sekigahara and founded the Tokugawa shogunate?",
    "a": "Tokugawa Ieyasu",
    "w": [
      "Oda Nobunaga",
      "Toyotomi Hideyoshi",
      "Emperor Meiji"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which European power did the Dutch Republic fight to win independence?",
    "a": "Spain",
    "w": [
      "France",
      "England",
      "Portugal"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which 1579 agreement joined the northern Dutch provinces against Spain?",
    "a": "The Union of Utrecht",
    "w": [
      "The Treaty of Utrecht",
      "The Pacification of Ghent",
      "The League of Augsburg"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Who was known as William the Silent?",
    "a": "William of Orange",
    "w": [
      "William III of England",
      "William the Conqueror",
      "William Pitt"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "What were supporters of Parliament called in the English Civil War?",
    "a": "Roundheads",
    "w": [
      "Cavaliers",
      "Jacobites",
      "Levellers only"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "What were supporters of King Charles I called?",
    "a": "Cavaliers",
    "w": [
      "Roundheads",
      "Whigs",
      "Puritans only"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "What happened to Charles I in 1649?",
    "a": "He was tried and executed",
    "w": [
      "He defeated Parliament",
      "He became king of France",
      "He abdicated peacefully"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which king returned to the English throne in the Restoration of 1660?",
    "a": "Charles II",
    "w": [
      "James I",
      "William III",
      "George I"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which rulers replaced James II in the Glorious Revolution?",
    "a": "William III and Mary II",
    "w": [
      "Charles II and Catherine",
      "George I and Sophia",
      "Henry VIII and Anne"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which English law of 1689 limited royal power and strengthened Parliament?",
    "a": "The Bill of Rights",
    "w": [
      "The Magna Carta",
      "The Act of Supremacy",
      "The Reform Act"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "What legal principle protects people from imprisonment without lawful cause?",
    "a": "Habeas corpus",
    "w": [
      "Divine right",
      "Primogeniture",
      "Mercantilism"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which French minister strengthened royal power under Louis XIII?",
    "a": "Cardinal Richelieu",
    "w": [
      "Cardinal Mazarin",
      "Jean-Baptiste Colbert",
      "Talleyrand"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which policy did Louis XIV follow by revoking the Edict of Nantes?",
    "a": "He ended legal protection for French Protestants",
    "w": [
      "He granted universal voting rights",
      "He abolished noble titles",
      "He made France a republic"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which war began over who would inherit the Spanish throne after Charles II?",
    "a": "The War of the Spanish Succession",
    "w": [
      "The Seven Years' War",
      "The War of Austrian Succession",
      "The Thirty Years' War"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which 1713 treaty helped end the War of the Spanish Succession?",
    "a": "The Treaty of Utrecht",
    "w": [
      "The Treaty of Paris",
      "The Peace of Westphalia",
      "The Treaty of Versailles"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which Polish king helped defeat the Ottoman siege of Vienna in 1683?",
    "a": "John III Sobieski",
    "w": [
      "Casimir III",
      "Stanisław II",
      "Władysław II"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "At which 1709 battle did Peter the Great defeat Sweden?",
    "a": "Poltava",
    "w": [
      "Narva",
      "Vienna",
      "Blenheim"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which war made Russia the leading power on the Baltic Sea?",
    "a": "The Great Northern War",
    "w": [
      "The Crimean War",
      "The Seven Years' War",
      "The Livonian War"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which three powers partitioned Poland in the late 1700s?",
    "a": "Russia, Prussia, and Austria",
    "w": [
      "France, Britain, and Spain",
      "Sweden, Denmark, and Russia",
      "Austria, Italy, and the Ottoman Empire"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which thinker promoted observation and experimentation in scientific study?",
    "a": "Francis Bacon",
    "w": [
      "Thomas Hobbes",
      "John Locke",
      "Voltaire"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which philosopher wrote ‘I think, therefore I am’?",
    "a": "René Descartes",
    "w": [
      "Baruch Spinoza",
      "David Hume",
      "Immanuel Kant"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which astronomer formulated three laws of planetary motion?",
    "a": "Johannes Kepler",
    "w": [
      "Tycho Brahe",
      "Galileo",
      "Copernicus"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Who demonstrated that blood circulates through the body?",
    "a": "William Harvey",
    "w": [
      "Robert Hooke",
      "Edward Jenner",
      "Andreas Vesalius"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Who coined the term cell after examining cork?",
    "a": "Robert Hooke",
    "w": [
      "Antonie van Leeuwenhoek",
      "Isaac Newton",
      "William Harvey"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Who first observed microorganisms with powerful simple microscopes?",
    "a": "Antonie van Leeuwenhoek",
    "w": [
      "Robert Hooke",
      "Louis Pasteur",
      "Gregor Mendel"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Who wrote Leviathan and argued for a powerful sovereign?",
    "a": "Thomas Hobbes",
    "w": [
      "John Locke",
      "Jean-Jacques Rousseau",
      "Montesquieu"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which thinker argued that people possess natural rights to life, liberty, and property?",
    "a": "John Locke",
    "w": [
      "Thomas Hobbes",
      "Voltaire",
      "Diderot"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Who argued for separation of government powers?",
    "a": "Montesquieu",
    "w": [
      "Rousseau",
      "Adam Smith",
      "Thomas Paine"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Which Enlightenment writer strongly defended religious tolerance and free expression?",
    "a": "Voltaire",
    "w": [
      "Hobbes",
      "Metternich",
      "Bossuet"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Who wrote The Social Contract?",
    "a": "Jean-Jacques Rousseau",
    "w": [
      "John Locke",
      "Denis Diderot",
      "Cesare Beccaria"
    ]
  },
  {
    "s": "The 1600s, 1700s And Enlightenment",
    "p": "Who wrote The Wealth of Nations?",
    "a": "Adam Smith",
    "w": [
      "David Ricardo",
      "Karl Marx",
      "John Stuart Mill"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which conflict was known in North America as the French and Indian War?",
    "a": "The Seven Years' War",
    "w": [
      "The War of 1812",
      "The American Civil War",
      "The Thirty Years' War"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which 1774 laws were called the Intolerable Acts by American colonists?",
    "a": "Punitive British laws aimed at Massachusetts",
    "w": [
      "French taxes on imported tea",
      "Spanish limits on western settlement",
      "American laws against loyalists"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Where did the First Continental Congress meet?",
    "a": "Philadelphia",
    "w": [
      "Boston",
      "New York",
      "Richmond"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which 1775 battles began open fighting in the American Revolution?",
    "a": "Lexington and Concord",
    "w": [
      "Saratoga and Yorktown",
      "Trenton and Princeton",
      "Bunker Hill and Monmouth"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which American victory in 1777 helped bring France into the war?",
    "a": "Saratoga",
    "w": [
      "Yorktown",
      "Bunker Hill",
      "Valley Forge"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which battle effectively ended major fighting in the American Revolution?",
    "a": "Yorktown",
    "w": [
      "Saratoga",
      "Lexington",
      "Trenton"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which treaty recognized the independence of the United States in 1783?",
    "a": "The Treaty of Paris",
    "w": [
      "The Treaty of Ghent",
      "The Treaty of Versailles",
      "The Jay Treaty"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "What name was given to supporters of the proposed U.S. Constitution?",
    "a": "Federalists",
    "w": [
      "Loyalists",
      "Abolitionists",
      "Populists"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Where was George Washington inaugurated as president in 1789?",
    "a": "New York City",
    "w": [
      "Washington, D.C.",
      "Philadelphia",
      "Boston"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which body did Louis XVI summon in 1789 because of France's financial crisis?",
    "a": "The Estates-General",
    "w": [
      "The National Convention",
      "The Directory",
      "The Paris Commune"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which group took the Tennis Court Oath in June 1789?",
    "a": "The National Assembly",
    "w": [
      "The Committee of Public Safety",
      "The royal guards",
      "The Jacobin Club alone"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which French revolutionary document proclaimed liberty and equal rights?",
    "a": "The Declaration of the Rights of Man and of the Citizen",
    "w": [
      "The Civil Constitution of the Clergy",
      "The Napoleonic Code",
      "The Concordat"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "What happened to many feudal privileges in France in August 1789?",
    "a": "They were abolished",
    "w": [
      "They were expanded",
      "They were sold to Britain",
      "They became hereditary forever"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "When did France first declare itself a republic?",
    "a": "1792",
    "w": [
      "1789",
      "1804",
      "1815"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which French king was executed during the Revolution?",
    "a": "Louis XVI",
    "w": [
      "Louis XIV",
      "Louis XVIII",
      "Charles X"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which body directed France during the Reign of Terror?",
    "a": "The Committee of Public Safety",
    "w": [
      "The Estates-General",
      "The Directory",
      "The Council of Five Hundred only"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Who became the leading figure of the Reign of Terror?",
    "a": "Maximilien Robespierre",
    "w": [
      "Georges Danton",
      "Marquis de Lafayette",
      "Napoleon Bonaparte"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "What government ruled France immediately before Napoleon's 1799 coup?",
    "a": "The Directory",
    "w": [
      "The Consulate",
      "The Bourbon monarchy",
      "The Paris Commune"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "What was the name of Napoleon's 1799 seizure of power?",
    "a": "The coup of 18 Brumaire",
    "w": [
      "The July Revolution",
      "The Thermidorian Rising",
      "The Hundred Days"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which legal code spread equal civil law and property rights under Napoleon?",
    "a": "The Napoleonic Code",
    "w": [
      "The Code of Hammurabi",
      "The Justinian Code",
      "The Corn Laws"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "What was Napoleon's Continental System meant to do?",
    "a": "Block British trade with Europe",
    "w": [
      "Unite Italy",
      "Invade Russia by sea",
      "Restore the Holy Roman Empire"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which British admiral defeated the French and Spanish fleets at Trafalgar?",
    "a": "Horatio Nelson",
    "w": [
      "Arthur Wellesley",
      "John Jervis",
      "Francis Drake"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "What severely weakened Napoleon's army during its retreat from Moscow?",
    "a": "Cold, hunger, and Russian attacks",
    "w": [
      "A naval blockade",
      "An earthquake",
      "A rebellion in Egypt"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "At which 1813 battle did a coalition decisively defeat Napoleon in Germany?",
    "a": "Leipzig",
    "w": [
      "Austerlitz",
      "Jena",
      "Marengo"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "What were the Hundred Days?",
    "a": "Napoleon's brief return to power in 1815",
    "w": [
      "The first phase of the French Revolution",
      "The siege of Paris in 1871",
      "A meeting of the Congress of Vienna"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "What was a main goal of the Congress of Vienna?",
    "a": "Restore stability and a balance of power",
    "w": [
      "Create a united Germany immediately",
      "End all European monarchies",
      "Divide Europe into republics"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which 1819 attack on political reformers in Manchester became a symbol of repression?",
    "a": "The Peterloo Massacre",
    "w": [
      "The Tolpuddle Rising",
      "The Chartist Convention",
      "The Cato Street Conspiracy"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which 1823 policy warned European powers against new colonization in the Americas?",
    "a": "The Monroe Doctrine",
    "w": [
      "The Truman Doctrine",
      "The Roosevelt Corollary",
      "The Open Door Policy"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "In what year did Haiti declare independence from France?",
    "a": "1804",
    "w": [
      "1776",
      "1815",
      "1848"
    ]
  },
  {
    "s": "Revolutions And Napoleon",
    "p": "Which general helped liberate Argentina, Chile, and Peru from Spanish rule?",
    "a": "José de San Martín",
    "w": [
      "Bernardo O'Higgins alone",
      "Toussaint Louverture",
      "Antonio López de Santa Anna"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "In which country did the Industrial Revolution begin?",
    "a": "Great Britain",
    "w": [
      "France",
      "Germany",
      "The United States"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which industry was transformed first by many early British inventions?",
    "a": "Textiles",
    "w": [
      "Air travel",
      "Telecommunications",
      "Automobiles"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Who invented the spinning jenny?",
    "a": "James Hargreaves",
    "w": [
      "Richard Arkwright",
      "Edmund Cartwright",
      "Eli Whitney"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Who patented the water frame for spinning cotton?",
    "a": "Richard Arkwright",
    "w": [
      "James Hargreaves",
      "Samuel Crompton",
      "James Watt"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Who invented the power loom?",
    "a": "Edmund Cartwright",
    "w": [
      "Richard Arkwright",
      "George Stephenson",
      "Henry Bessemer"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which two resources were crucial to Britain's early heavy industry?",
    "a": "Coal and iron",
    "w": [
      "Gold and silver",
      "Cotton and silk",
      "Salt and timber"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "What did enclosure do in rural Britain?",
    "a": "Consolidated common fields into private farms",
    "w": [
      "Banned all new machinery",
      "Created free city housing",
      "Returned estates to monasteries"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "What does urbanization mean?",
    "a": "Growth of towns and cities",
    "w": [
      "Decline of overseas trade",
      "Spread of farming into forests",
      "A return to village life"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "What was the factory system?",
    "a": "Production organized in one workplace with machines",
    "w": [
      "Work done only in family homes",
      "A medieval guild ceremony",
      "Government ownership of every farm"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Why were early factory reform laws passed?",
    "a": "To limit dangerous labor conditions",
    "w": [
      "To abolish steam engines",
      "To restore feudal guilds",
      "To stop international trade"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Who were the Luddites?",
    "a": "Workers who attacked machinery they believed threatened their livelihoods",
    "w": [
      "Scientists who promoted electricity",
      "Owners of textile mills",
      "Railway investors"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which 1830 railway linked two major industrial cities in England?",
    "a": "The Liverpool and Manchester Railway",
    "w": [
      "The London Underground",
      "The Trans-Siberian Railway",
      "The Orient Express"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which engineer designed the Great Western Railway?",
    "a": "Isambard Kingdom Brunel",
    "w": [
      "George Stephenson",
      "Thomas Telford",
      "James Watt"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which process made steel cheaper to produce in large quantities?",
    "a": "The Bessemer process",
    "w": [
      "Pasteurization",
      "Vulcanization",
      "Electroplating"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which American inventor developed a practical telegraph system?",
    "a": "Samuel Morse",
    "w": [
      "Eli Whitney",
      "Cyrus McCormick",
      "Robert Fulton"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Whose experiments laid the foundation for the electric motor and generator?",
    "a": "Michael Faraday",
    "w": [
      "Alessandro Volta",
      "James Clerk Maxwell",
      "Guglielmo Marconi"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Who pioneered vaccination against smallpox?",
    "a": "Edward Jenner",
    "w": [
      "Louis Pasteur",
      "Robert Koch",
      "Joseph Lister"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "What medical advance allowed patients to undergo surgery without feeling pain?",
    "a": "Anesthesia",
    "w": [
      "The stethoscope",
      "Vaccination",
      "Blood typing"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which surgeon promoted antiseptic methods using carbolic acid?",
    "a": "Joseph Lister",
    "w": [
      "Edward Jenner",
      "John Snow",
      "Robert Koch"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Who traced a London cholera outbreak to a contaminated water pump?",
    "a": "John Snow",
    "w": [
      "Joseph Lister",
      "Louis Pasteur",
      "Robert Owen"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "During which war did Florence Nightingale reform military nursing?",
    "a": "The Crimean War",
    "w": [
      "The Boer War",
      "The Franco-Prussian War",
      "The American Civil War"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Why did workers form trade unions?",
    "a": "To bargain collectively for pay and conditions",
    "w": [
      "To restore absolute monarchy",
      "To run overseas colonies",
      "To replace factories with farms"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "What did Britain's Chartists demand?",
    "a": "Political reforms including broader male suffrage",
    "w": [
      "An end to all railways",
      "Restoration of Catholic monasteries",
      "Independence for India"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which British law expanded middle-class voting rights in 1832?",
    "a": "The Great Reform Act",
    "w": [
      "The Factory Act of 1847",
      "The Corn Law",
      "The Poor Law"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which Welsh industrialist and reformer became known for improving conditions at New Lanark?",
    "a": "Robert Owen",
    "w": [
      "Andrew Carnegie",
      "James Watt",
      "Jeremy Bentham"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "What was Karl Marx's major study of capitalism called?",
    "a": "Das Kapital",
    "w": [
      "The Social Contract",
      "The Wealth of Nations",
      "The Condition of the Working Class"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "Which Welsh industrialist promoted model communities and cooperative ideas?",
    "a": "Robert Owen",
    "w": [
      "Richard Arkwright",
      "David Ricardo",
      "Jeremy Bentham"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "In socialism, who should control major productive resources according to its basic theory?",
    "a": "Society or the public",
    "w": [
      "A hereditary nobility",
      "Foreign investors alone",
      "Medieval guild masters"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "What is a defining feature of capitalism?",
    "a": "Private ownership and market exchange",
    "w": [
      "Rule by military councils",
      "Farming without money",
      "A ban on private trade"
    ]
  },
  {
    "s": "Industry And Nineteenth-Century Society",
    "p": "What glass-and-iron building housed London's Great Exhibition of 1851?",
    "a": "The Crystal Palace",
    "w": [
      "The Royal Albert Hall",
      "The Houses of Parliament",
      "The British Museum"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which political idea sought to restore traditional monarchies after Napoleon?",
    "a": "Conservatism",
    "w": [
      "Nationalism",
      "Socialism",
      "Anarchism"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which country won independence from the Ottoman Empire after a revolt beginning in 1821?",
    "a": "Greece",
    "w": [
      "Belgium",
      "Norway",
      "Ireland"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which new kingdom broke away from the Netherlands in 1830?",
    "a": "Belgium",
    "w": [
      "Luxembourg",
      "Denmark",
      "Switzerland"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which revolution overthrew France's King Charles X in 1830?",
    "a": "The July Revolution",
    "w": [
      "The February Revolution",
      "The Paris Commune",
      "The Thermidorian Reaction"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "What form of government did France establish after the February Revolution of 1848?",
    "a": "The Second Republic",
    "w": [
      "The First Empire",
      "The Bourbon monarchy",
      "The Paris Commune"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Who became emperor of France as Napoleon III?",
    "a": "Louis-Napoleon Bonaparte",
    "w": [
      "Napoleon's son",
      "Louis XVIII",
      "Adolphe Thiers"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which war pitted Russia against the Ottoman Empire, Britain, France, and Sardinia?",
    "a": "The Crimean War",
    "w": [
      "The Russo-Japanese War",
      "The Balkan Wars",
      "The Seven Years' War"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which Russian tsar emancipated the serfs in 1861?",
    "a": "Alexander II",
    "w": [
      "Nicholas I",
      "Alexander III",
      "Nicholas II"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which 1825 revolt was led by Russian officers seeking political reform?",
    "a": "The Decembrist Revolt",
    "w": [
      "The Pugachev Rebellion",
      "The February Revolution",
      "The Kornilov Affair"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Who founded the Young Italy movement?",
    "a": "Giuseppe Mazzini",
    "w": [
      "Giuseppe Garibaldi",
      "Count Cavour",
      "Victor Emmanuel II"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which statesman led Piedmont-Sardinia during much of Italian unification?",
    "a": "Count Cavour",
    "w": [
      "Giuseppe Mazzini",
      "Giuseppe Garibaldi",
      "Pope Pius IX"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "What color shirts were associated with Garibaldi's volunteers?",
    "a": "Red",
    "w": [
      "Black",
      "Blue",
      "White"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Who became the first king of a united Italy in 1861?",
    "a": "Victor Emmanuel II",
    "w": [
      "Giuseppe Garibaldi",
      "Count Cavour",
      "Napoleon III"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which city became the capital of united Italy in 1870?",
    "a": "Rome",
    "w": [
      "Turin",
      "Florence",
      "Milan"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "What was the Zollverein?",
    "a": "A German customs union",
    "w": [
      "An Italian secret society",
      "A Russian parliament",
      "An Austrian military order"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which Prussian statesman led the unification of Germany?",
    "a": "Otto von Bismarck",
    "w": [
      "Helmuth von Moltke",
      "Kaiser Wilhelm II",
      "Friedrich Engels"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which phrase is associated with Bismarck's hard-headed unification policy?",
    "a": "Blood and iron",
    "w": [
      "Liberty, equality, fraternity",
      "Peace, land, and bread",
      "One man, one vote"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which 1864 war brought Prussia and Austria into conflict with Denmark?",
    "a": "The Second Schleswig War",
    "w": [
      "The Seven Weeks' War",
      "The Crimean War",
      "The Franco-Prussian War"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which 1866 conflict excluded Austria from German unification?",
    "a": "The Austro-Prussian War",
    "w": [
      "The Franco-Prussian War",
      "The Crimean War",
      "The War of 1812"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which war led directly to the proclamation of the German Empire?",
    "a": "The Franco-Prussian War",
    "w": [
      "The Crimean War",
      "The Austro-Prussian War",
      "The Balkan Wars"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Where was the German Empire proclaimed in 1871?",
    "a": "The Palace of Versailles",
    "w": [
      "The Reichstag in Berlin",
      "Frankfurt Cathedral",
      "The palace at Potsdam"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Who became the first German emperor in 1871?",
    "a": "Wilhelm I",
    "w": [
      "Wilhelm II",
      "Frederick III",
      "Otto von Bismarck"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "What radical government briefly ruled Paris in 1871?",
    "a": "The Paris Commune",
    "w": [
      "The Directory",
      "The National Convention",
      "The Jacobin Republic"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which republic was established in France after Napoleon III's defeat?",
    "a": "The Third Republic",
    "w": [
      "The Second Republic",
      "The Fourth Republic",
      "The First Republic"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which scandal divided France over the false treason conviction of a Jewish army officer?",
    "a": "The Dreyfus Affair",
    "w": [
      "The Panama Affair",
      "The Boulanger Crisis",
      "The Fashoda Incident"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "What political arrangement created Austria-Hungary in 1867?",
    "a": "The Compromise, or Ausgleich",
    "w": [
      "The Congress of Vienna",
      "The Treaty of Berlin",
      "The Pragmatic Sanction"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "What did the Eastern Question concern?",
    "a": "The decline of Ottoman power and its territories",
    "w": [
      "Control of the Atlantic slave trade",
      "German overseas colonies only",
      "Irish home rule"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which 1878 meeting revised the settlement after a Russo-Turkish war?",
    "a": "The Congress of Berlin",
    "w": [
      "The Congress of Vienna",
      "The Paris Peace Conference",
      "The Algeciras Conference"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which 1898 confrontation in Sudan nearly caused war between Britain and France?",
    "a": "The Fashoda Incident",
    "w": [
      "The Agadir Crisis",
      "The Jameson Raid",
      "The Boxer Rebellion"
    ]
  },
  {
    "s": "Nationalism And Nineteenth-Century Europe",
    "p": "Which war was fought between Britain and two Boer republics in southern Africa?",
    "a": "The Second Boer War",
    "w": [
      "The Crimean War",
      "The Zulu Civil War",
      "The Mahdist War"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Around what year did the Magyar conquest of the Carpathian Basin begin?",
    "a": "895",
    "w": [
      "1000",
      "1241",
      "1526"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Who was the leading prince associated with the Magyar conquest?",
    "a": "Árpád",
    "w": [
      "Stephen I",
      "Béla IV",
      "Matthias Corvinus"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Who was Árpád's father according to Hungarian tradition?",
    "a": "Álmos",
    "w": [
      "Géza",
      "Koppány",
      "Taksony"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "How many Magyar tribes formed the traditional tribal alliance?",
    "a": "Seven",
    "w": [
      "Five",
      "Nine",
      "Twelve"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "What earlier homeland did the Magyars occupy shortly before entering the Carpathian Basin?",
    "a": "Etelköz",
    "w": [
      "Pannonia",
      "Moravia",
      "Transylvania"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which mountain range surrounds much of the Carpathian Basin?",
    "a": "The Carpathians",
    "w": [
      "The Alps",
      "The Urals",
      "The Apennines"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which 955 battle ended the major Magyar raids into Western Europe?",
    "a": "The Battle of Lechfeld",
    "w": [
      "The Battle of Mohács",
      "The Battle of Muhi",
      "The Battle of Kosovo"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which Hungarian grand prince promoted conversion to Christianity before Stephen I?",
    "a": "Géza",
    "w": [
      "Árpád",
      "Andrew I",
      "Coloman"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Who became Hungary's first Christian king?",
    "a": "Stephen I",
    "w": [
      "Ladislaus I",
      "Géza",
      "Emeric"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Around which year was Stephen I crowned king?",
    "a": "1000",
    "w": [
      "955",
      "1095",
      "1222"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which rival did Stephen defeat while consolidating his rule?",
    "a": "Koppány",
    "w": [
      "Álmos",
      "Béla",
      "Hunyadi János"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "What local administrative units did Stephen I organize across Hungary?",
    "a": "Counties",
    "w": [
      "Satrapies",
      "Cantons",
      "Soviets"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which prince was the son and intended heir of Stephen I?",
    "a": "Emeric",
    "w": [
      "Ladislaus",
      "Coloman",
      "Andrew"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which Hungarian king was canonized and became an ideal of medieval kingship and chivalry?",
    "a": "Ladislaus I",
    "w": [
      "Andrew II",
      "Louis II",
      "Sigismund"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which king is traditionally called Coloman the Learned?",
    "a": "Coloman",
    "w": [
      "Béla III",
      "Andrew I",
      "Stephen II"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which charter did Andrew II issue in 1222?",
    "a": "The Golden Bull",
    "w": [
      "The Pragmatic Sanction",
      "The April Laws",
      "The Diploma Leopoldinum"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which invading force devastated Hungary in 1241–42?",
    "a": "The Mongols",
    "w": [
      "The Ottomans",
      "The Normans",
      "The Crusaders"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "At which battle did the Mongols defeat the Hungarian army in 1241?",
    "a": "Muhi",
    "w": [
      "Mohács",
      "Nándorfehérvár",
      "Pákozd"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which king rebuilt Hungary after the Mongol invasion?",
    "a": "Béla IV",
    "w": [
      "Andrew II",
      "Charles Robert",
      "Sigismund"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Why is Béla IV called Hungary's second founder?",
    "a": "He led reconstruction after the Mongol invasion",
    "w": [
      "He reconquered Buda from the Ottomans",
      "He created Austria-Hungary",
      "He ended the Golden Bull"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "What type of fortification did Béla IV encourage after the Mongol invasion?",
    "a": "Stone castles",
    "w": [
      "Wooden palisades only",
      "Coastal forts",
      "Underground bunkers"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "In which year did the male line of the Árpád dynasty end?",
    "a": "1301",
    "w": [
      "1241",
      "1458",
      "1526"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which Angevin king strengthened royal authority in fourteenth-century Hungary?",
    "a": "Charles Robert",
    "w": [
      "Louis II",
      "Matthias Corvinus",
      "Władysław III"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which valuable coin did Charles Robert introduce?",
    "a": "The gold florin",
    "w": [
      "The silver dollar",
      "The ducat of Venice only",
      "The paper forint"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which 1335 meeting brought the kings of Hungary, Poland, and Bohemia to Visegrád?",
    "a": "The Congress of Visegrád",
    "w": [
      "The Diet of Buda",
      "The Peace of Pressburg",
      "The Council of Constance"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which Hungarian king also became king of Poland in 1370?",
    "a": "Louis the Great",
    "w": [
      "Sigismund",
      "Charles Robert",
      "Matthias Corvinus"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which king of Hungary later became Holy Roman emperor and hosted the Council of Constance?",
    "a": "Sigismund of Luxembourg",
    "w": [
      "Louis the Great",
      "Albert the Magnanimous",
      "Ladislaus the Posthumous"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Who led the defense of Belgrade against the Ottomans in 1456?",
    "a": "John Hunyadi",
    "w": [
      "Matthias Corvinus",
      "George Dózsa",
      "Miklós Zrínyi"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "Which Hungarian king maintained the professional Black Army?",
    "a": "Matthias Corvinus",
    "w": [
      "Stephen I",
      "Béla IV",
      "Louis II"
    ]
  },
  {
    "s": "Hungary: Origins To The Late Middle Ages",
    "p": "What were the Corvinae?",
    "a": "Manuscripts from Matthias Corvinus's royal library",
    "w": [
      "Coins minted by Charles Robert",
      "Laws issued by Andrew II",
      "Fortresses on the Ottoman frontier"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which 1514 uprising was led by George Dózsa?",
    "a": "A peasant revolt",
    "w": [
      "A noble revolt against Matthias",
      "An Ottoman mutiny",
      "A miners' strike"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which Ottoman sultan defeated Hungary at Mohács in 1526?",
    "a": "Suleiman the Magnificent",
    "w": [
      "Mehmed II",
      "Selim III",
      "Murad IV"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which young Hungarian king died after the Battle of Mohács?",
    "a": "Louis II",
    "w": [
      "Matthias Corvinus",
      "John Szapolyai",
      "Ferdinand I"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which two men claimed the Hungarian crown after Mohács?",
    "a": "John Szapolyai and Ferdinand of Habsburg",
    "w": [
      "John Hunyadi and Matthias Corvinus",
      "Bocskai and Bethlen",
      "Rákóczi and Kossuth"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "In what year did the Ottomans capture Buda?",
    "a": "1541",
    "w": [
      "1526",
      "1552",
      "1686"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "After 1541, into how many main parts was the medieval Kingdom of Hungary divided?",
    "a": "Three",
    "w": [
      "Two",
      "Four",
      "Five"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which captain commanded Eger during its successful defense in 1552?",
    "a": "István Dobó",
    "w": [
      "Miklós Zrínyi",
      "John Hunyadi",
      "Stephen Bocskai"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "At which fortress did Miklós Zrínyi make a last stand in 1566?",
    "a": "Szigetvár",
    "w": [
      "Eger",
      "Buda",
      "Temesvár"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which prince led an anti-Habsburg uprising and settled the Hajdú soldiers?",
    "a": "Stephen Bocskai",
    "w": [
      "Gabriel Bethlen",
      "Francis II Rákóczi",
      "Imre Thököly"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which Transylvanian prince's reign is often called a golden age?",
    "a": "Gabriel Bethlen's",
    "w": [
      "Stephen Bocskai's",
      "George Dózsa's",
      "John Szapolyai's"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which alliance recaptured Buda from the Ottomans in 1686?",
    "a": "The Holy League",
    "w": [
      "The Triple Alliance",
      "The Holy Alliance",
      "The Schmalkaldic League"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which 1699 treaty ended most Ottoman rule in historic Hungary?",
    "a": "The Treaty of Karlowitz",
    "w": [
      "The Treaty of Passarowitz",
      "The Peace of Vasvár",
      "The Treaty of Trianon"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Who led the Hungarian uprising that began in 1703?",
    "a": "Francis II Rákóczi",
    "w": [
      "Louis Kossuth",
      "Stephen Bocskai",
      "Imre Nagy"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "What were Rákóczi's anti-Habsburg fighters commonly called?",
    "a": "Kuruc",
    "w": [
      "Labanc",
      "Janissaries",
      "Honvéd only"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which 1711 peace ended Rákóczi's War of Independence?",
    "a": "The Treaty of Szatmár",
    "w": [
      "The Treaty of Karlowitz",
      "The Peace of Vasvár",
      "The Treaty of Pressburg"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which Habsburg ruler appealed to the Hungarian Diet for support in 1741?",
    "a": "Maria Theresa",
    "w": [
      "Joseph II",
      "Leopold II",
      "Francis I"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which Habsburg ruler was nicknamed the ‘king in a hat’ in Hungary because he was not crowned there?",
    "a": "Joseph II",
    "w": [
      "Charles VI",
      "Leopold I",
      "Francis Joseph"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which language did Joseph II try to make the main language of administration?",
    "a": "German",
    "w": [
      "Latin",
      "Hungarian",
      "French"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which 1825 event is commonly taken as the beginning of Hungary's Reform Era?",
    "a": "The opening of the reform Diet",
    "w": [
      "The opening of the Chain Bridge",
      "The founding of Budapest",
      "The coronation of Francis Joseph"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Who offered a year's income to help found the Hungarian Academy of Sciences?",
    "a": "István Széchenyi",
    "w": [
      "Louis Kossuth",
      "Ferenc Deák",
      "Sándor Petőfi"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which newspaper was edited by Louis Kossuth in the 1840s?",
    "a": "Pesti Hírlap",
    "w": [
      "Népszava",
      "Magyar Nemzet",
      "Az Est"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "What did Hungary's April Laws of 1848 help abolish?",
    "a": "Feudal privileges and serfdom",
    "w": [
      "The Hungarian language",
      "All private property",
      "The county system"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Who headed Hungary's first responsible government in 1848?",
    "a": "Lajos Batthyány",
    "w": [
      "Louis Kossuth",
      "Ferenc Deák",
      "Artúr Görgei"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "At which battle did Hungarian forces stop Josip Jelačić in September 1848?",
    "a": "Pákozd",
    "w": [
      "Világos",
      "Isaszeg",
      "Temesvár"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which empire intervened militarily against Hungary in 1849?",
    "a": "The Russian Empire",
    "w": [
      "The Ottoman Empire",
      "The French Empire",
      "The British Empire"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Where did the main Hungarian army surrender in August 1849?",
    "a": "Világos",
    "w": [
      "Arad",
      "Pákozd",
      "Debrecen"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "What name is given to the centralized Austrian rule in Hungary during much of the 1850s?",
    "a": "The Bach system",
    "w": [
      "The Dual System",
      "The Kuruc era",
      "The Regency"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "What did the Compromise of 1867 create?",
    "a": "The Dual Monarchy of Austria-Hungary",
    "w": [
      "An independent Hungarian republic",
      "The Kingdom of Yugoslavia",
      "The Warsaw Pact"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "Which three cities united to form Budapest in 1873?",
    "a": "Buda, Pest, and Óbuda",
    "w": [
      "Buda, Vác, and Pest",
      "Pest, Csepel, and Gödöllő",
      "Óbuda, Esztergom, and Visegrád"
    ]
  },
  {
    "s": "Hungary: Ottoman Era To 1914",
    "p": "What anniversary did Hungary's Millennium celebrations mark in 1896?",
    "a": "One thousand years since the Magyar conquest",
    "w": [
      "Nine hundred years since Stephen's coronation",
      "Fifty years since the 1848 revolution",
      "Two hundred years since Buda's recapture"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "On which side did Austria-Hungary fight in World War I?",
    "a": "The Central Powers",
    "w": [
      "The Triple Entente",
      "The Allies of World War II",
      "The Non-Aligned Movement"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Which Hungarian prime minister was assassinated during the Aster Revolution?",
    "a": "István Tisza",
    "w": [
      "Mihály Károlyi",
      "István Bethlen",
      "Pál Teleki"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Who became the leading figure of Hungary after the Aster Revolution of 1918?",
    "a": "Mihály Károlyi",
    "w": [
      "Béla Kun",
      "Miklós Horthy",
      "Mátyás Rákosi"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "What short-lived state was proclaimed in Hungary in March 1919?",
    "a": "The Hungarian Soviet Republic",
    "w": [
      "The Kingdom of Hungary",
      "The Second Hungarian Republic",
      "The Austro-Hungarian Empire"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Who was the principal leader of the Hungarian Soviet Republic?",
    "a": "Béla Kun",
    "w": [
      "Mihály Károlyi",
      "Miklós Horthy",
      "Imre Nagy"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "What title did Miklós Horthy hold from 1920 to 1944?",
    "a": "Regent",
    "w": [
      "King",
      "President",
      "Party secretary"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "On what date was the Treaty of Trianon signed?",
    "a": "June 4, 1920",
    "w": [
      "November 11, 1918",
      "March 21, 1919",
      "August 20, 1920"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "In which palace complex was the Treaty of Trianon signed?",
    "a": "The Grand Trianon at Versailles",
    "w": [
      "Schönbrunn Palace",
      "Buda Castle",
      "The Hofburg"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "About what share of its prewar territory did historic Hungary lose at Trianon?",
    "a": "About two-thirds",
    "w": [
      "About one-quarter",
      "About one-half",
      "About one-tenth"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Which prime minister is associated with political and economic consolidation in Hungary during the 1920s?",
    "a": "István Bethlen",
    "w": [
      "Pál Teleki",
      "Gyula Gömbös",
      "László Bárdossy"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Which currency replaced the Hungarian korona in 1927?",
    "a": "The pengő",
    "w": [
      "The forint",
      "The crown",
      "The dinar"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Which pact did Hungary join in November 1940?",
    "a": "The Tripartite Pact",
    "w": [
      "The Warsaw Pact",
      "The North Atlantic Treaty",
      "The Little Entente"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "What territory did the First Vienna Award return to Hungary in 1938?",
    "a": "Parts of southern Slovakia",
    "w": [
      "Transylvania in full",
      "Burgenland",
      "Croatia"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "What major territory did the Second Vienna Award assign to Hungary in 1940?",
    "a": "Northern Transylvania",
    "w": [
      "Vojvodina",
      "Carpathian Ruthenia",
      "Burgenland"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "After the bombing of which city did Hungary declare war on the Soviet Union in 1941?",
    "a": "Kassa",
    "w": [
      "Budapest",
      "Debrecen",
      "Szeged"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Where did Hungary's Second Army suffer catastrophic losses in 1943?",
    "a": "At the Don River",
    "w": [
      "At Stalingrad city center",
      "At El Alamein",
      "At Normandy"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "What was the code name for Germany's occupation of Hungary in 1944?",
    "a": "Operation Margarethe",
    "w": [
      "Operation Barbarossa",
      "Operation Panzerfaust",
      "Operation Overlord"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "On what date did German forces occupy Hungary in 1944?",
    "a": "March 19",
    "w": [
      "June 6",
      "October 15",
      "December 7"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Which fascist movement seized power in Hungary in October 1944?",
    "a": "The Arrow Cross Party",
    "w": [
      "The Smallholders' Party",
      "The Social Democratic Party",
      "The Hungarian Independence Party"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Who led the Arrow Cross government?",
    "a": "Ferenc Szálasi",
    "w": [
      "Miklós Horthy",
      "László Bárdossy",
      "Béla Imrédy"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Which neutral country's protective passports did Raoul Wallenberg issue in Budapest?",
    "a": "Sweden's",
    "w": [
      "Switzerland's",
      "Spain's",
      "Portugal's"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "During which winter did the siege of Budapest take place?",
    "a": "1944–45",
    "w": [
      "1941–42",
      "1939–40",
      "1947–48"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "What form of state was proclaimed in Hungary on February 1, 1946?",
    "a": "A republic",
    "w": [
      "A restored monarchy",
      "A Soviet republic",
      "A dual monarchy"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Which currency was introduced in Hungary in August 1946?",
    "a": "The forint",
    "w": [
      "The pengő",
      "The euro",
      "The korona"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Which communist leader used ‘salami tactics’ to eliminate political rivals?",
    "a": "Mátyás Rákosi",
    "w": [
      "János Kádár",
      "Imre Nagy",
      "Béla Kun"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "What was the name of communist Hungary's feared state security organization?",
    "a": "The ÁVH",
    "w": [
      "The Honvéd",
      "The MÁV",
      "The MDF"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Who served as prime minister during the Hungarian Revolution of 1956?",
    "a": "Imre Nagy",
    "w": [
      "János Kádár",
      "Mátyás Rákosi",
      "Pál Maléter"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "On what date did the main Soviet assault crush the 1956 Hungarian Revolution?",
    "a": "November 4, 1956",
    "w": [
      "October 23, 1956",
      "June 16, 1958",
      "May 1, 1957"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "Which 1968 reform introduced limited market mechanisms into Hungary's planned economy?",
    "a": "The New Economic Mechanism",
    "w": [
      "The first Five-Year Plan",
      "The Bokros package",
      "The Marshall Plan"
    ]
  },
  {
    "s": "Hungary From World War I To 1990",
    "p": "What happened in Hungary on October 23, 1989?",
    "a": "The Third Hungarian Republic was proclaimed",
    "w": [
      "Hungary joined the Warsaw Pact",
      "Imre Nagy was executed",
      "The first Five-Year Plan began"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which countries formed the core of the Triple Entente?",
    "a": "Britain, France, and Russia",
    "w": [
      "Germany, Austria-Hungary, and Italy",
      "France, Italy, and the Ottoman Empire",
      "Britain, Germany, and Russia"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which countries formed the Triple Alliance before World War I?",
    "a": "Germany, Austria-Hungary, and Italy",
    "w": [
      "Britain, France, and Russia",
      "Germany, Bulgaria, and the Ottoman Empire",
      "France, Russia, and Serbia"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Who assassinated Archduke Franz Ferdinand?",
    "a": "Gavrilo Princip",
    "w": [
      "Leon Czolgosz",
      "Lee Harvey Oswald",
      "Nedeljko Čabrinović alone"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "In which city was Archduke Franz Ferdinand assassinated?",
    "a": "Sarajevo",
    "w": [
      "Belgrade",
      "Vienna",
      "Zagreb"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "What was Germany's ‘blank cheque’ in July 1914?",
    "a": "A promise of strong support to Austria-Hungary",
    "w": [
      "A plan to pay British war debts",
      "An offer of peace to Russia",
      "A colonial agreement with France"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "What was the Schlieffen Plan designed to avoid?",
    "a": "A prolonged two-front war",
    "w": [
      "Naval war with Britain",
      "Fighting in Belgium",
      "Mobilizing the German army"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which 1914 battle stopped Germany's advance toward Paris?",
    "a": "The First Battle of the Marne",
    "w": [
      "The Battle of Verdun",
      "The Battle of the Somme",
      "The Battle of Jutland"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which type of warfare dominated the Western Front?",
    "a": "Trench warfare",
    "w": [
      "Jungle warfare",
      "Naval warfare only",
      "Guerrilla warfare"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "At which 1914 battle did Germany defeat a Russian army in East Prussia?",
    "a": "Tannenberg",
    "w": [
      "Gallipoli",
      "Caporetto",
      "Passchendaele"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which 1916 battle became a symbol of French endurance?",
    "a": "Verdun",
    "w": [
      "The Somme",
      "Ypres",
      "Tannenberg"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which 1916 offensive caused enormous British, French, and German casualties along a river in France?",
    "a": "The Somme",
    "w": [
      "Verdun",
      "Gallipoli",
      "Jutland"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Near which Belgian city was poison gas first used on a large scale in World War I?",
    "a": "Ypres",
    "w": [
      "Bruges",
      "Antwerp",
      "Liège"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "What were German U-boats?",
    "a": "Submarines",
    "w": [
      "Armored trains",
      "Fighter aircraft",
      "Heavy artillery"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which passenger liner was sunk by a German U-boat in 1915?",
    "a": "Lusitania",
    "w": [
      "Britannic",
      "Mauretania",
      "Olympic"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "What did the Zimmermann Telegram propose?",
    "a": "A German-Mexican alliance against the United States",
    "w": [
      "Peace between Germany and Russia",
      "A British alliance with Japan",
      "American entry into the League of Nations"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "In which year did the United States enter World War I?",
    "a": "1917",
    "w": [
      "1914",
      "1916",
      "1918"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which treaty took Russia out of World War I?",
    "a": "The Treaty of Brest-Litovsk",
    "w": [
      "The Treaty of Riga",
      "The Treaty of Versailles",
      "The Treaty of Rapallo"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Where was the November 1918 armistice signed?",
    "a": "In a railway carriage near Compiègne",
    "w": [
      "At Versailles Palace",
      "In the Reichstag",
      "At Buckingham Palace"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Who proposed the Fourteen Points?",
    "a": "Woodrow Wilson",
    "w": [
      "David Lloyd George",
      "Georges Clemenceau",
      "Vittorio Orlando"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which international organization was created after World War I to preserve peace?",
    "a": "The League of Nations",
    "w": [
      "The United Nations",
      "NATO",
      "The European Union"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "What heavy obligation did the Versailles treaty impose on Germany?",
    "a": "Reparations",
    "w": [
      "Membership in NATO",
      "Control of Austria",
      "A permanent seat in the League"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "What was Germany's democratic government from 1919 to 1933 commonly called?",
    "a": "The Weimar Republic",
    "w": [
      "The German Confederation",
      "The Second Reich",
      "The Federal Republic"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "What happened to German money during the hyperinflation of 1923?",
    "a": "It lost value extremely rapidly",
    "w": [
      "It became tied to gold",
      "It replaced the dollar",
      "It was abolished permanently"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which plan reorganized German reparations payments in 1924?",
    "a": "The Dawes Plan",
    "w": [
      "The Marshall Plan",
      "The Young Turk Plan",
      "The Schlieffen Plan"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which 1925 agreements improved relations between Germany and its western neighbors?",
    "a": "The Locarno Treaties",
    "w": [
      "The Lateran Treaties",
      "The Rapallo Treaties",
      "The Munich Agreement"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which 1928 pact renounced war as an instrument of national policy?",
    "a": "The Kellogg-Briand Pact",
    "w": [
      "The Molotov-Ribbentrop Pact",
      "The Anti-Comintern Pact",
      "The Warsaw Pact"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which 1925 agreements aimed to improve relations between Germany, France, and Belgium?",
    "a": "The Locarno Treaties",
    "w": [
      "The Geneva Accords",
      "The Dawes Plan",
      "The Kellogg-Briand Pact"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Who led the Fascist March on Rome in 1922?",
    "a": "Benito Mussolini",
    "w": [
      "Victor Emmanuel III",
      "Gabriele D'Annunzio",
      "Pietro Badoglio"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "What symbol was used by Italian Fascism and gave the movement its name?",
    "a": "The fasces",
    "w": [
      "The hammer and sickle",
      "The tricolor cockade",
      "The Roman eagle only"
    ]
  },
  {
    "s": "World War I And The Interwar Years",
    "p": "Which failed 1923 coup first brought Adolf Hitler national attention?",
    "a": "The Beer Hall Putsch",
    "w": [
      "The Kapp Putsch",
      "The July Plot",
      "The Spartacist Uprising"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which region of Czechoslovakia did Germany gain through the Munich Agreement?",
    "a": "The Sudetenland",
    "w": [
      "Bohemia in full",
      "Slovakia",
      "Carpathian Ruthenia"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What secret provision accompanied the 1939 German-Soviet nonaggression pact?",
    "a": "A division of spheres in Eastern Europe",
    "w": [
      "A joint invasion of Britain",
      "Soviet membership in the Axis",
      "German withdrawal from Austria"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "On what date did Germany invade Poland?",
    "a": "September 1, 1939",
    "w": [
      "August 23, 1939",
      "June 22, 1941",
      "May 10, 1940"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What does blitzkrieg mean?",
    "a": "Lightning war",
    "w": [
      "Total war",
      "Submarine war",
      "Winter war"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What name was given to the quiet period on the Western Front in late 1939?",
    "a": "The Phoney War",
    "w": [
      "The Sitzkrieg of 1944",
      "The Great Silence",
      "The Winter Truce"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which country fell to Germany after a six-week campaign in 1940?",
    "a": "France",
    "w": [
      "Britain",
      "Sweden",
      "Spain"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What was Vichy France?",
    "a": "An authoritarian French regime that collaborated with Germany",
    "w": [
      "The French government-in-exile in London",
      "A resistance army",
      "A neutral Swiss canton"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which British service fought the Luftwaffe in the Battle of Britain?",
    "a": "The Royal Air Force",
    "w": [
      "The Royal Navy",
      "The British Expeditionary Force",
      "The Home Guard alone"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What was Operation Barbarossa?",
    "a": "Germany's invasion of the Soviet Union",
    "w": [
      "The Allied invasion of Italy",
      "Japan's attack on Pearl Harbor",
      "The German occupation of Denmark"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which Soviet city endured a siege lasting about 872 days?",
    "a": "Leningrad",
    "w": [
      "Moscow",
      "Kyiv",
      "Minsk"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which battle ended with the surrender of Germany's Sixth Army in February 1943?",
    "a": "Stalingrad",
    "w": [
      "Kursk",
      "Moscow",
      "Smolensk"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which British victory in Egypt helped turn the North African campaign?",
    "a": "El Alamein",
    "w": [
      "Tobruk",
      "Kasserine Pass",
      "Monte Cassino"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which 1942 naval battle was a turning point in the Pacific War?",
    "a": "Midway",
    "w": [
      "Coral Sea",
      "Leyte Gulf",
      "Guadalcanal"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What was the Allied strategy of capturing selected Pacific islands called?",
    "a": "Island hopping",
    "w": [
      "Leapfrogging Europe",
      "Scorched earth",
      "Convoy raiding"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What was the code name for the Allied invasion of Normandy?",
    "a": "Operation Overlord",
    "w": [
      "Operation Torch",
      "Operation Market Garden",
      "Operation Husky"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Who was supreme commander of the Allied forces for the Normandy invasion?",
    "a": "Dwight D. Eisenhower",
    "w": [
      "Bernard Montgomery",
      "George C. Marshall",
      "George S. Patton"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which 1944 Soviet offensive destroyed much of German Army Group Centre?",
    "a": "Operation Bagration",
    "w": [
      "Operation Uranus",
      "Operation Citadel",
      "Operation Typhoon"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which underground force began an uprising against German occupation in Warsaw in August 1944?",
    "a": "The Polish Home Army",
    "w": [
      "The Red Army",
      "The French Resistance",
      "The Czech Legion"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which February 1945 conference brought Roosevelt, Churchill, and Stalin together?",
    "a": "The Yalta Conference",
    "w": [
      "The Potsdam Conference",
      "The Tehran Conference",
      "The Casablanca Conference"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What did V-E Day mark?",
    "a": "Germany's defeat in Europe",
    "w": [
      "Japan's surrender",
      "The Normandy landings",
      "The founding of the United Nations"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "On what date did Japan formally surrender aboard the USS Missouri?",
    "a": "September 2, 1945",
    "w": [
      "August 6, 1945",
      "August 15, 1945",
      "May 8, 1945"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What did Nazi leaders coordinate at the Wannsee Conference?",
    "a": "The systematic deportation and murder of Europe's Jews",
    "w": [
      "The invasion of the Soviet Union",
      "The bombing of Britain",
      "The occupation of France"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What were ghettos under Nazi occupation?",
    "a": "Confined urban districts where Jews were forced to live",
    "w": [
      "German military bases",
      "Neutral refugee camps",
      "Factories owned by resistance groups"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "In which occupied country was the Auschwitz-Birkenau complex located?",
    "a": "Poland",
    "w": [
      "Germany",
      "Austria",
      "Hungary"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What were the Einsatzgruppen?",
    "a": "Mobile Nazi killing units",
    "w": [
      "German submarine crews",
      "Allied codebreakers",
      "Italian partisan groups"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which 1943 revolt was the largest Jewish uprising against the Nazis?",
    "a": "The Warsaw Ghetto Uprising",
    "w": [
      "The Warsaw Uprising",
      "The Sobibor revolt",
      "The Białystok strike"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Who organized a rescue network that saved many Jewish children from the Warsaw Ghetto?",
    "a": "Irena Sendler",
    "w": [
      "Sophie Scholl",
      "Hannah Szenes",
      "Leni Riefenstahl"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "What were the Nuremberg Trials?",
    "a": "Trials of leading Nazi officials for international crimes",
    "w": [
      "Trials of German resistance members",
      "Hearings on the Versailles treaty",
      "Soviet trials of Polish officers"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Which term describes deliberate destruction of a national, ethnic, racial, or religious group?",
    "a": "Genocide",
    "w": [
      "Armistice",
      "Appeasement",
      "Internment"
    ]
  },
  {
    "s": "World War II And The Holocaust",
    "p": "Who coined the word genocide?",
    "a": "Raphael Lemkin",
    "w": [
      "Elie Wiesel",
      "Primo Levi",
      "Simon Wiesenthal"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which U.S. policy promised support to countries resisting communist pressure?",
    "a": "The Truman Doctrine",
    "w": [
      "The Monroe Doctrine",
      "The Brezhnev Doctrine",
      "The Hallstein Doctrine"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which two countries were the first main focus of the Truman Doctrine?",
    "a": "Greece and Turkey",
    "w": [
      "France and Italy",
      "Poland and Hungary",
      "Japan and Korea"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What was Cominform?",
    "a": "An organization coordinating European communist parties",
    "w": [
      "A Western defense alliance",
      "A United Nations aid agency",
      "A Soviet space program"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What was Comecon?",
    "a": "A Soviet-led economic organization",
    "w": [
      "A NATO command",
      "A human-rights court",
      "A trade union in Poland"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "In what year was the Warsaw Pact formed?",
    "a": "1955",
    "w": [
      "1945",
      "1949",
      "1961"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What action by the Soviet Union triggered the Berlin Airlift?",
    "a": "A blockade of land routes to West Berlin",
    "w": [
      "Construction of the Berlin Wall",
      "An invasion of West Germany",
      "Closure of East Berlin airports only"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What was West Germany's official name?",
    "a": "The Federal Republic of Germany",
    "w": [
      "The German Democratic Republic",
      "The German Confederation",
      "The Weimar Republic"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What was East Germany's official name?",
    "a": "The German Democratic Republic",
    "w": [
      "The Federal Republic of Germany",
      "The People's Republic of Prussia",
      "The German Soviet Republic"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Who was West Germany's first chancellor?",
    "a": "Konrad Adenauer",
    "w": [
      "Willy Brandt",
      "Helmut Kohl",
      "Ludwig Erhard"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "In which year was the Berlin Wall built?",
    "a": "1961",
    "w": [
      "1948",
      "1953",
      "1968"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which Soviet leader denounced some of Stalin's crimes in a 1956 secret speech?",
    "a": "Nikita Khrushchev",
    "w": [
      "Leonid Brezhnev",
      "Mikhail Gorbachev",
      "Georgy Malenkov"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which leader returned to power during the Polish October of 1956?",
    "a": "Władysław Gomułka",
    "w": [
      "Edward Gierek",
      "Bolesław Bierut",
      "Lech Wałęsa"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which Central European capital saw a major anti-Soviet revolution in October 1956?",
    "a": "Budapest",
    "w": [
      "Prague",
      "Warsaw",
      "Sofia"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Who led the Prague Spring reforms of 1968?",
    "a": "Alexander Dubček",
    "w": [
      "Václav Havel",
      "Gustáv Husák",
      "János Kádár"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What phrase described Dubček's reform program?",
    "a": "Socialism with a human face",
    "w": [
      "Peaceful coexistence",
      "Goulash communism",
      "New political thinking"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What did the Brezhnev Doctrine claim?",
    "a": "The Soviet bloc could intervene to preserve communist rule",
    "w": [
      "Each Warsaw Pact state could leave freely",
      "The Soviet Union would end military alliances",
      "West Germany could reunify Berlin"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "At which workplace was Poland's Solidarity movement founded?",
    "a": "The Gdańsk Shipyard",
    "w": [
      "The Nowa Huta steelworks",
      "The Warsaw University",
      "The Łódź textile mills"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Who became the best-known leader of Solidarity?",
    "a": "Lech Wałęsa",
    "w": [
      "Wojciech Jaruzelski",
      "Tadeusz Mazowiecki",
      "Karol Wojtyła"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Who imposed martial law in Poland in 1981?",
    "a": "Wojciech Jaruzelski",
    "w": [
      "Lech Wałęsa",
      "Edward Gierek",
      "Władysław Gomułka"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which 1975 agreement linked European security with human-rights commitments?",
    "a": "The Helsinki Final Act",
    "w": [
      "The Treaty of Rome",
      "The Camp David Accords",
      "The SALT I Treaty"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What did détente mean during the Cold War?",
    "a": "An easing of tensions",
    "w": [
      "A nuclear first strike",
      "A communist economic plan",
      "The division of Germany"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What did the SALT talks seek to limit?",
    "a": "Strategic nuclear weapons",
    "w": [
      "Conventional tanks in Africa",
      "International trade",
      "Space exploration"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which country did the Soviet Union invade in 1979?",
    "a": "Afghanistan",
    "w": [
      "Iran",
      "Pakistan",
      "Romania"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which 1986 disaster exposed weaknesses in the Soviet system?",
    "a": "The Chernobyl nuclear accident",
    "w": [
      "The Aral Sea earthquake",
      "The Kursk submarine sinking",
      "The Hungarian red-mud spill"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What did glasnost mean under Gorbachev?",
    "a": "Greater openness",
    "w": [
      "Rapid privatization",
      "Military expansion",
      "Agricultural collectivization"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What did perestroika mean under Gorbachev?",
    "a": "Restructuring",
    "w": [
      "Censorship",
      "Collectivization",
      "Isolation"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which negotiations led to partly free elections in Poland in 1989?",
    "a": "The Round Table Talks",
    "w": [
      "The Helsinki Talks",
      "The Potsdam Talks",
      "The Camp David Talks"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which playwright became president after Czechoslovakia's Velvet Revolution?",
    "a": "Václav Havel",
    "w": [
      "Alexander Dubček",
      "Milan Kundera",
      "Gustáv Husák"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "Which Romanian dictator was overthrown and executed in December 1989?",
    "a": "Nicolae Ceaușescu",
    "w": [
      "Josip Broz Tito",
      "Todor Zhivkov",
      "Enver Hoxha"
    ]
  },
  {
    "s": "The Cold War And Eastern Europe",
    "p": "What happened to the Soviet Union in December 1991?",
    "a": "It dissolved into independent states",
    "w": [
      "It joined NATO",
      "It reunited with Eastern Europe",
      "It restored the monarchy"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "In which year did British India become independent?",
    "a": "1947",
    "w": [
      "1945",
      "1950",
      "1960"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which two states were created by the 1947 partition of British India?",
    "a": "India and Pakistan",
    "w": [
      "India and Bangladesh",
      "Pakistan and Afghanistan",
      "India and Sri Lanka"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Who became independent India's first prime minister?",
    "a": "Jawaharlal Nehru",
    "w": [
      "Mahatma Gandhi",
      "Muhammad Ali Jinnah",
      "Indira Gandhi"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Who became Pakistan's founding governor-general?",
    "a": "Muhammad Ali Jinnah",
    "w": [
      "Jawaharlal Nehru",
      "Liaquat Ali Khan",
      "Ayub Khan"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which 1930 protest challenged Britain's tax and monopoly on salt in India?",
    "a": "The Salt March",
    "w": [
      "The Quit India March",
      "The Amritsar March",
      "The Bengal Partition"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Who became Indonesia's first president after independence?",
    "a": "Sukarno",
    "w": [
      "Suharto",
      "Ho Chi Minh",
      "Norodom Sihanouk"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which 1954 battle ended major French colonial rule in Indochina?",
    "a": "Dien Bien Phu",
    "w": [
      "Khe Sanh",
      "Tet",
      "Saigon"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which agreements temporarily divided Vietnam near the 17th parallel?",
    "a": "The Geneva Accords",
    "w": [
      "The Paris Peace Accords",
      "The Bandung Declaration",
      "The Camp David Accords"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which movement led the Algerian war for independence from France?",
    "a": "The FLN",
    "w": [
      "The ANC",
      "The Viet Minh",
      "The Mau Mau"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Who led Ghana to independence in 1957?",
    "a": "Kwame Nkrumah",
    "w": [
      "Jomo Kenyatta",
      "Patrice Lumumba",
      "Julius Nyerere"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which anticolonial uprising took place in Kenya during the 1950s?",
    "a": "The Mau Mau uprising",
    "w": [
      "The Maji Maji revolt",
      "The Boxer Rebellion",
      "The Easter Rising"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which African country gained independence from Belgium in 1960 amid severe crisis?",
    "a": "The Congo",
    "w": [
      "Ghana",
      "Kenya",
      "Algeria"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Who was the Congo's first prime minister after independence?",
    "a": "Patrice Lumumba",
    "w": [
      "Mobutu Sese Seko",
      "Joseph Kasa-Vubu",
      "Moise Tshombe"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which Egyptian leader nationalized the Suez Canal in 1956?",
    "a": "Gamal Abdel Nasser",
    "w": [
      "Anwar Sadat",
      "King Farouk",
      "Hosni Mubarak"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which three countries attacked Egypt during the Suez Crisis?",
    "a": "Britain, France, and Israel",
    "w": [
      "The United States, Britain, and France",
      "Israel, Jordan, and Syria",
      "The Soviet Union, France, and Israel"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which Ghanaian independence leader became a major advocate of Pan-Africanism?",
    "a": "Kwame Nkrumah",
    "w": [
      "Jomo Kenyatta",
      "Julius Nyerere",
      "Léopold Sédar Senghor"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which leaders were closely associated with founding the Non-Aligned Movement?",
    "a": "Tito, Nehru, and Nasser",
    "w": [
      "Churchill, Truman, and Stalin",
      "Mao, Castro, and Ho Chi Minh",
      "Adenauer, de Gaulle, and Brandt"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "What system of racial segregation became official policy in South Africa in 1948?",
    "a": "Apartheid",
    "w": [
      "Jim Crow",
      "Assimilation",
      "Separate development only outside cities"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which 1960 massacre of protesters shocked the world in South Africa?",
    "a": "Sharpeville",
    "w": [
      "Soweto",
      "Marikana",
      "Boipatong"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "What do the initials ANC stand for in South African history?",
    "a": "African National Congress",
    "w": [
      "African Nations Council",
      "Alliance for National Cooperation",
      "African Neutrality Committee"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "On which island was Nelson Mandela imprisoned for most of his long sentence?",
    "a": "Robben Island",
    "w": [
      "Saint Helena",
      "Zanzibar",
      "Gorée Island"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "What sparked the Soweto uprising of 1976?",
    "a": "A policy enforcing Afrikaans in schools",
    "w": [
      "A ban on gold mining",
      "An increase in railway fares",
      "A border war with Angola"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "In which year did South Africa hold its first fully democratic national election?",
    "a": "1994",
    "w": [
      "1990",
      "1989",
      "1999"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Who proclaimed the People's Republic of China in 1949?",
    "a": "Mao Zedong",
    "w": [
      "Chiang Kai-shek",
      "Deng Xiaoping",
      "Zhou Enlai"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "What was the Great Leap Forward?",
    "a": "Mao's campaign for rapid industrial and agricultural transformation",
    "w": [
      "China's first space mission",
      "The Nationalist retreat to Taiwan",
      "The opening of China to foreign investment"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "What movement attacked traditional culture and alleged political enemies in China after 1966?",
    "a": "The Cultural Revolution",
    "w": [
      "The May Fourth Movement",
      "The Boxer Rebellion",
      "The Hundred Days' Reform"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which Chinese leader launched market-oriented reforms after Mao's death?",
    "a": "Deng Xiaoping",
    "w": [
      "Zhou Enlai",
      "Liu Shaoqi",
      "Sun Yat-sen"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which 1953 agreement stopped the fighting in the Korean War?",
    "a": "The Korean Armistice Agreement",
    "w": [
      "The Treaty of Seoul",
      "The Geneva Accords",
      "The San Francisco Treaty"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which city fell in April 1975, marking the end of the Vietnam War?",
    "a": "Saigon",
    "w": [
      "Hanoi",
      "Hue",
      "Dien Bien Phu"
    ]
  },
  {
    "s": "Decolonization And The Postwar World",
    "p": "Which 1948 United Nations document set out fundamental rights for all people?",
    "a": "The Universal Declaration of Human Rights",
    "w": [
      "The United Nations Charter",
      "The Geneva Convention",
      "The Atlantic Charter"
    ]
  }
]
$questions$::jsonb) with ordinality as question(item, ordinality);

do $verify$
begin
  if (
    select count(*)
    from public.quiz_questions
    where id between 'hist_0431' and 'hist_1030'
      and category_id = 'history'
      and language_code = 'en'
      and is_active
  ) <> 600 then
    raise exception 'History expansion verification failed: expected 600 active questions';
  end if;
end
$verify$;

commit;
