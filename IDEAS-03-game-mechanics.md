# Game mechanics — making the existing bank feel new

Produced 2026-09-16. Findings verified against `app.js` and the live database.

**Status key:** ✅ done · 🔍 decide later · ⬜ not started

---

## ✅ The headline: "stale" is partly a misdiagnosis — now fixed

Median run length is **4 questions** in Tricky True or False and **6** in History.
In her two most-played categories, half of all runs end before question six. She
has played 1,219 Unlimited runs and is still replaying the same short front slice
of each bank.

**Two causes, both in `app.js`:**

**The weighting is a no-op in the only mode she plays.** `weightedSample` is a
correct weighted sample without replacement — `weight = 1/sqrt(1+views)` — but
Unlimited calls it as `weightedSample(pool, pool.length)`, the entire pool.
Selection is vacuous; the weight only sets **order**.

**That ordering creates a death trap.** Least-seen sorts first, so every run
front-loads exactly the questions she hasn't learned:

| History bank | n | avg times_shown | accuracy |
|---|---|---|---|
| Seed (`subject IS NULL`) | 430 | 14.2 | **98.7%** |
| 13 Aug expansion | 600 | **2.2** | **81.1%** |

The 600 hard expansion questions sort to the front of all 307 History runs. She
misses one by question ~6, the run ends, their `times_shown` stays low, and they
sort to the front again forever. **104 of 307 History runs died at ≤3 questions.**
Same shape in Tricky True or False: 193 of 419 runs died at ≤3.

So there are two separate jobs: **unlock the questions she can't reach**, and
**make the mastered ones hard again.**

### ✅ What shipped

`weightedSample` in `app.js` now multiplies three gentle pulls instead of one
harsh one. Every question still keeps a real weight, so nothing is ever
excluded — the CLAUDE.md rule survives. The constants sit at the top of the
function, named, so any one of them can be turned on its own:

| Constant | Value | What it does |
|---|---|---|
| `VARIETY_PULL` | 0.25 | toward questions seen less often (was effectively 0.5) |
| `COOLDOWN_DAYS` / `COOLDOWN_FLOOR` | 7 / 0.4 | a just-answered question rests, then recovers |
| `EASE_SPREAD` | 0.3 | questions she reliably gets right drift earlier, so a run warms up |
| `MIN_ANSWERS_FOR_EASE` | 4 | below this there is no useful accuracy yet |

`supabase-client.js` now also loads `last_answered_at`, which the cooldown needs.

### Measured before and after

`drafts/ordering_test.js` rebuilds a question pool from the real joint
distribution of views, accuracy and recency (a grouped `SELECT`, nothing
written) and orders it both ways 20,000 times. The model is credible: it
reproduces the observed median run lengths closely.

**History** — 1,030 questions, real median run 6:

| | median | mean | died by Q3 | reached 25 | new qs seen/run |
|---|---|---|---|---|---|
| before | 4 | 5.5 | 48% | 1% | 2.8 |
| **after** | **5** | **7.1** | **41%** | **4%** | 2.7 |

**Tricky True or False** — 301 questions, real median run 4:

| | median | mean | died by Q3 | reached 25 | new qs seen/run |
|---|---|---|---|---|---|
| before | 5 | 7.6 | 39% | 5% | 0.0 |
| **after** | **6** | **8.6** | **36%** | **6%** | 0.0 |

Mean run length up ~29%, and runs that reach 25 questions roughly quadruple —
while freshness is essentially unchanged (2.8 → 2.7 new questions per run).

*Note the 0.0 for Tricky True or False: every question in it has been seen at
least seven times. There is no new material there for any ordering to find.
That category needs content, not tuning.*

### If you want to turn it up

The sweep in the same script shows which lever costs what:

| Change | mean run | new qs/run |
|---|---|---|
| `VARIETY_PULL` 0.5 → 0.25 (shipped) | 6.1 → 7.1 | 2.9 → 2.7 |
| `VARIETY_PULL` → 0 | 8.4 | 2.5 |
| `EASE_SPREAD` 0 → 0.3 (shipped) | 6.4 → 7.1 | 2.7 → 2.7 |
| `EASE_SPREAD` → 0.5 | 7.6 | 2.7 |
| `EASE_SPREAD` → 0.7 | 8.0 | 2.7 |

**`EASE_SPREAD` is the free lever.** Raising it lengthens runs at no cost to how
much new material she meets, because it reorders on accuracy rather than on view
count. `VARIETY_PULL` trades freshness for length, so lowering it further is the
one to be careful with. Shipped values are deliberately at the gentle end.

---

## ⬜ The mechanics, ranked by impact ÷ cost

### 1. Sibling distractors
Nothing changes in the UI. *"What is the capital of Paraguay?"* stops offering
three soft wrong answers and starts offering Montevideo, Santiago, La Paz — real
capitals pulled from other Geography rows. Same question, genuinely harder,
different every time.

This is the only mechanic that attacks the **1,654 questions (48% of the bank)
answered 8+ times and never once missed**. Roughly 35 lines in `app.js`, no
migration.

