/* Quiz Time! — Supabase data, anonymous identity, and score tracking. */
(function () {
  "use strict";

  var RESULT_TABLES = {
    history: "history_quiz_results",
    geography: "geography_quiz_results",
    hungarian: "hungarian_quiz_results",
    magyar_foldrajz: "magyar_foldrajz_quiz_results",
    foldrajz_magyarul: "foldrajz_magyarul_quiz_results",
    magyar_irodalom: "magyar_irodalom_quiz_results",
    magyar_tudomany: "magyar_tudomany_quiz_results",
    magyar_nepmesek: "magyar_nepmesek_quiz_results",
    magyar_konyha: "magyar_konyha_quiz_results",
    magyar_zene: "magyar_zene_quiz_results",
    regen_volt: "regen_volt_quiz_results",
    tobb_vagy_kevesebb: "tobb_vagy_kevesebb_quiz_results",
    ket_igazsag: "ket_igazsag_quiz_results",
    time_traveler: "time_traveler_quiz_results",
    tricky_true_false: "tricky_true_false_quiz_results",
    psychology: "psychology_quiz_results",
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
      /* Null on most questions. Two categories make the payoff the real figure
         behind the answer, so the quiz shows it once the answer is revealed. */
      why: row.explanation || null,
      grade: row.grade_level,
      subject: row.subject,
      timesShown: Number(row.times_shown) || 0,
      timesAnswered: Number(row.times_answered) || 0,
      timesCorrect: Number(row.times_correct) || 0,
      lastAnsweredAt: row.last_answered_at || null
    };
  }

  async function loadQuestions(category) {
    if (questionCache[category]) return questionCache[category].slice();
    if (!client || !userId) throw new Error("The quiz database is not ready.");

    var result = await client
      .from("quiz_questions")
      .select("id, category_id, prompt, correct_answer, wrong_answers, explanation, grade_level, subject, times_shown, times_answered, times_correct, last_answered_at")
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

  function viewerTimezone() {
    try {
      return Intl.DateTimeFormat().resolvedOptions().timeZone || "UTC";
    } catch (error) {
      return "UTC";
    }
  }

  /* The numbers behind the "Your best scores" screen. Deliberately the same for
     every viewer: identity is anonymous auth in localStorage, so filtering to the
     caller would show an empty screen on any device but the one she plays on.
     Everything it returns is an aggregate /metrics already publishes. */
  async function loadBestScores() {
    if (!client) throw new Error("The quiz database is not ready.");

    var result = await client.rpc("get_quiz_best_scores", {
      viewer_timezone: viewerTimezone()
    });

    if (result.error) {
      throw new Error(readableError(result.error, "Could not add up the scores."));
    }
    return result.data;
  }

  var crimeCache = { stories: null, videos: null };

  async function loadCrimeStories() {
    if (crimeCache.stories) return crimeCache.stories.slice();
    if (!client || !userId) throw new Error("The quiz database is not ready.");

    var result = await client
      .from("crime_stories")
      .select("id, title, teaser, body, year_label, place, closing, minutes")
      .eq("is_active", true)
      .order("display_order", { ascending: true });

    if (result.error) {
      throw new Error(readableError(result.error, "Nem sikerült betölteni a történeteket."));
    }

    crimeCache.stories = result.data;
    return crimeCache.stories.slice();
  }

  /* Both halves in one call: the videos themselves, and which of them this
     player has already opened. The three-hour grace period is worked out in the
     app from first_clicked_at, so nothing here is ever deleted. */
  async function loadCrimeVideos() {
    if (crimeCache.videos) return crimeCache.videos;
    if (!client || !userId) throw new Error("The quiz database is not ready.");

    var videoResult = await client
      .from("crime_videos")
      .select("id, youtube_id, title, channel, summary, case_name")
      .eq("is_active", true)
      .order("display_order", { ascending: true });

    if (videoResult.error) {
      throw new Error(readableError(videoResult.error, "Nem sikerült betölteni a videókat."));
    }

    var viewResult = await client
      .from("crime_video_views")
      .select("video_id, first_clicked_at, last_clicked_at, click_count");

    if (viewResult.error) {
      throw new Error(readableError(viewResult.error, "Nem sikerült betölteni a megnézett videókat."));
    }

    var views = {};
    viewResult.data.forEach(function (row) {
      views[row.video_id] = row;
    });

    crimeCache.videos = { videos: videoResult.data, views: views };
    return crimeCache.videos;
  }

  async function recordCrimeVideoClick(videoId) {
    if (!client || !userId) return null;

    var result = await client.rpc("record_crime_video_click", {
      target_video_id: videoId
    });

    if (result.error) {
      throw new Error(readableError(result.error, "Nem sikerült elmenteni, hogy megnyitottad."));
    }

    /* Keep the cached copy in step so the list can re-render without a refetch. */
    if (crimeCache.videos) {
      var existing = crimeCache.videos.views[videoId];
      crimeCache.videos.views[videoId] = {
        video_id: videoId,
        first_clicked_at: existing ? existing.first_clicked_at : result.data,
        last_clicked_at: new Date().toISOString(),
        click_count: existing ? (existing.click_count + 1) : 1
      };
    }
    return result.data;
  }

  window.QuizBackend = {
    initialize: initialize,
    loadQuestions: loadQuestions,
    recordQuestionViews: recordQuestionViews,
    recordResult: recordResult,
    loadBestScores: loadBestScores,
    loadCrimeStories: loadCrimeStories,
    loadCrimeVideos: loadCrimeVideos,
    recordCrimeVideoClick: recordCrimeVideoClick
  };
})();
