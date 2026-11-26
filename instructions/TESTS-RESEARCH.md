# Test Philosophy Research: LLM Test Bloat, What Deserves a Test

> Status: research input, untracked on purpose. This file is raw material
> for a separate instruction-set authoring pass: read it end to end, then
> distill the project's testing instruction set (and its home in
> DEVELOPMENT.md / project memory) from Parts 2, 5, and 6.
>
> Sources were verified against primary text by two independent research
> agents; claims that could not be verified are explicitly marked UNVERIFIED
> in Part 7 and must not propagate into the instruction set.

---

## Part 1 — The problem: LLM/AI test bloat

AI coding agents have a structural add-bias: they generate tests for
everything reachable, not everything valuable. The measurable shape of the
problem, from practitioner reports and studies:

- **Volume reflex.** Agents add tests far faster than they delete or merge
  them. Practitioner reports: an AI-built Go project of several hundred
  tests showed 70-80% overlap between tests; a consultancy reported 15-20
  fresh tests duplicating coverage 3-4x per feature; one author removed
  300 tests / 5k lines from two repos with no coverage loss; HN reports
  say 2-4% of agent-written tests are broken at any time and ~10% of
  one-shot tests are bogus. (Rachev 2026; Kapernikov 2026; Shamun 2026;
  HN 46232972, 49795592, 46526088.)
- **Industry scale of the same disease.** Linear's suite grew ~4x in 2026
  (~2,000 tests/week added) and CI became the bottleneck; Shopify runs
  150k-170k tests growing 20-30%/year and had to invent test budgets and
  selection to keep p95 CI under control. Suite growth without a deletion
  discipline is an industry-wide failure mode that AI agents accelerate.
  (Linear 2026; Shopify 2020-2022.)
- **Quality studies.** Only 24.8% of ChatGPT-generated unit tests in one
  study passed at all (57.9% compile errors); "most test suites generated
  by LLMs contained at least one error or test smell", with Assertion
  Roulette (24.2%) and Magic Number Test the dominant smells; across 17
  LLMs, assertion correctness lags far behind execution correctness;
  coverage/mutation numbers of LLM suites are unreliable proxies for
  real-bug detection when the code under test may itself be buggy.
  (arXiv:2305.04207; arXiv:2506.14297; TestEval arXiv:2406.04531; FSE 2026
  replication, ACM TOSEM 3832093.)

### Named anti-patterns of AI test generation (and antidotes)

| # | Anti-pattern | Symptom | Antidote (per sources) |
|---|---|---|---|
| A | **Coverage Clone** | Dozens of tests differing only in an input value; production code has one branch or a passthrough, so the clones detect nothing new. The single most common agent bloat pattern. | "Same branch is not a new test" (Shamun 2026); compose/parameterize instead of cloning (Beck, Composable Tests 2025); scoped-coverage overlap scans to find duplicates (Rachev 2026) |
| B | **Mock Echo** | Test mocks a collaborator and asserts the method was called / asserts the mock's canned return. Passes when production breaks, fails on refactor. | Assert state at public seams, not interactions (Google SWE ch12); stubs/fakes over mocks; interaction assertions only when the interaction IS the behavior (Google 2014; Shore 2023; KCD 2019) |
| C | **Tautology / assertion-free test** | Passes by construction; no assertion, trivial getter, or asserts what the compiler already proves. | Meta TestGen-LLM acceptance filters: builds, passes reliably, increases coverage; reject no-assertion / trivial-getter / multi-responsibility tests (Meta 2024); mutation thinking as the filter (PIT/Stryker) |
| D | **Fault-Enforcer** | The agent writes a "regression" test from the CURRENT (buggy) implementation, encoding the bug as expected behavior. In a 145-PR study, 8-17% of LLM-generated tests were fault-enforcing, only 2.4-4.8% fault-revealing, 83-91% of the fault-enforcers persisted, and the developer's own suite caught only 14-30% of them (arXiv:2610.11835). | Write the regression test from the bug report/spec, then WATCH IT FAIL before the fix lands (Google SRE; Bland 2014); human review of agent-authored regression tests |
| E | **Test-Everything Reflex / suite inflation** | Tests for external libraries, language features, config shapes, getters; suite grows faster than the product; CI becomes the bottleneck; agents burn context reading their own tests. | Lifecycle rule: write tests freely while building, justify or delete before merge (Kapernikov); wall-clock budget enforced by CI (Shopify); one test per behavior the request names (Specstory 2026); risk-based quantity (Google 2021) |

