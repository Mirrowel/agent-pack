---
name: methodical-problem-solving
description: Solve bugs and unexpected behavior in a codebase methodically. Use when debugging any failure whose cause isn't visible on sight: bug, panic, wrong output, flaky behavior, "it used to work", or a fix that didn't hold.
---

# Methodical Problem Solving

A problem is not solved when the symptom disappears. It is solved when you can
state the root cause in one sentence, point at the line(s) that embody it, and
show a regression test that fails without the fix and passes with it.

Work the phases in order. Skipping a phase is how fixes turn into new bugs.

What you work out belongs in your thinking. Write to the user only what is
useful for them to see.

Scale exception: when the cause is visible on sight (a typo, a missing null
check, an obvious off-by-one), run Phase 1, Phase 5 and Phase 6 only. A trivial
fix such as a typo still needs no regression test.

## Phase 1: Reproduce before you touch anything

- Get a concrete, repeatable reproduction: exact command, exact input, exact
  observed output vs. expected output. "It sometimes breaks" is not a repro yet.
- If it is intermittent, find the variable that makes it intermittent (timing,
  ordering, network reordering, uninitialized state) and
  pin it until the failure is deterministic. When it cannot be pinned, raise
  the reproduction rate instead: loop the trigger 100 times, add stress, narrow
  timing windows. A 50% flake is debuggable; 1% is not.
- Write the repro down (a failing test if cheap, otherwise a scratch command
  outside the source tree). This becomes your oracle: you are done only when
  *this* passes.
- The repro is a feedback loop, and building it is the skill; everything else
  consumes it. No red-capable command, no Phase 2: reading code to form a
  theory before that command exists is the failure this skill prevents.
- Ways to build one, in order: a failing test at the seam that reaches the bug;
  a curl script against the running server; a CLI run with a fixture, diffed
  against a known-good snapshot; a headless browser script; a replayed captured
  trace; a throwaway harness; a fuzz loop; a `git bisect run` harness; the same
  input through old and new, outputs diffed.
- Tighten the loop: faster (cache setup, skip unrelated init, narrow the
  scope), sharper (assert the specific symptom, not "didn't crash"),
  deterministic (pin time, seed randomness, freeze the network). A 30-second
  flaky loop is barely better than no loop.
- If you cannot reproduce it, stop fixing and start instrumenting. Do not ship
  a speculative fix for a failure you have never seen.

## Phase 2: Deconstruct to fundamental truths

- Spell out, in your thinking, what *must* be true for the system to behave
  correctly, as a chain:
  "input X arrives → parser produces Y → system Z reacts → state becomes W".
- Each link in that chain is a checkable claim. The bug lives in exactly one
  broken link (occasionally two). Your job is to find which.
- Spell out every assumption. The bug is usually hiding inside the one you
  were least willing to spell out.
- Do not guess library or framework behavior. Read the actual source at the
  version the project pins (vendored dependencies, the installed package, the
  library's repository, its shipped docs). Source lies less than documentation,
  and documentation lies less than memory.

## Phase 3: Locate with evidence, not intuition

- Bisect the chain from Phase 2: pick the midpoint link and verify it directly
  (log, debugger, assert, unit test of that piece in isolation). Each check
  halves the search space. Resist the urge to "just look around" the code.
- Useful bisection axes:
  - **Data**: is the value already wrong at this point, or still right?
  - **Time**: `git bisect` if it used to work. Let the machine do it.
  - **Space**: minimize the input, config or data until the failure barely survives.
  - **Layers**: client vs. server, network vs. local, our code vs. dependency.
- Add temporary instrumentation freely, every line tagged with one unique
  prefix (`[DEBUG-a4f2]`), so cleanup is a single grep. Untagged logs survive.
  Each probe maps to one prediction and changes one variable; never "log
  everything and grep". Redact every secret in what you show: auth headers,
  tokens, environment values. For a performance regression, logs are usually
  the wrong tool: take a baseline measurement, then bisect.
- Read the error message. All of it. Then read the lines above it. Panics,
  backtraces, and warnings are evidence, not noise to scroll past.

## Phase 4: Prove the root cause

- Spell out 3 to 5 ranked hypotheses before testing any; the first plausible
  idea anchors. Then test one at a time, each with a *falsifiable prediction*:
  "if this is the cause, then changing/logging A must show B". Then check.
- If the prediction fails, the hypothesis is dead. Do not rescue it with
  epicycles; go back to Phase 3 with what you learned.
- You have a root cause when you can explain **every** observed symptom from
  it, including the weird ones. A cause that explains 80% of the symptoms is
  usually a co-traveler, not the cause.
- Distinguish the root cause from the place the symptom surfaced. A panic in
  the renderer caused by a NaN from physics is a physics bug. Fix where the
  invariant was first violated, not where it was finally noticed.

## Phase 5: Fix at the source

- Fix the broken invariant, not the symptom. No clamps, retries, default-value
  fallbacks (`unwrap_or` and its likes), silent catches, or "skip if weird"
  guards that paper over the real defect.
- If bad input reaches deep code, the fix is rejecting it loudly at the
  boundary (validate, error out), not tolerating it downstream.
- Keep the fix minimal and on-thesis: it should be explainable as "the root
  cause was X, so I changed exactly the code that embodied X". Unrelated
  cleanups go in a separate change.
- If the fix breaks something else, that something else was depending on the
  bug. Fix it too. Do not revert to the broken invariant, and do not weaken a
  test to get back to green.

## Phase 6: Lock it in

- Write a regression test that encodes the Phase 1 repro: it must fail on the
  pre-fix code and pass now. Actually verify the "fails without fix" half
  (stash the fix or invert the assertion briefly); a test that never failed
  proves nothing.
- Write the test at a correct seam: one that exercises the real bug pattern as
  it occurs at the call site. If none exists, that itself is the finding; the
  architecture is keeping the bug from being locked down. Note it.
- Run the tests that cover the change as the end-of-fix gate, not only the new
  test. Until then, iterate on narrower targets.
- Strip all temporary instrumentation and scratch files.
- Re-read the diff end to end as a reviewer would: does every hunk serve the
  stated root cause?

## Phase 7: Reflect

- One to three sentences each: what was the root cause, why did it survive
  until now, and is the same defect pattern lurking elsewhere in the codebase?
  If yes, grep for siblings and report them. Fix them only when asked.
- If a wrong assumption cost you time, note what evidence would have killed it
  earlier: that is the check to run first next time.

## Anti-patterns (hard stops)

- **Shotgun debugging**: changing several things at once and seeing if the
  symptom goes away. You learn nothing and often trade one bug for two.
- **Fixing by analogy**: "a similar issue was fixed by doing X, so do X here"
  without verifying the mechanism matches.
- **Declaring victory on absence of symptom**: the symptom can vanish because
  you disturbed timing, not because you fixed anything. Only the Phase 1
  oracle plus a regression test count as proof.
- **Blaming the framework first**: it is almost always our code. Suspect the
  dependency only after evidence excludes our layers; then prove it by
  reading its source, and pin the exact line.
- **Asking the code to be lenient**: accepting malformed input "just in case"
  hides the next ten bugs. Error out.
