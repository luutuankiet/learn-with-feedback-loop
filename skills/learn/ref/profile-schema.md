# The learner record — schema & philosophy

This documents the structure and the *reasoning* behind the learner record, so a future refactor starts from decisions already made rather than re-deriving them. The record reference (`record.md`, beside this file) points here; it does not embed this.

The record is a **tree**, not a file: a hand-written Level 0, one page per topic, and an index generated from those pages. Nothing in it is maintained twice.

## What the two previous shapes taught

| Shape | Where it broke |
|---|---|
| **v1 — prose profile with opaque headers** | `### Closures` tells you nothing about whether it is a gap, in progress, or owned. Learner-state had to move *into* the greppable surface. |
| **v1 — unbounded session log** | ~67% of the file was an append-only dated log. Growth had to be isolated into something archivable. |
| **v1 — accumulated, not distilled** | the strengths section grew to ~19 entries by appending. |
| **v2 — one file, three tiers** | the fix for all of the above, and it **measurably did not scale**: one file, one learner, a few weeks, tens of thousands of tokens the learner declines to read. A load argument, not a privacy preference. |
| **v2 — hand-maintained shared lists** | active foci and recall currency were lists many concurrent sessions appended to. Two sessions a day made them a merge surface. |

## The two rules everything else follows from

**1 · Never store what can be computed.** A stored field that could have been derived is a field that will one day disagree with reality. Anything derivable is regenerated from the pages on every boot.

**2 · Everything two sessions would both touch is derived.** Collisions then regenerate instead of merging. The learner runs many sessions a day on a single linear branch; this is what makes an abandoned session the *cheapest* outcome rather than the messiest.

## Level 0 — who the learner is

Hand-written, bounded, rewritten in place, and **never written by a learning session** — only by housekeeping. That single property is what makes the concurrent case conflict-free rather than nearly.

It carries: background · fluent anchors · learning traits · coaching points · mentoring preferences · momentum triggers · **the mission** (the standing why, in the learner's own words).

It does **not** carry active foci — those are derived. It does not carry recall currency either: durable quotes and analogies live on the topic page they belong to, where the boot surfaces a few derived rather than maintained. Accepted cost: an analogy that explains four unrelated things gets filed under one of them.

## A topic page

Flat frontmatter, no nesting beyond the two lists. Flatness is the whole reason the index generator is `awk` rather than a YAML parser.

| field | values | rule |
|---|---|---|
| `status` | `gap` · `learning` · `owned` | **`rusty` is never stored** — it is `owned` plus an age threshold, so it is computed |
| `track` | slug | the only pure taxonomy field |
| `earned_by` | `asserted` · `rubber-duck` | **`owned` requires `rubber-duck`.** No third value, because a third value is a door to walk through when in a hurry |
| `model` | one line, or `null` | **only ever the learner's own words.** The mentor transcribes; it never authors one on their behalf. `null` is meaningful — it means nobody has heard them explain this |
| `anchor` | slug of another topic, or `null` | what this was explained *in terms of*. This is the graph edge the adjacency ranking walks |
| `reps` | `answered/posed` | one field, split on `/` |
| `open_reps` | list of short slugs | what a resuming session picks up |
| `touches` | integer | distinct sessions that engaged this topic. Replaces wall-clock duration, which in an agentic session is mostly idle gaps |
| `last` | `YYYY-MM-DD` | last touch. Drives every age computation |
| `seen_in` | list, capped at 3 | the **situation**, not a session identifier — *"the Snowflake cost spike"*, never a timestamp. This is the recognition handle that makes a topic identifiable without a second read |

```
---
status: learning
track: data-pipelines
earned_by: rubber-duck
model: "reprocess a trailing slice; no state to get wrong"
anchor: batch-reprocessing
reps: 1/5
open_reps: [trace-late-arrival, watermark-failure, merge-condition, cost-at-10x]
touches: 2
last: 2026-08-19
seen_in:
  - the nightly DAG rewrite
  - the Snowflake cost spike
---

# lookback windows

<the learner's own compressed page — the inverted reference, written by them>

## open reps
- trace a late-arriving row through a 3-day window
- what breaks first when the window is shorter than the lateness
```

### Why `earned_by` exists, and why `owned` is strict

The counterpart page, from the same session, is the case the whole design exists for:

```
---
status: learning
track: data-pipelines
earned_by: asserted
model: null
reps: 0/4
touches: 1
last: 2026-08-19
seen_in:
  - same session — presented, skipped for time
---
```

`asserted` with an empty `model` is unmistakable, and **no date can rescue it.** A status records *how* it was earned, so a topic skipped for time can never be read as knowledge. Decay being visible is the record being honest; false ownership is the record lying, and dates alone never catch that.

**A topic that was mentioned and not engaged gets no page at all.** Mentioning is not engagement. It resurfaces the next time the learner ships something that touches it.

## Derived — never written

Anything in this table appearing inside a file is a bug.

| derived | from |
|---|---|
| `rusty` | `status: owned` and `last` older than the threshold |
| `unverified` | `earned_by: asserted` |
| **active foci** | `status: learning` with non-empty `open_reps`, ordered by `last` |
| progress | `reps` |
| difficulty | reps consumed moving `gap → owned` — measured, not guessed |
| distance from owned | walk `anchor` edges to the nearest `owned` + `rubber-duck` topic. **This is the adjacency ordering** |
| every housekeeping counter | the scan |

The generated index *is* the aggregate table, so no second store exists. If it ever outgrows `awk`, that index is a markdown table DuckDB reads as-is — zero migration, which is why this cannot be got wrong now.

## Multi-concurrent-session design

- **A single linear branch.** A branch is residue; the property worth protecting is that an abandoned session leaves nothing.
- **`git pull --rebase` immediately before the write, never at boot.** The hazard is a stale base, not a simultaneous write. Never `git merge`.
- **Exact-match edits, never whole-file overwrite.** Prefer touching a topic's own page over anything shared.
- **No chronology directory.** Git is the chronology; the commit message carries what a session log used to.
- **Every engaged session writes.** Silent no-write was the measured leak — one write in nine sessions. A session the learner scrapped is the sole legitimate exception.

## The philosophy this serves

Writing is thinking; the mentor's job is to make the learner write. The record exists so the mentor **boots in one call** and **persists distilled deltas** — without the learner ever reading it. What persistent storage holds is **who the learner is**, not the material: the model already knows the material.
