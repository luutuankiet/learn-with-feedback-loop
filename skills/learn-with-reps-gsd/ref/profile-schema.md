# PROFILE.md — Schema & Philosophy

**Locked:** 2026-06-01. This documents the structure and *reasoning* behind `PROFILE.md`, so any future retro-refactor starts from the decisions already made rather than re-deriving them. The mentoring sidecar skill (`learn-with-reps-gsd`) points here; it does not embed this.

## Why the v2 profile was refactored

The first month's profile (archived at `_archive/PROFILE.v2-2026-06-01.md`) hit five structural limits:

| Limit | Symptom |
|---|---|
| **Opaque headers** | leveled for ripgrep-outline, but the header *text* carried no learner-state — `### Closures` tells you nothing about whether it's a gap, being learned, or owned |
| **Unbounded session log** | ~67% of the file was an append-only dated log; grows forever, eventually bloats even the outline |
| **Accumulated, not distilled** | the strengths section grew to ~19 entries by appending instead of distilling |
| **Single active focus** | one "Active focus" field; the learner actually runs many concurrent learning tracks across many sessions a day |
| **Monoculture** | every entry was one track (JS/Exercism); no room for nextjs, mcp, PR-onboarding, etc. |

## The core idea

**Put learner-state INTO the header text, so `rg '^### '` ≈ the whole profile.** Detailed body reads become JIT, only for the topic a session touches. Isolate the unbounded growth into one archivable tier so the outline stays bounded forever.

## The three tiers

```
TIER 1 — Learner Core    (bounded · REWRITTEN in place · read every session)
  Background · Fluent anchors · Learning traits · Coaching points · Mentoring prefs
  · Momentum triggers · Active foci (PLURAL — concurrent tracks)
  · Recall currency (durable verbatim quotes + analogies that landed)

TIER 2 — Topic Ledger    (the greppable SPINE · grows by CONCEPT · partitioned by track)
  ## track: <name>
  ### [status] topic — one-line-model-or-gap · anchor:X · date

TIER 3 — Session Log     (append-only · ROLLED UP on trigger · read only when cited)
  #### YYYY-MM-DD — session title {what landed; quotes promoted to Tier 1}
```

**What goes where:** durable *traits / dispositions* (how the learner learns) → Tier 1. *Concept mastery* (what they know) → Tier 2. *Session events* (what happened) → Tier 3.

## Header grammar (Tier 2)

`### [status] topic — model-or-gap · anchor:X · date`

- **status** — `[gap]` (not started / flagged) → `[learning]` (in progress, model still shaky) → `[owned]` (can teach it). `[rusty]` = was owned, decayed, re-confirm if it resurfaces.
- **model-or-gap** — the one-line mental model if owned ("labels-on-boxes"), or the specific gap if not ("when does it re-run?").
- **anchor** — the fluent-language analogy hook (`anchor:py-unpacking`).
- **date** — last touched (YYYY-MM-DD). Doubles as decay query: `[owned]` untouched >60d = re-drill candidate.
- **links** *(optional)* — comma-list of related topic keys (`links:incremental-dbt,merge-vs-upsert`) — greppable adjacency so a session hydrates a topic plus its neighbors.
- **reps** *(optional)* — open rep-debt as `reps:answered/posed` (e.g. `reps:2/5`) — cleared when the learner writes the remaining answers in a later session; spaced retrieval is the design, not a failure.
- **Hard width cap: a row is one line, ≤60 words.** Detail lives in the Tier-3 session body, never the row.

**Grep verbs this unlocks:** `rg '^### \['` (whole profile) · `rg '^### \[gap\]'` (backlog) · `rg '^### \[learning\]'` (active edges) · `rg '^## track:'` (tracks).

## Multi-concurrent-session design

The learner runs many sessions across many tracks in a day. The profile is **not** one-agent-one-session. Consequences baked into the write discipline:

- **Active foci is a list**, not a field — any session reads it to locate which track it belongs to.
- **Read-just-before-write** — never trust start-of-session state for a wrap write; another session may have edited in between.
- **Exact-match edits, never whole-file overwrite. Unique-keyed appends.** Tier-1 rewrites are rare and re-read immediately before editing.
- **Every session closes the loop** — wrap-write (≥1 edit) or an explicit "no durable delta this session" line. Silent no-write was the measured 2026-08 leak: 1 write in 9 learning sessions, one explicit "update my profile" instruction dropped.

## Rollup valve (the "forever" pressure release)

Tier 1 is rewritten (can't grow). Tier 2 grows by concept (slow). Tier 3 is the only unbounded tier — so it's the only one that gets archived. **Trigger (length):** when Tier 3 exceeds ~25 entries or the file exceeds ~700 lines, move the oldest block to `_archive/`, leaving a one-line rolled summary. **Trigger (width — added 2026-08-11):** when the Tier-2 ledger exceeds ~25KB total OR any single row exceeds ~60 words, a row-diet is due — archive the fat version, rewrite rows to true one-liners. Width is the measured bloat vector: the 2026-08 audit found 57 "one-line" rows averaging 1.28KB (73KB ledger) at only 475 file lines — the length triggers slept through a fat-doubling. Concepts already live as Tier-2 rows; only the narrative is archived. Promote any durable quote / analogy up to Tier 1 *before* archiving its session.

## The philosophy this serves

Writing is thinking; the mentor's job is to make the learner write. The profile exists so the mentor **onboards fast (ripgrep-in)** and **persists distilled deltas (distill-out)** — without the learner ever reading it. The learner writes verbose, unstructured thoughts and raw materials; the agent distills them to durable, token-efficient state. After distillation the learner notices no difference in the mentoring; the agent's working state just got leaner. This is the same distillation that compaction performs to context — here it is performed to disk.
