---
name: writing-documentation
description: Write or restructure documentation for its reader: README, guides, API docs, UI copy, agent instructions. Includes the FOR-AGENTS, SKILL-MECHANICS and COMPRESSION references.
---

# Writing documentation

Write for a reader who enters mid-page: from search, a deep link, or a single FAQ entry.

## Phase 1: Pick the audience

One of: User, Developer, Agent. Hold it in mind. Do not label the document with it; a glossary and a folder layout may reflect it, nothing else.

## Phase 2: What that reader needs

Think about what information is relevant, and how it needs to be cited.

- **User**: a "how do I do this" guide. Only the app surface, no references to the code.
- **Developer or Agent**: an introduction to the project, its edge cases and environment specifics, style and implementation guides.
- **Agent instructions**: short sentences in technical English (ASD-STE100), one requirement per sentence, RFC 2119 words (MUST, SHOULD, MAY) with their defined strength. When migrating or compressing such instructions, do not escalate importance: a SHOULD never becomes a MUST. For the structure of such text (skills, `AGENTS.md`, instruction packs): read `FOR-AGENTS.md`; when the document is a skill, also `SKILL-MECHANICS.md`. To shorten such text for the model without losing a rule: `COMPRESSION.md`.

## Phase 3: Is this documentation needed?

- Did the user request it?
- Does it fix a misconception or stale documentation?
- Cut fluff. Align existing pages with this guide instead of adding new ones.

## Rules for all documentation and product copy

- Leave out meta information that is not intended for the audience.
- Say what happens instead of what does not: "Click once to save" instead of "Don't click twice".
- Write each section so it works on its own. No reliance on earlier sections.
- Spell out the full phrase instead of an acronym. When an acronym stays (more familiar than the phrase, or the phrase is too long to repeat), expand it at its first use on that page. Never only in a glossary or a later entry: in an FAQ, every entry is its own entry point.
- No em dashes. Period, comma, colon, or parentheses instead.
- Do not state behavior the reader already expects ("closing the terminal or rebooting loses nothing", when the app has a session system).
- Do not blanket-avoid technical terms for a technical audience: "the app keeps every conversation in its database", not "in a store on the host".
- No grandiose qualifiers: "the exact <thing>", "the honest <thing>", "quietly".

## Rules for user-facing pages

- Avoid sections that ask a question and answer it in one sentence. Use a task-named heading and the steps.
- Replace a long list of paths or names with a sentence or a table.
- Consider whether every stated condition applies in all cases. A side effect that appears only sometimes may not need naming.
- Leave out irrelevant technicalities: the implementation language, file masks, safety features that hold in normal operation.