> ⚠️ **I found a flaw in this one.** The agent's plan matches on `subject`, but
> **Geography and Hungarian have no `subject` values at all** — 845 questions, all
> null, and they are precisely the two most-memorised banks. Worse, your
> distractors are deliberately type-matched: *capital of North Dakota* → Fargo,
> Grand Forks, Minot. A naive sibling swap would offer Egypt and Mount Everest,
> making the question **easier**. This needs answer-type classification first.
> It is a real project, not a 35-line change.

### 2. Fix the weighting, add a cooldown tier
A question answered correctly in the last ~7 days sinks toward the back of the
order instead of the front. ~10 lines; `last_answered_at` already exists on the
table. Should take her History median run from 6 to north of 30.

### 3. 🎯 Revenge Round — "My tricky questions"
Only questions she has personally got wrong, hardest first, leaving the pool after
two clean answers. **121 questions have been missed 3+ times; 48 missed 5+ times**
out of 1,253 total misses ever. That is the hardest content in the app and it
already exists. Needs one `security definer` RPC — the `answers` jsonb in every
result table already carries `question_id` and `correct`.

Must be short, never sudden-death, and framed as "getting these back" rather than
a remedial list.

### 4. 🔥 Hard Mode toggle
A second toggle beside Unlimited: any category filtered to questions below 90%
accuracy or never answered. Pool sizes today: Tricky T/F 42 under 80%, Textbook
History 37, Geography 11, History 9, plus **328 Psychology questions never
answered**. ~40 lines, no migration. Pair it with standard mode, not Unlimited —
as sudden death it would have a median run of 2–3.

### 5. 📚 Subject Gauntlet
After tapping a category, a second screen of large buttons — "Ancient Rome",
"World War I" — each a 30-question themed run. **71 themed sub-rounds already
exist** in the `subject` column: 21 subjects in History, 17 in Psychology, 12 in
Textbook History, 11 in Time Traveler, 10 in Tricky T/F.

And the subject data is where the difficulty signal is: History's *World War I And
The Interwar Years* sits at **59.3%**, *Revolutions And Napoleon* at **67.1%**,
against a 98.7% seed bank. She has specific weak spots and no way to find them.

Needs human-readable display names — History's labels are machine-cased
("The 1600s, 1700s And Enlightenment"). Add a "Play everything" button at the top
so it doesn't put friction between her and playing.

### 6. Make standard mode an escalating ladder
Question 1 from her 95%+ pool, question 10 from her sub-70% pool. Standard mode is
dead (25 rounds ever) because a flat 10 questions at 98% has no arc. ~30 lines,
reusing the `buildFifthGradeRound` pattern that already proves the shape works.
Worth doing only because it's cheap — don't bet on her turning Unlimited off.

### 7. 🌍 The Grand Tour
All 8 banks in sequence, 10 from each to advance. Forces her through Psychology
(320 of 602 never seen) and Fifth Grader (untouched since 30 Aug). Context-switching
between Hungarian and English mid-run is itself a difficulty source. Needs
per-category checkpointing to be humane — 80 questions with no save point is cruel.

*On the retired `mix` category: it was retired because it never had its own
questions, not because mixing failed. The row still exists with `is_active = false`.
Mixing is cheap to revive.*

---

## Rejected

1. **Any speed pressure.** A countdown is either animated (banned) or a static
   number (useless), and either way it punishes *reading speed* — the exact axis a
   low-vision ESL player is slowest on. Her 11s/question is fast recognition of
   memorised items; on History she takes 27s because she's *reading*. A timer
   would make the app hostile to the person it was built for.
2. **Reverse questions** ("which question does *Ashoka* answer?"). The option text
   becomes full prompts, which breaks the big-target and legibility rules at 200%
   zoom, and "which is NOT" is precisely the complex-clause construction the
   plain-language rule forbids.
3. **A "Mastered" tier that retires questions permanently.** You've already said no
   to removing questions, and it's the wrong fix anyway: retirement would shrink
   Geography from 415 to 68 playable questions, making staleness *worse*. A
   cooldown that re-weights is the right version; exclusion is not.

---

## Data findings worth keeping

- **1,654 questions (48.3%) have been answered 8+ times and never missed once.**
  1,265 (37%) at 12+ times.
- **Only 121 questions have been missed 3+ times.** Total misses: 1,253.
- **Worst question:** "White chocolate contains no cocoa solids" — 1/15 (7%).
- **Hardest clusters:** Tricky T/F astronomy; Hungarian textbook battle and
  place-name recall (Poltava 10%, Szolón 13%, Gaugaméla 44%, Cannae 45%); US state
  capitals and nicknames.
- **Psychology is stalling:** 320 of 602 never seen, last played 2026-09-06.
- **100% of non-true/false questions have same-subject siblings available** — but
  see the flaw noted in mechanic 1.
- The `answers` jsonb already carries `question_id`, `correct`, `outcome`,
  `subject` and `selected_answers` per question. A personal miss bank needs no new
  table, only an RPC.
