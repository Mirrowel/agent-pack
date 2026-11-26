# Tests: source of truth

Maintenance note (human readers only): this file is the canonical spec. The LLM-facing compressed version (`TESTS.llm.md`, served as a public gist and loaded via opencode `instructions`) is generated from it: when rules change here, regenerate it there.

Distilled from the test-philosophy research report (`openshare/TESTS-RESEARCH.md`), reviewed against its verified sources. The short version of why this exists: AI agents generate tests for everything reachable, not everything valuable. They add far faster than they delete, clone tests per input value, test what the compiler already proves, and run whole suites repeatedly mid-change, so iteration time becomes waiting. The studies agree: prompting for more tests changed nothing except cost; only 1.23% of Google's tests ever caught a real breakage; 70-80% overlap was found in one AI-built suite. The correction is a filter, not a ban.

A test exists to fail when real behavior breaks. Every test is a perpetual tax: runtime, maintenance, and reading time, forever.

## Rules

1. **Name the failure before writing the test.** One sentence: what breaks and how the test sees it. No name, no test. If no realistic change to the production code would turn the test red, do not write it. This is the fastest filter against tests that pass by construction.

2. **Test through public seams; assert state, not interactions.** Assert observable state and behavior, never mock-call sequences, unless the interaction itself is the behavior being tested (a contract test asserting exactly one email is sent is testing the interaction, and is correct). If a behavior-preserving refactor breaks a test, the test was coupled to implementation: rewrite it against public behavior. Never reshape production code just to make it testable. Mock at system boundaries only (external services, time and randomness, the file system, the database only when no test database is possible); never your own modules or internal collaborators: those run for real.

3. **One test per behavior; one regression test per bug class.** Cover each branch of the behavior, but parameterize input values instead of cloning a test per value. Same branch, different input value is a clone, not a new test. A behavior spans layers: cover it end to end at one seam, not one test per layer (horizontal slicing).

4. **Every non-trivial bug fix gets one failing-first regression test.** Written from the bug report or the observed failure, one per bug class, and watched failing before the fix lands. If the class is already covered, strengthen the existing test instead of cloning. A regression test never seen failing may encode the very bug it claims to catch. Trivial fixes need no test.

5. **Pick the lowest tier that can catch the bug.** Unit tests for real branching logic, integration tests only at real seams, e2e only for user-visible flows. Higher tiers are slower, flakier, and less precise.

6. **Never make a test's subject something that cannot break.** Trivial getters, constants, type declarations, config object shapes, framework or library behavior, anything the language already guarantees. Coverage is a diagnostic for finding untested code; it is never a target.

7. **The suite lives inside a wall-clock budget.** Respect the project's test budget. A change that grows runtime must delete or merge tests elsewhere, starting with proven duplicates.

8. **Deterministic waits: poll with a deadline and backoff.** Never fixed sleeps. Fixed sleeps inflate wall time and flake under load.

9. **A flaky test is a bug in the test or the design.** Fix the cause, or delete the test if it guards nothing unique. Never retry, skip, or mask a flaky test.

10. **While iterating, run the narrowest target that covers the change.** One file or one filter. The full suite is a gate (pre-push or CI), not a scratchpad; running it repeatedly mid-change is the iteration tax this set exists to kill.

11. **Deletion is legitimate maintenance, reviewed as strictly as additions.** Merge clones into parameterized tests; delete only proven duplicates. Quarantine a never-failing test before deleting it: "never failed" alone is not grounds for deletion, proven duplication is.

12. **Weight test effort by risk.** Auth, money, and data-loss surfaces get the densest tests; presentation and tooling get the thinnest. Equal density everywhere is misallocation.

13. **A test change that turns red into green is a suspect until explained.** New skips, weaker assertions, narrowed inputs, regenerated reference outputs: each is the cheapest way to make a failure disappear. Legitimate changes happen; say which was made and why. Never weaken a check to obtain a pass.

14. **The regression test must fail the real gate.** A filter, a path, or a config that keeps the test out of the CI command means it guards nothing. Verify that a failing test actually fails the job.

15. **The expected value must be independent of the code.** A test that recomputes the expected value the way the implementation does (`expected = items.reduce(...)`) passes by construction. Use a known literal (`15`).

## Anti-patterns

Recognition anchors, each rule above is the antidote to one of these:

- **Coverage Clone.** Dozens of tests differing only in an input value, detecting nothing new. Antidote: rule 3.
- **Mock Echo.** The test mocks a collaborator and asserts the mock was called; passes when production breaks, fails on refactor. Antidote: rule 2.
- **Tautology.** Passes by construction: no assertion, trivial getter, asserts what the compiler already proves, or recomputes the expected value the way the code does. Antidotes: rules 1, 6, 15.
- **Fault-Enforcer.** A "regression" test written from the current buggy implementation, encoding the bug as expected behavior; 8-17% of LLM-authored regression tests in one 145-PR study, and most persisted. Antidote: rule 4.
- **Test-Everything Reflex.** Suite grows faster than the product; CI becomes the bottleneck; agents burn context reading their own tests. Antidotes: rules 5, 6, 7, 10, 11.
- **Green by Editing.** The test went red, so the test changed: a skip, a looser assertion, a narrower fixture, a regenerated snapshot. The failure is gone and so is the guard. Antidote: rule 13.
- **Phantom Guard.** A regression test that never runs where it counts: excluded by a filter, a path, or a config, so the job stays green while the bug walks back in. Antidote: rule 14.
