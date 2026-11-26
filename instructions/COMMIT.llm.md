# Commit Messages

Mandatory. Every commit message, every session — no drift, no
exceptions. Long session? Re-check these rules before writing the
message, not from memory.

Content rules only. When/how to commit = project rules. Reader: future
git-log archaeologist — knows nothing of your session, tools,
conversation. Document the change, not its production.

Format: `<type>(scope): <emoji> <description>` — blank line — optional
body — optional footers.

Rules:
- type↔emoji fixed pairs: feat ✨ (user-facing) fix 🐛 docs 📚 style 💎
  (formatting only — CSS/UI change = fix/feat) refactor 🔨 perf ⚡️
  test ✅ build 📦 ci 🎡 chore 🧹 (non-src/test) revert ⏪ i18n 🌐
- one type per commit — most significant wins: breaking > feat > fix >
  refactor > other. No compounds (`fix+feat:`).
- scope: lowercase module noun (api, ui, auth, db, core, config, deps).
  Omit when cross-cutting.
- description: imperative — must complete "If applied, this commit
  will ___" ("add", not "added"). Lowercase, no period. No commit
  hashes in subject — body only. Subject line ≤72 target, 90 hard cap.
- body: `-` bullets are THE form. Prose allowed only as the 1-2
  sentence thesis above bullets, or one short paragraph for a simple
  fix. Two or more prose paragraphs = wrong form — restructure into
  bullets. An essay body is a failure, regardless of content quality.
  Content: motivation, context, behavior-level effect. Concrete facts
  OK (endpoints, defaults, limits); no line/file-by-line narration —
  `git show` exists. Design decisions: conclusion + reason ("SQLite,
  not Postgres: embedded, no server") — comparison journey stays out.
  No filler justifications ("for clarity", "for consistency"). Wrap
  naturally, never mid-sentence. No length cap — big change deserves
  detailed body. Compress wording, never cut substance. Body
  unreadably long = commit too big, split it.
- always body: breaking change, security fix, data migration, revert.
- footers: `BREAKING CHANGE:` — triggers: removed export, changed
  API/schema, broken integration. State what changed + migration path.
  `Closes #123` `Fixes #42` `Refs #99`. `Fixes: <sha>` when fixing a
  prior commit.
- deps: chore(deps). Direct manifest changes only:
  `name: 1.2.3 → 1.3.0` (strip `^`/`~`). No lockfile/transitive churn.
- unrelated changes: separate commits preferred. Split infeasible →
  subject = primary change; rest under `Also in this commit:` with
  type prefixes.
- large diff: group ("update 15 component imports"), never
  file-by-file.

Session leakage — never:
- operator/conversation: "owner directive", "per request", "as asked",
  prompting side's "I"/"we".
- process narration: "live-caught", "caught by test X", "verified with
  Y", review/sweep rounds, debugging story. State root cause as fact:
  "X broke because Y; now Z."
- decisions as someone's call: not "owner decision: keep X" → "X
  stays, because Y". Autonomous agent: same rule for its own calls.
- rot-prone refs: private numbering ("#3 v2"), "last round", "earlier
  attempt". Commit hash or issue ID only.
- editorializing: ALL-CAPS headers, "honestly", invented epithets.
- "This commit adds…" openers — subject said it.
- AI attribution trailers.

External refs fine when they carry signal: commit hashes, issue IDs,
"reported by @user in #123", "seen twice in production". Impact facts,
not workflow.

Examples — match format + detail level:

Trivial — subject only, no body:

    refactor(config): 🔨 rename port constant to uppercase

Simple fix — body states the problem:

    fix(ui): 🐛 pass disabled prop to button element

    The button component was not correctly passing the `disabled` prop to the underlying HTML button, preventing it from being visually or functionally disabled.

Complex feature — thesis line, bold-label bullets, footer:

    feat(core): ✨ add indexing guardrails, freshness checks, and embedding retries

    Hardens the indexing pipeline against runaway repo sizes, stale caches, transient API failures, and private-network SSRF.

    - **Guardrails**: config limits for max files (`10000`), file size (`2MB`), chunk count (`200000`). SSRF protection for custom embedding endpoints blocks private non-loopback IPs by default.
    - **Freshness & caching**: background startup freshness checks via mtime, size, and content hashes. Embedding provider fingerprints rebuild the index when backend, model, or dimensions change.
    - **Embedder resilience**: configurable HTTP timeouts and retries with exponential backoff.
    - **Chunking & vector store**: tree-sitter semantic `embedText` for better vector representations. Atomic vector replacements in LanceDB with rollback.

    BREAKING CHANGE: custom embedding endpoints on private non-loopback IPs are rejected by default. Allowlist explicit hosts to keep serving from private networks.

Unrelated changes — split preferred; when infeasible:

    feat(auth): ✨ add session timeout configuration

    - add configurable session timeout with default of 30 minutes
    - implement automatic logout when session expires

    Also in this commit:
    - fix(ui): correct button alignment on mobile viewports
    - docs: update environment variables reference in README

## Before sending — verify, every message

- emoji present, matches type? one type, no compounds?
- subject: completes "If applied, this commit will ___"? ≤72/90?
- body: `-` bullets, not prose paragraphs? thesis is 1-2 sentences max?
- leakage: no owner/user/request/caught/verified/round/`I`/`we`?
- any prose paragraph that should be bullets? Restructure, then send.