---

## Part 2 — Principles: what deserves a test (ranked, cited)

Both research agents converged on the same core from independent source
sets. Merged and deduplicated:

1. **A test must name the regression it catches.** If you cannot state the
   failure in one sentence — or break the production code in an obvious way
   and watch the test still pass — it is not testing behavior. This is
   manual mutation thinking; PIT calls mutation score "the gold standard
   against which all other types of coverage are measured." Fastest filter
   against agent tests that pass by construction. (Kapernikov 2026; PIT;
   Stryker.)
2. **Test behavior through public seams; assert state, not interactions.**
   Tests must fail when behavior changes and survive refactors. Google's
   rules: "test via public APIs" and "test state, not interactions."
   Beck's desiderata name this *behavioral* and *structure-insensitive*.
   (Google SWE ch12; Beck 2019; Shore 2023.) Counterweight: DHH's
   "test-induced design damage" — do not add indirection solely to make
   unit testing easy (DHH 2014).
3. **Smallest test at the lowest tier that can actually fail for the reason
   you care about.** Google's 70/20/10 unit/integration/e2e split is "a
   good first guess," not a law; higher tiers are slower, flakier, less
   precise. Rainsberger's strong version: don't use broad integrated tests
   to fill gaps that focused contract tests should cover. Caveat: the
   lowest tier that touches the line is not the same as the lowest tier
   that can catch the bug. (Google 2015; Fowler/Vocke 2018; Rainsberger
   2009/2015.)
4. **One regression test per bug class; every bug fix gets a failing-first
   test.** Incident-linked regression tests are the highest-value tests in
   existence because they encode a failure that actually happened. "No bug
   is considered properly fixed without an automated regression test."
   Duplicates for the same failure mode add maintenance without detection.
   (Google SRE; Bland 2014; Google SWE ch12.)
5. **Coverage is a diagnostic, not a target.** "High coverage numbers are
   too easy to reach with low quality testing" (Fowler); diminishing
   returns past ~70% (KCD, number admitted made-up); 100% pushes teams to
   test logic-free code. Use coverage to find untested code, never as a
   goal. (Fowler 2012; KCD 2019; Google "Code Coverage Best Practices"
   2020.)
6. **Test boundaries and contracts, not every unit.** "Bugs tend to live
   in the boundaries" (Shore). Collaboration + contract tests give the
   confidence of integrated tests at a fraction of the maintenance
   (Rainsberger). Practical filter: if a test exercises a helper through a
   private seam, ask which public behavior would catch the same bug.
7. **Parameterize inputs; never clone a test per value.** Beck's
   composition example: 4 computations x 5 reports = 20 brute-force tests
   or 4+5+1 composed. "Same branch is not a new test" unless production
   code branches on the difference. (Beck 2025; Shamun 2026.)
8. **Keep the suite inside a wall-clock budget; enforce it.** Beck: 10s
   tolerable, 1 minute is a context switch; his economics: a 10s suite run
   50x/hour over 1,000 programming hours = 139 hours/year of waiting
   (~$27k/yr at $200/h; cutting 10s→2s saves ~$13k/yr). Google caps small
   tests at 60s; Shopify's test budget finds 80% of failures after 60% of
   the selected suite; Linear holds PR wait near 5 min while adding ~2k
   tests/week; CI literature pegs acceptable build duration ~10 min.
   (Beck 2019/2024; Google 2010; Shopify 2022; Linear 2026; Ghaleb et al.
   2019.)
