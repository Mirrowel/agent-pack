# Web research tools — hard rules for LLM agents

Tools: exa_web_search_advanced_exa (exa_adv), exa_web_fetch_exa (exa_fetch), closedrouter_web_search (cr), tavily_tavily_extract (tavily).

## Route

- search anything → exa_adv (Discovery; Lean known fact; Pinned symbol)
- read known URL → exa_fetch
- specific fact from known page → tavily + query (one target/call)
- whole page incl. tail → exa_fetch, maxCharacters ~12000+
- bugs / real-world errors / non-English → cr

## exa_adv — default search

Presets, best-first:
1. Discovery (default): numResults 5, textMaxCharacters 1, enableHighlights true, highlightsQuery OMITTED, highlightsMaxCharacters 2500 — open discovery, fused search+extract. ~8–12 KB.
2. Lean: Discovery + highlightsQuery "<one specific fact>", highlightsMaxCharacters 800 — known-target facts. ~2–5 KB.
3. Page-prose: enableHighlights false, textMaxCharacters 2000–3000 — verbatim short pages / GitHub issues / schemas ONLY (truncates from top, drifts to stale mirrors). ~10–15 KB.
4. Pinned: Lean + includeText ["<symbol>"] / includeDomains — exact-symbol or domain verification. ~2–5 KB.

- Query text MUST contain exact symbols + discriminative nouns (steers ranking).
- Any explicit highlightsQuery constrains results; omitted → query-relevant page excerpts (why Discovery omits it).
- Target missing from results: add 1–2 additionalQueries naming the target → rerun Discovery → page-prose or fetch the URL. NEVER settle for one incomplete search.
- numResults: ALWAYS set; 5 default; 8 issue-digging only (reorders, not extends); NEVER >10.
- Code-heavy results (GitHub blobs, OpenAPI): textMaxCharacters stays 1 (base64 junk leaks even capped).
- NEVER: unset textMaxCharacters or numResults · enableSummary (forbidden) · set type · subpages/subpageTarget · contextMaxCharacters.
- NEVER search+fetch the same page when highlights already carried the answer.

## exa_fetch — known pages

- ALWAYS set maxCharacters: 2000–6000; ~12000+ only if the whole page is needed.
- Truncates from top; top-heavy pages (base64/code first) burn the budget → mid/late-page facts: tavily+query instead.
- .md docs URLs: good for guides; API references = raw OpenAPI dump, avoid.
- GitHub repos → digest. Batch ≤3 URLs. Cannot read x.com.

## tavily — snippets

- WITH query: ONE target concept per call — multi-concept queries over-narrow to the first concept. N facts = N calls or exa_fetch. NEVER combine targets in one query.
- Verify output non-empty + on-topic; may garble/duplicate text, drops markdown state markers; NEVER sole source for exact JSON or verbatim quotes. extract_depth basic.
- WITHOUT query (full page): last resort ONLY — tail beyond fetch budget, or x.com. Otherwise use exa_fetch.

## cr — pitfall hunter

- Authority-first, GitHub-issue bias, pitfall hunter. count 3–8. NEVER page (broken). language works. Retry once on rate-limit error.
- Snippets often contain the answer — NEVER re-fetch what it returned.
- Poor results: rephrase or switch engines; NEVER rerun the same query.
