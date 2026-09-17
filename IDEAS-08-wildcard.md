# Wildcard — ambitious ideas

Produced 2026-09-16. Verified environment facts included.

**Status key:** ✅ done · 🔍 decide later · ⬜ not started

---

## Verified environment

- **1,878 questions (55% of the bank) have been answered 3+ times and never once
  missed.** Only **75 questions** are ones she gets wrong more than 40% of the time.
- **Busiest hour: 1am Pacific**, ahead of 7pm.
- **Zero Edge Functions deployed.** `pg_cron`, `pg_net`, `pg_trgm` and `vector` are
  all **available but not installed** on the project.
- **`quiz_questions.language_code` already exists**, defaults to `'en'`, and is
  completely unused.
- No image or audio column exists.

---

## ⬜ THE BIG ONE — The Forge: a nightly question factory

*Every night while she sleeps, the bank grows by more than she can play tomorrow.*

**The problem this solves is arithmetic, not taste.** One human writing questions
in evenings cannot feed a player who consumes ~3,000 a month, and every hand-written
batch is consumed faster than the next can be written. Your 13 August drop of 900
questions raised her play from 378/day to 1,111/day for exactly one week.

**Architecture:**
1. One Edge Function `generate-questions` (Deno), with `ANTHROPIC_API_KEY` in
   Supabase Function secrets — **never** `config.js`.
2. Install `pg_cron` + `pg_net`; cron at 03:00 Pacific POSTs the function.
3. **Generate** — `claude-sonnet-5` via the **Batch API**. Prompt = a per-category
   style guide + 40 sampled existing prompts, with a `cache_control` breakpoint on
   the frozen prefix.
4. **Verify — the gate that matters.** A *second, independent* `claude-opus-5` call
   sees only the prompt and the four options, **never the intended answer**, and
   must independently pick one. Disagreement → killed, logged, never shown. This
   catches the confidently-wrong-fact failure directly, because a hallucination
   rarely survives being re-derived blind. Far stronger than asking a model to
   check its own work.
5. **Dedupe** — `pg_trgm`, reject `similarity() > 0.6` against existing prompts.
6. **Shape** — insert into `question_drafts` so the existing check constraints
   (exactly-3 wrong answers, True/False pairing, `grade_level` rules) fail loudly
   on garbage. Add a **plain-language gate**: reject prompts over ~90 characters.
7. **Review** — `metrics/review.html`, owner-only, kept out of the quiz bundle the
   way `/metrics` already is. Approve / Reject / Edit.

**Cost, real numbers:** 300 questions/night ≈ 30K in + 45K out on Sonnet 5
($2/$10 per MTok) = $0.51; verification on Opus 5 ($5/$25) ≈ $0.42. **~$0.93/night,
and the Batch API's 50% discount takes it to roughly $14/month.**

**What goes wrong:** she "learns" a wrong fact — the only genuinely serious risk.
Mitigations in order: blind re-derivation, your review queue (never auto-publish
for the first month), and the "This looks wrong" button below as the last line.
Secondary: cost drift if cron double-fires — put a hard nightly row-cap in SQL, not
in the prompt.

**Effort:** Month (a Weekend for a manual, run-it-yourself v0 with no cron).

---

## ⬜ The rest, ranked

### 2. 🌙 Night Mode — eyes-free, screen dark
She plays at 1am. Extend the existing `speak()` / `questionSpeechText()` into a
real mode: auto-read the question, then each option prefixed "One… Two…", answer by
keypress 1–4 or four full-screen quadrant taps so no aiming is needed. Wake Lock so
the screen doesn't sleep mid-run.

**Doesn't add content — adds hours.** The most on-mission idea on this list for a
low-vision player. Make auto-advance generous and abortable by any key.
**Effort: Week.**

### 3. 🗄️ The Vault — retire what she has mastered
55% of the bank can no longer teach her anything. A `question_mastery` view feeding
a multiplier in `weightedSample` that pushes mastered questions to near-zero weight
**without ever excluding them** — which honours the CLAUDE.md rule. Surface it:
"You have retired 1,878 questions." Resurface them occasionally as "Do you still
know this?"

> **You've said no to removing questions for now.** Noted — and the honest risk the
> agent itself flagged is that her 90–99% accuracy *isn't a bug*. A version that
> leaves only hard questions would be "better designed" and worse to play.
> **Effort: Weekend if you change your mind.**

### 4. 🤺 Nemesis — the 75
A category made entirely of the questions that have beaten her
(`times_answered >= 3 and times_correct/times_answered < 0.6`). Self-refilling:
beat one and it leaves. No new content — it's the highest-value 75 rows she has,
currently diluted 1-in-46. Frame it as "Rematch", not "Your mistakes".
**Effort: Weekend.**