9. **Delete and merge with evidence; "never failed" alone is not grounds.**
   A quiet test may guard stable code. Prove subsumption (per-test coverage
   + mutation-kill equivalence), quarantine before delete. The safe
   deletion target is the duplicate that kills no unique mutant. Facebook
   policy (via Beck): delete non-deterministic tests outright. Deletion is
   legitimate maintenance: one hanging test's removal cut Shopify's p95 by
   10 minutes. (Specstory 2026; Beck 2019; Shopify 2021; Fowler.)
10. **A flaky test is a bug in the test or the design; fix or delete, never
    retry-mask.** Google: 1.5% of runs flaky, 16% of 3.5M tests have
    flaked, 84% of pass→fail transitions are flakes (not real breakage);
    flakiness scales with size: 0.5% small / 1.6% medium / 14% large.
    Flaky tests consume >=2.5% of productive dev time; a rerun costs $0.0002,
    a manual investigation $5.67. (Google 2016/2017; Leinen et al. 2024.)
11. **Weight test effort by risk: blast radius, churn, failure history.**
    Equal test density is misallocation — an auth path deserves more tests
    than a formatter. Google's "How much testing is enough?" is risk-based,
    not coverage-based; Shopify's prioritization (failure rate, duration,
    churn, coverage, complexity) finds 80% of failures in 60% of the suite.
    (Google 2021; Shopify 2022.)
12. **Every test is a perpetual tax: runtime, maintenance, review, context.**
    "A bad test suite can be worse than no test suite at all" (Google SWE
    ch11). Bloat = cost without a unique bug catch (Specstory). Three cost
    axes: maintenance, CI time, and context consumed every time a human or
    agent reads the test (Kapernikov). Add a test only when expected
    bug-catching value exceeds lifetime cost.

---

## Part 3 — Hard data

**Flakiness (Google, 2016/2017)**
- 4.2M tests, 150M executions/day; 1.5% of runs flaky; 16% of tests have
  flaked; 84% of pass→fail transitions are flakes; only 1.23% of tests ever
  found a breakage; 2-16% of CI compute spent re-running flakes.
- By size: 0.5% small / 1.6% medium / 14% large.
- Leinen et al. 2024: flaky tests consume >=2.5% of productive dev time
  (1.1% investigation, 1.3% repair, 0.1% tooling); rerun $0.0002 vs $5.67
  manual investigation.
- Shopify: core stability 88%→97% via test selection; mobile E2E 50%→98%
  with a pre-promotion flakiness gate.

**Runtime economics**
- Beck/JUnit Max: 10s suite x 50 runs/h x 1,000 h/yr = 139 h/yr waiting;
  ~$27k/yr at $200/h. Sub-second ideal, 10s tolerable, 1 min = context
  switch.
- Google test size caps: small 60s / medium 300s / large 900s+.
- CI literature: ~10 minutes acceptable build duration (Ghaleb et al. 2019,
  citing Hilton et al.).
- Shopify: 170k tests, 41h on one machine; CI p95 45→18 min after selection
  + timeouts; test budget: 80% of failures in 60% of selected suite (70% in
  70% at p95).
- Linear: ~4x suite growth in 2026, ~2,000 tests/week, PR wait >6 min →
  just over 5 min; runner time per test roughly halved.
- Meta Sandcastle: feedback target under 10 minutes; "we're not going to
  run a test unless your diff might actually have broken it."

**AI test-generation studies**
- Meta TestGen-LLM (2024): 75% of generated test classes built, 57% passed
  reliably, 25% of classes gained a coverage-increasing test; human trial
  success 4-5%; 73% of recommendations accepted; rejections included
  trivial getters, no-assertion, multi-responsibility tests.
