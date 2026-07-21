# 🧠 Quiz Time!

An accessible, large-print quiz game made for Mom. The app now loads its question library from Supabase and silently keeps the same anonymous player identity in the browser—there is no name or login form.

## Quiz library

The Supabase database contains **1,350 unique questions**:

- 430 History questions
- 415 Geography questions
- 430 Hungarian-language history questions
- 75 “Are You Smarter Than a Fifth Grader?” questions, with 15 questions at each grade level

The fifth-grade challenge asks two questions from each grade, in order from Grade 1 through Grade 5. It simulates the show’s three classmate helps:

- **Peek** reveals the simulated classmate’s answer while leaving the player free to choose.
- **Copy** commits to the simulated classmate’s answer.
- **Save** is automatic after a wrong answer and succeeds only when the simulated classmate is right.

History, Geography, Mixed, and Hungarian quizzes keep the friendly second-chance rule from the original app.

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
- `supabase/seed.sql`

Each question also keeps global `times_shown`, `times_answered`, and `times_correct` counters. Round selection uses gentle weighted randomness: questions with fewer views have a better chance of appearing, but no active question is excluded. `quiz_question_stats_dashboard` provides an admin-friendly view of those counters and per-question accuracy.

Completed scores are deliberately separated by quiz:

- `history_quiz_results`
- `geography_quiz_results`
- `mixed_quiz_results`
- `hungarian_quiz_results`
- `fifth_grader_quiz_results`

`quiz_metrics` contains each player’s quiz count, average percentage, best percentage, cumulative totals, latest score, and latest play time for each category. `quiz_metrics_dashboard` joins those metrics with the anonymous device ID and browser timezone for easy reading in the Supabase SQL editor.

The browser signs in with Supabase Anonymous Auth. Row Level Security allows players to read active questions, manage only their own device profile, and insert only their own score rows. Private per-player metrics and full result records are not exposed to browser users.

## Metrics dashboard

Visit `/metrics` for the dark, owner-facing activity dashboard. It shows all-time and daily totals, category performance, score distribution, streaks, timing, second-chance points, a 30-day activity graph, and the latest sessions. The dashboard keeps a small local snapshot so it can paint immediately on repeat visits, then refreshes once in the background.

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

The repository is linked to the Supabase **Quiz App** project. Use the Supabase CLI migration workflow for schema changes, and keep all exposed tables protected by RLS and explicit grants. Add or edit question content in `supabase/seed.sql`, then apply it with the project’s reviewed database workflow.

Made with ❤️ for Mom.