### 5. 🇭🇺 Magyarul — double the library by translating it
`language_code` is already in the schema and unused. Batch the full bank through an
Edge Function: `claude-opus-5` translates prompt + answers, then a second pass
checks exactly one answer is still correct and the distractors stay plausible
(**translated distractors often collapse into synonyms** — a real failure mode).
One-off cost well under $50. Needs her eyes on a sample before bulk insert.
**Effort: Week.**

### 6. 🌐 Wikidata Geography — provably correct, literally infinite
An Edge Function hits the Wikidata SPARQL endpoint (free, no key, **CC0**) for
capital-of, highest-point, borders-with, population-rank. A template engine turns
each row into a question and picks distractors from **sibling rows of the same
type** — which is what makes them plausible. **Zero hallucination risk by
construction.** Use both: Wikidata for factual categories, the Forge for conceptual
ones. Risk: robotic sameness, and occasional bad Wikidata rows (a country with two
"capitals"). **Effort: Week.**

### 7. ✅ Mom the Curator — three buttons, no typing
After feedback on any question: **"Too easy" / "Too hard" / "This looks wrong."**
Writes to `question_feedback` (RLS: insert own only). "Looks wrong" flags the row,
drops it from rotation pending review, and lands in the same queue as Forge drafts.

**This is the safety net that makes the Forge shippable**, and it makes her a
participant rather than a consumer. Put the buttons below Next with real spacing.
**Effort: Weekend.**

### 8. 🎁 Mom's Picks — she commissions tomorrow's questions
~30 pre-written topic buttons (Opera, Budapest, Cooking, Space, 1970s Film…). Her
pick writes a row to `topic_requests`; the nightly cron seeds that batch. Next
afternoon: *"New: Opera — 50 questions, made for you."* Converts "the content is
stale" from your problem into her steering wheel. Gate behind review even after the
main Forge goes automatic. **Effort: Week on top of the Forge.**

### 9. 👻 The Ghost — play your run
Any run saved as a challenge (question id list + per-question outcome). She plays
the identical sequence and sees "He got this one wrong." **The only idea here that
puts another person in the room at 1am.** Honest dependency: it dies if you stop
playing. **Effort: Week.**

### 10. 🎵 The Sound Round — and an honest word about images
Add `media_url` + `media_type`, files in Supabase Storage. **Audio only:** Hungarian
songs of her youth, speeches, instruments, birdsong. Huge full-width play button,
unlimited replay, text fallback always present. Never autoplay — that's close kin
to the no-animation rule.

> **Images are a mistake here.** A photo question for a low-vision player is one
> she can't reliably answer — it converts the app's core promise (everything is
> legible) into a coin flip, and no zoom control fixes "which painting is this."
> **Audio has no such problem — it gets *better* with low vision.**

### 11. 📕 The Book — a printed large-print booklet
A Node script pulls unseen questions and lays them out in Atkinson Hyperlegible at
24pt, answers in the back, writes a PDF. Print monthly. Reaches the hours she can't
or doesn't want to look at a screen, and it's a physical object from her son. Print
is the purest form of the legibility rule. **Effort: Weekend.**

### 12. 🗓️ Today — questions that exist only today
A `daily_pack` built nightly from Wikidata "on this day" + the Forge, tagged with
the date. Structurally unrepeatable content. Keep the last 7 days as "Catch up" so
missing a day isn't punishing. **Effort: Week on top of the Forge.**

### 13. 🏆 The Final Question
When a run ends, offer one last high-stakes question from Nemesis. Right, keep the
score; wrong, lose half. Turns 1,219 structurally identical runs into runs with an
ending. **Opt-in per round only** — taking half a hard-won score is a designer's
idea of drama and a player's idea of unfairness. **Effort: Weekend.**

### 14. 🪜 The Ladder — named tiers and seasons
Progress by streak length, plain-language tiers, monthly reset. Makes yesterday
matter today without new questions. **Real risk of turning a nightly pleasure into
a chore.** Never show a broken-streak penalty. **Effort: Week.**

---

## The honest check — ideas that are worse for her than what she has

The agent was asked to be ruthless about its own list. It named:

- **Images.** Cut outright. The most impressive-looking idea here and the most
  directly hostile to the person it's for.
- **The Phone Quiz** (a daily Twilio call reading questions to her keypad).
  Technically the flashiest. But a scheduled robot call replaces something she
  *chooses* to do with something that happens *to* her. Only build it if she asks.
- **The Ladder and seasons.** She restarts Tricky True or False constantly and
  enjoys losing — that's someone playing for fun, not progression.
- **The Final Question as mandatory.** Opt-in only.
- **The Vault, if tuned aggressively.** Her 90–99% accuracy isn't a bug to be
  engineered away. Competence feels good.

**And the meta-risk across all of it: complexity you maintain alone.** Every Edge
Function, cron job and API key is something that can break at 1am when she opens
the app and gets an error screen. **The current app's greatest feature is that it is
three static files that cannot fail.** Anything added should degrade to the existing
experience when it breaks, not replace it.
