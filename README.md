# 🧠 Quiz Time!

An accessible, large-print quiz game made for Mom. The app now loads its question library from Supabase and silently keeps the same anonymous player identity in the browser—there is no name or login form.

## Quiz library

The Supabase database contains **1,650 unique questions**:

- 430 History questions
- 415 Geography questions
- 430 Hungarian-language history questions
- 300 Hungarian “Tankönyvi történelem” questions inspired by the school curriculum encountered by students born around 1964
- 75 “Are You Smarter Than a Fifth Grader?” questions, with 15 questions at each grade level

The fifth-grade challenge asks two questions from each grade, in order from Grade 1 through Grade 5. It simulates the show’s three classmate helps:

- **Peek** reveals the simulated classmate’s answer while leaving the player free to choose.
- **Copy** commits to the simulated classmate’s answer.
- **Save** is automatic after a wrong answer and succeeds only when the simulated classmate is right.

History, Geography, Mixed, Hungarian, and Textbook History quizzes keep the friendly second-chance rule from the original app.

## Unlimited Mode

The large **Unlimited Mode** control on the quiz menu turns History, Geography, Mixed, Hungarian, and Textbook History into sudden-death runs. Questions continue through the weighted category library until one question is answered incorrectly twice. The second chance remains available, and Fifth Grader is visibly unavailable until Unlimited Mode is turned off again.

Unlimited results are stored in the same per-category result tables with `is_unlimited = true`; every result created before this feature is marked `false`. Standard quiz counts, averages, perfect scores, category performance, and score distribution remain standard-only. Daily activity, streaks, correct-answer totals, and second-chance totals include both modes. Unlimited runs also have separate counts, category records, and a dated top-three leaderboard.

## Accessibility

- Atkinson Hyperlegible with full Hungarian character support
- Large type and large click targets
- A−/A+ text scaling
- Light and dark themes
- Optional English or Hungarian speech
- Keyboard shortcuts 1–4 for answer choices
- High contrast, strong focus rings, and answer states that do not rely on color alone
- No required typing or recurring sign-in
- A large results-only share button that prepares a plain-text score message

## Supabase data

Questions are stored in `quiz_questions`; the original local JavaScript question banks are no longer loaded by the site. The checked-in migration and seed make the database reproducible:

- `supabase/migrations/20260721214305_initial_quiz_schema.sql`
- `supabase/migrations/20260722071433_textbook_history.sql`
- `supabase/migrations/20260722073720_textbook_history_cold_war_balance.sql`
- `supabase/seed.sql`

Each question also keeps global `times_shown`, `times_answered`, and `times_correct` counters. Round selection uses gentle weighted randomness: questions with fewer views have a better chance of appearing, but no active question is excluded. A view is recorded only when the question actually reaches the screen, which keeps long Unlimited runs from counting unseen questions. `quiz_question_stats_dashboard` provides an admin-friendly view of those counters and per-question accuracy.

Completed scores are deliberately separated by quiz:

- `history_quiz_results`
- `geography_quiz_results`
- `mixed_quiz_results`
- `hungarian_quiz_results`
- `textbook_history_quiz_results`
- `fifth_grader_quiz_results`

`quiz_metrics` contains each player’s quiz count, average percentage, best percentage, cumulative totals, latest score, and latest play time for each category. `quiz_metrics_dashboard` joins those metrics with the anonymous device ID and browser timezone for easy reading in the Supabase SQL editor. Database triggers recompute the affected metrics and synchronize `quiz_public_attempts` after every result insert, update, or delete, so dashboard totals stay aligned with the six source result tables.

The browser signs in with Supabase Anonymous Auth. Row Level Security allows players to read active questions, manage only their own device profile, and insert only their own score rows. Private per-player metrics and full result records are not exposed to browser users.

## Metrics dashboard

Visit `/metrics` for the dark, owner-facing activity dashboard. It shows standard quiz performance, combined daily activity, streaks, timing, second-chance points, separate Unlimited Mode records, a dated top-three leaderboard, a 30-day standard/Unlimited activity graph, and the latest sessions. It always starts with a fresh database request, refreshes every 15 seconds while visible, and refreshes immediately when you return to a stale tab.

The dashboard code and database request are isolated to the `/metrics` directory. Visiting the main quiz page does not download the dashboard assets or request its statistics.

The dashboard is intentionally public. Its single aggregate request reads from `quiz_public_attempts`, a sanitized projection that contains no user IDs, device IDs, answer details, or question text. The original per-category result tables remain blocked from the public API.

## Files

- `index.html` — accessible page structure
- `style.css` — large-print light/dark design
- `app.js` — quiz flow, second chances, voice, and game-show lifelines
- `supabase-client.js` — anonymous identity, question loading, and score recording
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
