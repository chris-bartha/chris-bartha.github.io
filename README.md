# 🧠 Quiz Time!

An accessible, large-print quiz game made for Mom. The app now loads its question library from Supabase and silently keeps the same anonymous player identity in the browser—there is no name or login form.

## Quiz library

The Supabase database contains **10,762 unique questions** across 17 active categories.

The menu is grouped by language. One **Magyar kvízek** button opens the eleven
Hungarian quizzes; the English ones stay on the main menu.

### Magyar kvízek — 5,054 questions

- 1,460 **Történelem magyarul** — Hungarian and world history, including the school
  curriculum encountered by students born around 1964
- 519 **Természet és tudomány** — animals, plants, the body, space, weather, physics,
  chemistry, and Hungarian scientists
- 518 **Földrajz magyarul** — world geography in Hungarian
- 415 **Magyar irodalom** — the school canon, with a *Híres sorok* block of
  line-completion questions
- 388 **Ahogy régen volt** — everyday life in Hungary, roughly 1974–1994
- 355 **Magyarország földrajza** — counties, rivers, mountains, towns, Budapest
- 322 **Népmesék és közmondások** — proverbs, idioms, folk tales, riddles
- 306 **Magyar konyha** — dishes, spices, pastries, holiday food, regional origins
- 268 **Magyar zene 1970–1989** — bands, singers, songs, rock operas
- 253 **Két igazság és egy hazugság** — three statements, two true, pick the lie
- 250 **Több vagy kevesebb?** — is the real figure more or less than this round number?

### English — 5,708 questions

- 2,063 History questions
- 1,245 Geography questions
- 901 “Tricky True or False” statements where the obvious answer is often the wrong one
- 822 “Time Traveler” questions about everyday life, food, clothing, inventions, culture, medicine, travel, and discovery across history
- 602 Psychology questions on the brain, memory, learning, biases, development, and mental health
- 75 “Are You Smarter Than a Fifth Grader?” questions, with 15 questions at each grade level

Every question is written so the correct answer is **never reliably the longest
option**, and all choices share one type and grammatical form. Measured across the
4,183 questions added in September 2026, the correct answer is the strictly longest
option 24.9% of the time — chance is 25%. The Psychology bank was rewritten for the
same reason — see below.

### The expansion of September 2026

She had cleared or nearly cleared the categories she plays most: her longest Time
Traveler run reached all 275 questions, Geography 308 of 415, History 430. Those
five banks were doubled or tripled, and two new Hungarian categories were added:

| Category | Was | Now |
| --- | --- | --- |
| History | 1,030 | 2,063 |
| Történelem magyarul | 730 | 1,460 |
| Geography | 415 | 1,245 |
| Tricky True or False | 301 | 901 |
| Time Traveler | 275 | 822 |
| Több vagy kevesebb? | — | 250 |
| Két igazság és egy hazugság | — | 253 |

### The note behind an answer

`quiz_questions.explanation` is an optional single sentence shown after the answer
is revealed. It is required in the two new categories, where the real figure or the
correction *is* the payoff, and optional everywhere else — 2,577 questions carry one,
including every Tricky True or False statement added in the expansion.

The fifth-grade challenge asks two questions from each grade, in order from Grade 1 through Grade 5. It simulates the show’s three classmate helps:

- **Peek** reveals the simulated classmate’s answer while leaving the player free to choose.
- **Copy** commits to the simulated classmate’s answer.
- **Save** is automatic after a wrong answer and succeeds only when the simulated classmate is right.

Every category except Tricky True or False keeps the friendly second-chance rule from the original app.

## Psychology, rewritten

The Psychology bank shipped in August 2026 with two faults, both measured rather than guessed:

- The correct answer was the **strictly longest of the four options in 501 of 602 questions (83.2%)**, against 25% by chance. The bank used one template throughout — a full definition as the answer beside three short dismissals — so the category could be won without reading the prompt. Distractors are now real definitions of neighbouring concepts, in the same grammatical form and within a few words of the answer. That brings the rate to **22.8%**, indistinguishable from chance. Tuning it to zero was rejected deliberately: it would only have created the opposite tell.
- **97 questions (16%)** asked who discovered or ran something rather than how the mind works, including an entire subject label, “Famous Names and Studies”. Those were **converted, not deleted** — each now asks about the mechanism the name was attached to — so no question was lost. No prompt begins with “Who”, and no correct answer is a person’s name.

576 of the 602 rows were updated in place by id; the other 26 were already clean.

## Question order in Unlimited Mode

