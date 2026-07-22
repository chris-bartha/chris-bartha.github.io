/* Quiz Time! — Supabase data, anonymous identity, and score tracking. */
(function () {
  "use strict";

  var RESULT_TABLES = {
    history: "history_quiz_results",
    geography: "geography_quiz_results",
    hungarian: "hungarian_quiz_results",
    textbook_history: "textbook_history_quiz_results",
    fifth_grader: "fifth_grader_quiz_results"
  };
  var client = null;
  var userId = null;
  var deviceId = null;
  var questionCache = {};

  function loadLocal(key) {
    try { return localStorage.getItem(key); } catch (error) { return null; }
  }

  function saveLocal(key, value) {
    try { localStorage.setItem(key, value); } catch (error) { /* Storage may be blocked. */ }
  }

  function makeId() {
    if (window.crypto && typeof window.crypto.randomUUID === "function") {
      return window.crypto.randomUUID();
    }
    return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (char) {
      var random = Math.random() * 16 | 0;
      var value = char === "x" ? random : (random & 3 | 8);
      return value.toString(16);
    });
  }

  function readableError(error, fallback) {
    if (!error) return fallback;
    if (error.message) return error.message;
    return fallback;
  }

  async function initialize() {
    var config = window.QUIZ_CONFIG;
    if (!config || !config.supabaseUrl || !config.supabasePublishableKey ||
        config.supabasePublishableKey.indexOf("__") === 0) {
      throw new Error("The quiz database connection has not been configured yet.");
    }
    if (!window.supabase || typeof window.supabase.createClient !== "function") {
      throw new Error("The quiz database library could not be loaded.");
    }

    client = window.supabase.createClient(
      config.supabaseUrl,
      config.supabasePublishableKey,
      {
        auth: {
          persistSession: true,
          autoRefreshToken: true,
          detectSessionInUrl: false,
          storageKey: "quiz-time-anonymous-session"
        }
      }
    );

    var sessionResult = await client.auth.getSession();
    if (sessionResult.error) {
      throw new Error(readableError(sessionResult.error, "Could not restore this quiz player."));
    }

    var session = sessionResult.data.session;
    if (!session) {
      var signInResult = await client.auth.signInAnonymously();
      if (signInResult.error || !signInResult.data.user) {
        throw new Error(readableError(signInResult.error, "Could not create a private quiz player."));
      }
      userId = signInResult.data.user.id;
    } else {
      userId = session.user.id;
    }

    deviceId = loadLocal("quiz-time-device-id") || makeId();
    saveLocal("quiz-time-device-id", deviceId);

    var profileResult = await client.from("quiz_players").upsert({
      user_id: userId,
      device_id: deviceId,
      browser_language: navigator.language || null,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || null,
      last_seen_at: new Date().toISOString()
    }, { onConflict: "user_id" });

    if (profileResult.error) {
      throw new Error(readableError(profileResult.error, "Could not register this quiz player."));
    }
  }

  function mapQuestion(row) {
    return {
      id: row.id,
      cat: row.category_id,
      q: row.prompt,
      a: row.correct_answer,
      w: row.wrong_answers,
      grade: row.grade_level,
      subject: row.subject,
      timesShown: Number(row.times_shown) || 0,
      timesAnswered: Number(row.times_answered) || 0,
      timesCorrect: Number(row.times_correct) || 0
    };
  }

  async function loadQuestions(category) {
    if (questionCache[category]) return questionCache[category].slice();
    if (!client || !userId) throw new Error("The quiz database is not ready.");

    var result = await client
      .from("quiz_questions")
      .select("id, category_id, prompt, correct_answer, wrong_answers, grade_level, subject, times_shown, times_answered, times_correct")
      .eq("category_id", category)
      .eq("is_active", true)
      .order("display_order", { ascending: true });

    if (result.error) {
      throw new Error(readableError(result.error, "Could not load the questions."));
    }

    questionCache[category] = result.data.map(mapQuestion);
    return questionCache[category].slice();
  }

  async function recordQuestionViews(questions) {
    if (!client || !userId || !questions || !questions.length) return;

    var questionIds = questions.map(function (question) { return question.id; });
    var result = await client.rpc("record_question_views", {
      selected_question_ids: questionIds
    });

    if (result.error) {
      throw new Error(readableError(result.error, "Could not update question variety."));
    }
  }

  async function recordResult(category, result) {
    var table = RESULT_TABLES[category];
    if (!table || !client || !userId) return;

    var insertResult = await client.from(table).insert({
      user_id: userId,
      score: result.score,
      total_questions: result.totalQuestions,
      first_try_correct: result.firstTryCorrect,
      second_try_correct: result.secondTryCorrect,
      is_unlimited: Boolean(result.isUnlimited),
      started_at: result.startedAt,
      duration_seconds: result.durationSeconds,
      answers: result.answers,
      lifelines_used: result.lifelinesUsed
    });

    if (insertResult.error) {
      throw new Error(readableError(insertResult.error, "Could not save the quiz score."));
    }
  }

  window.QuizBackend = {
    initialize: initialize,
    loadQuestions: loadQuestions,
    recordQuestionViews: recordQuestionViews,
    recordResult: recordResult
  };
})();
