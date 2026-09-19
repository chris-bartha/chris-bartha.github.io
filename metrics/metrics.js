(function () {
  "use strict";

  var AUTO_REFRESH_MS = 15000;
  var RETRY_REFRESH_MS = 30000;
  var CATEGORY_ICONS = {
    history: "🏛",
    geography: "◉",
    mix: "✦",
    hungarian: "◆",
    textbook_history: "▣",
    magyar_foldrajz: "▲",
    foldrajz_magyarul: "◍",
    magyar_irodalom: "✎",
    magyar_tudomany: "⚛",
    magyar_nepmesek: "❧",
    magyar_konyha: "♨",
    magyar_zene: "♪",
    regen_volt: "▤",
    tobb_vagy_kevesebb: "⇅",
    ket_igazsag: "🎭",
    time_traveler: "⌛",
    tricky_true_false: "⚖",
    psychology: "💭",
    fifth_grader: "🎓"
  };
  var CATEGORY_COLORS = {
    history: "#64a8ff",
    geography: "#53e0ce",
    mix: "#a78bfa",
    hungarian: "#f472b6",
    textbook_history: "#fb923c",
    magyar_foldrajz: "#facc15",
    foldrajz_magyarul: "#38bdf8",
    magyar_irodalom: "#c4b5fd",
    magyar_tudomany: "#4ade80",
    magyar_nepmesek: "#fdba74",
    magyar_konyha: "#f87171",
    magyar_zene: "#f0abfc",
    regen_volt: "#94a3b8",
    tobb_vagy_kevesebb: "#818cf8",
    ket_igazsag: "#34d399",
    time_traveler: "#a3e635",
    tricky_true_false: "#fb7185",
    psychology: "#e879f9",
    fifth_grader: "#f4c95d"
  };

  var dashboard = document.getElementById("dashboard");
  var loadingState = document.getElementById("loading-state");
  var errorState = document.getElementById("error-state");
  var errorMessage = document.getElementById("error-message");
  var dataStatus = document.getElementById("data-status");
  var refreshButton = document.getElementById("refresh-button");
  var scoreSelect = document.getElementById("score-select");
  var currentMetrics = null;
  var isLoading = false;
  var refreshTimer = null;
  var lastRefreshAt = 0;

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  function number(value) {
    return new Intl.NumberFormat().format(Number(value) || 0);
  }

  function percent(value) {
    return (Number(value) || 0).toFixed(Number(value) % 1 ? 1 : 0) + "%";
  }

  function duration(seconds) {
    var total = Math.max(0, Math.round(Number(seconds) || 0));
    if (total < 60) return total + "s";
    var minutes = Math.floor(total / 60);
    var remainder = total % 60;
    if (minutes < 60) return minutes + "m " + remainder + "s";
    return Math.floor(minutes / 60) + "h " + (minutes % 60) + "m";
  }

  function plural(value, singular, pluralWord) {
    return number(value) + " " + (Number(value) === 1 ? singular : (pluralWord || singular + "s"));
  }

  function dateTime(value, timezone) {
    if (!value) return "Never";
    return new Intl.DateTimeFormat(undefined, {
      month: "short",
      day: "numeric",
      hour: "numeric",
      minute: "2-digit",
      timeZone: timezone || undefined
    }).format(new Date(value));
  }

  function fullDateTime(value, timezone) {
    if (!value) return "Never";
    return new Intl.DateTimeFormat(undefined, {
      day: "numeric",
      month: "short",
      year: "numeric",
      hour: "numeric",
      minute: "2-digit",
      timeZone: timezone || undefined
    }).format(new Date(value));
  }

  function timeWithSeconds(value, timezone) {
    if (!value) return "—";
    return new Intl.DateTimeFormat(undefined, {
      hour: "numeric",
      minute: "2-digit",
      second: "2-digit",
      timeZone: timezone || undefined
    }).format(new Date(value));
  }

  function dateOnly(value) {
    if (!value) return "—";
    return new Intl.DateTimeFormat(undefined, { month: "short", day: "numeric" })
      .format(new Date(value + "T12:00:00"));
  }

  function setText(id, value) {
    document.getElementById(id).textContent = value;
  }

  function categoryIcon(id) {
    return CATEGORY_ICONS[id] || "●";
  }

  function scoreKey(item) {
    return item.score + "-" + item.total_questions;
  }

  /* The page is lang="en", so Hungarian quiz names need marking or a screen reader
     reads "Népmesék és közmondások" with English phonetics. language_code carries it. */
  var languageById = {};

  function languageAttr(id) {
    return languageById[id] && languageById[id] !== "en" ? ' lang="' + escapeHtml(languageById[id]) + '"' : "";
  }

  /* A run beats her instead of running out, so "plays" means runs plus any old ten-question rounds. */
  function categoryPlays(category) {
    return (Number(category.unlimited_quizzes) || 0) + (Number(category.quizzes) || 0);
  }

  function renderHero(metrics) {
    var overview = metrics.overview;
    var unlimited = metrics.unlimited || {};
    var runs = Number(unlimited.runs) || 0;
    var bestRun = (unlimited.top_runs || [])[0];

    setText("best-run", runs ? number(unlimited.best_score) : "—");
    /* top_runs can be empty or nameless while runs is not, so the note never claims there are none. */
    setText("best-run-note", runs
      ? (bestRun && bestRun.category_name
          ? bestRun.category_name + " · " + dateTime(bestRun.completed_at, metrics.timezone)
          : "Questions answered before a question beat her twice")
      : "No Unlimited runs yet");
    setText("total-runs", number(runs));
    setText("total-runs-note", runs
      ? number(unlimited.runs_last_30_days) + " in the last 30 days · " +
        percent(overview.unlimited_share) + " of all " + number(overview.total_sessions) + " rounds ever played"
      : "No Unlimited runs yet");
    setText("run-accuracy", runs ? percent(unlimited.accuracy) : "—");
    document.getElementById("accuracy-meter").style.width = Math.min(100, Number(unlimited.accuracy) || 0) + "%";
    setText("run-accuracy-note", number(unlimited.total_correct) + " correct from " +
      number(unlimited.questions_answered) + " questions in Unlimited");
    setText("current-streak", plural(overview.current_streak, "day"));
    setText("streak-note", "Longest: " + plural(overview.longest_streak, "day"));

    setText("quizzes-today", number(overview.quizzes_today));
    setText("today-note", overview.quizzes_today
      ? number(overview.unlimited_today) + " Unlimited · " + number(overview.standard_today) + " standard"
      : "No quizzes yet today");
    setText("questions-answered", number(overview.total_questions));
    setText("questions-answered-note", number(overview.question_bank) + " questions in the bank");
    setText("correct-answers", number(overview.total_correct));
    setText("correct-answers-note", percent(overview.accuracy) + " correct · all modes");
    setText("second-chances", number(overview.second_chance_correct));
    setText("second-chances-note", percent(overview.total_correct ? overview.second_chance_correct * 100 / overview.total_correct : 0) + " of all correct answers");
    setText("time-played", duration(overview.total_seconds));
    setText("time-played-note", runs ? "Average run " + duration(unlimited.average_duration_seconds) : "Since the first quiz");
    setText("month-total", number(overview.quizzes_last_30_days));
  }

  /* Every attempt counts here, in both modes — this is the one chart that has never changed meaning. */
  function renderActivity(metrics) {
    var activity = metrics.daily_activity || [];
    var chart = document.getElementById("activity-chart");
    if (!activity.length) {
      chart.removeAttribute("role");
      chart.removeAttribute("aria-label");
      chart.innerHTML = '<p class="empty-state">No activity recorded in the last 30 days.</p>';
      setText("chart-start", "30 days ago");
      return;
    }
    var max = Math.max.apply(null, activity.map(function (day) { return day.quizzes; }).concat([1]));
    document.getElementById("activity-chart").innerHTML = activity.map(function (day) {
      var height = day.quizzes ? Math.max(8, day.quizzes / max * 100) : 2;
      var className = day.quizzes ? "activity-bar" : "activity-bar zero";
      var standardShare = day.quizzes ? day.standard_quizzes / day.quizzes * 100 : 0;
      var unlimitedShare = day.quizzes ? day.unlimited_quizzes / day.quizzes * 100 : 0;
      var tip = dateOnly(day.date) + ": " + plural(day.quizzes, "session") +
        " · " + number(day.standard_quizzes) + " standard · " +
        number(day.unlimited_quizzes) + " Unlimited" +
        (day.best_unlimited_score ? " · best run " + number(day.best_unlimited_score) : "");
      return '<span class="' + className + '" style="height:' + height + '%" data-tip="' + escapeHtml(tip) + '">' +
        '<i class="activity-standard" style="height:' + standardShare + '%"></i>' +
        '<i class="activity-unlimited" style="height:' + unlimitedShare + '%"></i></span>';
    }).join("");
    /* The per-day numbers live in a hover tooltip, so the chart itself needs a spoken summary.
       max is floored at 1 to keep the bar heights finite, so the busiest day is counted again here. */
    var totalSessions = activity.reduce(function (sum, day) { return sum + (Number(day.quizzes) || 0); }, 0);
    var busiest = activity.reduce(function (top, day) { return Math.max(top, Number(day.quizzes) || 0); }, 0);
    var playedDays = activity.filter(function (day) { return day.quizzes; }).length;
    chart.setAttribute("role", "img");
    chart.setAttribute("aria-label", "Daily quiz activity from " + dateOnly(activity[0].date) +
      " to " + dateOnly(activity[activity.length - 1].date) + ": " +
      (totalSessions
        ? plural(totalSessions, "session") + " across " + plural(playedDays, "day") +
          ", busiest day " + plural(busiest, "session") + "."
        : "no quizzes played."));
    setText("chart-start", dateOnly(activity[0].date));
  }

  /* How far a run gets is the only score there is now, so the buckets replace the old 0–10 spread. */
  function renderRunLengths(metrics) {
    var unlimited = metrics.unlimited || {};
    var buckets = unlimited.run_lengths || [];
    var counted = buckets.filter(function (bucket) { return Number(bucket.runs) > 0; });
    setText("run-length-total", number(unlimited.runs));

    if (!counted.length) {
      document.getElementById("run-length-bars").innerHTML =
        '<p class="empty-state">Run lengths appear after the first Unlimited run.</p>';
      setText("run-length-caption", "No runs recorded yet.");
      return;
    }

    var max = Math.max.apply(null, counted.map(function (bucket) { return Number(bucket.runs) || 0; }));
    document.getElementById("run-length-bars").innerHTML = buckets.map(function (bucket) {
      var runs = Number(bucket.runs) || 0;
      var width = runs ? Math.max(2, runs / max * 100) : 0;
      return '<div class="runlength-row"><span class="runlength-label">' + escapeHtml(bucket.bucket) + '</span>' +
        '<div class="distribution-track"><div class="runlength-fill" style="width:' + width + '%"></div></div>' +
        '<span class="distribution-count">' + number(runs) + ' · ' + percent(bucket.share_percentage) + '</span></div>';
    }).join("");
    setText("run-length-caption", "Median run " + plural(unlimited.median_score, "question") +
      " · average " + number(unlimited.average_score) +
      " · longest " + number(unlimited.best_score) + ".");
  }

  function renderUnlimited(metrics) {
    var unlimited = metrics.unlimited || { runs: 0, best_score: 0, average_score: 0, second_chance_correct: 0, top_runs: [] };
    var runs = Number(unlimited.runs) || 0;
    setText("unlimited-over-100", runs ? number(unlimited.runs_over_100) : "—");
    setText("unlimited-average-score", runs ? number(unlimited.average_score) : "—");
    setText("unlimited-median-score", runs ? number(unlimited.median_score) : "—");
    setText("unlimited-average-time", runs ? duration(unlimited.average_duration_seconds) : "—");
    setText("unlimited-second-chances", number(unlimited.second_chance_correct));
    setText("unlimited-summary", runs
      ? plural(runs, "run") + " · " + number(unlimited.total_correct) + " correct answers · " +
        duration(unlimited.total_seconds) + " of playing"
      : "No Unlimited runs yet — the first record is waiting.");

    var topRuns = unlimited.top_runs || [];
    if (!topRuns.length) {
      document.getElementById("unlimited-top-runs").innerHTML =
        '<p class="empty-state unlimited-empty">Top scores will appear after the first Unlimited run.</p>';
      return;
    }

    document.getElementById("unlimited-top-runs").innerHTML = topRuns.map(function (run, index) {
      return '<article class="unlimited-record">' +
        '<span class="unlimited-rank">#' + (index + 1) + '</span>' +
        '<strong class="unlimited-score">' + number(run.score) + '</strong>' +
        '<div class="unlimited-record-copy"><b' + languageAttr(run.category_id) + '>' +
        escapeHtml(run.category_name) + '</b>' +
        '<span>' + escapeHtml(fullDateTime(run.completed_at, metrics.timezone)) + '</span></div>' +
        '<div class="unlimited-record-detail"><span>' + number(run.first_try_correct) + ' first try</span>' +
        '<span>' + number(run.second_try_correct) + ' second-chance</span>' +
        '<span>' + duration(run.duration_seconds) + '</span></div></article>';
    }).join("");
  }

  /* Her longest run against the whole bank: 100% means that quiz has nothing left to show her. */
  function renderCoverage(metrics) {
    var covered = metrics.categories.filter(function (category) {
      return Number(category.pool_size) > 0 && Number(category.unlimited_quizzes) > 0;
    }).sort(function (a, b) {
      return b.best_share_of_pool - a.best_share_of_pool || b.unlimited_best_score - a.unlimited_best_score;
    });
    setText("coverage-bank", number(metrics.overview.question_bank));

    if (!covered.length) {
      document.getElementById("coverage-bars").innerHTML =
        '<p class="empty-state">Coverage appears after the first Unlimited run.</p>';
      return;
    }

    document.getElementById("coverage-bars").innerHTML = covered.map(function (category) {
      var accent = CATEGORY_COLORS[category.id] || "#53e0ce";
      var share = Math.min(100, Number(category.best_share_of_pool) || 0);
      return '<div class="coverage-row" style="--category-accent:' + accent + '">' +
        '<span class="coverage-label"><i aria-hidden="true">' + categoryIcon(category.id) + '</i>' +
          '<span' + languageAttr(category.id) + '>' + escapeHtml(category.name) + '</span></span>' +
        '<div class="coverage-track"><div class="coverage-fill" style="width:' + Math.max(share ? 2 : 0, share) + '%"></div></div>' +
        '<span class="coverage-count"><b>' + percent(category.best_share_of_pool) + '</b>' +
          number(category.unlimited_best_score) + ' / ' + number(category.pool_size) + '</span></div>';
    }).join("");
  }

  function renderCategories(metrics) {
    var played = metrics.categories.filter(function (category) { return categoryPlays(category) > 0; });
    var mostPlayed = played.slice().sort(function (a, b) {
      return categoryPlays(b) - categoryPlays(a) || b.unlimited_best_score - a.unlimited_best_score;
    })[0];
    setText("favorite-category", mostPlayed
      ? "Most played: " + mostPlayed.name + " with " + plural(categoryPlays(mostPlayed), "play")
      : "No category results yet");

    document.getElementById("category-grid").innerHTML = metrics.categories.map(function (category) {
      var accent = CATEGORY_COLORS[category.id] || "#53e0ce";
      var runs = Number(category.unlimited_quizzes) || 0;
      var rounds = Number(category.quizzes) || 0;
      var pool = Number(category.pool_size) || 0;
      var last = category.last_played_at ? "Last played " + dateTime(category.last_played_at, metrics.timezone) : "Not played yet";
      var headline = "—";
      var headlineLabel = "not played yet";
      var barWidth = 0;
      var footnoteClass = "category-footnote is-waiting";
      var footnote = pool ? plural(pool, "question") + " waiting" : "No questions yet";
      var stats = '<span>Runs<b>0</b></span><span>Accuracy<b>—</b></span><span>Second chance<b>0</b></span>';

      if (runs) {
        headline = number(category.unlimited_best_score);
        headlineLabel = "best run";
        barWidth = Math.min(100, Number(category.best_share_of_pool) || 0);
        footnoteClass = "category-footnote is-unlimited";
        footnote = pool
          ? percent(category.best_share_of_pool) + " of its " + number(pool) + " questions in one run"
          : plural(category.unlimited_questions_answered, "question") + " answered";
        stats = '<span>Runs<b>' + number(runs) + '</b></span>' +
          '<span>Accuracy<b>' + percent(category.unlimited_accuracy) + '</b></span>' +
          '<span>Second chance<b>' + number(category.unlimited_second_chance_correct) + '</b></span>';
      } else if (rounds) {
        headline = number(rounds);
        headlineLabel = rounds === 1 ? "ten-question round" : "ten-question rounds";
        barWidth = Math.min(100, Number(category.average_percentage) || 0);
        footnoteClass = "category-footnote is-standard";
        footnote = "Still played ten questions at a time";
        stats = '<span>Average<b>' + percent(category.average_percentage) + '</b></span>' +
          '<span>Best<b>' + percent(category.best_percentage) + '</b></span>' +
          '<span>Perfect<b>' + number(category.perfect_scores) + '</b></span>';
      }

      return '<article class="category-card" style="--category-accent:' + accent + '">' +
        '<div class="category-card-top"><h3 class="category-name"' + languageAttr(category.id) + '>' +
        escapeHtml(category.name) +
        '</h3><span class="category-emoji" aria-hidden="true">' + categoryIcon(category.id) + '</span></div>' +
        '<strong class="category-count">' + headline + '</strong>' +
        '<span class="category-count-label">' + headlineLabel + '</span>' +
        '<div class="category-progress"><span style="width:' + barWidth + '%"></span></div>' +
        '<div class="category-stats">' + stats + '</div>' +
        '<p class="' + footnoteClass + '">' + escapeHtml(footnote) + '</p>' +
        '<p class="category-last">' + escapeHtml(last) + '</p></article>';
    }).join("");
  }

  function renderInsights(metrics) {
    var overview = metrics.overview;
    var unlimited = metrics.unlimited || {};
    var played = metrics.categories.filter(function (category) { return Number(category.unlimited_quizzes) > 0; });
    var deepest = played.slice().sort(function (a, b) { return b.best_share_of_pool - a.best_share_of_pool; })[0];
    var sharpest = played.slice().sort(function (a, b) { return b.unlimited_accuracy - a.unlimited_accuracy || b.unlimited_quizzes - a.unlimited_quizzes; })[0];
    var mostPlayed = metrics.categories.slice().sort(function (a, b) { return categoryPlays(b) - categoryPlays(a); })[0];
    var firstTryShare = overview.total_questions ? overview.first_try_correct * 100 / overview.total_questions : 0;
    var momentum = overview.quizzes_last_7_days === 0
      ? "No quizzes in the last 7 days"
      : plural(overview.quizzes_last_7_days, "quiz", "quizzes") + " in the last 7 days";
    var items = [
      { icon: "◎", label: "Furthest through a quiz", value: deepest ? deepest.name + " · " + percent(deepest.best_share_of_pool) + " of its questions" : "Waiting for a run" },
      { icon: "♛", label: "Sharpest quiz", value: sharpest ? sharpest.name + " · " + percent(sharpest.unlimited_accuracy) : "Waiting for a run" },
      { icon: "◫", label: "Most played", value: mostPlayed && categoryPlays(mostPlayed) ? mostPlayed.name + " · " + plural(categoryPlays(mostPlayed), "play") : "Waiting for a result" },
      { icon: "↗", label: "Recent momentum", value: momentum },
      { icon: "✓", label: "Right on the first try", value: percent(firstTryShare) + " of all questions" },
      { icon: "⚑", label: "Runs past 100 questions", value: plural(unlimited.runs_over_100, "run") },
      { icon: "◷", label: "Active days", value: plural(overview.active_days, "day") + " since tracking began" }
    ];
    document.getElementById("insights").innerHTML = items.map(function (item) {
      return '<div class="insight"><span class="insight-icon" aria-hidden="true">' + item.icon + '</span><div><p>' +
        escapeHtml(item.label) + '</p><strong>' + escapeHtml(item.value) + '</strong></div></div>';
    }).join("");
  }

  function renderRecent(metrics) {
    var rows = metrics.recent_results || [];
    var tbody = document.getElementById("recent-results");
    if (!rows.length) {
      tbody.innerHTML = '<tr><td colspan="7" class="empty-state">No completed quizzes yet.</td></tr>';
      return;
    }
    tbody.innerHTML = rows.map(function (result) {
      var unlimited = Boolean(result.is_unlimited);
      var score = unlimited ? number(result.score) + " correct" : result.score + "/" + result.total_questions;
      return "<tr><td>" + escapeHtml(dateTime(result.completed_at, metrics.timezone)) + "</td>" +
        '<td><span class="mode-badge ' + (unlimited ? "is-unlimited" : "") + '">' +
          (unlimited ? "Unlimited" : "Standard") + "</span></td>" +
        '<td><span class="table-category"><span aria-hidden="true">' + categoryIcon(result.category_id) + "</span>" +
          '<span' + languageAttr(result.category_id) + ">" + escapeHtml(result.category_name) + "</span></span></td>" +
        '<td><span class="score-badge ' + (unlimited ? "is-unlimited" : "") + '">' + escapeHtml(score) + "</span></td>" +
        "<td>" + number(result.first_try_correct) + "</td>" +
        "<td>" + number(result.second_try_correct) + "</td>" +
        "<td>" + duration(result.duration_seconds) + "</td></tr>";
    }).join("");
  }

  /* The ten-question era. Only Fifth Grader still adds to these, so they sit at the bottom. */
  function renderArchive(metrics) {
    var archive = metrics.archive || {};
    var overview = metrics.overview;
    var rounds = Number(archive.rounds) || 0;
    setText("archive-rounds", number(rounds));
    setText("archive-average", rounds ? percent(archive.average_percentage) : "—");
    document.getElementById("archive-meter").style.width = Math.min(100, Number(archive.average_percentage) || 0) + "%";
    setText("archive-best", rounds ? percent(archive.best_percentage) : "—");
    setText("archive-perfect", number(archive.perfect_scores));
    setText("archive-perfect-note", rounds
      ? percent(archive.perfect_scores * 100 / rounds) + " of those rounds"
      : "No ten-question rounds yet");
    setText("archive-summary", rounds
      ? percent(overview.unlimited_share) + " of every round she has ever played was Unlimited."
      : "No ten-question rounds recorded.");
    setText("archive-detail", rounds
      ? number(archive.total_correct) + " correct from " + number(archive.total_questions) +
        " questions · average round " + duration(archive.average_duration_seconds) +
        " · last one " + fullDateTime(archive.last_played_at, metrics.timezone)
      : "—");
  }

  function renderScoreChoice(key) {
    if (!currentMetrics || !currentMetrics.score_distribution.length) {
      document.getElementById("score-spotlight").innerHTML = '<p class="empty-state">No scores yet.</p>';
      document.getElementById("score-categories").innerHTML = "";
      return;
    }

    var item = currentMetrics.score_distribution.filter(function (candidate) {
      return scoreKey(candidate) === key;
    })[0] || currentMetrics.score_distribution[0];
    document.getElementById("score-spotlight").innerHTML =
      "<strong>" + number(item.quizzes) + "</strong>" +
      "<b>" + escapeHtml(item.score + "/" + item.total_questions) + " scores</b>" +
      "<span>" + percent(item.share_percentage) + " of all ten-question rounds · latest " +
        escapeHtml(dateTime(item.latest_at, currentMetrics.timezone)) + "</span>";

    document.getElementById("score-categories").innerHTML = item.categories.map(function (category) {
      return '<span class="score-chip"' + languageAttr(category.id) + '>' + escapeHtml(category.name) +
        ' <b>×' + number(category.quizzes) + '</b></span>';
    }).join("");
  }

  function renderScorePicker(metrics) {
    var distribution = metrics.score_distribution || [];
    if (!distribution.length) {
      scoreSelect.innerHTML = '<option>No scores yet</option>';
      scoreSelect.disabled = true;
      renderScoreChoice("");
      return;
    }

    var previousSelection = scoreSelect.value;
    scoreSelect.disabled = false;
    scoreSelect.innerHTML = distribution.map(function (item) {
      return '<option value="' + scoreKey(item) + '">' + escapeHtml(item.score + "/" + item.total_questions) +
        " — " + plural(item.quizzes, "round") + "</option>";
    }).join("");
    if (distribution.some(function (item) { return scoreKey(item) === previousSelection; })) {
      scoreSelect.value = previousSelection;
    }
    renderScoreChoice(scoreSelect.value);
  }

  function renderDistribution(metrics) {
    var distribution = metrics.score_distribution || [];
    if (!distribution.length) {
      document.getElementById("distribution-bars").innerHTML = '<p class="empty-state">No ten-question rounds were recorded.</p>';
      return;
    }
    var max = Math.max.apply(null, distribution.map(function (item) { return Number(item.quizzes) || 0; }).concat([1]));
    document.getElementById("distribution-bars").innerHTML = distribution.map(function (item) {
      return '<div class="distribution-row"><span class="distribution-label">' +
        escapeHtml(item.score + "/" + item.total_questions) + '</span><div class="distribution-track">' +
        '<div class="distribution-fill" style="width:' + ((Number(item.quizzes) || 0) / max * 100) + '%"></div></div>' +
        '<span class="distribution-count">' + number(item.quizzes) + ' · ' + percent(item.share_percentage) + '</span></div>';
    }).join("");
  }

  function render(metrics) {
    currentMetrics = metrics;
    languageById = {};
    metrics.categories.forEach(function (category) { languageById[category.id] = category.language_code; });
    renderHero(metrics);
    renderActivity(metrics);
    renderRunLengths(metrics);
    renderUnlimited(metrics);
    renderCoverage(metrics);
    renderCategories(metrics);
    renderInsights(metrics);
    renderRecent(metrics);
    renderArchive(metrics);
    renderScorePicker(metrics);
    renderDistribution(metrics);

    loadingState.hidden = true;
    errorState.hidden = true;
    dashboard.hidden = false;
    dataStatus.textContent = "Live · refreshed at " +
      timeWithSeconds(metrics.generated_at, metrics.timezone) +
      " · every 15 seconds";
    setText("footer-timezone", "Times shown in " + metrics.timezone);
  }

  function showError(error) {
    if (currentMetrics) {
      dataStatus.textContent = "Live refresh paused · retrying in 30 seconds";
      return;
    }
    loadingState.hidden = true;
    dashboard.hidden = true;
    errorState.hidden = false;
    errorMessage.textContent = error && error.message ? error.message : "Check the connection and try again.";
    dataStatus.textContent = "Database unavailable";
  }

  function scheduleRefresh(delay) {
    if (refreshTimer) clearTimeout(refreshTimer);
    refreshTimer = null;
    if (document.visibilityState !== "visible") return;
    refreshTimer = setTimeout(function () {
      loadMetrics({ background: true });
    }, delay || AUTO_REFRESH_MS);
  }

  async function loadMetrics(options) {
    if (isLoading) return;
    if (refreshTimer) clearTimeout(refreshTimer);
    refreshTimer = null;
    isLoading = true;
    var background = options && options.background;
    var nextRefresh = AUTO_REFRESH_MS;
    if (!background) {
      refreshButton.classList.add("is-loading");
      refreshButton.disabled = true;
    }

    try {
      var config = window.QUIZ_CONFIG || {};
      if (!config.supabaseUrl || !config.supabasePublishableKey) {
        throw new Error("The dashboard database configuration is missing.");
      }
      var timezone = "UTC";
      try { timezone = Intl.DateTimeFormat().resolvedOptions().timeZone || "UTC"; } catch (error) { /* UTC is safe. */ }

      var response = await fetch(config.supabaseUrl + "/rest/v1/rpc/get_quiz_public_metrics", {
        method: "POST",
        cache: "no-store",
        headers: {
          apikey: config.supabasePublishableKey,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ viewer_timezone: timezone })
      });
      if (!response.ok) {
        var detail = await response.text();
        throw new Error(response.status === 401 || response.status === 403
          ? "The metrics endpoint is not available to this browser yet."
          : "The database returned an error" + (detail ? "." : "."));
      }
      var metrics = await response.json();
      if (!metrics || !metrics.overview || !Array.isArray(metrics.categories)) {
        throw new Error("The metrics response was incomplete.");
      }
      lastRefreshAt = Date.now();
      render(metrics);
    } catch (error) {
      nextRefresh = RETRY_REFRESH_MS;
      showError(error);
    } finally {
      isLoading = false;
      if (!background) {
        refreshButton.classList.remove("is-loading");
        refreshButton.disabled = false;
      }
      scheduleRefresh(nextRefresh);
    }
  }

  scoreSelect.addEventListener("change", function () {
    renderScoreChoice(scoreSelect.value);
  });
  refreshButton.addEventListener("click", function () {
    loadMetrics({ background: false });
  });
  document.getElementById("retry-button").addEventListener("click", function () {
    loadMetrics({ background: false });
  });
  document.addEventListener("visibilitychange", function () {
    if (document.visibilityState !== "visible") {
      if (refreshTimer) clearTimeout(refreshTimer);
      refreshTimer = null;
      return;
    }
    if (!lastRefreshAt || Date.now() - lastRefreshAt >= AUTO_REFRESH_MS) {
      loadMetrics({ background: true });
    } else {
      scheduleRefresh(AUTO_REFRESH_MS - (Date.now() - lastRefreshAt));
    }
  });
  window.addEventListener("pagehide", function () {
    if (refreshTimer) clearTimeout(refreshTimer);
  });

  try { localStorage.removeItem("quiz-metrics-cache-v1"); } catch (error) { /* Old cache cleanup is optional. */ }
  loadMetrics({ background: false });
}());
