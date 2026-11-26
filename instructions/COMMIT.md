# Commit Messages — source of truth

Maintenance note (human readers only): this file is the canonical spec. The LLM-facing compressed version (`COMMIT.llm.md`, served as a public gist and loaded via opencode `instructions`) is generated from it — when rules change here, regenerate it there.

These rules are mandatory. Every commit message, every session — no drift, no exceptions. In a long session, re-check them before writing a message, not from memory.

Rules for commit message content only. When/how to commit is project-level rules, out of scope.

Write like a human developer documenting a change — cold documentation. The reader is a future git-log archaeologist: knows nothing about the session, tools, or conversation that produced the commit. Cares about the change, not its production.

## Format

    <type>(scope): <emoji> <description>

    [optional body]

    [optional footers]

## Rules

- Type ↔ emoji are fixed pairs: feat ✨ (user-facing) · fix 🐛 · docs 📚 · style 💎 (formatting only — CSS/UI changes are fix/feat) · refactor 🔨 · perf ⚡️ · test ✅ · build 📦 · ci 🎡 · chore 🧹 (non-src/test) · revert ⏪ · i18n 🌐
- One type per commit: most significant change wins (breaking > feat > fix > refactor > other). Never compound types (`fix+feat:`).
- Scope: lowercase noun for the affected module (api, ui, auth, db, core, config, deps). Omit when cross-cutting.
- Description: imperative present tense ("add", not "added") — the subject must grammatically complete "If applied, this commit will ___". Starts lowercase, no trailing period. No commit hashes in the subject line; hashes belong in the body. Subject line ≤72 chars when possible, hard cap 90.
- Body: `-` bullets are THE form. Prose is allowed only as the 1-2 sentence thesis above bullets, or one short paragraph for a simple fix. Two or more prose paragraphs is the wrong form — restructure into bullets. An essay body is a failure, regardless of content quality. Content: motivation, context, behavior-level effects. Concrete facts belong here (endpoints, defaults, limits); line-by-line or file-by-file narration doesn't — `git show` already does that. Design decisions: state the conclusion and the surviving reason ("SQLite, not Postgres: the install is embedded and must run without a server") — the comparison journey that led there stays out. No filler justifications ("for clarity", "for consistency"). Wrap naturally, never mid-sentence. No length cap: a big change deserves a detailed body — compress the wording, never cut substance. If the body stops fitting readably, the commit is too big: split the commit.
- Always include a body: breaking changes, security fixes, data migrations, reverts.
- Footers: `BREAKING CHANGE:` — triggers: removed export, changed API/schema, broken integration — plus what changed and the migration path; `Closes #123` / `Fixes #42` / `Refs #99`; `Fixes: <sha>` when fixing a prior commit.
- Dependency updates: chore(deps). List only direct manifest changes as `name: 1.2.3 → 1.3.0` (strip `^`/`~`); never lockfile/transitive churn.
- Unrelated changes: prefer separate commits. Only when splitting isn't feasible: subject = primary change, rest under `Also in this commit:` with their own type prefixes.
- Large diffs: group similar changes ("update 15 component imports"); no file-by-file lists.

## Session leakage — what stays out

The message documents the change, not the work session that produced it. Holds whether the session had a human operator, a review pipeline, or an autonomous agent working alone.

Never:
- The operator or the conversation: "owner directive", "per request", "as asked", the prompting side's "I"/"we".
- Process narration: "live-caught", "caught by test X", "verified with tool Y", "review round 2", "sweep subagents", "found on the way", debugging chronology. State root causes as facts: "X broke because Y; now Z."
- Decisions as someone's call: not "owner decision: keep X" — "X stays, because Y". Same rule for an autonomous agent's own decisions.
- References that rot: private numbering ("#3 v2 re-emit"), "last round", "earlier attempt". Commit hash or issue ID only.
- Editorializing: ALL-CAPS headers, "honestly", "pointless", invented epithets.
- "This commit adds/fixes/introduces…" openers — the subject already said it.
- AI attribution trailers.

Fine, with reason — external facts that resolve or carry signal:
- Prior commits by hash, issues by number.
- People outside the session: "reported by @user in #123", "seen twice in production" — impact facts about the bug, not workflow facts.

## Examples — match this format and detail level

Trivial change — subject only:

    refactor(config): 🔨 rename port constant to uppercase

Simple fix — body states the problem:

    fix(ui): 🐛 pass disabled prop to button element

    The button component was not correctly passing the `disabled` prop to the underlying HTML button, preventing it from being visually or functionally disabled.

Complex feature — thesis line, bold-label bullets, subsystem grouping, footer:

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

- Emoji present, matches the type? One type, no compounds?
- Subject: completes "If applied, this commit will ___"? Within 72/90?
- Body: `-` bullets, not prose paragraphs? Thesis is 1-2 sentences max?
- Leakage: no owner/user/request/caught/verified/round/`I`/`we`?
- Any prose paragraph that should be bullets? Restructure, then send.