Unlimited Mode orders the whole pool, so under sudden death the order *is* the game. The original weighting sorted least-seen first, which also meant hardest-first — newly added questions are exactly the ones she has not learned yet — so runs died early and each new batch stayed stuck at the front of the queue.

`weightedSample` now multiplies three gentle pulls instead of one harsh one, with every question keeping a real weight so nothing is ever excluded:

- `VARIETY_PULL` — toward questions seen less often
- `COOLDOWN_DAYS` / `COOLDOWN_FLOOR` — a just-answered question rests, then recovers
- `EASE_SPREAD` — questions answered correctly in the past drift earlier, so a run warms up rather than opening on a wall

Simulated against the real distribution of views, accuracy and recency, mean History run length rises from 5.5 to 7.1 questions and runs reaching 25 questions go from 1% to 4%, with no measurable loss in how much new material a run reaches.

## Tricky True or False

Every statement in this category is written so the obvious answer is often the wrong one — common misconceptions alongside surprising facts, rather than technicality traps. Each round offers two choices, **True** and **False**, and the library stays close to an even split between them so guessing gains nothing.

This is the one category with **no second chances**. Two choices plus a second try would simply hand over the answer, so a miss reveals the answer immediately. The quiz screen states the rule on a badge, the keyboard hint narrows to **1** or **2**, and `second_try_correct` is always zero — enforced in the database by a check constraint, not only in the browser. In Unlimited Mode this makes the category true sudden death: the very first miss ends the run.

## One mode: the run

Every quiz but **Are You Smarter Than a Fifth Grader?** is a single open-ended run.
Questions continue through the weighted category library until one question is
answered incorrectly twice. The second chance remains available everywhere except
the two-choice categories — Tricky True or False and Több vagy kevesebb? — where a
second try would simply hand over the answer, so a single miss ends the run.

This used to be a toggle called Unlimited Mode, and the toggle is gone. It was not
a close call: **1,344 of her 1,405 rounds (95.7%) were already Unlimited runs**, so
the switch was a step between her and a round rather than a choice she was making.
Fifth Grader keeps its ten-question Grade 1 → Grade 5 ladder, its classmate helps,
and its progress bar, and is the only category still recorded with
`is_unlimited = false`.

`ROUND_LENGTH` still exists, and still means ten, but now only the Fifth Grader
ladder reads it.

Unlimited results are stored in the same per-category result tables with `is_unlimited = true`; every result created before this feature is marked `false`. Standard quiz counts, averages, perfect scores, category performance, and score distribution remain standard-only. Daily activity, streaks, correct-answer totals, and second-chance totals include both modes. Unlimited runs also have separate counts, category records, and a dated top-three leaderboard.

## Your best scores

A **🏆 Your best scores** button on the main menu opens the numbers: longest run
overall, rounds played, accuracy, total right answers, current streak and longest
streak, then a row per category showing the best run, how much of that category's
question bank it covered, and when it happened, and finally the last eight rounds.

It shows **the same thing to every visitor**, which is the point. Identity here is
anonymous auth in `localStorage`, so every device is its own player; filtering to
the caller meant opening the page on any other device showed an empty screen
reading "no rounds yet" next to her 1,395. `get_quiz_best_scores(timezone)` returns
aggregates only — no user ids, device ids, answer payloads or question text — the
same class of data `/metrics` has always published. The per-category result tables
stay blocked from the public API.

Both this screen and `/metrics` count days in **her** timezone rather than the
viewer's. A streak is counted in calendar days and she plays past midnight, so the
same history reads as a 60-day streak in Los Angeles and a 5-day streak in Toronto.
`quiz_player_timezone()` returns the timezone of whoever has played the most, and
both screens use it, so the number cannot change with who is looking.

## Bűnügyi történetek — the crime corner

A **🚨 Bűnügyi történetek** button opens the one part of the app that is not a quiz:
ten long-form Hungarian true-crime stories to read in place, and 93 hand-picked
Hungarian-language crime videos that open on YouTube.

The stories run 900–1,400 words in short paragraphs of plain prose, written for
reading at 22px and up, and cover documented historical cases — the 1983
Szépművészeti theft, Rózsa Sándor, the 1911 Mona Lisa theft, the Tichborne
Claimant, the great gold robbery of 1855. No gore, no recent cases involving living
private individuals.

Every YouTube id was checked against `https://www.youtube.com/oembed` before it was
inserted, and the stored title and channel are the ones YouTube itself returned. A
hallucinated eleven-character id looks exactly like a real one, and a dead link is a
dead end she has no way to diagnose. `drafts/round2/verify_youtube.py` does the
check and drops anything that is not live.

