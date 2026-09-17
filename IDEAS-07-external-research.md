# External research — standards, prior art, content sources

Produced 2026-09-16. Sources cited; confidence marked per finding.

---

## 1. Low-vision and older-adult design guidance

- **WCAG 2.2 SC 2.5.8 Target Size (Minimum) is only 24×24 CSS px** (Level AA).
  Your 4.2rem full-width buttons clear it by roughly 3×. *Verified —
  [w3.org](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)*
- **WCAG 2.2 SC 3.3.8 Accessible Authentication (AA)** — "don't make people solve,
  recall or transcribe something to log in." **Your anonymous-auth design satisfies
  this perfectly.** Worth recording as a deliberate conformance win, not an
  accident. *Verified*
- **SC 1.4.4 Resize Text specifies exactly 200%** — which your A−/A+ ceiling
  matches. But the standard means *browser* zoom; custom controls don't exempt the
  site. Confirm browser zoom still works *on top of* A+ without clipping. *Verified*
- **On the 22px base:** RNIB treats 16pt (~21.3px) as the *threshold* of large
  print and notes most requests are for 18–20pt; APH is stricter, calling anything
  between 12 and 18pt merely "enlarged". The Game Accessibility Guidelines put the
  floor at 28px. *Likely*

  > **Correction — this does not apply to your site as shipped.** The agent read
  > `html { font-size: 22px }` but missed that `state.fontStep` defaults to **1 =
  > 115%**, so she actually renders at **25.3px ≈ 19pt**, above APH's 18pt bar.
  > Only pressing A− drops her below it. No change needed.

