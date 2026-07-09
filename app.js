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
    fontStep: 1,     // index into FONT_STEPS (default 115%)
    voiceOn: false
  };

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
    window.speechSynthesis.speak(u);
  }

  function questionSpeechText() {
    var q = state.round[state.index];
    var parts = [q.q];
    var btns = optionsEl.querySelectorAll(".option-btn");
    for (var i = 0; i < btns.length; i++) {
      parts.push("Option " + (i + 1) + ": " + btns[i].dataset.text);
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
  function poolFor(category) {
    if (category === "mix") return QUESTIONS;
    return QUESTIONS.filter(function (q) { return q.cat === category; });
  }

  function startRound(category) {
    state.category = category;
    state.round = shuffle(poolFor(category)).slice(0, ROUND_LENGTH);
    state.index = 0;
    state.score = 0;
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
    updateBar(state.index);

    progressEl.textContent =
      "Question " + (state.index + 1) + " of " + state.round.length +
      "  •  Score: " + state.score;

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

      var badge = document.createElement("span");
      badge.className = "option-badge";
      badge.setAttribute("aria-hidden", "true");
      badge.textContent = String(i + 1);
      btn.appendChild(badge);

      var label = document.createElement("span");
      label.textContent = text;
      btn.appendChild(label);

      btn.setAttribute("aria-label", "Option " + (i + 1) + ": " + text);
      btn.addEventListener("click", function () { answer(btn, text === q.a); });
      optionsEl.appendChild(btn);
    });

    questionEl.focus();
    if (state.voiceOn) speak(questionSpeechText());
  }

  function answer(chosenBtn, isRight) {
    if (state.answered) return;
    state.answered = true;

    var q = state.round[state.index];
    var btns = optionsEl.querySelectorAll(".option-btn");
    for (var i = 0; i < btns.length; i++) {
      var b = btns[i];
      b.disabled = true;
      var badge = b.querySelector(".option-badge");
      if (b.dataset.text === q.a) {
        b.classList.add("is-correct");
        badge.textContent = "✓";
      } else if (b === chosenBtn) {
        b.classList.add("is-wrong");
        badge.textContent = "✗";
      } else {
        b.classList.add("is-faded");
      }
    }
    updateBar(state.index + 1);

    var spoken;
    if (isRight) {
      state.score++;
      feedbackEl.textContent = "✓ Correct! Well done.";
      feedbackEl.className = "feedback good";
      spoken = "Correct! Well done.";
    } else {
      feedbackEl.textContent = "✗ Not quite. The answer is: " + q.a;
      feedbackEl.className = "feedback bad";
      spoken = "Not quite. The answer is: " + q.a;
    }

    progressEl.textContent =
      "Question " + (state.index + 1) + " of " + state.round.length +
      "  •  Score: " + state.score;

    var last = state.index === state.round.length - 1;
    nextBtn.textContent = last ? "See my result ➜" : "Next question ➜";
    nextBtn.hidden = false;
    nextBtn.focus();

    if (state.voiceOn) speak(spoken);
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
    var emoji, title;
    if (s === total)      { emoji = "🌟🌟🌟"; title = "Perfect score!"; }
    else if (s >= total * 0.8) { emoji = "🎉";  title = "Excellent!"; }
    else if (s >= total * 0.6) { emoji = "😊";  title = "Well done!"; }
    else if (s >= total * 0.4) { emoji = "👍";  title = "Good effort!"; }
    else                  { emoji = "💪";  title = "Nice try — play again!"; }

    resultEmoji.textContent = emoji;
    resultTitle.textContent = title;
    resultScore.textContent = "You got " + s + " out of " + total + " right.";
    show("results");
    resultTitle.focus();
    if (state.voiceOn) {
      speak(title + " You got " + s + " out of " + total + " right.");
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
