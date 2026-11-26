# Exploratory test of a web app

Explore like a user, prove every finding, write each one down as it is found. Depth of evidence over count: five proven issues beat twenty vague ones.

## Setup

- The target URL is all that is needed. Name the session after the site (`--session example-com`). Make an output folder for screenshots, videos and the report.
- Log in when the app needs it (SKILL.md, Logins). An OTP or email code: ask the user, wait, then enter it.
- Orient: `screenshot --annotate`, `snapshot -i`. Map the navigation, then visit each top-level section.

## At each page

`snapshot -i`, a screenshot, `errors`, `console`. Then the checklist:

1. Visual scan of the screenshot: layout, alignment, clipped text, contrast, dark mode.
2. Every control: buttons, links, toggles. Is there feedback after each?
3. Forms: empty submit, invalid input, edge values.
4. Navigation: each path, the back button, deep links.
5. States: empty, loading, error, overflow.
6. Console and failed requests.
7. Responsive: at least one narrow viewport.
8. Auth boundaries, when roles exist.

Most time goes to the core features. A cluster of issues in one area deserves a deeper look.

## Prove it

- Confirm the issue reproduces once more before collecting evidence.
- Seen without interaction (a typo, clipped text, a broken image, a console error on load): one annotated screenshot.
- Needs interaction: `record start` before the steps, a screenshot after each step with about a second between them, an annotated screenshot of the broken state, then `record stop`. `type` rather than `fill` during a recording, so the video shows the text appearing.
- Append the finding to the report at once. Number them `ISSUE-001`, `ISSUE-002`.

## Report

```markdown
# QA report: <app>

Date, URL, session, scope.

| Severity | Count |
|---|---|
| critical (blocks a core flow, data loss, crash) | |
| high (major feature broken, no workaround) | |
| medium (works, with noticeable problems) | |
| low (cosmetic) | |

### ISSUE-001: <title>

Severity, category (visual, functional, ux, content, performance, console, accessibility), URL, repro video or `N/A`.

What is wrong and what was expected.

1. <step>
   ![step 1](screenshots/issue-001-step-1.png)
```

At the end, make the counts match the issues. Close the session. Tell the user where the report is and which findings are the worst.

## Rules

- Test as a user. Do not read the app's source.
- Never delete output files mid-run.
