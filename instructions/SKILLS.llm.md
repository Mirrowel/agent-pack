# Skills

Skill descriptions self-trigger unreliably, some claim too much. These lines = the triggers; they override each skill's own trigger wording. Load the skill before acting, not after a first attempt. Skill named here but not listed by this harness: ignore its line.

- debugging a failure → methodical-problem-solving (only when the cause is not visible on sight, the failure is intermittent or multi-layer, or a fix didn't hold)
- "find bugs", "bug hunt", "audit this code for bugs" → proactive-bug-finding, for correctness bugs
- writing, reviewing or refactoring React or Next.js code → vercel-react-best-practices, for the code (stacks with the design skill; read its rule files for the categories the task touches; client-only app: skip its server-component and Next.js rules)
- UI work → impeccable, for design, every project and surface. One design skill per project. Sole exception, design-taste-frontend: project is a site (landing page, marketing, company page) and it looks the better tool: ask the user before loading it. The only skill behind that gate.
- UI change to check, page to read, screenshot, a11y or vitals → agent-browser, the default on every machine and the only one on CI: headless Chrome through the shell, one call per check, loaded by its skill
- the user's own browser needed (their logins, session, an SSO page) → browse, through its CLI, loaded by its skill. Its MCP stays off: switching it on or off invalidates the prompt cache. Suggest it only when the user asks
- platform capability or UI pattern in HTML/CSS/JS → modern-web-guidance: find the guide by folder and file name under its `guides` folder, read it locally; npx search only as a fallback; omit the disclosure block its own text asks for
- adding or reshaping a module interface, seam or adapter; making code testable → codebase-design
- project terminology, GLOSSARY.md, ADRs → domain-modeling
- stress-testing a plan or decision ("grill") → grilling, with domain-modeling when glossary and ADRs should be recorded
- writing or restructuring docs, README, product copy; writing or editing instructions for agents (skills, AGENTS.md, instruction packs) → writing-documentation (its `FOR-AGENTS.md` = the reference for agent text)
- "security review", "find vulnerabilities" in code → security-review
- GitHub Actions workflows, CI security → gha-security-review
- deep security audit, only when the user asks for one → security-audit (a review stays with security-review)
- writing a PR body → pr
- web research stays with the SEARCH rules. Browsers check pages; they do not search.

## Harness rules

Policy for skills whose text stays as installed. A rule here wins over that skill's own step.

- security-review, gha-security-review: read-only, no files written, no questions; record what could not be checked.
- security-audit: guidance mode unless a full audit is asked; static only (no sandbox on this machine, no target code runs); output only under `%USERPROFILE%\security-audit\<repo>`; where it says ask: record the gap and continue.