- arXiv 2610.11835 (145-PR study): 8-17% of LLM-generated tests
  fault-enforcing, 2.4-4.8% fault-revealing, 83-91% of fault-enforcers
  persist, developer suites catch only 14-30% of them.
- arXiv 2602.07900: prompt-induced test VOLUME did not significantly change
  task resolution; encouraging more tests cost +5.5% API calls and +19.8%
  output tokens with no gain; discouraging tests cut input tokens 49% and
  API calls 35.4% with no loss. (Strong evidence that more tests ≠ better
  outcomes.)
- arXiv:2305.04207: only 24.8% of ChatGPT unit tests passed.
- arXiv:2506.14297: most LLM suites contain >=1 error or test smell;
  Assertion Roulette 24.2%.
- Practitioner: 300 tests / 5k lines removed with no coverage loss
  (Shamun); 70-80% overlap found in an AI-built suite (Rachev).

**Mutation testing as the value filter**
- Google (2021, 33M test-suite runs): ~70% of real bugs were coupled to a
  killable mutant. A test that survives every realistic mutation of the
  code it claims to guard is a deletion candidate.

---

## Part 4 — OpenShare inventory (measured 2026-11-01)

The repo's own suite: 13 entries in one parallel wave (share-plugin
`npm test`), ~420 checks total, full matrix 177.7s wall; quick gate
(`npm run test:quick`) 80-86s. Worker address/ports: `suite-lib.mjs`
derives `WORKER_URL` from `OPENSHARE_WORKER_PORT` (default 8789); the
matrix driver assigns port blocks; suites either boot their own
`wrangler dev` (isolated `--persist-to`, generated toml) or reuse the
shared 8789 worker; a Bun backend (`share-server/server.ts`) exists behind
`OPENSHARE_BACKEND=bun` with full parity (203/203).

| Suite | Checks | Wall (matrix) | Drives | Verdict (research-applied) |
|---|---|---|---|---|
| auth-tests | 203 | 94.8s | own x2 wrangler workers, HTTP/WS | Keep: densest regression net, incident-linked checks (T21 DELETE-auth, T24 seq, T30 classes all born from real bugs). Cost driver: two wrangler boots, not checks. |
| tui-flow | 73 | 63.4s | own worker + 1 serve, mock TUI host | Keep: public-seam tests of the TUI contract; found the F9 drift class. |
| manual core/allmode/engine1/2 | 52 | 99/70/37/28s | real opencode serve x11 + real worker, mock LLM | Keep, trim: the only real-host-pipeline coverage; fixed sleeps and a 68s retry-backoff probe inflate it. |
| enroll a/b/public | 19 | 169.8s worst | own wrangler per shard (3 workers) | Restructure/trim: worst wall-dominator; plugin-side value overlaps tui-flow F6/F15 and auth T02-T05/T20. |
| fanout | 10 | 155.5s | own worker + 4 serves | Trim: unique coverage (multi-server fan-out) but 24.5s hardcoded sleeps; also the wave's flake source. |
| regression | 8 blocks | 63.7s | in-process dist imports, shared worker | Keep: parity + engine units; cost is real settle timing. |
| v2-mock | 17 | 14.3s | mock v2 host, shared worker | Keep: cheap adapter contract. |
| big | 25 | 24.3s | own worker | Keep: scale locks cheaply. |
| server-* (Bun parity) | same | on demand | Bun | Keep manual: right tier. |
| share-cli | 0 | — | — | GAP: the root-routing footgun class (fixed by hand) had no net. Small smoke suite warranted. |
| viewer | 0 in-repo | — | — | Standing decision: verification rigs live outside the repo, run manually. |

Mapped against the principles: the suite is integration-heavy and
public-seam-driven (good, principle 2/6); nearly every check block is
incident-linked (good, principle 4); the failures are in COST discipline —
fixed sleeps instead of polling (violates 8/10), three parallel worker
boots for a 19-check suite (violates 12), and no budget enforcement
(violates 8).

---

## Part 5 — Decision frameworks worth adopting

