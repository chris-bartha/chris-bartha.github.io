# 🧠 Quiz Time!

A friendly, easy-to-read quiz game with **1,200 questions**:
400 History, 400 Geography, and 400 **Történelem magyarul** — a section
entirely in Hungarian (text and speech), mixing Hungarian history with
great world events.

Built for low-vision readers: big text with A−/A+ size controls, high contrast,
dark mode, huge buttons, keyboard shortcuts (press 1–4 to answer), and an
optional voice that reads questions out loud (Hungarian questions get a
Hungarian voice). A wrong answer earns a **second chance** — the voice says
"Not correct, try again" (or "Nem helyes, próbáld újra") and the wrong choice
is crossed out; only after a second miss is the answer revealed.

Plain HTML/CSS/JavaScript — no build step, no dependencies.

## Files

- `index.html` — the page
- `style.css` — styling (light + dark themes)
- `app.js` — quiz logic and accessibility settings
- `questions.js` — the English question bank
- `questions-hu.js` — the Hungarian question bank

## Put it on GitHub Pages

1. Create a new repository on GitHub (e.g. `quiz`).
2. Upload these four files (or push them with git):
   ```
   git init
   git add .
   git commit -m "Quiz Time!"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/quiz.git
   git push -u origin main
   ```
3. On GitHub, open the repo → **Settings** → **Pages**.
4. Under **Source**, choose **Deploy from a branch**, pick `main` and `/ (root)`, then **Save**.
5. After a minute, the quiz will be live at
   `https://YOUR-USERNAME.github.io/quiz/`

## Adding questions

Open `questions.js` and add a line like this anywhere in the list:

```js
H("Your history question?", "Correct answer", "Wrong 1", "Wrong 2", "Wrong 3"),
G("Your geography question?", "Correct answer", "Wrong 1", "Wrong 2", "Wrong 3"),
```

The correct answer always goes **first** — the app shuffles the choices
automatically every time.
