# Accessibility & UX audit

Produced 2026-09-16. Every claim below was verified against the code; contrast
ratios were computed from the actual hex tokens in `style.css`.

**Status key:** ✅ fixed in this session · 🔍 needs your second look · ⬜ not done

---

## ✅ 1. The Unlimited toggle did not persist

`app.js` hardcoded `applyUnlimitedMode(false)` at startup and the function never
called `save()`. Only `quiz-font-step`, `quiz-theme` and `quiz-voice` were
persisted. **98% of her rounds are Unlimited** (1,219 of 1,244), so she re-tapped
this every single session.

Worse: the 25 standard rounds ever played are scattered and recent, which reads
as *forgotten-toggle accidents* rather than preference. In Tricky True or False a
forgotten toggle silently swaps her into a different game — 10 questions, no
sudden death.

**Fixed:** `applyUnlimitedMode` now saves, and startup reads it back with
Unlimited as the default (`load("quiz-unlimited") !== "off"`).

## ✅ 2. Dark mode is now the default

`prefers-color-scheme` appeared **zero times** in the entire codebase and the
theme defaulted to light. 57% of her rounds finish between 19:00 and 03:00.

You confirmed she prefers dark and has cataracts. That matches the research: the
general low-vision advantage is actually for *light* mode, but it reverses for
people with cloudy ocular media, where light scatter dominates — cataracts are
the textbook case. Dark is right for her specifically.

**Fixed:** startup is now `load("quiz-theme") === "light" ? "light" : "dark"`.
An explicit choice still wins.

## ✅ 3. Fifth Grader was unreachable, not unloved

`setMenuBusy` set `menuBtns[i].disabled = busy || unavailable`, so whenever
Unlimited was on the button was genuinely `disabled` — unreachable by keyboard,
and its explanatory text sat at `opacity: 0.48` with `grayscale(0.8)`, computing
to roughly **1.9:1** against the card. Effectively invisible.

She always has Unlimited on. The category went dark on 2026-08-30. That is a
lockout, not boredom.

**Fixed:** the button stays focusable with `aria-disabled` only (the click was
already refused in `startRound`), opacity raised to 0.75, grayscale removed.

🔍 **Worth deciding:** it would be better still to let Fifth Grader simply ignore
the Unlimited flag and always run its fixed 10-question ladder. That removes the
lockout entirely. I did not do it because it changes game rules, not
accessibility.

## ✅ 4. The restart loop cost her two taps and a scroll, ~1,250 times

From a miss to the next run was: Next → results → *find* "Play again". Focus
landed on the result title. Keyboard cost was four keystrokes because the Share
button sat between the title and Play again in the DOM.

And the most prominent button on her hottest screen — plum fill, drop shadow —
was **Share**, which she almost never needs. Median Tricky True or False run is
**4 questions**, so she sees this screen constantly.

**Fixed:** "Play again" moved above Share, given the plum `.next-btn` treatment,
and focus now lands on it. Share is a plain button below. One tap, no scroll,
Enter works immediately.

## ✅ 5. Contrast — two real weak spots

Core pairs were already excellent (ink/paper **16.2:1** in both themes, muted
text 8.2–9.2:1, plum buttons 9.5:1). Two failures:

- **Light-theme focus ring** `--focus: #e37400` was **3.01:1** on paper — barely
  over the non-text floor and far under what low vision needs. Dark theme's
  `#ffb300` was fine at 10.3:1. **Fixed:** light theme is now `#a33d00` (~7:1).
- **Red** `#b3261e` was **6.5:1**, the only type in the app under 7:1.
  **Fixed:** `--wrong-bg` and `--bad-text` are now `#9c1c15` (~7.6:1).
- **`.is-faded`** distractors at `opacity: 0.55` computed to ~3.7:1, so she
  couldn't read the other answers after responding. **Fixed:** raised to 0.75.

## ✅ 6. Answer buttons collapsed at large text on a phone

