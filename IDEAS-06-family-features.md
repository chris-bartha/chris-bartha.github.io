# The family & motivation layer

Produced 2026-09-16.

**Status key:** ✅ done · 🔍 decide later · ⬜ not started

---

## Three findings that shape everything

1. **She has played all 58 days since launch. Zero misses.** 31,331 questions
   answered, 30,093 correct (**96.0%**). Biggest day: **1,677 on 2026-08-15**.
   147.8 hours — over six full days of her life in eight weeks.
2. **The 430 was not a fluke — she has gone perfect 430/430 ten times**
   (six Hungarian, four History). Also 275/275 Time Traveler and a **122-question
   Tricky True or False run** under sudden death. **She almost certainly knows none
   of this.**
3. **`quiz_public_attempts` has no `user_id` and there are already 13 anonymous
   player rows.** Her identity has held — one uid holds 31,005 of 31,331 questions
   — but the moment a second family member plays, their rounds blend into
   `/metrics` as if they were hers. **Fix attribution before building any
   head-to-head.**

Existing hooks worth reusing: `#question-meta` is already in the DOM and hidden;
`detectSessionInUrl: false` means custom URL params are free; and
`record_question_views` is an existing precedent for "do a privileged thing
without exposing the table".

---

## ⬜ The one that matters most: ⭐ Your best scores

One new button at the bottom of the home screen. Real copy, written for an ESL
reader:

> **Your best scores**
>
> You have answered **31,331 questions**. You got **30,093 right**.
> That is **96 out of every 100**.
>
> **Your longest runs**
> 🏛️ History — **430 questions, all correct.** August 12.
> 🇭🇺 Történelem magyarul — **430 questions, all correct.** July 29.
> 🕰️ Time Traveler — **275 questions, all correct.**
> 🤔 Tricky True or False — **122 in a row.** Only one try is allowed here.
>
> **Your biggest day**
> August 15. You answered **1,677 questions** in one day.
>
> You have played on **58 days**.

One `security definer` RPC filtered on `auth.uid()`. Zero new public exposure —
the safest idea in this document. Half a day's work.

**Why this one:** she has answered 31,331 questions, gone perfect through an entire
bank ten times, and played every single day the app has existed — and the only
place any of that is visible is a dark dashboard designed for you. That asymmetry
is the actual problem in this project. Everything else here is a new loop to
maintain; this one just stops hiding what she already did.

---

## ⬜ The rest, ranked

### 👪 Family Slots — the keystone primitive
Not a feature she sees; the thing that makes six others possible. A
`family_members(slot, display_name, claim_token, claimed_user_id)` table you
populate by hand in SQL. You text a `?join=MOM` link once per person; on load the
app calls `claim_family_slot(token)`, binds `auth.uid()` to the slot, and strips
the param with `history.replaceState`. **One tap, no typing, no friend list to
manage.** Re-tapping a claimed slot from the same uid is a no-op, so a re-sent link
is harmless.

Keep the slot **out** of `quiz_public_attempts` — add a separate narrow view for
the dashboard instead, or gate it behind an RPC. No uids, no device ids.

### 💌 A note from Chris + 👀 "Chris looked at your scores today"
Two hours of work together, and they make the app feel inhabited.

The note is one row and one SQL update, shown above the menu at full type size:
*"Chris says: Good morning. I saw your 122 yesterday. 🤯"* Highest warmth-to-effort
ratio in the document — and the easiest to let go stale, which then reads as
neglect. Only build it if you'll actually write in it.

The watch line is ~20 lines: visiting `/metrics` writes a timestamp, her home
screen reads the latest. I expected this to read as surveillance and it doesn't —
it *discloses* the watching, which is the honest move. It says someone is paying
attention without asking her to respond.

### 🤝 Same Questions, Both of Us
The real async head-to-head. **Critically: not a 10-question round** — she's played
1,219 Unlimited runs and 25 standard ones, so comparing 10 questions compares a
mode she doesn't play.

A card above the menu: *"Chris played History today. He reached **34**. Your turn."*
She taps and plays the same category with the **same shuffled order**, sudden death
as always. Afterwards: *"You reached **122**. Chris reached **34**."* No word "won",
no trophy.

Mechanism: `daily_order(date, category_id, question_ids[])`, generated lazily by an
RPC on the day's first request using a date-seeded shuffle. The date is the shared
key — no session, no invite, no pairing. You will usually lose by 10×. Say so
plainly and let that be the joke.

