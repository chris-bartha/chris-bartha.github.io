# Things that aren't quizzes

Produced 2026-09-16.

**Status key:** ✅ done · 🔍 decide later · ⬜ not started

---

## The constraint that decides everything

**31,331 questions in 58 days. 540/day lifetime average, ~380–420/day recently.
Biggest day: 1,677.** At that rate she consumes the entire 3,428-question library
every 6–8 days.

So the filter on every idea below is **content economics**. Anything hand-written
one item at a time loses. Winners are **combinatorial** (a small seed table → tens
of thousands of screens), **date-derived**, **public-domain**, or **derived from
data she already generates**.

Two seed tables would carry half this list:
- a **numeric-facts table** (~400 entities + one number each)
- a **dated-events table** (~600 events + a year each)

Each is written once and powers three modes.

---

## ⬜ Top 5

### 1. ⚖️ Több vagy kevesebb? / Higher or Lower
*"Which number is bigger? Two buttons. Keep going as long as you can."*

One line of large text — `Which is taller?` — then two full-width buttons:
`1. Mount Fuji` / `2. Mont Blanc`. Pick, both heights reveal as words with ✓/✗,
big Next.

**This is Tricky True or False's exact shape** — two buttons, one try, sudden
death — which is her single most-played category at 419 rounds. **~400 entities
generate 79,800 distinct pairs**, written once. Reuses the existing `option-btn`
and true/false code path. Accessibility: clean pass on every rule.

### 2. 🏅 Your Story / A te történeted
*"Everything you have done here. In big letters."*

Light or dark theme, same look as the quiz, one fact per full-width card, **no
charts of any kind**:

```
  You have played 58 days.
  You have not missed a single one.
  ──────────────────────────────────
  You have answered 31,331 questions.
  ──────────────────────────────────
  Your longest run: 430 questions
  without one mistake.
  ──────────────────────────────────
  Out of every 100 answers,
  96 are right.
```

**She has never seen any of this.** `/metrics` is dark, dense and built for you.
A 58-day unbroken streak and a 430-question perfect run are extraordinary and
nobody has told her. Zero ongoing content burden, forever.

Refuse every chart, sparkline, progress bar and heatmap — all of them are
colour-coded fine detail. Numbers as words, one per card. Say "96 out of every
100", not "96.0%".

### 3. 🎭 Melyik a hamis? / Two Truths and a Lie
Three stacked full-width buttons, one statement each, keys 1–3, miss ends the run.
**Generated entirely from the existing `tricky_true_false` bank** — two True
statements plus one False. Over a million distinct triples. **Zero new writing.**

### 4. 📖 Olvasnivaló / Read to Me
One paragraph per screen at full width, three buttons: `🔊 Read this page`,
`Next page ➜`, `Back to the menu`. Position saved in `localStorage`.

**The single most useful thing on this list.** Low vision makes print books hard;
this turns Jókai, Mikszáth, Móricz and Krúdy into an audiobook in her mother
tongue at any type size. Public domain, effectively unlimited, zero writing.

Honest caveat: it is *calm*, not competitive — a mismatch with her sudden-death
appetite. Build it anyway; it serves a need nothing else on the site touches.

### 5. ⏳ Melyik volt előbb? / Which Came First?
Two full-width buttons with an event each; the reveal shows both years in words.
**~600 dated events → ~180,000 pairs.** Tests *relative* knowledge, which is
genuinely harder than recall, using facts she already has. The same table also
gives you *Guess the Decade* and *On This Day* for almost nothing.

---

## ⬜ The rest

| Idea | What it is | Content burden |
|---|---|---|
| 🪺 **Ki a kakukktojás?** | Four buttons, three belong together. Identical layout to today's quiz, different thinking | Low (needs ~80 tagged sets) |
| 📅 **Melyik évtized?** | One event, four decade buttons. Her lifetime, and the most forgiving difficulty on the list | Low (shares the events table) |
| 📦 **Melyik dobozba?** | One word, four category boxes. **The honest, accessible replacement for Connections** — same grouping pleasure, one decision at a time, no 4×4 grid | Low |
| 🗓️ **Mi történt ma?** | 3–5 events for today's date, one line each, with a Read button | Low |
| 🗣️ **Fejezd be a közmondást!** | Hungarian proverb completion. Near-100% expected — that's the point, it's warm, not a test. Good cool-down after a lost run | Low |
| 🕯️ **A nap verse** | One Hungarian poem a day, large type, read aloud. Highest emotional return per line of code on the list. Needs `white-space: pre-wrap` with hanging indents so line breaks survive A+ | Low |
| 🔤 **A nap szava** | One English word and its Hungarian twin daily, with both speech buttons. Date-derived index into a static array — no DB needed | Low |
| 🍲 **Recept lépésről lépésre** | One step per screen, read aloud. Genuinely useful — reading a recipe card while cooking is exactly what low vision makes miserable, and speech means no wet hands on the screen. 30 recipes is a complete product | Medium but low-volume |
| 🔢 **Mi jön ezután?** | Number sequences, infinite, algorithmic, no cultural knowledge. But a *different* pleasure from her trivia habit — she may bounce. Cheap trial, not a headline | None |
| 🕰️ **Ma / Today** | A date strip on the home screen: "Wednesday, September 16. You have played 58 days. ✓" Two lines maximum so it doesn't push the menu below the fold at 200% | None |
| 💭 **Emlékszel még?** | Unscored reminiscence cards. **Honest verdict: a mismatch.** She plays sudden death for hours; an unscored card gives her nothing to win. And she'd burn 200 prompts in an evening | High relative to value |
| 🧩 **Találós kérdés** | One riddle a day. The scarcity is also the flaw — she'd want fifty | High |

---

## The daily ritual

**Correct the premise first: she is not a morning person.** 19 questions ever
answered at 8am. The day starts around 14:00 and peaks at **22:00**, running to
02:00.

So the ritual isn't a morning brief — it's what greets her when she sits down in
the afternoon. Make it **Your Story with the Today strip pinned above the menu**.
Every time she opens the page, before she picks anything:
*"Wednesday, September 16. You have played 58 days in a row. ✓"*

It costs nothing to maintain, grows on its own every day she shows up, and turns
an unbroken two-month streak from invisible database rows into the reason she
opens the page.

---

## Disqualified on accessibility grounds — and the exact rule that killed each

- **Connections / any 4×4 grid** — 16 tiles cannot hold 22px type without
  shrinking. Killed by *never shrink type*. Replaced by *Melyik dobozba?*
- **Memory / matching tiles** — needs a grid *and* a flip. Killed twice.
- **Crossword, Wordle, word search, typed anagrams** — all need letter entry.
  Killed by *no typing*. A "pick from 4 words" variant is a vocabulary quiz
  wearing a costume.
- **Drag-and-drop ordering** — pointer precision plus motion. Replaced by *Which
  Came First?*'s repeated binary choice.
- **Any countdown timer** — killed by *no animation*, and it punishes reading speed.
- **Sudoku or any number grid** — 81 cells. Killed by type size.
- **Solitaire and card games** — small pips, dense tableau, dragging.
- **Spot-the-difference, jigsaws, map-clicking** — require resolving fine visual
  detail. Killed by low vision outright.
- **Picture of the Day** — honest demotion rather than a kill: with low vision the
  caption does all the work, so it's a Fact of the Day with an expensive image
  attached. Ship the caption, skip the picture.
- **Charts or streak heatmaps in Your Story** — every one signals with colour and
  fine detail.
- **Confetti on a new record** — killed by *no animation*. Use a large ✓ and the
  word "Record!"
