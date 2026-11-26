# Tests

Test must fail when real behavior breaks. Every test = perpetual tax: runtime, maintenance, reading.

- Name the failure first, 1 sentence: what breaks, how the test sees it. No name, no test. No realistic change to production code turns it red: don't write it.
- Public seams; assert observable state and behavior, not mock-call assertions, unless the interaction is the behavior. If a behavior-preserving refactor breaks the test: rewrite against public behavior. Never reshape production for testability. Mock at system boundaries only (external services, time and randomness, file system, the database only when no test database is possible); never your own modules or internal collaborators, those run for real.
- 1 test per behavior, 1 regression per bug class. Cover each branch, parameterize values. Same branch with a different value is a clone, not a new test. A behavior spans layers: cover it end to end at one seam, not one test per layer.
- Non-trivial bug fix: failing-first regression per class, from bug report or observed failure, watched failing before the fix. Class covered: strengthen, don't clone. Never seen failing may encode the bug. Trivial fix: no test.
- Lowest tier that catches it: unit for real branching, integration at real seams, e2e only for user-visible flows.
- Never test what cannot break: trivial getters, constants, type declarations, config shapes, framework or library behavior, anything the language guarantees. Coverage = diagnostic, never target.
- Wall-clock budget: respect the project's test budget; a change that grows runtime deletes or merges tests elsewhere, proven duplicates first.
- Poll with deadline and backoff, no fixed sleeps.
- Flaky = bug in test or design: fix the cause, or delete the test if it guards nothing unique. No retry, skip, mask.
- Iterate on narrowest target: 1 file or filter. Full suite = gate (pre-push/CI), not scratchpad.
- Deletion = maintenance, reviewed as strictly as additions. Merge clones, delete proven duplicates only. Quarantine never-failing first: never-failing is not grounds for deletion, proven duplication is.
- Treat a test change that turns red into green as a suspect until you can explain it: new skips, weaker assertions, narrowed inputs, regenerated reference outputs. Say what changed and why. Never weaken a check to pass.
- The regression test must fail the real gate: a filter, path or config that keeps it out of the CI command means it guards nothing. Verify that a failing test actually fails the job.
- Density by risk: auth, money, data loss dense; presentation and tooling thin.
- Expected value independent of the code: recomputing it the way the implementation does passes by construction. Use a known literal.