A video she opens **stays on the list for three hours** — long enough to go back to
it — and then drops out of the way. The click is never deleted: `crime_video_views`
keeps it, and a **👁️ Amiket már megnéztem** button brings the older ones back.

Every screen outside the main menu carries a red **✖ Kilépés / ✖ Exit** button at
the top *and* at the bottom, the same size as the quiz buttons, so the way out is
never further away than the top or the bottom of the page.

## Accessibility

- Atkinson Hyperlegible with full Hungarian character support
- Large type and large click targets
- A−/A+ text scaling
- Light and dark themes
- Optional English or Hungarian speech
- Keyboard shortcuts 1–4 for answer choices, narrowing to 1–3 in Két igazság és egy hazugság and 1–2 in the two-choice categories
- A red, clearly-worded exit button at the top and the bottom of every screen that is not the main menu
- High contrast, strong focus rings, and answer states that do not rely on color alone
- No required typing or recurring sign-in
- A large results-only share button that prepares a plain-text score message
- **Dark theme by default**, since most play happens between the afternoon and the small hours and cataracts make a bright page harder to read; an explicit choice still wins
- Answer states reach assistive technology as words, not just colour and a symbol — the ✓/✗ badge is decorative, so each button's label is updated too
- Answer buttons stack the number above the text at large text sizes, so the answer never gets squeezed into a two-character column
- Stopping a run part-way asks for confirmation once five questions have been answered, so a mis-tap cannot discard a long run
- If a score fails to save, the results screen says so instead of failing silently
- Hungarian speech falls back gracefully: if the device has no Hungarian voice the app stays quiet and says why, rather than reading Hungarian with an English voice

## Supabase data

Questions are stored in `quiz_questions`; the original local JavaScript question banks are no longer loaded by the site. The checked-in migration and seed make the database reproducible:

- `supabase/migrations/20260721214305_initial_quiz_schema.sql`
- `supabase/migrations/20260722071433_textbook_history.sql`
- `supabase/migrations/20260722073720_textbook_history_cold_war_balance.sql`
- `supabase/migrations/20260723165822_add_time_traveler_quiz.sql`
- `supabase/migrations/20260813063547_add_history_question_expansion.sql`
- `supabase/migrations/20260813071131_add_tricky_true_false_quiz_schema.sql`
- `supabase/migrations/20260813071333_add_tricky_true_false_questions.sql`
- `supabase/migrations/20260813074229_add_tricky_true_false_sharks_question.sql`
- `supabase/migrations/20260817073140_add_psychology_quiz_schema.sql`
- `supabase/migrations/20260817073205_add_psychology_questions.sql`
- `supabase/migrations/20260917061639_merge_hungarian_history.sql`
- `supabase/migrations/20260917061640_add_hungarian_category_expansion.sql`
- `supabase/migrations/20260917062001_add_magyar_foldrajz_questions.sql`
- `supabase/migrations/20260917062002_add_foldrajz_magyarul_questions.sql`
- `supabase/migrations/20260917062003_add_magyar_irodalom_questions.sql`
- `supabase/migrations/20260917062004_add_magyar_tudomany_questions.sql`
- `supabase/migrations/20260917062005_add_magyar_nepmesek_questions.sql`
- `supabase/migrations/20260917062006_add_magyar_konyha_questions.sql`
- `supabase/migrations/20260917062007_add_magyar_zene_questions.sql`
- `supabase/migrations/20260917062008_add_regen_volt_questions.sql`
- `supabase/migrations/20260917062009_correct_psychology_questions.sql`
- `supabase/migrations/20260918070000_two_new_hungarian_categories.sql`
- `supabase/migrations/20260918070100_crime_stories_and_videos.sql`
- `supabase/migrations/20260918070200_my_best_scores.sql`
- `supabase/migrations/20260918070300_unlimited_first_metrics.sql`
- `supabase/migrations/20260918071000_crime_content.sql`
- `supabase/migrations/20260918072001_add_history_round_two.sql`
- `supabase/migrations/20260918072004_add_hungarian_round_two.sql`
- `supabase/migrations/20260918072005_add_tricky_true_false_round_two.sql`
- `supabase/migrations/20260918073000_crime_stories_replacements.sql`
- `supabase/migrations/20260918074002_add_geography_round_two.sql`
- `supabase/migrations/20260918074003_add_time_traveler_round_two.sql`
- `supabase/migrations/20260918074006_add_tobb_vagy_kevesebb_questions.sql`
- `supabase/migrations/20260918074007_add_ket_igazsag_questions.sql`
- `supabase/migrations/20260918080000_shared_best_scores.sql`
- `supabase/migrations/20260918080100_pin_metrics_timezone.sql`
- `supabase/migrations/20260918080200_fix_timezone_helper_schema.sql`
- `supabase/seed.sql`

