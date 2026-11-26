---
name: proactive-bug-finding
description: How to hunt for bugs in code before they're reported. Use when asked to "find bugs", "bug hunt", "look for bugs", "audit this code for bugs", or "what's broken here", without a specific bug report or failing test to start from.
argument-hint: <path, module, or "recent changes">
---

# Proactive Bug Finding

Hunt for genuine, demonstrable bugs in the given scope. Style issues, hypothetical concerns and "this could be cleaner" are out of scope. The deliverable is a short list of findings the user would actually fix, each backed by evidence.

## Scope

Resolve the scope from the argument:

- A path or module → that code plus its direct callers/callees.
- "recent changes" or no argument in a git repo → `git diff` against the default branch, or the last few commits if the branch is clean. Recently changed code is where bugs concentrate.
- No argument, no recent changes → ask the user, or pick the highest-risk area (see hotspots below) and say which you picked.

Keep the scope small enough to read thoroughly. A deep pass over one module beats a shallow pass over ten.

## Method

Work in this order. Do not skip step 4.

### 1. Map the risk hotspots

Before reading line-by-line, find where bugs are likely to live:

- **Boundaries**: parsing, serialization, user input, external APIs, file/network I/O, unit conversions, timezone/encoding handling.
- **Concurrency**: shared mutable state, async ordering assumptions, locks, caches, anything with "race" potential.
- **Arithmetic and indexing**: off-by-one candidates, integer overflow/truncation, division, float comparison, empty-collection handling.
- **Error paths**: `catch` blocks that swallow, cleanup that can be skipped, partial-failure states, retries without idempotency.
- **State machines and invariants**: code that assumes an order of operations or a field being set; check who can violate it.
- **Recent churn**: `git log --stat` for files changed often or changed by many hands; fixes that touched the same lines repeatedly.

### 2. Read adversarially

For each hotspot, read the code asking "what input or sequence of events makes this wrong?" rather than "what does this do?". Specifically:

- Trace data flow end to end: where a value is produced, every transformation, where it's consumed. Mismatched assumptions between producer and consumer are the richest seam.
- Check every function against its callers: do callers pass things the function doesn't handle (null, empty, negative, huge, unicode, concurrent calls)?
- Check the contract, not just the code: compare behavior against docstrings, type hints, comments, tests, and names. A function named `getOrCreate` that can return null is a bug even if every line is "correct."
- Look for asymmetry: lock taken but not released on one path, resource opened without close on error, pairs (start/stop, push/pop, encode/decode) that don't mirror each other.
- For diffs: read the surrounding unchanged code too. Most regression bugs are a changed line invalidating an assumption in an unchanged one.

### 3. Triage suspicions

For each suspicion, decide: is there a concrete input or event sequence that triggers it? If you can't describe the trigger, it's not a finding yet: either dig until you can, or drop it. Apply these bars:

- **Reachable**: the triggering input can actually occur in practice. Dead code and impossible inputs don't count.
- **Wrong**: the behavior differs from what the contract/caller/user expects, not merely from what you'd have written.
- **Not deliberate**: check git blame, comments, and tests before flagging something that looks odd; it may be intentional. If a test asserts the behavior, it's a design decision, not a bug (you may still note it separately).

### 4. Verify before reporting

This step separates findings from noise. For each surviving suspicion, try to demonstrate it:

- Write and run a minimal repro: a small script, a REPL session, or a failing test case exercising the exact trigger.
- If a repro isn't practical (needs prod data, hardware, a race window), trace the exact code path line-by-line in your report instead, quoting the lines and the triggering values.
- If the repro passes (no bug), say nothing about it or downgrade it honestly; do not report unverified suspicions as bugs.

Do not fix anything unless the user asked for fixes. The deliverable is the findings.

## Report format

Order findings by severity (data loss / corruption / security > wrong results > crashes > degraded behavior). For each:

```
### N. <one-line summary> · <severity> · <file:line>

**Trigger:** the concrete input or sequence that causes it.
**What happens:** observed/derived wrong behavior vs. expected.
**Evidence:** repro output, or the quoted code-path trace.
**Suggested fix:** one or two sentences (no patch unless asked).
```

After the list, add a short "Checked but clean" line naming the hotspot areas you examined that held up, so the user knows what was covered, not just what failed.

If you find nothing that clears the bar, say so plainly and list what you checked. Zero findings from a thorough pass is a valid, useful result; three speculative non-bugs are not.

## Anti-goals

- No style, naming, or refactoring commentary.
- No generic advice ("consider adding more tests").
- No CVE-pattern scanning theater (flagging every `eval` or `exec` regardless of context). Reachability and a concrete trigger are required.
- Don't pad the list. One verified bug outranks ten maybes.
