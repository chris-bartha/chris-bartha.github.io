# Hungarian, generational and immigrant categories

Produced 2026-09-16.

**Status key:** ✅ built in this session · 🔍 decide later · ⬜ not started

---

## The structural fact

She cleared the entire 430-question Hungarian bank in a single Unlimited run —
and has gone perfect 430/430 **ten times** (six Hungarian, four History). Her
average Hungarian run is **155.7 questions** against 9.9 in Tricky True or False.

**Any new Hungarian category under ~500 questions is a one-evening category.**
One 700-question bank beats two 350-question banks. Use the internal `subject`
column for topic balance, the way `textbook_history` already does.

Both existing Hungarian categories are history-only. **Everything Hungarian that
is not history was open ground** — which is what this session's build addresses.

---

## ✅ Built in this session

| Category | Scope |
|---|---|
| 🗺️ **Magyarország földrajza** | Counties, rivers, mountains, towns, national parks, Budapest |
| 🌍 **Földrajz magyarul** | World geography in Hungarian, Europe weighted heaviest |
| 📚 **Magyar irodalom** | The school canon — plus *Híres sorok* line-completion merged in as its own subject block |
| 🔬 **Természet és tudomány magyarul** | Animals, plants, the body, space, weather, physics, chemistry, Hungarian scientists |
| 🦊 **Népmesék és közmondások** | Proverb completion, idiom meanings, folk tales, riddles |
| 🥘 **Magyar konyha** | Dishes, spices, pastries, holiday food, regional origins, a small wine block |
| 🎸 **Magyar zene 1970–1989** | Omega, LGT, Illés, Koncz Zsuzsa, rock operas, Táncdalfesztivál, plus classical |
| 📺 **Ahogy régen volt** | Daily life 1974–94 — Trabant, Közért, úttörő, Tévémaci, Balaton, holidays |

Also merged: **Történelem magyarul** and **Tankönyvi történelem** into one Hungarian
history category, at your request.

*Why 1974–1994 specifically:* the "reminiscence bump" puts peak autobiographical
recall at ages 10–30. Born ~1964, that is exactly her window. It's a computable
content target, not a vibe.

---

## ⬜ Not built — still on the table

### 💡 Magyar feltalálók és Nobel-díjasok
180–250 honest questions — too small to stand alone. **Folded into Természet és
tudomány as a subject block** rather than shipped separately. Note the trap:
several "Hungarian inventions" circulating online are contested; stick to the
documented ones.

### 🎬 Magyar film és tévé
300–400 available (the cartoons — Vuk, Mézga család, Frakk, Kockásfülű nyúl — carry
a lot of it). In a one-or-two-channel country everyone watched the same thing on
the same night, so it's shared-memory material. **Partly absorbed into *Ahogy régen
volt*;** worth splitting out later if that block proves popular.

### 🤔 Igaz vagy hamis — magyarul
A Hungarian sibling of her most-played category. Tricky True or False has 419
rounds — more than anything else — but her weakest accuracy at 89.9%. It's the
format she loves *and* finds hard. In Hungarian it becomes the one place she's
genuinely tested without a language handicap. 300–400 questions.

Inherits the ~50/50 True/False constraint, the `second_try_correct = 0` constraint,
and the `isTrueFalse()` / badge / 1–2 keyboard layers. **Hard to write well** —
"tricky because intuition is wrong, never a word game" is a demanding bar.

### 🇺🇸 US Citizenship Test
The official set is 100 questions (2008 version; a 128-question 2025 set exists,
effective 20 Oct 2025). **Public domain** as a US Government work. Expands to
300–400 with adjacent civics. The one American subject where she has an emotional
claim — she either took this test or knows people who did.

### 🦃 American Life
Thanksgiving, tipping, potlucks, the DMV, garage sales, ZIP codes, Social Security.
400–500 available. Unlike every other English category, **some of it is genuinely
new to her** — knowledge acquired as an adult rather than absorbed as a child.
88–94% expected, her most honest English challenge.

### 🔤 Hogy mondjuk angolul? + ⚠️ Hamis barátok
600–900 available, and the only category with a use *outside* the app. Plays to her
fastest mode: recognition, in Hungarian, short answer. The false-friends block
(farmer/jeans, aktuális/actual, szimpatikus/sympathetic, gimnázium/gymnasium) is
150–250 on its own — too small to ship alone, so make it a subject block inside the
vocabulary category. 80–90% — the hardest English category she could be given, in
the best way.

---

## Rejected

- **Pszichológia magyarul** (translating the 602-question Psychology bank).
  Nearly free, but it misdiagnoses the failure. Psychology has 28 rounds and 320
  questions never shown — the problem is that the subject doesn't interest her, not
  that it's in English. Translating a bank she ignores produces a Hungarian bank
  she ignores.
- **Magyar borvidékek as a standalone category.** 60–80 genuinely distinct
  questions exist. She'd clear it in twenty minutes. It's a subject block inside
  Magyar konyha, not a menu button.
- **Magyar néptánc és népviselet.** Inherently visual and auditory; the schema has
  no image or audio support. Reduced to text it becomes dry taxonomy about a
  subject whose whole appeal is seeing and hearing it. Same reasoning rules out a
  photo-based "Melyik város ez?".
- **A Hungarian Fifth Grader.** She abandoned that format on 2026-08-30 — though
  note the accessibility audit found the abandonment was caused by a UI lockout,
  not the format. Worth revisiting after that fix.

---

## 🔍 Needs you — an AI cannot source these

**These are potentially the best ideas in the whole document.**

- **Szülőföld — her hometown.** Her town, her county, the river through it, the
  school, the street, the church, the market. A 100–150 question bank here would
  outperform everything above emotionally.
- **Családi kvíz — family quiz.** Birthdays, name days, relatives' names, where
  people met, what her grandmother cooked, the year she emigrated. **This beats
  *Ahogy régen volt*** if you're willing to write it — it's the only category where
  she is the sole expert in the world. The no-typing rule holds fine; only you
  type, once, into a migration.
- **Prices and wages of her exact years.** A kifli, a mozijegy, a Bambi, a monthly
  wage, the Trabant waiting list. Enormously evocative — and precisely where a
  model produces confident wrong numbers. **I instructed the *Ahogy régen volt*
  agent to omit prices entirely** for this reason. Supply them and they can be
  added.
- **Which songs, films and foods she actually loved.** An agent can write the
  canonical 70s–80s hits; you know which five she sings in the kitchen. Weighting
  the bank toward those turns a good category into a personal one.
- **Her emigration year and route**, which determines where "American Life" starts
  being new to her rather than obvious.
