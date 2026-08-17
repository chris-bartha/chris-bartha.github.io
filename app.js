/* Quiz Time! — accessible quiz flow, fifth-grade challenge, and score capture. */
(function () {
  "use strict";

  var ROUND_LENGTH = 10;
  var FONT_STEPS = [100, 115, 130, 150, 175, 200];
  var FIFTH_PRIZES = [
    "$1,000", "$2,000", "$5,000", "$10,000", "$25,000",
    "$50,000", "$100,000", "$175,000", "$300,000", "$1,000,000"
  ];
  var CATEGORY_NAMES = {
    history: "History",
    geography: "Geography",
    hungarian: "History in Hungarian",
    textbook_history: "Tankönyvi történelem",
    time_traveler: "Time Traveler",
    tricky_true_false: "Tricky True or False",
    psychology: "Psychology",
    fifth_grader: "Are You Smarter Than a Fifth Grader?"
  };

  /* True/false rounds offer two choices, so a second chance would simply hand
     over the answer. These categories get one attempt per question instead. */
  var TRUE_FALSE_CATEGORIES = { tricky_true_false: true };

  var screens = {
    loading: document.getElementById("screen-loading"),
    error: document.getElementById("screen-error"),
    home: document.getElementById("screen-home"),
    quiz: document.getElementById("screen-quiz"),
    results: document.getElementById("screen-results")
  };
  var progressEl = document.getElementById("progress");
  var barEl = document.getElementById("progress-bar");
  var questionMetaEl = document.getElementById("question-meta");
  var questionEl = document.getElementById("question-text");
  var questionCardEl = questionEl.parentElement;
  var optionsEl = document.getElementById("options");
  var feedbackEl = document.getElementById("feedback");
  var nextBtn = document.getElementById("next-btn");
  var quitBtn = document.getElementById("quit-btn");
  var readBtn = document.getElementById("read-btn");
  var resultEmoji = document.getElementById("result-emoji");
  var resultTitle = document.getElementById("result-title");
  var resultScore = document.getElementById("result-score");
  var shareBtn = document.getElementById("share-btn");
  var shareStatusEl = document.getElementById("share-status");
  var errorMessageEl = document.getElementById("error-message");
  var fifthHelpEl = document.getElementById("fifth-help");
  var peekBtn = document.getElementById("peek-btn");
  var copyBtn = document.getElementById("copy-btn");
  var saveIndicator = document.getElementById("save-indicator");
  var helpStatusEl = document.getElementById("help-status");
  var menuBtns = document.querySelectorAll(".menu-btn");
  var unlimitedToggle = document.getElementById("unlimited-toggle");
  var unlimitedToggleState = document.getElementById("unlimited-toggle-state");
  var unlimitedToggleDescription = document.getElementById("unlimited-toggle-description");
  var fifthMenuBtn = document.querySelector('.menu-btn[data-category="fifth_grader"]');
  var fifthMenuDescription = document.getElementById("fifth-menu-description");
  var trickyMenuDescription = document.getElementById("tricky-menu-description");

  var state = {
    category: "textbook_history",
    round: [],
    index: 0,
    score: 0,
    firstTryCorrect: 0,
    secondTryCorrect: 0,
    answered: false,
    attempts: 0,
    currentSelections: [],
    answers: [],
    startedAt: null,
    fontStep: 1,
    voiceOn: false,
    loading: false,
    unlimited: false,
    unlimitedEnded: false,
    classmateAnswer: null,
    answerViaCopy: false,
    lifelines: {
      peek: false,
      copy: false,
      save: false,
      saveSucceeded: false
    }
  };

  var STRINGS = {
    en: {
      lang: "en-US",
      progress: function (i, n, score) {
        return "Question " + i + " of " + n + "  •  Score: " + score;
      },
      option: function (i) { return "Option " + i; },
      correct: "✓ Correct! Well done.",
      correctSpoken: "Correct! Well done.",
      correct2: "✓ Correct — you got it on the second try!",
      correct2Spoken: "Correct! You got it on the second try.",
      tryAgain: "✗ Not correct — try again!",
      tryAgainSpoken: "Not correct, try again.",
      reveal: function (answer) { return "✗ Not quite. The answer is: " + answer; },
      revealSpoken: function (answer) { return "Not quite. The answer is: " + answer; },
      next: "Next question ➜",
      seeResult: "See my result ➜",
      read: "🔊 Read this question",
      quit: "Stop and go back to the menu",
      kbHint: "Tip: you can press <strong>1, 2, 3 or 4</strong> on your keyboard to answer.",
      kbHintTwo: "Tip: you can press <strong>1 or 2</strong> on your keyboard to answer.",
      singleAttemptMeta: "⚠️ One try only — no second chances",
      unlimitedSingleAttemptMeta: "😈 Unlimited Mode — one try each, a single miss ends the run",
      shareNoSecondChances: "One try per question — no second chances.",
      again: "🔁 Play again",
      home: "🏠 Back to the menu",
      share: "💬 Text my score",
      shareHelp: "Opens your sharing menu with a ready-to-send message.",
      shareReady: "Your score is ready to send.",
      score: function (score, total) { return "You got " + score + " out of " + total + " right."; },
      unlimitedProgress: function (i, score) {
        return "Unlimited Mode  •  Question " + i + "  •  Score: " + score;
      },
      unlimitedMeta: "😈 Unlimited Mode — a second miss ends the run",
      unlimitedReveal: function (answer) {
        return "😈 That ends this Unlimited run. The answer is: " + answer;
      },
      unlimitedRevealSpoken: function (answer) {
        return "That ends this Unlimited run. The answer is " + answer;
      },
      unlimitedSeeResult: "See my Unlimited score ➜",
      unlimitedScore: function (score, attempted, cleared) {
        if (cleared) return "Amazing — you cleared every question with " + score + " correct!";
        return "You answered " + score + " correctly before the run ended. " +
          attempted + (attempted === 1 ? " question" : " questions") + " attempted.";
      },
      titles: ["Perfect score!", "Excellent!", "Well done!", "Good effort!", "Nice try — play again!"]
    },
    hu: {
      lang: "hu-HU",
      progress: function (i, n, score) {
        return i + ". kérdés a " + n + "-ből  •  Pontszám: " + score;
      },
      option: function (i) { return i + ". válasz"; },
      correct: "✓ Helyes! Ügyes vagy!",
      correctSpoken: "Helyes! Ügyes vagy!",
      correct2: "✓ Helyes — másodikra sikerült!",
      correct2Spoken: "Helyes! Másodikra sikerült!",
      tryAgain: "✗ Nem helyes. Próbáld újra!",
      tryAgainSpoken: "Nem helyes, próbáld újra.",
      reveal: function (answer) { return "✗ Sajnos nem. A helyes válasz: " + answer; },
      revealSpoken: function (answer) { return "Sajnos nem. A helyes válasz: " + answer; },
      next: "Következő kérdés ➜",
      seeResult: "Mutasd az eredményt ➜",
      read: "🔊 Olvasd fel a kérdést",
      quit: "Megállok, vissza a menübe",
      kbHint: "Tipp: a billentyűzeten az <strong>1, 2, 3 vagy 4</strong> gombbal is válaszolhatsz.",
      kbHintTwo: "Tipp: a billentyűzeten az <strong>1 vagy 2</strong> gombbal is válaszolhatsz.",
      singleAttemptMeta: "⚠️ Csak egy próbálkozás — nincs második esély",
      unlimitedSingleAttemptMeta: "😈 Korlátlan mód — egy próbálkozás, egyetlen hiba véget vet a játéknak",
      shareNoSecondChances: "Egy próbálkozás kérdésenként — nincs második esély.",
      again: "🔁 Játszom még egyszer",
      home: "🏠 Vissza a menübe",
      share: "💬 Elküldöm az eredményt",
      shareHelp: "Megnyitja a megosztást egy elkészített üzenettel.",
      shareReady: "Az üzenet elkészült.",
      score: function (score, total) { return total + " kérdésből " + score + " helyes válaszod volt."; },
      unlimitedProgress: function (i, score) {
        return "Korlátlan mód  •  " + i + ". kérdés  •  Pontszám: " + score;
      },
      unlimitedMeta: "😈 Korlátlan mód — a második hibás válasz véget vet a játéknak",
      unlimitedReveal: function (answer) {
        return "😈 A korlátlan játéknak vége. A helyes válasz: " + answer;
      },
      unlimitedRevealSpoken: function (answer) {
        return "A korlátlan játéknak vége. A helyes válasz " + answer;
      },
      unlimitedSeeResult: "Mutasd a korlátlan eredményt ➜",
      unlimitedScore: function (score, attempted, cleared) {
        if (cleared) return "Csodálatos — minden kérdésre helyesen válaszoltál! Pontszám: " + score + ".";
        return score + " helyes válaszod volt, mielőtt a játék véget ért. Megválaszolt kérdések: " + attempted + ".";
      },
      titles: ["Hibátlan! Csodálatos!", "Kiváló!", "Szép munka!", "Jó próbálkozás!", "Ne add fel — próbáld újra!"]
    }
  };

  function locale() {
    return state.category === "hungarian" || state.category === "textbook_history" ? "hu" : "en";
  }

  function isTrueFalse() {
    return Boolean(TRUE_FALSE_CATEGORIES[state.category]);
  }

  function L() {
    return STRINGS[locale()];
  }

  function shuffle(items) {
    var copy = items.slice();
    for (var i = copy.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var temporary = copy[i];
      copy[i] = copy[j];
      copy[j] = temporary;
    }
    return copy;
  }

  /* Weighted sampling without replacement. Every question remains eligible,
     while a question with fewer global views receives a larger lottery weight. */
  function weightedSample(items, count) {
    return items.map(function (question) {
      var views = Math.max(question.timesShown || 0, question.timesAnswered || 0);
      var weight = 1 / Math.sqrt(1 + views);
      var random = Math.max(Math.random(), Number.MIN_VALUE);
      return {
        question: question,
        lotteryKey: -Math.log(random) / weight
      };
    }).sort(function (left, right) {
      return left.lotteryKey - right.lotteryKey;
    }).slice(0, count).map(function (entry) {
      return entry.question;
    });
  }

  function show(name) {
    Object.keys(screens).forEach(function (key) {
      screens[key].hidden = key !== name;
    });
  }

  function save(key, value) {
    try { localStorage.setItem(key, String(value)); } catch (error) { /* Optional preference. */ }
  }

  function load(key) {
    try { return localStorage.getItem(key); } catch (error) { return null; }
  }

  function setMenuBusy(busy) {
    for (var i = 0; i < menuBtns.length; i++) {
      var unavailable = state.unlimited && menuBtns[i].dataset.category === "fifth_grader";
      menuBtns[i].disabled = busy || unavailable;
      menuBtns[i].classList.toggle("mode-unavailable", unavailable);
    }
  }

  function applyUnlimitedMode(enabled) {
    state.unlimited = Boolean(enabled);
    state.unlimitedEnded = false;
    unlimitedToggle.setAttribute("aria-pressed", String(state.unlimited));
    unlimitedToggleState.textContent = state.unlimited ? "On" : "Off";
    unlimitedToggleDescription.textContent = state.unlimited
      ? "Keep going until one question is missed twice. Second chances stay on."
      : "Tap to keep playing until one question is missed twice.";
    fifthMenuDescription.textContent = state.unlimited
      ? "Unavailable in Unlimited Mode — turn it off to play"
      : "Climb from Grade 1 to Grade 5 with Peek, Copy, and Save";
    /* This quiz never had second chances, so in Unlimited Mode the very first
       miss ends the run rather than the second. */
    trickyMenuDescription.textContent = state.unlimited
      ? "One try each — a single miss ends the run"
      : "The obvious answer is often wrong — one try each, no second chances";
    fifthMenuBtn.setAttribute("aria-disabled", String(state.unlimited));
    setMenuBusy(state.loading);
  }

  unlimitedToggle.addEventListener("click", function () {
    applyUnlimitedMode(!state.unlimited);
  });

  function showError(error) {
    errorMessageEl.textContent = error && error.message
      ? error.message
      : "Please check the internet connection and try again.";
    show("error");
    document.getElementById("retry-btn").focus();
  }

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

  var voiceBtn = document.getElementById("voice-toggle");
  var speechOK = "speechSynthesis" in window;

  function speak(text) {
    if (!speechOK) return;
    window.speechSynthesis.cancel();
    var utterance = new SpeechSynthesisUtterance(text);
    utterance.rate = 0.9;
    utterance.lang = L().lang;
    var voices = window.speechSynthesis.getVoices();
    for (var i = 0; i < voices.length; i++) {
      if (voices[i].lang && voices[i].lang.indexOf(locale()) === 0) {
        utterance.voice = voices[i];
        break;
      }
    }
    window.speechSynthesis.speak(utterance);
  }

  function questionSpeechText() {
    var question = state.round[state.index];
    if (!question) return "";
    var parts = [];
    if (!questionMetaEl.hidden) parts.push(questionMetaEl.textContent);
    parts.push(question.q);
    var buttons = optionsEl.querySelectorAll(".option-btn:not(:disabled)");
    for (var i = 0; i < buttons.length; i++) {
      parts.push(L().option(buttons[i].dataset.num) + ": " + buttons[i].dataset.text);
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
      speak(screens.quiz.hidden ? "Voice is on. Questions will be read out loud." : questionSpeechText());
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

  function applyLocale() {
    var strings = L();
    readBtn.textContent = strings.read;
    quitBtn.textContent = strings.quit;
    document.getElementById("kb-hint").innerHTML = isTrueFalse() ? strings.kbHintTwo : strings.kbHint;
    document.getElementById("again-btn").textContent = strings.again;
    document.getElementById("home-btn").textContent = strings.home;
    shareBtn.textContent = strings.share;
    shareStatusEl.textContent = strings.shareHelp;
    var lang = locale() === "hu" ? "hu" : "en";
    screens.quiz.setAttribute("lang", lang);
    screens.results.setAttribute("lang", lang);
  }

  function buildFifthGradeRound(pool) {
    var round = [];
    for (var grade = 1; grade <= 5; grade++) {
      var gradePool = pool.filter(function (question) { return question.grade === grade; });
      if (gradePool.length < 2) throw new Error("The Grade " + grade + " question set is incomplete.");
      round = round.concat(weightedSample(gradePool, 2));
    }
    return round;
  }

  function rememberQuestionView(question) {
    question.timesShown = (question.timesShown || 0) + 1;
    window.QuizBackend.recordQuestionViews([question]).catch(function (error) {
      console.error("Question variety tracking failed:", error);
    });
  }

  async function startRound(category) {
    if (state.loading) return;
    if (state.unlimited && category === "fifth_grader") return;
    state.loading = true;
    setMenuBusy(true);
    show("loading");

    try {
      var pool = await window.QuizBackend.loadQuestions(category);
      if ((!state.unlimited && pool.length < ROUND_LENGTH) || pool.length < 1) {
        throw new Error("There are not enough questions in this quiz yet.");
      }

      state.category = category;
      state.round = state.unlimited
        ? weightedSample(pool, pool.length)
        : category === "fifth_grader"
        ? buildFifthGradeRound(pool)
        : weightedSample(pool, ROUND_LENGTH);
      state.index = 0;
      state.score = 0;
      state.firstTryCorrect = 0;
      state.secondTryCorrect = 0;
      state.answers = [];
      state.startedAt = new Date().toISOString();
      state.unlimitedEnded = false;
      state.lifelines = { peek: false, copy: false, save: false, saveSucceeded: false };

      applyLocale();
      barEl.innerHTML = "";
      barEl.hidden = state.unlimited;
      if (!state.unlimited) {
        for (var i = 0; i < state.round.length; i++) {
          barEl.appendChild(document.createElement("span"));
        }
      }
      show("quiz");
      renderQuestion();
    } catch (error) {
      showError(error);
    } finally {
      state.loading = false;
      setMenuBusy(false);
    }
  }

  function updateBar(doneCount) {
    if (barEl.hidden) return;
    var segments = barEl.children;
    for (var i = 0; i < segments.length; i++) {
      segments[i].className = i < doneCount ? "done" : "";
    }
  }

  function progressText() {
    var question = state.round[state.index];
    if (state.unlimited) return L().unlimitedProgress(state.index + 1, state.score);
    if (state.category === "fifth_grader") {
      return "Grade " + question.grade + "  •  Question " + (state.index + 1) +
        " of " + state.round.length + "  •  Score: " + state.score;
    }
    return L().progress(state.index + 1, state.round.length, state.score);
  }

  function chooseClassmateAnswer(question) {
    var correctChance = 0.94 - ((question.grade - 1) * 0.07);
    if (Math.random() < correctChance) return question.a;
    return shuffle(question.w)[0];
  }

  function updateHelpPanel() {
    var fifthMode = state.category === "fifth_grader";
    fifthHelpEl.hidden = !fifthMode;
    if (!fifthMode) return;

    peekBtn.disabled = state.lifelines.peek || state.answered;
    copyBtn.disabled = state.lifelines.copy || state.answered;
    peekBtn.classList.toggle("is-used", state.lifelines.peek);
    copyBtn.classList.toggle("is-used", state.lifelines.copy);
    peekBtn.textContent = state.lifelines.peek ? "👀 Peek: Used" : "👀 Peek";
    copyBtn.textContent = state.lifelines.copy ? "📝 Copy: Used" : "📝 Copy";
    saveIndicator.textContent = state.lifelines.save ? "🛟 Save: Used" : "🛟 Save: Ready";
    saveIndicator.classList.toggle("is-used", state.lifelines.save);
  }

  function renderQuestion() {
    if (speechOK) window.speechSynthesis.cancel();
    var question = state.round[state.index];
    state.answered = false;
    state.attempts = 0;
    state.currentSelections = [];
    state.answerViaCopy = false;
    updateBar(state.index);
    rememberQuestionView(question);

    progressEl.textContent = progressText();
    questionEl.textContent = question.q;
    feedbackEl.textContent = "";
    feedbackEl.className = "feedback";
    nextBtn.hidden = true;

    if (state.category === "fifth_grader") {
      questionMetaEl.hidden = false;
      questionMetaEl.textContent = "Grade " + question.grade + " " + question.subject +
        "  •  " + FIFTH_PRIZES[state.index] + " question";
      state.classmateAnswer = chooseClassmateAnswer(question);
      helpStatusEl.textContent = state.lifelines.save
        ? "Your automatic Save has already been used."
        : "Your classmate is ready to help.";
    } else if (state.unlimited || isTrueFalse()) {
      questionMetaEl.hidden = false;
      questionMetaEl.textContent = state.unlimited
        ? (isTrueFalse() ? L().unlimitedSingleAttemptMeta : L().unlimitedMeta)
        : L().singleAttemptMeta;
      state.classmateAnswer = null;
      helpStatusEl.textContent = "";
    } else {
      questionMetaEl.hidden = true;
      questionMetaEl.textContent = "";
      state.classmateAnswer = null;
      helpStatusEl.textContent = "";
    }
    updateHelpPanel();

    var choices = shuffle([question.a].concat(question.w));
    optionsEl.innerHTML = "";
    choices.forEach(function (text, index) {
      var button = document.createElement("button");
      button.type = "button";
      button.className = "option-btn";
      button.dataset.text = text;
      button.dataset.num = String(index + 1);

      var badge = document.createElement("span");
      badge.className = "option-badge";
      badge.setAttribute("aria-hidden", "true");
      badge.textContent = String(index + 1);
      button.appendChild(badge);

      var label = document.createElement("span");
      label.textContent = text;
      button.appendChild(label);

      button.setAttribute("aria-label", L().option(index + 1) + ": " + text);
      button.addEventListener("click", function () {
        answer(button, text === question.a);
      });
      optionsEl.appendChild(button);
    });

    if (state.index === 0) {
      questionEl.focus();
    } else {
      /* Mobile browsers can preserve the tapped Next button's lower scroll
         position. Wait for the new layout, then align the question card. */
      window.requestAnimationFrame(function () {
        try {
          questionEl.focus({ preventScroll: true });
        } catch (error) {
          questionEl.focus();
        }
        questionCardEl.scrollIntoView({ behavior: "auto", block: "start" });
      });
    }
    if (state.voiceOn) speak(questionSpeechText());
  }

  function logAnswer(correct, outcome) {
    var question = state.round[state.index];
    state.answers.push({
      question_id: question.id,
      grade_level: question.grade || null,
      subject: question.subject || null,
      selected_answers: state.currentSelections.slice(),
      correct: correct,
      attempts_used: state.currentSelections.length,
      outcome: outcome
    });
  }

  function finishQuestion(chosenWrongButton, correct, outcome) {
    var question = state.round[state.index];
    var buttons = optionsEl.querySelectorAll(".option-btn");
    for (var i = 0; i < buttons.length; i++) {
      var button = buttons[i];
      var badge = button.querySelector(".option-badge");
      if (button.dataset.text === question.a) {
        button.classList.add("is-correct");
        button.classList.remove("is-faded");
        badge.textContent = "✓";
      } else if (button === chosenWrongButton) {
        button.classList.add("is-wrong");
        badge.textContent = "✗";
      } else if (!button.classList.contains("is-wrong")) {
        button.classList.add("is-faded");
      }
      button.disabled = true;
    }

    updateBar(state.index + 1);
    state.answered = true;
    logAnswer(correct, outcome);
    progressEl.textContent = progressText();

    var last = state.unlimitedEnded || state.index === state.round.length - 1;
    nextBtn.textContent = state.unlimitedEnded
      ? L().unlimitedSeeResult
      : last ? L().seeResult : L().next;
    nextBtn.hidden = false;
    updateHelpPanel();
    nextBtn.focus();
  }

  function regularAnswer(chosenButton, isRight) {
    var strings = L();
    if (isRight) {
      var secondTry = state.attempts > 0;
      state.score++;
      if (secondTry) state.secondTryCorrect++;
      else state.firstTryCorrect++;
      feedbackEl.textContent = secondTry ? strings.correct2 : strings.correct;
      feedbackEl.className = "feedback good";
      finishQuestion(null, true, secondTry ? "second_try" : "first_try");
      if (state.voiceOn) speak(secondTry ? strings.correct2Spoken : strings.correctSpoken);
      return;
    }

    state.attempts++;
    /* A true/false round has only two choices, so the reveal comes straight
       away — a second chance would leave just the correct answer standing. */
    if (state.attempts === 1 && !isTrueFalse()) {
      chosenButton.disabled = true;
      chosenButton.classList.add("is-wrong");
      chosenButton.querySelector(".option-badge").textContent = "✗";
      feedbackEl.textContent = strings.tryAgain;
      feedbackEl.className = "feedback bad";
      if (state.voiceOn) speak(strings.tryAgainSpoken);
      return;
    }

    var question = state.round[state.index];
    if (state.unlimited) state.unlimitedEnded = true;
    feedbackEl.textContent = state.unlimited
      ? strings.unlimitedReveal(question.a)
      : strings.reveal(question.a);
    feedbackEl.className = "feedback bad";
    finishQuestion(chosenButton, false, "incorrect");
    if (state.voiceOn) {
      speak(state.unlimited
        ? strings.unlimitedRevealSpoken(question.a)
        : strings.revealSpoken(question.a));
    }
  }

  function fifthGradeAnswer(chosenButton, isRight) {
    var question = state.round[state.index];
    if (isRight) {
      state.score++;
      state.firstTryCorrect++;
      feedbackEl.textContent = "✓ Correct! You are climbing the grade-school ladder.";
      feedbackEl.className = "feedback good";
      finishQuestion(null, true, state.answerViaCopy ? "copy" : "first_try");
      if (state.voiceOn) speak("Correct! You are climbing the grade school ladder.");
      return;
    }

    if (!state.lifelines.save) {
      state.lifelines.save = true;
      if (state.classmateAnswer === question.a) {
        state.lifelines.saveSucceeded = true;
        state.score++;
        state.secondTryCorrect++;
        feedbackEl.textContent = "🛟 Saved! Your classmate knew the answer: " + question.a;
        feedbackEl.className = "feedback good";
        helpStatusEl.textContent = "Your automatic Save kept you in the game.";
        finishQuestion(chosenButton, true, "saved");
        if (state.voiceOn) speak("Saved! Your classmate knew the answer.");
        return;
      }
      helpStatusEl.textContent = "Your classmate missed this one too, so the Save was used.";
    }

    feedbackEl.textContent = "✗ Not this time. The answer is: " + question.a;
    feedbackEl.className = "feedback bad";
    finishQuestion(chosenButton, false, state.answerViaCopy ? "copy_incorrect" : "incorrect");
    if (state.voiceOn) speak("Not this time. The answer is " + question.a);
  }

  function answer(chosenButton, isRight) {
    if (state.answered || chosenButton.disabled) return;
    state.currentSelections.push(chosenButton.dataset.text);
    if (state.category === "fifth_grader") fifthGradeAnswer(chosenButton, isRight);
    else regularAnswer(chosenButton, isRight);
  }

  peekBtn.addEventListener("click", function () {
    if (state.answered || state.lifelines.peek) return;
    state.lifelines.peek = true;
    helpStatusEl.textContent = "Your classmate chose: “" + state.classmateAnswer + ".” You may choose any answer.";
    updateHelpPanel();
    if (state.voiceOn) speak(helpStatusEl.textContent);
  });

  copyBtn.addEventListener("click", function () {
    if (state.answered || state.lifelines.copy) return;
    state.lifelines.copy = true;
    state.answerViaCopy = true;
    helpStatusEl.textContent = "Copy used. Your classmate chose: “" + state.classmateAnswer + ".”";
    updateHelpPanel();
    var buttons = optionsEl.querySelectorAll(".option-btn");
    for (var i = 0; i < buttons.length; i++) {
      if (buttons[i].dataset.text === state.classmateAnswer) {
        buttons[i].click();
        break;
      }
    }
  });

  nextBtn.addEventListener("click", function () {
    if (!state.unlimitedEnded && state.index < state.round.length - 1) {
      state.index++;
      renderQuestion();
    } else {
      showResults();
    }
  });

  quitBtn.addEventListener("click", function () {
    if (speechOK) window.speechSynthesis.cancel();
    show("home");
    var currentMenuButton = document.querySelector(
      '.menu-btn[data-category="' + state.category + '"]'
    );
    if (currentMenuButton) currentMenuButton.focus();
  });

  function resultPayload() {
    var startedTime = new Date(state.startedAt).getTime();
    var duration = Math.max(0, Math.round((Date.now() - startedTime) / 1000));
    var lifelines = state.category === "fifth_grader" ? {
      peek: state.lifelines.peek,
      copy: state.lifelines.copy,
      save: state.lifelines.save,
      save_succeeded: state.lifelines.saveSucceeded
    } : {};

    return {
      score: state.score,
      totalQuestions: state.answers.length,
      firstTryCorrect: state.firstTryCorrect,
      secondTryCorrect: state.secondTryCorrect,
      isUnlimited: state.unlimited,
      startedAt: state.startedAt,
      durationSeconds: duration,
      answers: state.answers,
      lifelinesUsed: lifelines
    };
  }

  function shareResultText() {
    var categoryName = CATEGORY_NAMES[state.category] || "Quiz Time";
    var secondChanceText;

    if (isTrueFalse()) {
      secondChanceText = L().shareNoSecondChances;
    } else if (state.secondTryCorrect === 0) {
      secondChanceText = "No points came from second chances.";
    } else if (state.secondTryCorrect === 1) {
      secondChanceText = "1 point came from a second chance.";
    } else {
      secondChanceText = state.secondTryCorrect + " points came from second chances.";
    }

    if (state.unlimited) {
      return "I scored " + state.score + " on the " + categoryName +
        " quiz in Unlimited Mode! " + secondChanceText + " 😈";
    }

    return "I scored " + state.score + " out of " + state.answers.length +
      " on the " + categoryName + " quiz! " + secondChanceText + " 😊";
  }

  function openMessageComposer(text) {
    window.location.href = "sms:?&body=" + encodeURIComponent(text);
  }

  shareBtn.addEventListener("click", async function () {
    var text = shareResultText();
    shareBtn.disabled = true;

    try {
      if (typeof navigator.share === "function") {
        await navigator.share({ text: text });
        shareStatusEl.textContent = L().shareReady;
      } else {
        openMessageComposer(text);
      }
    } catch (error) {
      if (!error || error.name !== "AbortError") openMessageComposer(text);
    } finally {
      shareBtn.disabled = false;
    }
  });

  function showResults() {
    var total = state.answers.length;
    var score = state.score;
    var strings = L();
    var emoji;
    var title;
    var clearedUnlimited = state.unlimited && !state.unlimitedEnded && state.index === state.round.length - 1;
    if (state.unlimited) {
      emoji = clearedUnlimited ? "😈🏆" : "😈";
      title = clearedUnlimited ? "Unlimited Mode conquered!" : "Unlimited run complete!";
    }
    else if (score === total) { emoji = "🌟🌟🌟"; title = strings.titles[0]; }
    else if (score >= total * 0.8) { emoji = "🎉"; title = strings.titles[1]; }
    else if (score >= total * 0.6) { emoji = "😊"; title = strings.titles[2]; }
    else if (score >= total * 0.4) { emoji = "👍"; title = strings.titles[3]; }
    else { emoji = "💪"; title = strings.titles[4]; }

    resultEmoji.textContent = emoji;
    resultTitle.textContent = title;
    resultScore.textContent = state.unlimited
      ? strings.unlimitedScore(score, total, clearedUnlimited)
      : strings.score(score, total);
    shareStatusEl.textContent = strings.shareHelp;
    show("results");
    resultTitle.focus();
    if (state.voiceOn) {
      speak(title + " " + (state.unlimited
        ? strings.unlimitedScore(score, total, clearedUnlimited)
        : strings.score(score, total)));
    }

    window.QuizBackend.recordResult(state.category, resultPayload()).catch(function (error) {
      console.error("Quiz score tracking failed:", error);
    });
  }

  document.getElementById("again-btn").addEventListener("click", function () {
    startRound(state.category);
  });

  document.getElementById("home-btn").addEventListener("click", function () {
    show("home");
    var currentMenuButton = document.querySelector(
      '.menu-btn[data-category="' + state.category + '"]'
    );
    if (currentMenuButton) currentMenuButton.focus();
  });

  for (var menuIndex = 0; menuIndex < menuBtns.length; menuIndex++) {
    (function (button) {
      button.addEventListener("click", function () {
        startRound(button.dataset.category);
      });
    })(menuBtns[menuIndex]);
  }

  document.addEventListener("keydown", function (event) {
    if (screens.quiz.hidden || state.answered) return;
    var number = parseInt(event.key, 10);
    if (number >= 1 && number <= 4) {
      var buttons = optionsEl.querySelectorAll(".option-btn");
      if (buttons[number - 1]) buttons[number - 1].click();
    }
  });

  async function initializeApp() {
    show("loading");
    try {
      await window.QuizBackend.initialize();
      show("home");
      try {
        unlimitedToggle.focus({ preventScroll: true });
      } catch (error) {
        unlimitedToggle.focus();
      }
      window.scrollTo(0, 0);
    } catch (error) {
      showError(error);
    }
  }

  document.getElementById("retry-btn").addEventListener("click", initializeApp);

  var savedStep = parseInt(load("quiz-font-step"), 10);
  if (!isNaN(savedStep) && savedStep >= 0 && savedStep < FONT_STEPS.length) {
    state.fontStep = savedStep;
  }
  applyFontStep();
  applyTheme(load("quiz-theme") === "dark" ? "dark" : "light");
  state.voiceOn = load("quiz-voice") === "on";
  applyVoice();
  applyUnlimitedMode(false);
  initializeApp();
})();