`.options .option-btn` was the only oversized element with no width safety — a
flat `1.25rem` beside a `flex: none` 2.3rem badge. The badge scales *with* the
text, so the text column collapses:

| Text step | Root | Text column | ≈chars/line |
|---|---|---|---|
| 100% | 22px | 221px | 14.6 |
| 150% | 33px | 140px | 6.2 |
| **200%** | **44px** | **58px** | **1.9** |

A 72-character Psychology answer at 200% wraps to ~36 lines — one option taller
than four screens. Nothing clipped (`overflow-wrap: anywhere` saved it) but it
became unusable vertically.

Compounding it: the `@media (max-width: 34rem)` block **never fires in response
to A+**, because `rem` in a media query resolves against the browser's initial
16px, not `html{font-size}`.

**Fixed:** option buttons now stack the badge above the answer both at ≤34rem and
at text steps 4–5 on any width, via a new `data-font-step` attribute on `<html>`.
No type shrunk, no spacing tightened.

## ✅ 7. ✓/✗ + colour + words was broken on the assistive-technology path

Visually the rule held everywhere. But the ✓/✗ badge carries `aria-hidden="true"`
and each button's `aria-label` was set once at creation and never updated, so a
screen reader heard the answer text with no indication of right or wrong. The
`line-through` on `.is-wrong` wasn't exposed either.

**Fixed:** `finishQuestion` now prefixes the label with "Correct answer." /
"Your answer, wrong." in both languages.

## ✅ 8. ARIA corrections

- **Theme button** announced "Light, pressed" when dark was on — the label names
  the *action*, so `aria-pressed` contradicted it. **Fixed:** removed. (The voice
  and Unlimited toggles were already correct and were left alone.)
- **`#feedback`** had `role="status"` *and* `aria-live="assertive"`, a
  self-contradicting pair. **Fixed:** `role="alert"` alone.
- **Progress announced twice per question** — on render and again after
  answering. In a 430-question run that is 860 announcements. **Fixed:** removed
  the live region; the text is still visible and still spoken by the voice
  feature. 🔍 *Judgment call — if she does use a screen reader and wants running
  score, this is the one to revisit.*
- **`aria-label="Answer choices"`** was hardcoded English even on Hungarian
  screens. **Fixed:** moved into `STRINGS`.
- **No `<h1>`** on the quiz or results screens (both started at `h2`). No
  duplicate-h1 conflict exists because hidden screens leave the a11y tree.
  **Fixed:** both promoted to `h1`.

## ✅ 9. A mis-tap could destroy a 400-question run

`quitBtn` called `show("home")` and nothing else — no save, no confirmation. It
sits directly below Next, and `.quiz-bottom` **had no CSS rule at all**, so the
two were separated only by collapsed 0.8rem margins. Her average Hungarian run is
155 questions.

**Fixed:** past 5 answered questions, Quit now opens an in-page confirmation
("Stop this run? You have N right so far.") with two full-width buttons. Not a
browser `confirm()` — that renders at system size, which defeats the point. Also
added `.quiz-bottom { margin-top: 1.6rem }`.

## ✅ 10. Score-save failures were silent

`recordResult(...).catch(console.error)` — network down at the end of a
430-question run meant the score vanished and she saw a normal results screen.

**Fixed:** the failure now writes a plain sentence into the status line under the
buttons, in both languages.

## ✅ 11. Speech synthesis

- **No `voiceschanged` listener existed.** In Chrome `getVoices()` returns `[]`
  until that event fires, so the *first* utterance of every session used the
  wrong voice regardless of category. **Fixed:** voices are cached and refreshed
  on the event.
- **No Hungarian voice meant Hungarian read with English phonemes** — gibberish,
  not silence. macOS ships exactly one Hungarian voice ("Tünde"); iOS may ship
  none. **Fixed:** the app now prefers a device-local voice over a remote one,
  and when no Hungarian voice exists it stays quiet, hides the Read button, and
  shows "Hungarian speech is not installed on this device."