- **The W3C's own low-vision document refuses to give numbers**, framing needs as
  capabilities ("users can change the text size") because they vary individually.
  A useful antidote to anyone citing "the standard says X px". *Verified —
  [w3.org/TR/low-vision-needs](https://www.w3.org/TR/low-vision-needs/)*
- **COGA "Making Content Usable"** — three objectives you're likely missing: *allow
  pauses and breaks*, *show progress through a workflow*, and *include time
  estimates*. A 100+ question Unlimited run has no progress marker and no pause.
  COGA also endorses literal language over idiom, independently validating your
  plain-language rule. *Verified — [w3.org/TR/coga-usable](https://www.w3.org/TR/coga-usable/)*
- **WCAG 3.0 is a Working Draft**; Candidate Recommendation not anticipated before
  Q4 2027, and the contrast algorithm is still undecided. **Don't build to it.**
- **Dark mode is not automatically better for low vision.** A 2024 study found a
  *light* mode advantage for both younger and older adults on acuity and
  proofreading. The dark-mode advantage is specific to people with **cloudy ocular
  media — cataracts** — where light scatter dominates. *Likely —
  [arXiv 2409.10841](https://arxiv.org/abs/2409.10841)*

  > **This is why dark-as-default is correct for her specifically**, and why it
  > would have been the wrong default on a general assumption.

## 2. Prior art in quiz and brain-game products

- **The efficacy claims are mostly hollow.** Simons et al. (2016), *Psychological
  Science in the Public Interest* 17(3):103–186, reviewed 130+ studies and found no
  strong evidence of transfer beyond the trained games. **Lumosity paid $2M to the
  FTC in January 2016** for claiming otherwise. *Verified —
  [ftc.gov](https://www.ftc.gov/news-events/news/press-releases/2016/01/lumosity-pay-2-million-settle-ftc-deceptive-advertising-charges-its-brain-training-program)*
- **ACTIVE trial** is the strongest counter-case: speed-of-processing training held
  its effect on the *trained ability* at 10 years (d = 0.66). Transfer to everyday
  function was mixed. The widely-quoted 29% dementia-risk figure is a contested
  secondary analysis. *Likely*
- **The Synapse Project** (Park et al. 2014) is the finding that bears on this
  site: adults 60–90 who spent ~15h/week on a *high-challenge new skill* (quilting,
  digital photography) improved episodic memory; groups doing enjoyable tasks that
  drew on *existing knowledge* showed **no gains**. *Likely —
  [PubMed 24214244](https://pubmed.ncbi.nlm.nih.gov/24214244/)*

  > **You've already settled this one:** the site isn't for her to get smarter, and
  > that's the right frame. Recorded here only so nobody later markets it as brain
  > training — which would be both false and legally exposed.

- **Mechanics that survive your constraints:** AARP Games and Sporcle both run
  daily-puzzle + streak loops — fully compatible. Sporcle's *core* typed
  list-recall does not survive the no-typing rule. **Kahoot** conforms to WCAG 2.2
  AA with a published VPAT and ships Read Aloud, high-contrast and timer removal —
  **your site already matches or beats it.** **Blindfold Games** (31 audio-first
  iOS titles for blind players) proves a pure audio quiz loop is viable.

## 3. Reminiscence and nostalgia

- **Cochrane 2018 (Woods et al., CD001120.pub3):** 22 studies, n = 1,972. Some
  evidence reminiscence therapy improves quality of life, cognition and
  communication — **but all benefits were small and inconsistent, and this is a
  dementia population.** Evidence in healthy older adults is much thinner. Don't
  claim a nostalgia feature improves a healthy 62-year-old's cognition. *Likely*
- **The reminiscence bump is real and datable.** Memories from **ages 10–30** are
  disproportionately recalled, and the effect is strongest of all for **music**.
  For someone born ~1964 that window is **1974–1994** — late-Kádár "goulash
  communism" through the 1989 transition. A computable content target. *Likely —
  [PLOS One](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0208595)*
- **Cultural specificity is evidenced, not assumed.** A culturally adapted 12-week
  intervention with Spanish- and Vietnamese-speaking elders produced significant
  improvement in depression, loneliness and life satisfaction. The mechanism is
  cue–encoding match: **American nostalgia cannot cue Hungarian memories.** *Likely*
- **Formats to copy:** **BBC RemArc** (browse the BBC archive by decade or theme)
  and **My House of Memories** (National Museums Liverpool — everyday objects by
  decade, saved to a personal "memory box"). Both are **browse-and-prompt, not
  quiz.**

## 4. Licence-clean content sources

| Source | Licence (precise) | Volume | Language | Fit |
|---|---|---|---|---|
| **Wikidata** | **CC0 1.0** — public domain, no attribution | Unbounded via SPARQL | Labels in **hu** via `SERVICE wikibase:label "hu,en"` | **Best fit.** Correct answer = object of a property; distractors = siblings of the same class |
| **USCIS civics** | US Government work → **public domain** (17 U.S.C. §105) | 100 (2008) / **128 (2025, effective 20 Oct 2025)** | EN | Free-response answers; you write the distractors |
| **Wikipedia "On this day"** | Text **CC BY-SA 4.0**. **Facts are not copyrightable** — *Feist v. Rural Telephone*, 499 U.S. 340 (1991) | hu.wikipedia: 573,919 articles | hu + en | `api.wikimedia.org/feed/v1/wikipedia/hu/onthisday/selected/MM/DD`. **Paraphrase the fact; never copy the sentence** |
| **Fortepan** | **CC BY-SA 3.0**, credit `FOTO:FORTEPAN / <donor>` | **156,000+ Hungarian photos, 1900–1990** | hu | Images only — for a browse mode, not the quiz |
| **KSH** (Hungarian statistics office) | Website content **CC BY 4.0**. **Individually-requested extracts are CC BY-NC 4.0** — different licence, same site | Large | hu/en | The NC split is a trap |
| **Project Gutenberg** | Texts are **PD in the US**; the PG licence binds you only if you keep the header | ~75k works | Mostly EN, small hu set | Literature, and *Read to Me* |
| **Open Trivia DB** | **CC BY-SA 4.0** | **21,619 total — only 5,298 verified** | EN only | ⚠️ See warnings |
| **OpenTriviaQA** | CC BY-SA 4.0, provenance "gathered from various sources some years ago" | ~11k | EN | ⚠️ Avoid |
| **The Trivia API** | **CC BY-NC 4.0** | Large | Multi | ⚠️ Avoid |
| **tudaskerek** (GitHub) | **No licence file → all rights reserved** | 5,827 Hungarian questions | hu | ⚠️ Don't copy — but it proves a ~6k Hungarian bank is buildable from CC0 Wikidata |

**Also:** the **EU sui generis database right** (Directive 96/9/EC) protects
extraction of a substantial part of a database for 15 years even where individual
facts aren't copyrightable. "Facts aren't copyrightable" is a **US** doctrine and
is not a complete defence for bulk-harvesting an EU-hosted Hungarian database.

## 5. Hungarian speech synthesis

- **Verified on this machine:** `say -v '?'` on macOS 27.0 returns 186 voices, of
  which **exactly one is Hungarian — "Tünde" (hu_HU)**. A single legacy/compact
  voice; there is no Siri-grade Hungarian. Safari exposes system voices, so it's
  reachable from `speechSynthesis`.
- **Chrome's Google voices are `remote`** — higher latency, and they need a
  network. Prefer a local voice. *Verified for the API*
- **Windows 11:** hu-HU has legacy SAPI (Szabolcs) plus neural Noemi/Tamas, and the
  neural ones are **cloud-dependent**. *Likely*
- **iOS: could not confirm a bundled hu-HU voice from a primary source.**
  *Unconfirmed.* Two iOS constraints do apply: `getVoices()` returns far fewer
  voices than desktop, and speech must start inside a user gesture.
- **Web Speech API: ~95.4% global support**, unchanged recently. Still a Community
  Group report, not a W3C Recommendation. *Verified — [caniuse](https://caniuse.com/speech-synthesis)*

> Both speech bugs this section identified — the missing `voiceschanged` listener
> and Hungarian read with an English voice — **are fixed.** See
> `IDEAS-05-accessibility-audit.md` §11.

---

## ⚠️ Licence warnings — read before importing anything

- **Do not import Open Trivia DB or OpenTriviaQA into `quiz_questions`.** Both are
  CC BY-SA 4.0. ShareAlike would attach to your **entire derived question bank**,
  and CC BY-SA 4.0 explicitly covers sui generis database rights. Only 5,298 of
  ODB's 21,619 questions are even verified. If you ever want them, they must live
  in a separate, separately-licensed table — never mixed in.
- **Do not touch any Jeopardy! dataset** — jService, J!Archive scrapes, the 200k or
  554k clue dumps. They carry the notice *"All data is property of Jeopardy
  Productions, Inc."* Sony enforces. Public availability is not a licence.
- **Do not use The Trivia API's questions** — CC BY-NC 4.0, incompatible with
  essentially everything else.
- **Do not copy `tudaskerek`'s 5,827 Hungarian questions** — no licence file means
  all rights reserved.
- **Wikipedia: paraphrase facts, never copy sentences.**
- **Watch the KSH split** — website content is CC BY 4.0, requested data is CC BY-**NC** 4.0.
- **Fortepan requires the exact credit string** `FOTO:FORTEPAN / <donor name>`.
- **Generate from CC0 Wikidata rather than scraping Hungarian sites**, because of
  the EU database right.