1. **Budget model (Shopify test budget).** Wall-clock ceiling per tier,
   enforced by the runner: exceeding budget fails the run; a change that
   grows runtime must delete or merge elsewhere. OpenShare tiers: quick
   gate (dev loop) and full matrix (pre-push). Ratchet: set at today's
   achieved numbers, tighten over time.
2. **Deletion policy.** Quarantine-before-delete for quiet tests; delete
   duplicates on overlap evidence; delete flaky tests same-day unless the
   fix is immediate; review test deletions as strictly as additions.
3. **Mutation thinking without mutation tooling.** For each new test, state
   the one-line regression it catches; when pruning, ask "what realistic
   change would turn this red?" Full mutation testing (PIT/Stryker-class)
   is likely impractical over workerd/bun integration suites — treat the
   one-line discipline as the working substitute.
4. **Fault-enforcer guard for AI-authored regression tests.** Write from
   the bug report; watch it fail against the unfixed code before trusting
   it; a regression test that cannot be shown failing is suspect.
5. **Same-branch rule.** A new test whose only difference from an existing
   one is an input value is a clone; parameterize instead.
6. **Risk-weighted density.** Auth/identity and sync-loss surfaces get the
   densest nets; presentation and tooling get thin ones; "equal everywhere"
   is misallocation.

---

## Part 6 — Instruction-set raw drafts

Three candidate drafts exist for the instruction-set author to merge.

**Draft A (agent 1, 10 lines):**
1. A test must name the regression it catches in one sentence; the PR must state it.
2. Test behavior through public seams; assert state, not mock calls.
3. One test per behavior or bug class; parameterize inputs, never clone for values.
4. Use the lowest tier that can catch the bug; integration only at real seams.
5. Coverage is a diagnostic, not a target; 100% is a smell.
6. Every bug fix gets one failing-first regression test.
7. The suite has a wall-clock budget; new tests must fit inside it.
8. Delete or merge redundant/obsolete tests; quarantine before delete; "never failed" alone is not grounds.
9. A flaky test is a bug; fix or delete, don't retry.
10. No tests for getters, framework behavior, external libraries, or language features.

**Draft B (agent 2, 10 lines):**
1. A test exists to fail when a real behavior breaks. If no plausible change would turn it red, don't write it.
2. Test through public boundaries. Never test private functions or mock-echo internals.
3. Default to integration tests; unit tests only for real branching logic; E2E only for user-visible flows.
4. No tests for types, constants, config files, or anything the compiler already proves. No coverage-chasing.
5. One regression test per real, observed bug — linked to the incident. No speculative edge-case families.
6. Before adding a test: name the bug class it catches that existing suites don't. Can't name it → don't add it.
7. Budget: the suite stays under its wall-clock ceiling. A change that grows runtime must delete or merge tests elsewhere.
8. A refactor may not break tests. If it does, the tests were testing implementation — fix the tests.
9. Flaky or redundant test: delete or fix the same day. Never mask with retries or skips.
10. Periodic prune: check the hottest paths for tests that catch nothing; delete them.

**Draft C (synthesis, 8 rules — the working proposal):**
1. Name the regression in one sentence — no name, no test.
2. Public seams only; assert state, never mock-call sequences.
3. One test per bug class; parameterize, never clone per value.
4. Bug fixes get exactly one failing-first regression test, watched failing before the fix.
5. Wall-clock budget is law; growth requires deletion elsewhere.
6. No tests for getters, config shapes, compiler-proven or framework behavior; coverage is a diagnostic, never a target.
7. Flaky = fix or delete same day; never retry-mask.
8. Deletion is legitimate maintenance — prune duplicates; "never failed" alone is not grounds, duplication is.

OpenShare-specific additions the author should consider folding in:
- Suites share the matrix worker where possible (port blocks); a suite that
  needs its own worker pays for it in wall time and must justify it.
- Real-model / real-deployment checks stay out of the default suites
  (costs money; on-demand only) — existing project rule.
