# Web Research Tools — usage rules

Defaults are traps; Tools: `exa_web_search_advanced_exa`, `exa_web_fetch_exa`, `closedrouter_web_search`, `tavily_tavily_extract`.

## exa advanced search — the default tool

Presets, ranked (most useful first):

| # | Preset | Parameters | For | ~Weight |
|---|---|---|---|---|
| 1 | **Discovery** (default) | `numResults: 5, textMaxCharacters: 1, enableHighlights: true, highlightsQuery` OMITTED, `highlightsMaxCharacters: 2500` | Open discovery, research calls, fused search+extract | 8–12 KB |
| 2 | **Lean fact** | same, but `highlightsQuery: "<one specific fact>"`, `highlightsMaxCharacters: 800` | Known-target extraction | 2–5 KB |
| 3 | **Page-prose** | `enableHighlights: false, textMaxCharacters: 2000–3000` | Verbatim short pages, GitHub issues, schemas | 10–15 KB |
| 4 | **Pinned** | Lean + `includeText: ["<exact symbol>"]` and/or `includeDomains` | Exact-symbol / domain verification | 2–5 KB |

- Put exact symbols and discriminative nouns IN the query text — it steers ranking.
- An explicitly phrased `highlightsQuery` (narrow or broad) constrains what arrives — that is why Discovery omits it: highlights then default to query-relevant whole-page excerpts.
- Miss-recovery ladder (don't settle): add 1–2 `additionalQueries` naming the target (cheapest) → re-run Discovery → page-prose or `exa_web_fetch_exa` on the known URL.
- `numResults`: 5; 8 only for issue-digging recall (it reorders, doesn't extend). Never >10. Always set.
- Code-heavy results (GitHub blobs, OpenAPI dumps): keep `textMaxCharacters: 1`.
- Page-prose truncates from the page top and drifts toward stale commits/mirrors — short pages and issues only.
- NEVER: unset `textMaxCharacters` or `numResults` · `enableSummary` (forbidden) · setting `type` (default is the only mode) · `subpages`/`subpageTarget` · `contextMaxCharacters`.

## exa fetch — reading known pages

- ALWAYS set `maxCharacters`: 2000–6000 normal; up to ~12000+ when the whole page is genuinely needed.
- Truncates from the top; top-heavy pages (base64/code first) can burn the budget — for mid/late-page facts use tavily extract with `query`.
- `.md` suffix on docs URLs: good for guides, bad for API references (raw OpenAPI dump).
- GitHub repos come back as digests. Batch ≤ 3 URLs. Cannot read x.com.

## tavily extract — surgical snippets

- Default mode: WITH `query`, and ONE target concept per call — multi-concept queries over-narrow to the first concept (verified: whole guides collapsed to one snippet). Need N facts from a page → N calls, or exa fetch.
- Verify output is non-empty and on-topic; it can garble/duplicate text and silently drop markdown state markers — never the sole source for exact JSON or verbatim quotes. `extract_depth: "basic"`.
- WITHOUT `query` (full page): last resort — when the needed content sits beyond a sane fetch budget or the URL is one exa fetch can't read (x.com). Otherwise prefer exa fetch.

## closedrouter search

- Compact, authority-first, code/GitHub-issue bias — the best pitfall hunter. `count: 3–8`. Never `page` (broken). `language` works. Retry once on rate-limit errors.
- Its snippets often already contain the answer — don't re-fetch what it returned.
- Poor results? Rephrase the query or switch engines — don't re-run the same thing.

## Routing

| Need | Tool |
|---|---|
| Anything search-shaped | advanced Preset 1 (Lean for known facts, Pinned for symbols) |
| Read a known page | exa fetch |
| Specific fact from a known page | tavily extract + `query` (one target per call) |
| Whole page incl. tail | exa fetch, high `maxCharacters` (tavily no-query last resort) |
| Pitfalls, real-world bugs, non-English | closedrouter |

## Anti-patterns

1. Unset `textMaxCharacters` (up to 1 MB payloads).
2. Unset or >10 `numResults`.
3. `enableSummary` — forbidden.
4. Setting `type` at all.
5. Multi-target tavily `query`.
6. Phrasing `highlightsQuery` broadly and expecting a hedge — explicit phrasing constrains; omit it instead.
7. Search + fetch of the same page when highlights carried the answer.
8. Tavily extract without `query` when exa fetch works.
9. Settling for one incomplete search instead of walking the recovery ladder.
