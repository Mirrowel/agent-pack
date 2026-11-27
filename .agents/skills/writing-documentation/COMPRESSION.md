# Compressing text for LLMs

How to shorten a prompt, instruction pack, skill or reference that is already correct. The reader is a model, not a person. The pass changes wording only: every rule, condition, number and literal survives, with the same strength. Shorter text that lost a rule is a failure, whatever it saved. For what to delete at the document level (no-ops, duplication, disclosure): [FOR-AGENTS.md](FOR-AGENTS.md), Pruning.

## The contract

A compression is correct when all of this holds:

- **Every instruction stays**: each rule, prohibition, condition, exception, default, warning and list item, and the reason clause where it says when the rule applies.
- **Strength stays.** MUST, SHOULD, MAY, never, always, only, if, unless: same word, same scope. A SHOULD never becomes a MUST. Two rules of different strength never merge into one.
- **Literals stay verbatim**: commands, flags, paths, names, error strings, numbers with their units, `${VAR}` placeholders (same spelling, same count), markers and tags another tool greps for, code blocks.
- **Structure stays**: same sections in the same order, headings verbatim, one list item per rule. A heading may change punctuation when no tool and no other file keys on its wording. The pass optimizes the text. It does not rework it.
- **Nothing is added**: no rule, no emphasis, no comment.

## What goes

- Restatement: a sentence that repeats an earlier one in the same file, in the same or other words.
- Staging and politeness: "It is important to note", "In order to", "Please", "You should now", a closing summary.
- The subject "the agent" or "you". Write the imperative: "Snapshot again", not "The agent should then take a snapshot again".
- Articles and connectives, where the sentence still has one meaning.
- An explanation that restates its rule. Keep the rule and the reason that changes behavior.
- Cost tables, timings, version and provenance lines, how the text was made.

Keep the shape: headings, bullets, one rule a line. A wall of text saves little and costs attention.

## How to rewrite a sentence

1. Find the verb, its object and its conditions. Those words stay.
2. Cut what surrounds them.
3. Read the result as someone who has never seen the source. One reading, no decoding. Otherwise restore words.

A condition that says when an action is allowed, required or forbidden keeps its subject, object, verb, destination and cause. It reads fine without them and is looser with them gone.

Each line below was a real compression that passed a word count and failed the reader:

| Wrongly compressed | Correct | Lost |
|---|---|---|
| `Platform's value forms.` | `Keep values in the form the platform already gives you.` | the verb: a rule with no verb cannot tell keep from avoid |
| `delete if guards` | `delete the test if it guards nothing unique` | the object |
| `never fix by analogy` | `never fix by analogy without checking the mechanism` | the condition: a scoped ban became total |
| `not mock calls` | `not mock-call assertions` | the meaning: it banned the calls, not the assertions |
| `a request naming "review"` | `the word "review" as a request` | the condition: a request that only mentions the word now passes the gate |
| `a failure report with the error` | `a failure report to the thread explaining the error` | the destination |
| `One search` | `A simple search` | the depth: a qualifier became a cap |

## Stop

- A line that needs decoding is not short.
- Tight text stays. An already short, tested core loses more than it saves.
- Never truncate to fit a budget. Tier or split instead.
- The text obeys its own rules. A pack that bans em dashes carries none.
- Dense text has a floor. A second pass with a stronger mandate that moves the total by about one percent has reached it. Report the number; whether reasons and examples may go is the owner's decision.

## Persona text

Role and voice lines steer behavior ("You are a lazy senior developer"). Remove restatement only.

## Measure

Count tokens with a tokenizer before and after, per section, largest first. Words are a rough proxy: about 1.3 tokens a word in English prose.

## Verify

Not done until all of these pass:

1. **Scripted**: every placeholder, backtick span, heading and marker of the source is in the result, with the same counts. Every fence closed. Prove the script on a copy broken on purpose before trusting it.
2. **Guard walk**, by an agent that did not compress: number every requirement in the source, then mark each one kept, weakened, strengthened or lost. The compressor misses its own drift.
3. **Removed words**: read an inline diff of source against result with every dropped span marked. A lost subject or cause shows there first.
4. Fix, then repeat all on the changed files.

A check that writes test files runs on a scratch copy of the tree. One that writes into the output can destroy it.