Each question also keeps global `times_shown`, `times_answered`, and `times_correct` counters. Round selection uses gentle weighted randomness: questions with fewer views have a better chance of appearing, but no active question is excluded. A view is recorded only when the question actually reaches the screen, which keeps long Unlimited runs from counting unseen questions. `quiz_question_stats_dashboard` provides an admin-friendly view of those counters and per-question accuracy.

Completed scores are deliberately separated by quiz:

- `history_quiz_results`
- `geography_quiz_results`
- `hungarian_quiz_results`
- `textbook_history_quiz_results` (retired — see below)
- `magyar_foldrajz_quiz_results`
- `foldrajz_magyarul_quiz_results`
- `magyar_irodalom_quiz_results`
- `magyar_tudomany_quiz_results`
- `magyar_nepmesek_quiz_results`
- `magyar_konyha_quiz_results`
- `magyar_zene_quiz_results`
- `regen_volt_quiz_results`
- `tobb_vagy_kevesebb_quiz_results`
- `ket_igazsag_quiz_results`
- `time_traveler_quiz_results`
- `tricky_true_false_quiz_results`
- `psychology_quiz_results`
- `fifth_grader_quiz_results`

The retired `mixed_quiz_results` table is kept only so its historical score remains intact; no new mixed quizzes are offered. `textbook_history_quiz_results` is kept on the same terms: in September 2026 the “Tankönyvi történelem” questions were merged into `hungarian` to make one 730-question Hungarian history bank, and the category was deactivated rather than dropped so its 206 recorded rounds survive.

`quiz_metrics` contains each player’s quiz count, average percentage, best percentage, cumulative totals, latest score, and latest play time for each category. `quiz_metrics_dashboard` joins those metrics with the anonymous device ID and browser timezone for easy reading in the Supabase SQL editor. Database triggers recompute the affected metrics and synchronize `quiz_public_attempts` after every result insert, update, or delete, so dashboard totals stay aligned with the seven source result tables, including the retired mixed table retained for history.

The browser signs in with Supabase Anonymous Auth. Row Level Security allows players to read active questions, manage only their own device profile, and insert only their own score rows. Private per-player metrics and full result records are not exposed to browser users.

## Metrics dashboard

Visit `/metrics` for the dark, owner-facing activity dashboard. It leads with the
run — longest run, run-length distribution, accuracy, questions answered — plus
streaks, daily activity, timing, second-chance points, a dated leaderboard of the
ten longest runs, and the latest sessions. It always starts with a fresh database
request, refreshes every 15 seconds while visible, and refreshes immediately when
you return to a stale tab.

Ten-question rounds stopped being produced in September 2026, so the numbers that
described them — average percentage, best percentage, perfect scores, score
distribution — stopped moving. They are not deleted: the 61 standard rounds that
happened are kept whole under an **archive** section, clearly marked as historical.
Streaks, daily activity and correct-answer totals have always counted every attempt
regardless of mode and were not touched by the change.

`categories[].best_share_of_pool` is the interesting new number: how much of a
category's whole question bank her longest run got through. It is what says
"she has finished this quiz" — and therefore which bank needs more questions.

The dashboard code and database request are isolated to the `/metrics` directory. Visiting the main quiz page does not download the dashboard assets or request its statistics.

The dashboard is intentionally public. Its single aggregate request reads from `quiz_public_attempts`, a sanitized projection that contains no user IDs, device IDs, answer details, or question text. The original per-category result tables remain blocked from the public API.

## Files

- `index.html` — accessible page structure
- `style.css` — large-print light/dark design
- `app.js` — quiz flow, second chances, voice, game-show lifelines, best scores, and the crime corner
- `supabase-client.js` — anonymous identity, question loading, score recording, stats, and crime content
- `config.js` — project URL and browser-safe Supabase publishable key
- `metrics/` — dark metrics dashboard at `/metrics`
- `supabase/` — CLI config, database migration, and question seed

## Local development

Run a local static server from the repository root:

```sh
python3 -m http.server 3000 --bind 127.0.0.1
```

Then open `http://127.0.0.1:3000`.

The publishable key in `config.js` is intended for browser use. Never put a Supabase secret key or service-role key in this repository.

## Database changes

The repository is linked to the Supabase **Quiz App** project. Use the Supabase CLI migration workflow for schema changes, and keep all exposed tables protected by RLS and explicit grants. The original banks live in `supabase/seed.sql`; later reviewed question banks may live in dedicated data migrations so a reset remains reproducible.

Made with ❤️ for Mom.