- XDG sandbox isolation is mandatory for any suite spawning opencode —
  existing project rule.

---

## Part 7 — Marked myths / UNVERIFIED claims (do not propagate)

- "Shopify has an integration-to-unit-test ratio policy" — UNVERIFIED by
  both agents. Shopify's verified contributions: test selection, test
  budgets, CI p95 targets.
- "Google SWE book mandates 60%/90% coverage" — UNVERIFIED.
- Kent Beck "Skeptic" essays — UNVERIFIED; verified later works: Test
  Desiderata (2019), Programmer Test Principles (2019), To Test or Not to
  Test? (2024), Composable Tests (2025).
- "test apospasia" — no such Google term.
- "Spotify/Martin Fowler Testing Without Mocks" — the pattern language is
  James Shore's (2023).
- Meta "sndbx" — the CI system is Sandcastle.
- "38-100% test smells in LLM suites" — secondhand; primary not located.

---

## Part 8 — Sources (merged, deduplicated)

**Philosophy:** Kent Beck, Test Desiderata (2019) medium.com/@kentbeck_7670/test-desiderata-94150638a4b3 + testdesiderata.com; Programmer Test Principles (2019); To Test or Not to Test? (2024) newsletter.kentbeck.com; The Economic Case for JUnit Max (2024); Composable Tests (2025). Martin Fowler, Test Coverage (2012) martinfowler.com/bliki/TestCoverage.html; Is TDD Dead? (2014). Ham Vocke, The Practical Test Pyramid (2018). Google Testing Blog: Just Say No to More End-to-End Tests (2015); Test Sizes (2010); Effective Testing (2014); Flaky Tests at Google (2016); Where do our flaky tests come from? (2017); Code Coverage Best Practices (2020); How Much Testing is Enough? (2021); Mutation Testing (2021). Software Engineering at Google ch11/ch12 (abseil.io/resources/swe-book). J.B. Rainsberger, Integrated Tests Are a Scam (2009) + Clearing Up (2015). Kent C. Dodds, Write tests. Not too many. Mostly integration. (2019). DHH, Test-induced design damage (2014). James Shore, Testing Without Mocks (2023). Mike Bland, Goto Fail, Heartbleed, and Unit Testing Culture (2014). Google SRE Book, Testing Reliability (sre.google).

**Data:** Leinen et al., Cost of Flaky Tests in CI (ICST 2024). Ghaleb et al., Long Duration of CI Builds (EMSE 2019). GitHub, hidden costs of slow build times (2022). Shopify: Spark Joy by Running Fewer Tests (2020); Keeping Developers Happy with a Fast CI (2021); Test Budget (2022); mobile E2E stability (2026). Linear, AI coding has made CI a bottleneck (2026). Micco, State of CI Testing at Google (ICST 2017 keynote).

**AI-specific:** Meta, Automated Unit Test Improvement using LLMs / TestGen-LLM (arXiv:2402.09171). On the Risks of using LLM-Generated Tests for Regression Testing (arXiv:2610.11835). Rethinking the Value of Agent-Generated Tests (arXiv:2602.07900). Ouédraogo et al., Test Smells in LLM-Generated Unit Tests (arXiv:2410.10628). TestEval (arXiv:2406.04531). ChatGPT unit test quality (arXiv:2305.04207). VibeCheck (ACM 2026). Specstory, How many tests is too many? (2026). Kapernikov, Fewer tests, better tests (2026). Shamun, Reducing redundant test bloat generated by AI coding agents (2026). Rachev, Scoped Coverage to Prune an AI-Generated Go Test Suite (2026). Preventing LLM unit test spam (blog.larah.me). SQRBOK suite maintenance; Tessl test-removal-criteria. HN threads 49795592, 47248086, 46232972, 46526088, 41936855.

**Mutation tooling:** pitest.org; Stryker mutant-states docs; Microsoft Learn mutation testing.