---

## 🔍 Needs your second look

1. **Fifth Grader under Unlimited** — see §3. Letting it ignore the flag entirely
   is probably right, but it's a rules change.
2. **Progress live region** — see §8. I removed it to stop 860 announcements per
   run. Reinstate if she uses a screen reader.
3. **Voice rate is hardcoded** at `0.9`. For hours of daily listening this should
   be a saved preference. Small change, real value, but it adds a control to the
   toolbar and CLAUDE.md says don't crowd controls.
4. **A−/A+ fail silently at the ends.** At step 5, A+ does nothing — no announcement,
   and a single step is hard to perceive at low acuity. A "Text size 5 of 6"
   status line would fix it but adds DOM.
5. **No crash or close recovery.** Nothing is written until `showResults()`, and
   there is no `beforeunload`/`pagehide` handler. A phone sleeping mid-run loses
   everything. The fix — checkpointing to `localStorage` each question and
   offering "Continue your run?" — is a real feature, not a patch.
6. **`rememberQuestionView` fires one network round-trip per question** even
   though `record_question_views` accepts an array. That's 430 requests in a long
   run. Batching is easy but touches the tracking path.

## ✅ Also fixed, on your later go-ahead — the Unlimited ordering bug

This was the biggest single finding of the session, and a gameplay change rather
than an accessibility one, so it was held back until you approved it separately.
Full detail and the measured before/after are in
`IDEAS-03-game-mechanics.md`. The problem was:

`app.js` calls `weightedSample(pool, pool.length)` — the entire pool — so the
weighting never *selects*, it only *orders*, least-seen first. Least-seen means
newest, which means hardest. Combined with sudden death:

| Category | median run | dead by Q3 |
|---|---|---|
| Tricky True/False | 4 | 46% |
| History | 6 | 34% |
| Geography | 33 | 6% |
| Hungarian | 89 | 3% |

History is two banks in one: 430 originals (seen 14.2× each, **98.7%**) and the
600 from 13 August (seen 2.2× each, **81.1%**). The hard 600 sort to the front of
every run, she dies around question six, their view count stays low, so they sort
to the front again. **The 430 she loves are walled off behind them.**

The fix weights on `last_answered_at` and accuracy alongside view count, keeps
every question eligible, and lifts the mean History run from 5.5 to 7.1 questions
with no measurable loss of freshness.

---

## Already good — don't touch

- **The colour system.** Every core pair clears WCAG AAA with room. Unusually disciplined.
- **`min(2rem, 15vw)` on `h1` and `min(1.6rem, 12vw)` on the question**, plus
  `overflow-wrap: anywhere`. Exactly the right instinct — it just never reached
  the option buttons.
- **`lang` handling** — `lang="hu"` on Hungarian menu buttons and `applyLocale`
  setting it per screen. Real work that most sites skip.
- **Focus returns to the originating menu button** on both quit and home.
- **`aria-hidden` discipline on decorative content** — brand, every emoji, the
  progress bar. The bar being hidden while the text carries the same information
  is exactly right.
- **The in-memory question cache** in `supabase-client.js` makes "Play again"
  network-free.
- **The "no second chances" rule enforced in three layers** for Tricky True or
  False — JS, a DB check constraint, and the narrowed keyboard hint.
- **Touch targets** — 4.2rem options, 4.4rem big buttons, 3rem toolbar controls.
  All above the AAA 44×44 floor at every text step. (WCAG 2.2's actual AA
  minimum is only 24×24 CSS px — you clear it by roughly 3×.)
- **`metrics/` is genuinely isolated.** The quiz page downloads none of it.
- **No sign-in** happens to satisfy WCAG 2.2 SC 3.3.8 Accessible Authentication
  perfectly. Worth writing down as a deliberate conformance win.
