(function () {
  "use strict";

  var AUTO_REFRESH_MS = 15000;
  var RETRY_REFRESH_MS = 30000;
  var CATEGORY_ICONS = {
    history: "🏛",
    geography: "◉",
    mix: "✦",
    hungarian: "◆",
    fifth_grader: "🎓"
  };
  var CATEGORY_COLORS = {
    history: "#64a8ff",
    geography: "#53e0ce",
    mix: "#a78bfa",
    hungarian: "#f472b6",
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

  function renderHero(metrics) {
    var overview = metrics.overview;
    setText("total-quizzes", number(overview.total_quizzes));
    setText("total-quizzes-note", "Standard rounds · Unlimited tracked separately");
    setText("quizzes-today", number(overview.quizzes_today));
    setText("today-note", overview.quizzes_today
      ? number(overview.standard_today) + " standard · " + number(overview.unlimited_today) + " Unlimited"
      : "No quizzes yet today");
    setText("average-score", percent(overview.average_percentage));
    document.getElementById("average-meter").style.width = Math.min(100, Number(overview.average_percentage) || 0) + "%";
    setText("average-note", number(overview.standard_total_correct) + " correct from " +
      number(overview.standard_total_questions) + " standard questions");
    setText("perfect-scores", number(overview.perfect_scores));
    setText("perfect-note", overview.total_quizzes
      ? percent(overview.perfect_scores * 100 / overview.total_quizzes) + " of standard quizzes"
      : "No standard scores yet");

    setText("correct-answers", number(overview.total_correct));
    setText("correct-answers-note", number(overview.total_questions) + " questions · all modes");
    setText("second-chances", number(overview.second_chance_correct));
    setText("second-chances-note", percent(overview.total_correct ? overview.second_chance_correct * 100 / overview.total_correct : 0) + " of all correct answers");
    setText("unlimited-runs", number(overview.unlimited_quizzes));
    setText("average-time", duration(overview.average_duration_seconds));
    setText("current-streak", plural(overview.current_streak, "day"));
    setText("streak-note", "Longest: " + plural(overview.longest_streak, "day"));
    setText("month-total", number(overview.quizzes_last_30_days));
  }

  function renderActivity(metrics) {
    var activity = metrics.daily_activity || [];
    var max = Math.max.apply(null, activity.map(function (day) { return day.quizzes; }).concat([1]));
    document.getElementById("activity-chart").innerHTML = activity.map(function (day) {
      var height = day.quizzes ? Math.max(8, day.quizzes / max * 100) : 2;
      var className = day.quizzes ? "activity-bar" : "activity-bar zero";
      var standardShare = day.quizzes ? day.standard_quizzes / day.quizzes * 100 : 0;
      var unlimitedShare = day.quizzes ? day.unlimited_quizzes / day.quizzes * 100 : 0;
      var tip = dateOnly(day.date) + ": " + plural(day.quizzes, "session") +
        " · " + number(day.standard_quizzes) + " standard · " +
        number(day.unlimited_quizzes) + " Unlimited";
      return '<span class="' + className + '" style="height:' + height + '%" data-tip="' + escapeHtml(tip) + '">' +
        '<i class="activity-standard" style="height:' + standardShare + '%"></i>' +
        '<i class="activity-unlimited" style="height:' + unlimitedShare + '%"></i></span>';
    }).join("");
    setText("chart-start", activity.length ? dateOnly(activity[0].date) : "30 days ago");
  }

  function renderUnlimited(metrics) {
    var unlimited = metrics.unlimited || { runs: 0, best_score: 0, average_score: 0, second_chance_correct: 0, top_runs: [] };
    var runs = Number(unlimited.runs) || 0;
    setText("unlimited-run-count", number(runs));
    setText("unlimited-best-score", runs ? number(unlimited.best_score) : "—");
    setText("unlimited-average-score", runs ? number(unlimited.average_score) : "—");
    setText("unlimited-second-chances", number(unlimited.second_chance_correct));
    setText("unlimited-summary", runs
      ? plural(runs, "run") + " · " + number(unlimited.total_correct) + " correct answers"
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
        '<div class="unlimited-record-copy"><b>' + escapeHtml(run.category_name) + '</b>' +
        '<span>' + escapeHtml(fullDateTime(run.completed_at, metrics.timezone)) + '</span></div>' +
        '<div class="unlimited-record-detail"><span>' + number(run.second_try_correct) + ' second-chance</span>' +
        '<span>' + duration(run.duration_seconds) + '</span></div></article>';
    }).join("");
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
      "<span>" + percent(item.share_percentage) + " of all completed quizzes · latest " +
        escapeHtml(dateTime(item.latest_at, currentMetrics.timezone)) + "</span>";

    document.getElementById("score-categories").innerHTML = item.categories.map(function (category) {
      return '<span class="score-chip">' + escapeHtml(category.name) + ' <b>×' + number(category.quizzes) + '</b></span>';
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
        " — " + plural(item.quizzes, "quiz", "quizzes") + "</option>";
    }).join("");
    if (distribution.some(function (item) { return scoreKey(item) === previousSelection; })) {
      scoreSelect.value = previousSelection;
    }
    renderScoreChoice(scoreSelect.value);
  }

  function renderCategories(metrics) {
    var played = metrics.categories.filter(function (category) { return category.quizzes > 0; });
    var mostPlayed = played.slice().sort(function (a, b) { return b.quizzes - a.quizzes || b.average_percentage - a.average_percentage; })[0];
    setText("favorite-category", mostPlayed
      ? "Most played: " + mostPlayed.name + " with " + plural(mostPlayed.quizzes, "quiz", "quizzes")
      : "No category results yet");

    document.getElementById("category-grid").innerHTML = metrics.categories.map(function (category) {
      var accent = CATEGORY_COLORS[category.id] || "#53e0ce";
      var last = category.last_played_at ? "Last played " + dateTime(category.last_played_at, metrics.timezone) : "Not played yet";
      return '<article class="category-card" style="--category-accent:' + accent + '">' +
        '<div class="category-card-top"><h3 class="category-name">' + escapeHtml(category.name) +
        '</h3><span class="category-emoji">' + categoryIcon(category.id) + '</span></div>' +
        '<strong class="category-count">' + number(category.quizzes) + '</strong>' +
        '<span class="category-count-label">' + (category.quizzes === 1 ? "quiz" : "quizzes") + '</span>' +
        '<div class="category-progress"><span style="width:' + Math.min(100, Number(category.average_percentage) || 0) + '%"></span></div>' +
        '<div class="category-stats"><span>Average<b>' + percent(category.average_percentage) + '</b></span>' +
        '<span>Best<b>' + percent(category.best_percentage) + '</b></span>' +
        '<span>Perfect<b>' + number(category.perfect_scores) + '</b></span></div>' +
        '<p class="category-unlimited">' + (category.unlimited_quizzes
          ? plural(category.unlimited_quizzes, "Unlimited run") + ' · best ' + number(category.unlimited_best_score)
          : 'No Unlimited runs') + '</p>' +
        '<p class="category-last">' + escapeHtml(last) + '</p></article>';
    }).join("");
  }

  function renderDistribution(metrics) {
    var distribution = metrics.score_distribution || [];
    if (!distribution.length) {
      document.getElementById("distribution-bars").innerHTML = '<p class="empty-state">Scores will appear here after the first quiz.</p>';
      return;
    }
    var max = Math.max.apply(null, distribution.map(function (item) { return item.quizzes; }));
    document.getElementById("distribution-bars").innerHTML = distribution.map(function (item) {
      return '<div class="distribution-row"><span class="distribution-label">' +
        escapeHtml(item.score + "/" + item.total_questions) + '</span><div class="distribution-track">' +
        '<div class="distribution-fill" style="width:' + (item.quizzes / max * 100) + '%"></div></div>' +
        '<span class="distribution-count">' + number(item.quizzes) + ' · ' + percent(item.share_percentage) + '</span></div>';
    }).join("");
  }

  function renderInsights(metrics) {
    var overview = metrics.overview;
    var played = metrics.categories.filter(function (category) { return category.quizzes > 0; });
    var strongest = played.slice().sort(function (a, b) { return b.average_percentage - a.average_percentage || b.quizzes - a.quizzes; })[0];
    var mostPlayed = played.slice().sort(function (a, b) { return b.quizzes - a.quizzes; })[0];
    var firstTryShare = overview.total_questions ? overview.first_try_correct * 100 / overview.total_questions : 0;
    var momentum = overview.quizzes_last_7_days === 0
      ? "No quizzes in the last 7 days"
      : plural(overview.quizzes_last_7_days, "quiz", "quizzes") + " in the last 7 days";
    var items = [
      { icon: "♛", label: "Strongest category", value: strongest ? strongest.name + " · " + percent(strongest.average_percentage) : "Waiting for a result" },
      { icon: "◫", label: "Most played", value: mostPlayed ? mostPlayed.name + " · " + plural(mostPlayed.quizzes, "quiz", "quizzes") : "Waiting for a result" },
      { icon: "↗", label: "Recent momentum", value: momentum },
      { icon: "✓", label: "Right on the first try", value: percent(firstTryShare) + " of all questions" },
      { icon: "◷", label: "Active days", value: plural(overview.active_days, "day") + " since tracking began" }
    ];
    document.getElementById("insights").innerHTML = items.map(function (item) {
      return '<div class="insight"><span class="insight-icon">' + item.icon + '</span><div><p>' +
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
        '<td><span class="table-category"><span>' + categoryIcon(result.category_id) + "</span>" + escapeHtml(result.category_name) + "</span></td>" +
        '<td><span class="score-badge ' + (unlimited ? "is-unlimited" : "") + '">' + escapeHtml(score) + "</span></td>" +
        "<td>" + number(result.first_try_correct) + "</td>" +
        "<td>" + number(result.second_try_correct) + "</td>" +
        "<td>" + duration(result.duration_seconds) + "</td></tr>";
    }).join("");
  }

  function render(metrics) {
    currentMetrics = metrics;
    renderHero(metrics);
    renderActivity(metrics);
    renderUnlimited(metrics);
    renderScorePicker(metrics);
    renderCategories(metrics);
    renderDistribution(metrics);
    renderInsights(metrics);
    renderRecent(metrics);

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
