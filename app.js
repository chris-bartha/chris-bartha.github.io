/* Quiz Time! — app logic. Plain JavaScript, no dependencies. */
(function () {
  "use strict";

  var ROUND_LENGTH = 10;
  var FONT_STEPS = [100, 115, 130, 150, 175, 200]; // percent of the 22px base

  // ---------- Elements ----------
  var screens = {
    home: document.getElementById("screen-home"),
    quiz: document.getElementById("screen-quiz"),
    results: document.getElementById("screen-results")
  };
  var progressEl = document.getElementById("progress");
  var barEl = document.getElementById("progress-bar");
  var questionEl = document.getElementById("question-text");
  var optionsEl = document.getElementById("options");
  var feedbackEl = document.getElementById("feedback");
  var nextBtn = document.getElementById("next-btn");
  var quitBtn = document.getElementById("quit-btn");
  var readBtn = document.getElementById("read-btn");
  var resultEmoji = document.getElementById("result-emoji");
  var resultTitle = document.getElementById("result-title");
  var resultScore = document.getElementById("result-score");

  // ---------- State ----------
  var state = {
    category: "mix",
    round: [],       // the questions for this round
    index: 0,        // which question we are on
    score: 0,
    answered: false,
    attempts: 0,     // wrong tries on the current question (max 2)
    fontStep: 1,     // index into FONT_STEPS (default 115%)
    voiceOn: false
  };

  // ---------- Languages ----------
  // The Hungarian section runs entirely in Hungarian: text and speech.
  var STRINGS = {
    en: {
      lang: "en-US",
      progress: function (i, n, s) { return "Question " + i + " of " + n + "  •  Score: " + s; },
      option: function (i) { return "Option " + i; },
      correct: "✓ Correct! Well done.",
      correctSpoken: "Correct! Well done.",
      correct2: "✓ Correct — you got it on the second try!",
      correct2Spoken: "Correct! You got it on the second try.",
      tryAgain: "✗ Not correct — try again!",
      tryAgainSpoken: "Not correct, try again.",
      reveal: function (a) { return "✗ Not quite. The answer is: " + a; },
      revealSpoken: function (a) { return "Not quite. The answer is: " + a; },
      next: "Next question ➜",
      seeResult: "See my result ➜",
      read: "🔊 Read this question",
      quit: "Stop and go back to the menu",
      kbHint: "Tip: you can press 1, 2, 3 or 4 on your keyboard to answer.",
      again: "🔁 Play again",
      home: "🏠 Back to the menu",
      score: function (s, n) { return "You got " + s + " out of " + n + " right."; },
      titles: ["Perfect score!", "Excellent!", "Well done!", "Good effort!", "Nice try — play again!"]
    },
    hu: {
      lang: "hu-HU",
      progress: function (i, n, s) { return i + ". kérdés a " + n + "-ből  •  Pontszám: " + s; },
      option: function (i) { return i + ". válasz"; },
      correct: "✓ Helyes! Ügyes vagy!",
      correctSpoken: "Helyes! Ügyes vagy!",
      correct2: "✓ Helyes — másodikra sikerült!",
      correct2Spoken: "Helyes! Másodikra sikerült!",
      tryAgain: "✗ Nem helyes. Próbáld újra!",
      tryAgainSpoken: "Nem helyes, próbáld újra.",
      reveal: function (a) { return "✗ Sajnos nem. A helyes válasz: " + a; },
      revealSpoken: function (a) { return "Sajnos nem. A helyes válasz: " + a; },
      next: "Következő kérdés ➜",
      seeResult: "Mutasd az eredményt ➜",
      read: "🔊 Olvasd fel a kérdést",
      quit: "Megállok, vissza a menübe",
      kbHint: "Tipp: a billentyűzeten az 1, 2, 3 vagy 4 gombbal is válaszolhatsz.",
      again: "🔁 Játszom még egyszer",
      home: "🏠 Vissza a menübe",
      score: function (s, n) { return n + " kérdésből " + s + " helyes válaszod volt."; },
      titles: ["Hibátlan! Csodálatos!", "Kiváló!", "Szép munka!", "Jó próbálkozás!", "Ne add fel — próbáld újra!"]
    }
  };

  function locale() {
    return state.category === "hungarian" ? "hu" : "en";
  }
  function L() {
    return STRINGS[locale()];
  }

  function applyLocale() {
    var s = L();
    readBtn.textContent = s.read;
    quitBtn.textContent = s.quit;
    document.getElementById("kb-hint").innerHTML = s.kbHint.replace("1, 2, 3", "<strong>1, 2, 3</strong>");
    document.getElementById("again-btn").textContent = s.again;
    document.getElementById("home-btn").textContent = s.home;
    var lang = locale() === "hu" ? "hu" : "en";
    screens.quiz.setAttribute("lang", lang);
    screens.results.setAttribute("lang", lang);
  }

  // ---------- Small helpers ----------
  function shuffle(arr) {
    var a = arr.slice();
    for (var i = a.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var t = a[i]; a[i] = a[j]; a[j] = t;
    }
    return a;
  }

  function show(name) {
    Object.keys(screens).forEach(function (k) {
      screens[k].hidden = (k !== name);
    });
  }

  function save(key, value) {
    try { localStorage.setItem(key, String(value)); } catch (e) { /* ok */ }
  }
  function load(key) {
    try { return localStorage.getItem(key); } catch (e) { return null; }
  }

  // ---------- Text size ----------
  function applyFontStep() {
    document.documentElement.style.fontSize =
      (22 * FONT_STEPS[state.fontStep] / 100) + "px";
    save("quiz-font-step", state.fontStep);
  }

  document.getElementById("text-bigger").addEventListener("click", function () {
    if (state.fontStep < FONT_STEPS.length - 1) state.fontStep++;
    applyFontStep();
  });
  document.getElementById("text-smaller").addEventListener("click", function () {
    if (state.fontStep > 0) state.fontStep--;
    applyFontStep();
  });

  // ---------- Theme ----------
  var themeBtn = document.getElementById("theme-toggle");
  function applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme);
    var dark = theme === "dark";
    themeBtn.textContent = dark ? "☀️ Light" : "🌙 Dark";
    themeBtn.setAttribute("aria-pressed", String(dark));
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute("content", dark ? "#161310" : "#fffbf2");
    save("quiz-theme", theme);
  }
  themeBtn.addEventListener("click", function () {
    var current = document.documentElement.getAttribute("data-theme");
    applyTheme(current === "dark" ? "light" : "dark");
  });

  // ---------- Voice (read questions out loud) ----------
  var voiceBtn = document.getElementById("voice-toggle");
  var speechOK = "speechSynthesis" in window;

  function speak(text) {
    if (!speechOK) return;
    window.speechSynthesis.cancel();
    var u = new SpeechSynthesisUtterance(text);
    u.rate = 0.9; // a touch slower, easier to follow
    u.lang = L().lang;
    // Prefer a voice that matches the language (e.g. Hungarian)
    var voices = window.speechSynthesis.getVoices();
    for (var i = 0; i < voices.length; i++) {
      if (voices[i].lang && voices[i].lang.indexOf(locale()) === 0) {
        u.voice = voices[i];
        break;
      }
    }
    window.speechSynthesis.speak(u);
  }

  function questionSpeechText() {
    var q = state.round[state.index];
    var parts = [q.q];
    var btns = optionsEl.querySelectorAll(".option-btn:not(:disabled)");
    for (var i = 0; i < btns.length; i++) {
      parts.push(L().option(btns[i].dataset.num) + ": " + btns[i].dataset.text);
    }
    return parts.join(". ");
  }

  function applyVoice() {
    voiceBtn.textContent = state.voiceOn ? "🔊 Voice: On" : "🔊 Voice: Off";
    voiceBtn.setAttribute("aria-pressed", String(state.voiceOn));
    save("quiz-voice", state.voiceOn ? "on" : "off");
  }

  voiceBtn.addEventListener("click", function () {
    state.voiceOn = !state.voiceOn;
    applyVoice();
    if (state.voiceOn) {
      speak(screens.quiz.hidden
        ? "Voice is on. Questions will be read out loud."
        : questionSpeechText());
    } else if (speechOK) {
      window.speechSynthesis.cancel();
    }
  });

  readBtn.addEventListener("click", function () {
    speak(questionSpeechText());
  });

  if (!speechOK) {
    voiceBtn.hidden = true;
    readBtn.hidden = true;
  }

  // ---------- Quiz flow ----------
  var ALL_QUESTIONS = QUESTIONS.concat(
    typeof QUESTIONS_HU !== "undefined" ? QUESTIONS_HU : []
  );

  function poolFor(category) {
    if (category === "mix") {
      // English history + geography only; Hungarian stays its own world
      return ALL_QUESTIONS.filter(function (q) { return q.cat !== "hungarian"; });
    }
    return ALL_QUESTIONS.filter(function (q) { return q.cat === category; });
  }

  function startRound(category) {
    state.category = category;
    state.round = shuffle(poolFor(category)).slice(0, ROUND_LENGTH);
    state.index = 0;
    state.score = 0;
    applyLocale();
    barEl.innerHTML = "";
    for (var s = 0; s < state.round.length; s++) {
      barEl.appendChild(document.createElement("span"));
    }
    show("quiz");
    renderQuestion();
  }

  function updateBar(doneCount) {
    var segs = barEl.children;
    for (var i = 0; i < segs.length; i++) {
      segs[i].className = i < doneCount ? "done" : "";
    }
  }

  function renderQuestion() {
    if (speechOK) window.speechSynthesis.cancel();
    var q = state.round[state.index];
    state.answered = false;
    state.attempts = 0;
    updateBar(state.index);

    progressEl.textContent =
      L().progress(state.index + 1, state.round.length, state.score);

    questionEl.textContent = q.q;
    feedbackEl.textContent = "";
    feedbackEl.className = "feedback";
    nextBtn.hidden = true;

    var choices = shuffle([q.a].concat(q.w));
    optionsEl.innerHTML = "";
    choices.forEach(function (text, i) {
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "option-btn";
      btn.dataset.text = text;
      btn.dataset.num = String(i + 1);

      var badge = document.createElement("span");
      badge.className = "option-badge";
      badge.setAttribute("aria-hidden", "true");
      badge.textContent = String(i + 1);
      btn.appendChild(badge);

      var label = document.createElement("span");
      label.textContent = text;
      btn.appendChild(label);

      btn.setAttribute("aria-label", L().option(i + 1) + ": " + text);
      btn.addEventListener("click", function () { answer(btn, text === q.a); });
      optionsEl.appendChild(btn);
    });

    questionEl.focus();
    if (state.voiceOn) speak(questionSpeechText());
  }

  function finishQuestion(chosenWrongBtn) {
    // Reveal the correct answer, lock every button
    var q = state.round[state.index];
    var btns = optionsEl.querySelectorAll(".option-btn");
    for (var i = 0; i < btns.length; i++) {
      var b = btns[i];
      var badge = b.querySelector(".option-badge");
      if (b.dataset.text === q.a) {
        b.classList.add("is-correct");
        b.classList.remove("is-faded");
        badge.textContent = "✓";
      } else if (b === chosenWrongBtn) {
        b.classList.add("is-wrong");
        badge.textContent = "✗";
      } else if (!b.classList.contains("is-wrong")) {
        b.classList.add("is-faded");
      }
      b.disabled = true;
    }
    updateBar(state.index + 1);
    state.answered = true;

    progressEl.textContent =
      L().progress(state.index + 1, state.round.length, state.score);

    var last = state.index === state.round.length - 1;
    nextBtn.textContent = last ? L().seeResult : L().next;
    nextBtn.hidden = false;
    nextBtn.focus();
  }

  function answer(chosenBtn, isRight) {
    if (state.answered || chosenBtn.disabled) return;
    var s = L();

    if (isRight) {
      var secondTry = state.attempts > 0;
      state.score++;
      feedbackEl.textContent = secondTry ? s.correct2 : s.correct;
      feedbackEl.className = "feedback good";
      finishQuestion(null);
      if (state.voiceOn) speak(secondTry ? s.correct2Spoken : s.correctSpoken);
      return;
    }

    state.attempts++;
    if (state.attempts === 1) {
      // Second chance: cross out the wrong pick and let her try again
      chosenBtn.disabled = true;
      chosenBtn.classList.add("is-wrong");
      chosenBtn.querySelector(".option-badge").textContent = "✗";
      feedbackEl.textContent = s.tryAgain;
      feedbackEl.className = "feedback bad";
      speak(s.tryAgainSpoken);
      return;
    }

    // Second miss: show the answer and move on
    var q = state.round[state.index];
    feedbackEl.textContent = s.reveal(q.a);
    feedbackEl.className = "feedback bad";
    finishQuestion(chosenBtn);
    if (state.voiceOn) speak(s.revealSpoken(q.a));
  }

  nextBtn.addEventListener("click", function () {
    if (state.index < state.round.length - 1) {
      state.index++;
      renderQuestion();
    } else {
      showResults();
    }
  });

  quitBtn.addEventListener("click", function () {
    if (speechOK) window.speechSynthesis.cancel();
    show("home");
  });

  function showResults() {
    var total = state.round.length;
    var s = state.score;
    var t = L();
    var emoji, title;
    if (s === total)           { emoji = "🌟🌟🌟"; title = t.titles[0]; }
    else if (s >= total * 0.8) { emoji = "🎉";  title = t.titles[1]; }
    else if (s >= total * 0.6) { emoji = "😊";  title = t.titles[2]; }
    else if (s >= total * 0.4) { emoji = "👍";  title = t.titles[3]; }
    else                       { emoji = "💪";  title = t.titles[4]; }

    resultEmoji.textContent = emoji;
    resultTitle.textContent = title;
    resultScore.textContent = t.score(s, total);
    show("results");
    resultTitle.focus();
    if (state.voiceOn) {
      speak(title + " " + t.score(s, total));
    }
  }

  document.getElementById("again-btn").addEventListener("click", function () {
    startRound(state.category);
  });
  document.getElementById("home-btn").addEventListener("click", function () {
    show("home");
  });

  // Menu buttons
  var menuBtns = document.querySelectorAll(".menu-btn");
  for (var m = 0; m < menuBtns.length; m++) {
    (function (btn) {
      btn.addEventListener("click", function () {
        startRound(btn.dataset.category);
      });
    })(menuBtns[m]);
  }

  // Keyboard: 1–4 picks an answer while the quiz is showing
  document.addEventListener("keydown", function (e) {
    if (screens.quiz.hidden || state.answered) return;
    var n = parseInt(e.key, 10);
    if (n >= 1 && n <= 4) {
      var btns = optionsEl.querySelectorAll(".option-btn");
      if (btns[n - 1]) btns[n - 1].click();
    }
  });

  // ---------- Restore saved settings and start ----------
  var savedStep = parseInt(load("quiz-font-step"), 10);
  if (!isNaN(savedStep) && savedStep >= 0 && savedStep < FONT_STEPS.length) {
    state.fontStep = savedStep;
  }
  applyFontStep();

  var savedTheme = load("quiz-theme");
  applyTheme(savedTheme === "dark" ? "dark" : "light");

  state.voiceOn = load("quiz-voice") === "on";
  applyVoice();

  show("home");
})();