### 🎯 A challenge from Chris
*"Chris says: I do not think you can get 20 Geography questions in a row. 🌍"* One
button: **Try it**. A row in `challenges(id uuid, from_slot, category, target,
message, expires_at)` and you text `?ch=<uuid>` — the uuid *is* the secret. Stored
in `localStorage` so the card survives closing the tab.

Word it literally: "I bet you can't" is idiomatic. Prefer *"Chris thinks 20 in a
row is too hard. Show him."*

### 📣 Upgraded share
The current message omits the only thing that makes a run remarkable. On a run that
beats her previous best, show **one additional** button: *"📣 Tell Chris about my
new record"* → *"I answered 122 Tricky True or False questions in a row. That is my
best ever. Only one try is allowed in this quiz. 😈"* It appears only when
deserved, so it never nags.

### 👨‍👩‍👧 Family Trivia (🏡 Our family)
Questions about her own family, written as a normal migration — grandchildren
dictate, you type. **This one genuinely needs a gate:** grandchildren's birthdays
must not be public on an open site. An RLS predicate on `quiz_questions`
(`category_id <> 'family' or is_family_member(auth.uid())`) does it cleanly, and
Family Slots provides `is_family_member`.

Worst content economics on the list — 50 questions is exhausted in a day. Ship it
small and *say* so: *"New family questions are added sometimes."*

### ✍️ "Chris wrote this one"
One line above the prompt in the existing `#question-meta` element, which is
already in the DOM and already styled. Tiny change, and a person appears mid-quiz.
Fine for "Chris"; **not** for a grandchild's name unless the question is
family-gated.

### 🎓 Grandchildren vs Grandma
After a Fifth Grader round: *"Lily played the same questions. Lily got 7. You got
9."* The best cross-generational fit in the app, because Fifth Grader is the one
category where a child is genuinely competitive. **Never rank** — show both
numbers, no ordering, no winner line.

### 🏅 Printable certificate · 📅 Your month · 🎄 Your year
All cheap once the records screen exists. The certificate is a `@media print` block
— and it matters because it converts a private number into something she can hand
to a person.

### 🔔 You get pinged on a record
A Supabase DB webhook → edge function → push. Good *for you* — and it converts into
warmth for her only if you then text her. The value is entirely downstream of your
reply.

---

## Don't build

- **A consecutive-day streak with a "keep it going" prompt.** She's at 58/58. A
  cumulative total only ever goes up; a streak is a number that one bad week
  destroys, and at some point she *will* be ill. Showing her a streak now means
  eventually showing her a 1 next to the memory of 58. **Show the total, never the
  streak, never a warning.**
- **Live presence ("Chris is online now") or auto-posting her scores to a family
  chat.** The first creates an obligation to interact — she plays until 2am, when
  nobody is there. The second removes her decision about whether to share. Both
  trade her agency for your visibility.
- **Any public leaderboard, or a head-to-head framed as winner/loser.** Her numbers
  are extraordinary; ranking her against strangers is noise, and ranking her
  against you produces either a hollow win or a bruise.

---

## Wording notes (ESL, low vision)

**Use:** short sentences, one idea each. Digits, not words — "430", not "four
hundred and thirty". Full verbs — "You have played", not "You've played". Plain
verbs — "got right", "answered", "reached". Plain dates — "August 12". Literal
rules — "Only one try is allowed here."

**Avoid:** idioms and sports slang — *crushed it, on fire, nailed it, keep it up,
you're on a roll, beat your PB*. Jargon — *stats, metrics, wrapped, recap,
leaderboard, unlocked, achievement*. Praise aimed at age or ability — *amazing
job!, good for you, impressive for…* — she is genuinely excellent and the numbers
say it without help. Duty-implying imperatives — *don't miss a day, come back
tomorrow*.

And never let a number be the only signal: pair every record with the word that
explains it (**"430 questions, all correct"**), the same way answer states pair
colour with ✓/✗ and words.

**Language note:** the UI already switches to Hungarian via `locale()`. Every
string above needs a Hungarian twin in `STRINGS.hu`, or the records screen becomes
the only English-only surface in a bilingual app. Worth deciding whether it should
be Hungarian *always* — it is the most personal screen in the product, and she
reads Hungarian first.
