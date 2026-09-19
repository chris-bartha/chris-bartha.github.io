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
    hungarian: "Történelem magyarul",
    magyar_foldrajz: "Magyarország földrajza",
    foldrajz_magyarul: "Földrajz magyarul",
    magyar_irodalom: "Magyar irodalom",
    magyar_tudomany: "Természet és tudomány",
    magyar_nepmesek: "Népmesék és közmondások",
    magyar_konyha: "Magyar konyha",
    magyar_zene: "Magyar zene 1970–1989",
    regen_volt: "Ahogy régen volt",
    tobb_vagy_kevesebb: "Több vagy kevesebb?",
    ket_igazsag: "Két igazság és egy hazugság",
    time_traveler: "Time Traveler",
    tricky_true_false: "Tricky True or False",
    psychology: "Psychology",
    fifth_grader: "Are You Smarter Than a Fifth Grader?"
  };

  /* The Hungarian quizzes live behind one menu button and share a locale. */
  var HUNGARIAN_CATEGORIES = {
    hungarian: true,
    magyar_foldrajz: true,
    foldrajz_magyarul: true,
    magyar_irodalom: true,
    magyar_tudomany: true,
    magyar_nepmesek: true,
    magyar_konyha: true,
    magyar_zene: true,
    regen_volt: true,
    tobb_vagy_kevesebb: true,
    ket_igazsag: true
  };

  /* Two-choice rounds get one attempt per question: a second chance would leave
     only the correct answer standing, which is not a second chance at all. */
  var SINGLE_ATTEMPT_CATEGORIES = {
    tricky_true_false: true,
    tobb_vagy_kevesebb: true
  };

  /* How many buttons a question shows, which is also how far the number-key
     shortcut goes. Four unless a category says otherwise. */
  var OPTION_COUNTS = {
    tricky_true_false: 2,
    tobb_vagy_kevesebb: 2,
    ket_igazsag: 3
  };

  /* The one quiz that is still a fixed ten-question round. Everywhere else the
     run continues until a question beats her twice. */
  var LADDER_CATEGORY = "fifth_grader";

  var screens = {
    loading: document.getElementById("screen-loading"),
    error: document.getElementById("screen-error"),
    home: document.getElementById("screen-home"),
    hungarian: document.getElementById("screen-hungarian"),
    stats: document.getElementById("screen-stats"),
    crime: document.getElementById("screen-crime"),
    crimeStories: document.getElementById("screen-crime-stories"),
    crimeStory: document.getElementById("screen-crime-story"),
    crimeVideos: document.getElementById("screen-crime-videos"),
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
  var explanationEl = document.getElementById("explanation");
  var nextBtn = document.getElementById("next-btn");
  var quitBtn = document.getElementById("quit-btn");
  var quitConfirmEl = document.getElementById("quit-confirm");
  var quitConfirmTextEl = document.getElementById("quit-confirm-text");
  var readBtn = document.getElementById("read-btn");
  var voiceNoticeEl = document.getElementById("voice-notice");
  var resultEmoji = document.getElementById("result-emoji");
  var resultTitle = document.getElementById("result-title");
  var resultScore = document.getElementById("result-score");
  var shareBtn = document.getElementById("share-btn");
  var shareStatusEl = document.getElementById("share-status");
  var againBtn = document.getElementById("again-btn");
  var errorMessageEl = document.getElementById("error-message");
  var fifthHelpEl = document.getElementById("fifth-help");
  var peekBtn = document.getElementById("peek-btn");
  var copyBtn = document.getElementById("copy-btn");
  var saveIndicator = document.getElementById("save-indicator");
  var helpStatusEl = document.getElementById("help-status");
  var menuBtns = document.querySelectorAll(".menu-btn[data-category]");
  var statsBtn = document.getElementById("stats-btn");
  var crimeBtn = document.getElementById("crime-btn");

  var state = {
    category: "hungarian",
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
      answersGroup: "Answer choices",
      answerCorrect: "Correct answer. ",
      answerWrong: "Your answer, wrong. ",
      quitConfirm: function (right) {
        return right === 1
          ? "Stop this run? You have 1 right so far."
          : "Stop this run? You have " + right + " right so far.";
      },
      quitKeep: "Keep playing",
      quitYes: "Yes, stop",
      saveFailed: "Your score could not be saved. Please check the internet connection.",
      noVoice: "Hungarian speech is not installed on this device.",
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
      kbHintThree: "Tip: you can press <strong>1, 2 or 3</strong> on your keyboard to answer.",
      kbHintTwo: "Tip: you can press <strong>1 or 2</strong> on your keyboard to answer.",
      why: function (text) { return "💡 In fact: " + text; },
      unlimitedSingleAttemptMeta: "⚠️ One try each — a single miss ends the run",
      shareNoSecondChances: "One try per question — no second chances.",
      again: "🔁 Play again",
      home: "🏠 Back to the menu",
      share: "💬 Text my score",
      shareHelp: "Opens your sharing menu with a ready-to-send message.",
      shareReady: "Your score is ready to send.",
      score: function (score, total) { return "You got " + score + " out of " + total + " right."; },
      unlimitedProgress: function (i, score) {
        return "Question " + i + "  •  Score: " + score;
      },
      unlimitedMeta: "😈 The run ends when one question beats you twice",
      unlimitedReveal: function (answer) {
        return "😈 That ends this run. The answer is: " + answer;
      },
      unlimitedRevealSpoken: function (answer) {
        return "That ends this run. The answer is " + answer;
      },
      unlimitedSeeResult: "See my score ➜",
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
      answersGroup: "Válaszlehetőségek",
      answerCorrect: "Helyes válasz. ",
      answerWrong: "A te válaszod, hibás. ",
      quitConfirm: function (right) {
        return "Megállsz? Eddig " + right + " helyes válaszod van.";
      },
      quitKeep: "Játszom tovább",
      quitYes: "Igen, megállok",
      saveFailed: "Az eredményt nem sikerült elmenteni. Ellenőrizd az internetkapcsolatot.",
      noVoice: "Ezen az eszközön nincs telepítve magyar beszédhang.",
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
      kbHintThree: "Tipp: a billentyűzeten az <strong>1, 2 vagy 3</strong> gombbal is válaszolhatsz.",
      kbHintTwo: "Tipp: a billentyűzeten az <strong>1 vagy 2</strong> gombbal is válaszolhatsz.",
      why: function (text) { return "💡 Valójában: " + text; },
      unlimitedSingleAttemptMeta: "⚠️ Egy próbálkozás — egyetlen hiba véget vet a játéknak",
      shareNoSecondChances: "Egy próbálkozás kérdésenként — nincs második esély.",
      again: "🔁 Játszom még egyszer",
      home: "🏠 Vissza a menübe",
      share: "💬 Elküldöm az eredményt",
      shareHelp: "Megnyitja a megosztást egy elkészített üzenettel.",
      shareReady: "Az üzenet elkészült.",
      score: function (score, total) { return total + " kérdésből " + score + " helyes válaszod volt."; },
      unlimitedProgress: function (i, score) {
        return i + ". kérdés  •  Pontszám: " + score;
      },
      unlimitedMeta: "😈 A játék addig tart, amíg egy kérdés kétszer be nem csap",
      unlimitedReveal: function (answer) {
        return "😈 A játéknak vége. A helyes válasz: " + answer;
      },
      unlimitedRevealSpoken: function (answer) {
        return "A játéknak vége. A helyes válasz " + answer;
      },
      unlimitedSeeResult: "Mutasd az eredményt ➜",
      unlimitedScore: function (score, attempted, cleared) {
        if (cleared) return "Csodálatos — minden kérdésre helyesen válaszoltál! Pontszám: " + score + ".";
        return score + " helyes válaszod volt, mielőtt a játék véget ért. Megválaszolt kérdések: " + attempted + ".";
      },
      titles: ["Hibátlan! Csodálatos!", "Kiváló!", "Szép munka!", "Jó próbálkozás!", "Ne add fel — próbáld újra!"]
    }
  };

  function locale() {
    return HUNGARIAN_CATEGORIES[state.category] ? "hu" : "en";
  }

  function isSingleAttempt() {
    return Boolean(SINGLE_ATTEMPT_CATEGORIES[state.category]);
  }

  function optionCount() {
    return OPTION_COUNTS[state.category] || 4;
  }

  /* Every quiz but the Fifth Grader ladder now runs as a single open-ended run.
     She played Unlimited Mode almost exclusively when it was a choice, and a
     toggle she never turned off was one more thing between her and a round. */
  function isUnlimitedCategory(category) {
    return category !== LADDER_CATEGORY;
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

  /* How the lottery is tuned. Every question always keeps a real weight, so
     nothing is ever excluded -- these only change the order things tend to
     arrive in. Raise a number to make that pull stronger. */
  var VARIETY_PULL = 0.25;      /* toward questions seen less often */
  var COOLDOWN_DAYS = 7;        /* how long a just-answered question rests */
  var COOLDOWN_FLOOR = 0.4;     /* its weight the moment after answering */
  var EASE_SPREAD = 0.3;        /* toward questions she usually gets right */
  var MIN_ANSWERS_FOR_EASE = 4; /* below this there is no useful accuracy yet */

  /* Weighted sampling without replacement (Efraimidis-Spirakis): each question
     draws a key of -ln(U)/weight and the smallest keys come first, so a heavier
     weight means "tends to arrive earlier" rather than "always wins".

     Unlimited Mode orders the whole pool this way, and it is sudden death, so
     the order is the game. The variety pull alone used to stack every
     least-seen question at the front -- which is also every hardest question,
     since new material is what she has seen least. Runs died around question
     six and the newest batch never got past the front of the queue. Two gentler
     pulls balance it: a question answered in the last few days rests for a
     while, and one she reliably gets right drifts forward of one that beats
     her, so a long run warms up instead of opening on a wall. */
  function weightedSample(items, count) {
    var now = Date.now();
    return items.map(function (question) {
      var views = Math.max(question.timesShown || 0, question.timesAnswered || 0);
      var weight = 1 / Math.pow(1 + views, VARIETY_PULL);

      var answered = question.timesAnswered || 0;
      if (answered >= MIN_ANSWERS_FOR_EASE) {
        var accuracy = Math.min(1, (question.timesCorrect || 0) / answered);
        weight *= (1 - EASE_SPREAD) + (2 * EASE_SPREAD * accuracy);
      }

      var answeredAt = question.lastAnsweredAt ? Date.parse(question.lastAnsweredAt) : NaN;
      if (!isNaN(answeredAt)) {
        var daysRested = (now - answeredAt) / 86400000;
        if (daysRested < COOLDOWN_DAYS) {
          var recovered = Math.max(0, daysRested) / COOLDOWN_DAYS;
          weight *= COOLDOWN_FLOOR + (1 - COOLDOWN_FLOOR) * recovered;
        }
      }

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

  /* Landing on the top of a new screen matters more here than usual: at 200%
     text the exit button may be the only thing above the fold, and she needs to
     know it is there before anything else. */
  function focusFirst(screen) {
    var target = screen.querySelector("h1[tabindex], .exit-btn, .big-btn, h1");
    if (!target) return;
    try {
      target.focus({ preventScroll: true });
    } catch (error) {
      target.focus();
    }
  }

  function openScreen(name, scroll) {
    show(name);
    if (scroll !== false) window.scrollTo(0, 0);
    focusFirst(screens[name]);
  }

  function save(key, value) {
    try { localStorage.setItem(key, String(value)); } catch (error) { /* Optional preference. */ }
  }

  function load(key) {
    try { return localStorage.getItem(key); } catch (error) { return null; }
  }

  function setMenuBusy(busy) {
    for (var i = 0; i < menuBtns.length; i++) {
      menuBtns[i].disabled = busy;
    }
    statsBtn.disabled = busy;
    crimeBtn.disabled = busy;
  }

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
    /* Lets the stylesheet react to the text step on any screen width. */
    document.documentElement.setAttribute("data-font-step", String(state.fontStep));
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
    /* The label names the action the button performs, so aria-pressed would
       contradict it ("Light, pressed" reads as "light mode is already on"). */
    themeBtn.textContent = dark ? "☀️ Light" : "🌙 Dark";
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

  /* Chrome fills the voice list asynchronously, so a cold getVoices() returns
     an empty array and the first question of a session would be read with the
     wrong voice. Cache the list and refresh it whenever the browser says so. */
  var voiceCache = [];
  function refreshVoices() {
    if (!speechOK) return;
    voiceCache = window.speechSynthesis.getVoices() || [];
  }
  if (speechOK) {
    refreshVoices();
    window.speechSynthesis.addEventListener("voiceschanged", refreshVoices);
  }

  function voiceFor(code) {
    if (!voiceCache.length) refreshVoices();
    var local = null;
    for (var i = 0; i < voiceCache.length; i++) {
      var voice = voiceCache[i];
      if (!voice.lang || voice.lang.toLowerCase().indexOf(code) !== 0) continue;
      /* Prefer a voice installed on the device: a remote one adds latency and
         goes silent without a network. */
      if (voice.localService) return voice;
      if (!local) local = voice;
    }
    return local;
  }

  function speak(text) {
    if (!speechOK) return;
    var voice = voiceFor(locale());
    /* Speaking Hungarian text with an English voice produces gibberish, which
       is worse than silence. Stay quiet and let applyVoice explain why. */
    if (!voice && locale() === "hu") return;
    window.speechSynthesis.cancel();
    var utterance = new SpeechSynthesisUtterance(text);
    utterance.rate = 0.9;
    utterance.lang = L().lang;
    if (voice) utterance.voice = voice;
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
    var hints = { 2: strings.kbHintTwo, 3: strings.kbHintThree };
    document.getElementById("kb-hint").innerHTML = hints[optionCount()] || strings.kbHint;
    document.getElementById("again-btn").textContent = strings.again;
    document.getElementById("home-btn").textContent = strings.home;
    shareBtn.textContent = strings.share;
    shareStatusEl.textContent = strings.shareHelp;
    optionsEl.setAttribute("aria-label", strings.answersGroup);
    document.getElementById("quit-keep-btn").textContent = strings.quitKeep;
    document.getElementById("quit-yes-btn").textContent = strings.quitYes;
    /* Without a matching voice, "Read this question" would do nothing at all.
       Say so rather than leaving a dead button on screen. */
    var speakable = !speechOK || Boolean(voiceFor(locale())) || locale() === "en";
    readBtn.hidden = !speechOK || !speakable;
    voiceNoticeEl.hidden = speakable;
    voiceNoticeEl.textContent = speakable ? "" : strings.noVoice;
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
    /* A menu button that opens a submenu has no category. Reaching here with
       one would load an empty pool and show "there are not enough questions",
       which is both alarming and untrue -- do nothing instead. */
    if (!category || !CATEGORY_NAMES[category]) {
      console.error("startRound called without a real category:", category);
      return;
    }
    state.loading = true;
    setMenuBusy(true);
    show("loading");

    try {
      var pool = await window.QuizBackend.loadQuestions(category);
      var unlimited = isUnlimitedCategory(category);
      if ((!unlimited && pool.length < ROUND_LENGTH) || pool.length < 1) {
        throw new Error("There are not enough questions in this quiz yet.");
      }

      state.category = category;
      state.unlimited = unlimited;
      state.round = unlimited
        ? weightedSample(pool, pool.length)
        : buildFifthGradeRound(pool);
      state.index = 0;
      state.score = 0;
      state.firstTryCorrect = 0;
      state.secondTryCorrect = 0;
      state.answers = [];
      state.startedAt = new Date().toISOString();
      state.unlimitedEnded = false;
      state.lifelines = { peek: false, copy: false, save: false, saveSucceeded: false };

      hideQuitConfirm();
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
    explanationEl.hidden = true;
    explanationEl.textContent = "";
    nextBtn.hidden = true;

    if (state.category === "fifth_grader") {
      questionMetaEl.hidden = false;
      questionMetaEl.textContent = "Grade " + question.grade + " " + question.subject +
        "  •  " + FIFTH_PRIZES[state.index] + " question";
      state.classmateAnswer = chooseClassmateAnswer(question);
      helpStatusEl.textContent = state.lifelines.save
        ? "Your automatic Save has already been used."
        : "Your classmate is ready to help.";
    } else {
      questionMetaEl.hidden = false;
      questionMetaEl.textContent = isSingleAttempt()
        ? L().unlimitedSingleAttemptMeta
        : L().unlimitedMeta;
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
      /* The badge is aria-hidden, so the ✓/✗ has to reach assistive technology
         through the label too — colour, symbol and words, on every path. */
      var spoken = L().option(button.dataset.num) + ": " + button.dataset.text;
      if (button.dataset.text === question.a) {
        button.classList.add("is-correct");
        button.classList.remove("is-faded");
        badge.textContent = "✓";
        button.setAttribute("aria-label", L().answerCorrect + spoken);
      } else if (button === chosenWrongButton) {
        button.classList.add("is-wrong");
        badge.textContent = "✗";
        button.setAttribute("aria-label", L().answerWrong + spoken);
      } else if (!button.classList.contains("is-wrong")) {
        button.classList.add("is-faded");
      }
      button.disabled = true;
    }

    /* One place covers every ending: right, wrong, saved, copied. Most banks
       carry no note at all, and then nothing appears. */
    var why = question.why;
    explanationEl.hidden = !why;
    explanationEl.textContent = why ? L().why(why) : "";

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
    if (state.attempts === 1 && !isSingleAttempt()) {
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

  /* Send her back to the menu the category actually lives on, and put focus on
     the button she came in through. */
  function returnToMenu() {
    show(HUNGARIAN_CATEGORIES[state.category] ? "hungarian" : "home");
    var currentMenuButton = document.querySelector(
      '.menu-btn[data-category="' + state.category + '"]'
    );
    if (currentMenuButton) currentMenuButton.focus();
  }

  function leaveRound() {
    if (speechOK) window.speechSynthesis.cancel();
    hideQuitConfirm();
    returnToMenu();
  }

  function hideQuitConfirm() {
    quitConfirmEl.hidden = true;
    quitBtn.hidden = false;
  }

  /* A run can be hundreds of questions long and this button sits under Next.
     One mis-tap should not silently throw the whole run away. */
  quitBtn.addEventListener("click", function () {
    if (state.answers.length < 5) {
      leaveRound();
      return;
    }
    quitConfirmTextEl.textContent = L().quitConfirm(state.score);
    quitConfirmEl.hidden = false;
    quitBtn.hidden = true;
    document.getElementById("quit-keep-btn").focus();
  });

  document.getElementById("quit-keep-btn").addEventListener("click", function () {
    hideQuitConfirm();
    quitBtn.focus();
  });

  document.getElementById("quit-yes-btn").addEventListener("click", leaveRound);

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

    if (isSingleAttempt()) {
      secondChanceText = L().shareNoSecondChances;
    } else if (state.secondTryCorrect === 0) {
      secondChanceText = "No points came from second chances.";
    } else if (state.secondTryCorrect === 1) {
      secondChanceText = "1 point came from a second chance.";
    } else {
      secondChanceText = state.secondTryCorrect + " points came from second chances.";
    }

    if (state.unlimited) {
      return "I answered " + state.score + " right in one run of the " +
        categoryName + " quiz! " + secondChanceText + " 😈";
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
      title = clearedUnlimited ? "You cleared the whole quiz!" : "Run complete!";
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
    /* She restarts constantly — half of all Tricky True or False runs end by
       question four — so land on the button she actually wants. The title is
       still read aloud below, so nothing is lost by not focusing it. */
    againBtn.focus();
    if (state.voiceOn) {
      speak(title + " " + (state.unlimited
        ? strings.unlimitedScore(score, total, clearedUnlimited)
        : strings.score(score, total)));
    }

    window.QuizBackend.recordResult(state.category, resultPayload()).catch(function (error) {
      console.error("Quiz score tracking failed:", error);
      /* A 430-question run is too much work to lose in silence. */
      shareStatusEl.textContent = strings.saveFailed;
    });
  }

  document.getElementById("again-btn").addEventListener("click", function () {
    startRound(state.category);
  });

  document.getElementById("home-btn").addEventListener("click", returnToMenu);

  for (var menuIndex = 0; menuIndex < menuBtns.length; menuIndex++) {
    (function (button) {
      /* The Hungarian group button carries no category — it opens a submenu. */
      if (!button.dataset.category) return;
      button.addEventListener("click", function () {
        startRound(button.dataset.category);
      });
    })(menuBtns[menuIndex]);
  }

  var hungarianGroupBtn = document.getElementById("hungarian-group-btn");
  hungarianGroupBtn.addEventListener("click", function () {
    show("hungarian");
    window.scrollTo(0, 0);
    screens.hungarian.querySelector(".menu-btn").focus();
  });

  /* Two exits on every screen — one above the content and one below it — so the
     way out is never further than the top or the bottom of the page. */
  function onExit(ids, handler) {
    ids.forEach(function (id) {
      var button = document.getElementById(id);
      if (button) button.addEventListener("click", handler);
    });
  }

  function backToHome(focusButton) {
    return function () {
      show("home");
      window.scrollTo(0, 0);
      if (focusButton) focusButton.focus();
      else focusFirst(screens.home);
    };
  }

  onExit(["hungarian-back-btn", "hungarian-back-btn-bottom"], backToHome(hungarianGroupBtn));

  /* ---------- Your best scores ---------- */

  var statsStatusEl = document.getElementById("stats-status");
  var statsHeadlineEl = document.getElementById("stats-headline");
  var statsCategoriesEl = document.getElementById("stats-categories");
  var statsRecentEl = document.getElementById("stats-recent");
  var statsCategoriesTitle = document.getElementById("stats-categories-title");
  var statsRecentTitle = document.getElementById("stats-recent-title");
  var statsLoaded = false;

  function plural(count, one, many) {
    return count === 1 ? one : many;
  }

  function shortDate(value) {
    if (!value) return "";
    var when = new Date(value);
    if (isNaN(when.getTime())) return "";
    return when.toLocaleDateString(undefined, {
      year: "numeric", month: "short", day: "numeric"
    });
  }

  function statTile(value, label) {
    var tile = document.createElement("div");
    tile.className = "stat-tile";
    var big = document.createElement("span");
    big.className = "stat-value";
    big.textContent = value;
    var small = document.createElement("span");
    small.className = "stat-label";
    small.textContent = label;
    tile.appendChild(big);
    tile.appendChild(small);
    return tile;
  }

  function statRow(title, detail, badge) {
    var row = document.createElement("div");
    row.className = "stat-row";
    if (badge) {
      var mark = document.createElement("span");
      mark.className = "stat-badge";
      mark.textContent = badge;
      row.appendChild(mark);
    }
    var copy = document.createElement("span");
    copy.className = "stat-copy";
    var heading = document.createElement("span");
    heading.className = "stat-row-title";
    heading.textContent = title;
    var sub = document.createElement("span");
    sub.className = "stat-row-detail";
    sub.textContent = detail;
    copy.appendChild(heading);
    copy.appendChild(sub);
    row.appendChild(copy);
    return row;
  }

  function renderStats(data) {
    var overall = data.overall || {};
    statsHeadlineEl.innerHTML = "";
    statsCategoriesEl.innerHTML = "";
    statsRecentEl.innerHTML = "";

    if (!overall.runs) {
      statsStatusEl.textContent = "You haven’t finished a round yet. Play one and your scores will appear here.";
      statsHeadlineEl.hidden = true;
      statsCategoriesTitle.hidden = true;
      statsRecentTitle.hidden = true;
      return;
    }

    var best = overall.best_run;
    statsStatusEl.textContent = best
      ? "Your longest run so far: " + best.score + " right in " + best.name + "."
      : "Here is how you are doing.";

    statsHeadlineEl.hidden = false;
    statsHeadlineEl.appendChild(statTile(String(overall.best_score), "Best run, any quiz"));
    statsHeadlineEl.appendChild(statTile(String(overall.runs), plural(overall.runs, "Round played", "Rounds played")));
    statsHeadlineEl.appendChild(statTile(overall.accuracy + "%", "Answers correct"));
    statsHeadlineEl.appendChild(statTile(String(overall.total_correct), "Right answers in total"));
    statsHeadlineEl.appendChild(statTile(String(overall.current_streak),
      plural(overall.current_streak, "Day in a row", "Days in a row")));
    statsHeadlineEl.appendChild(statTile(String(overall.longest_streak), "Longest run of days"));

    var categories = data.categories || [];
    statsCategoriesTitle.hidden = categories.length === 0;
    categories.forEach(function (category) {
      var detail = category.runs + " " + plural(category.runs, "round", "rounds") +
        "  •  " + category.accuracy + "% right";
      if (category.best_at) detail += "  •  best on " + shortDate(category.best_at);
      if (category.pool_size) {
        detail += "  •  " + category.pool_size + " questions in the quiz";
      }
      var row = statRow(category.name, detail, String(category.best_score));
      if (category.language_code === "hu") row.setAttribute("lang", "hu");
      statsCategoriesEl.appendChild(row);
    });

    var recent = data.recent || [];
    statsRecentTitle.hidden = recent.length === 0;
    recent.forEach(function (run) {
      var detail = shortDate(run.completed_at) + "  •  " + run.score + " right";
      if (!run.is_unlimited) detail += " out of " + run.total_questions;
      var row = statRow(run.name, detail, "");
      if (HUNGARIAN_CATEGORIES[run.category_id]) row.setAttribute("lang", "hu");
      statsRecentEl.appendChild(row);
    });
  }

  async function openStats() {
    openScreen("stats");
    if (statsLoaded) return;
    statsStatusEl.textContent = "Adding up your rounds…";
    try {
      var data = await window.QuizBackend.loadMyStats();
      statsLoaded = true;
      renderStats(data);
    } catch (error) {
      console.error("Could not load your scores:", error);
      statsStatusEl.textContent = "Your scores could not be loaded. Please check the internet connection and try again.";
    }
  }

  statsBtn.addEventListener("click", openStats);
  onExit(["stats-back-btn", "stats-back-btn-bottom"], backToHome(statsBtn));

  /* ---------- Bűnügyi történetek ---------- */

  var storiesStatusEl = document.getElementById("stories-status");
  var storiesListEl = document.getElementById("stories-list");
  var storyTitleEl = document.getElementById("story-title");
  var storyMetaEl = document.getElementById("story-meta");
  var storyBodyEl = document.getElementById("story-body");
  var storyClosingEl = document.getElementById("story-closing");
  var storyReadBtn = document.getElementById("story-read-btn");
  var videosStatusEl = document.getElementById("videos-status");
  var videosListEl = document.getElementById("videos-list");
  var videosWatchedToggle = document.getElementById("videos-watched-toggle");
  var crimeState = {
    stories: null,
    videos: null,
    views: {},
    openStory: null,
    showWatched: false,
    lastStoryButton: null,
    lastVideoButton: null
  };

  /* A video she has opened stays on the list for three hours, so she can go back
     to it, and then drops out of the way. The click itself is never deleted. */
  var WATCHED_GRACE_MS = 3 * 60 * 60 * 1000;

  function isRetired(view) {
    if (!view || !view.first_clicked_at) return false;
    var first = Date.parse(view.first_clicked_at);
    if (isNaN(first)) return false;
    return (Date.now() - first) > WATCHED_GRACE_MS;
  }

  function speakHungarian(text) {
    if (!speechOK || !text) return;
    var voice = voiceFor("hu");
    if (!voice) return;
    window.speechSynthesis.cancel();
    var utterance = new SpeechSynthesisUtterance(text);
    utterance.rate = 0.9;
    utterance.lang = "hu-HU";
    utterance.voice = voice;
    window.speechSynthesis.speak(utterance);
  }

  function crimeButton(emoji, title, detail, onClick) {
    var button = document.createElement("button");
    button.type = "button";
    button.className = "big-btn menu-btn";
    var mark = document.createElement("span");
    mark.className = "menu-emoji";
    mark.setAttribute("aria-hidden", "true");
    mark.textContent = emoji;
    var copy = document.createElement("span");
    var heading = document.createElement("span");
    heading.className = "menu-title";
    heading.textContent = title;
    var sub = document.createElement("span");
    sub.className = "menu-sub";
    sub.textContent = detail;
    copy.appendChild(heading);
    copy.appendChild(sub);
    button.appendChild(mark);
    button.appendChild(copy);
    button.addEventListener("click", onClick);
    return button;
  }

  function renderStoryList() {
    storiesListEl.innerHTML = "";
    var stories = crimeState.stories || [];
    if (!stories.length) {
      storiesStatusEl.textContent = "Még nincs itt egyetlen történet sem. Nézz vissza később!";
      return;
    }
    storiesStatusEl.textContent = stories.length === 1
      ? "Egy történet vár rád."
      : stories.length + " történet vár rád.";
    stories.forEach(function (story) {
      var detail = story.teaser;
      var tail = [story.place, story.year_label].filter(Boolean).join(", ");
      if (tail) detail += "  •  " + tail;
      detail += "  •  " + story.minutes + " perc olvasás";
      var button = crimeButton("📄", story.title, detail, function () {
        crimeState.lastStoryButton = button;
        openStory(story);
      });
      storiesListEl.appendChild(button);
    });
  }

  function openStory(story) {
    crimeState.openStory = story;
    storyTitleEl.textContent = story.title;
    var meta = [story.place, story.year_label].filter(Boolean).join(" • ");
    storyMetaEl.textContent = meta ? meta + " • " + story.minutes + " perc" : story.minutes + " perc";
    storyBodyEl.innerHTML = "";
    String(story.body).split(/\n\s*\n/).forEach(function (chunk) {
      var text = chunk.trim();
      if (!text) return;
      var paragraph = document.createElement("p");
      paragraph.textContent = text;
      storyBodyEl.appendChild(paragraph);
    });
    storyClosingEl.textContent = story.closing || "";
    storyClosingEl.hidden = !story.closing;
    openScreen("crimeStory");
    if (state.voiceOn) speakHungarian(story.title + ". " + story.body);
  }

  storyReadBtn.addEventListener("click", function () {
    var story = crimeState.openStory;
    if (!story) return;
    speakHungarian(story.title + ". " + story.body + " " + (story.closing || ""));
  });

  async function openStories() {
    openScreen("crimeStories");
    if (crimeState.stories) return;
    storiesStatusEl.textContent = "Töltöm a történeteket…";
    try {
      crimeState.stories = await window.QuizBackend.loadCrimeStories();
      renderStoryList();
    } catch (error) {
      console.error("Could not load the crime stories:", error);
      storiesStatusEl.textContent = "Nem sikerült betölteni a történeteket. Ellenőrizd az internetkapcsolatot.";
    }
  }

  function renderVideoList() {
    videosListEl.innerHTML = "";
    var videos = crimeState.videos || [];
    var hidden = 0;
    var shown = 0;

    videos.forEach(function (video) {
      var view = crimeState.views[video.id];
      var retired = isRetired(view);
      if (retired && !crimeState.showWatched) {
        hidden++;
        return;
      }
      if (crimeState.showWatched && !view) return;

      var detail = video.summary || "";
      if (video.channel) detail += (detail ? "  •  " : "") + video.channel;
      if (view) {
        detail += "  •  ✓ Megnézve " + shortDate(view.last_clicked_at);
      }
      var button = crimeButton(view ? "✅" : "▶️", video.title, detail, function () {
        crimeState.lastVideoButton = button;
        openVideo(video, button);
      });
      if (view) button.classList.add("is-watched");
      videosListEl.appendChild(button);
      shown++;
    });

    if (crimeState.showWatched) {
      videosStatusEl.textContent = shown
        ? shown + " videót néztél meg eddig."
        : "Még egy videót sem néztél meg.";
    } else if (!shown) {
      videosStatusEl.textContent = "Mindet megnézted! Alul előhozhatod a régieket.";
    } else {
      videosStatusEl.textContent = shown + " videó vár rád" +
        (hidden ? ", " + hidden + " pedig már lekerült a listáról." : ".");
    }

    videosWatchedToggle.hidden = false;
    videosWatchedToggle.textContent = crimeState.showWatched
      ? "⬅ Vissza a még meg nem nézett videókhoz"
      : "👁️ Amiket már megnéztem";
    videosWatchedToggle.setAttribute("aria-pressed", String(crimeState.showWatched));
  }

  function openVideo(video, button) {
    /* Open the tab first: a browser only treats window.open as wanted when it
       happens inside the click, so awaiting the write would get it blocked. */
    window.open("https://www.youtube.com/watch?v=" + video.youtube_id, "_blank", "noopener");
    button.classList.add("is-watched");
    window.QuizBackend.recordCrimeVideoClick(video.id).then(function (firstClickedAt) {
      crimeState.views[video.id] = {
        video_id: video.id,
        first_clicked_at: firstClickedAt || new Date().toISOString(),
        last_clicked_at: new Date().toISOString(),
        click_count: ((crimeState.views[video.id] || {}).click_count || 0) + 1
      };
      renderVideoList();
    }).catch(function (error) {
      console.error("Could not record the video click:", error);
    });
  }

  videosWatchedToggle.addEventListener("click", function () {
    crimeState.showWatched = !crimeState.showWatched;
    renderVideoList();
    window.scrollTo(0, 0);
    videosWatchedToggle.focus();
  });

  async function openVideos() {
    openScreen("crimeVideos");
    if (crimeState.videos) {
      /* Three hours may have passed while the page stayed open. */
      renderVideoList();
      return;
    }
    videosStatusEl.textContent = "Töltöm a videókat…";
    try {
      var payload = await window.QuizBackend.loadCrimeVideos();
      crimeState.videos = payload.videos;
      crimeState.views = payload.views;
      renderVideoList();
    } catch (error) {
      console.error("Could not load the crime videos:", error);
      videosStatusEl.textContent = "Nem sikerült betölteni a videókat. Ellenőrizd az internetkapcsolatot.";
    }
  }

  function openCrimeHub() {
    if (speechOK) window.speechSynthesis.cancel();
    openScreen("crime");
  }

  crimeBtn.addEventListener("click", openCrimeHub);
  document.getElementById("crime-stories-btn").addEventListener("click", openStories);
  document.getElementById("crime-videos-btn").addEventListener("click", openVideos);
  onExit(["crime-back-btn", "crime-back-btn-bottom"], backToHome(crimeBtn));
  onExit(["stories-back-btn", "stories-back-btn-bottom"], function () {
    if (speechOK) window.speechSynthesis.cancel();
    openCrimeHub();
  });
  onExit(["videos-back-btn", "videos-back-btn-bottom"], openCrimeHub);
  onExit(["story-back-btn", "story-back-btn-bottom"], function () {
    if (speechOK) window.speechSynthesis.cancel();
    show("crimeStories");
    window.scrollTo(0, 0);
    if (crimeState.lastStoryButton) crimeState.lastStoryButton.focus();
    else focusFirst(screens.crimeStories);
  });

  document.addEventListener("keydown", function (event) {
    if (screens.quiz.hidden || state.answered) return;
    var number = parseInt(event.key, 10);
    if (number >= 1 && number <= optionCount()) {
      var buttons = optionsEl.querySelectorAll(".option-btn");
      if (buttons[number - 1]) buttons[number - 1].click();
    }
  });

  async function initializeApp() {
    show("loading");
    try {
      await window.QuizBackend.initialize();
      show("home");
      focusFirst(screens.home);
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
  /* Dark is the default: she plays from the afternoon through to about 2am and
     has cataracts, where light scatter makes a bright page harder to read. An
     explicit choice still wins. */
  applyTheme(load("quiz-theme") === "light" ? "light" : "dark");
  state.voiceOn = load("quiz-voice") === "on";
  applyVoice();
  initializeApp();
})();
