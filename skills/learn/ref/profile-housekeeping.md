# Runbook — learner-record housekeeping

Load on demand. This is the **maintenance** workflow for the learner record (resolve its root per the sidecar, and run every command from there) — not a mentoring workflow. It is a meta-session: the learner is the *subject*, not the student, so the plain-English/never-leak rule of the mentoring skill is relaxed here. Paths, counts and status tokens may be discussed openly; they are the material.

It is also the **only** session that edits Level 0. A learning session never does.

Cadence: **monthly**, or when the boot reports something worth acting on.

---

## 0 · No general-purpose organiser, ever

The tempting move is to point a codebase-documentation organiser at this tree. Do not, and do not fork one either.

Those tools exist to impose structure on documentation that **has no schema** — arbitrary prose in an arbitrary codebase. This record has a schema by construction: fixed flat frontmatter, a generated index, and a purpose-built script that reads both. A generator that knows the schema strictly beats an organiser that has to infer one.

> ⚠️ And it would be actively harmful. **A codebase organiser's sort discipline deletes status, dates and sprint state as staleness.** That is correct for a codebase and exactly wrong here, because **the learner record *is* status.** `last`, `status`, `earned_by` and open reps are the payload, not drift to be tidied away.

This runbook is the variant. There is nothing to fork.

---

## 1 · When to run

Any one is sufficient:

| Trigger | Detect |
|---|---|
| **Broken anchors** | the boot's warning line reports a non-zero count — the one genuine corruption, and the only trigger that is urgent |
| Stale backlog | `gap` topics untouched past the long threshold, accumulating faster than they are opened |
| Unverified pile-up | many `asserted` topics — sessions are opening topics and not closing them |
| Boot feels heavy | the digest is no longer a digest, or the total-topic line is doing all the work |
| Calendar | ~monthly, even if nothing tripped — catches slow drift |

Backlog is not an emergency. The boot's housekeeping line is one line at the bottom and is meant to be ignorable.

---

## 2 · Measure before touching anything

Never diagnose from feel. Everything below is a `query` against the same scan the boot uses — there is no second store to consult.

```bash
<skill dir>/bin/boot.sh <record root> query 'anchor-broken'     # dangling edges
<skill dir>/bin/boot.sh <record root> query 'earned_by=asserted'
<skill dir>/bin/boot.sh <record root> query 'gap & last>180d'
<skill dir>/bin/boot.sh <record root> query --all | wc -l       # total topics
```

Two shapes worth separating, because they need opposite fixes:

| Symptom | Root cause | Fix |
|---|---|---|
| Many topics, digest still small | healthy — the design working | nothing |
| Digest large, few topics | too many open at once | §3 close rep debt before opening more |
| Many `asserted`, few `owned` | topics opened and abandoned | §3 prune, and read it as a dosage problem |
| Record stale, sessions happening | **write starvation** — wraps not landing | §4 governance |

**Behaviour audit (optional, the expensive one)** — wrap-write rate and rep completion over the window. Worth once a quarter, or when the record feels stale despite sessions happening. Delegate to a subagent with an explicit no-fan-out instruction; have it report a table of date · topic · human turns · reps posed/answered · whether a write occurred · boot shape.

---

## 3 · The pass — prune, merge, repair, regenerate

A dedicated session with a fresh context window. Never tack it onto the end of a learning session. Read `ref/profile-schema.md` in full first — it defines what is stored and what must never be.

1. **Commit first.** The tree is git; a clean starting point is the whole safety story. Nothing below is destructive once that holds.
2. **Repair broken anchors.** Every `anchor` must name a topic page that exists. A dangling edge silently breaks the adjacency ranking, which then quietly ranks against nothing.
3. **Merge duplicates.** Two pages for one idea split its history. Keep the one with the learner's own model line; fold the other's `seen_in`, `touches` and open reps into it and delete it.
4. **Prune the dead.** A `gap` topic nobody has touched in six months was never a gap, it was a passing mention. Delete it — git keeps it, and it will resurface honestly if it matters.
5. **Retire abandoned threads.** A `learning` topic with open reps and no touch in months is not in flight, and nothing in the reader will ever notice: the digest's ACTIVE list has no recency predicate and no retired state, so an abandoned thread stays active forever and the section grows with everything ever *begun*. The work-in-progress cap does not bound it — it only changes the header. Close the open reps or move the topic back to `gap`, whichever is true, and say which in the page. Never promote it to `owned`: an abandoned thread is unfinished, not learned.
6. **Rewrite Level 0 in place.** Distil, never accumulate; the v1 profile bloated by appending. Confirm the mission still reads true — it is standing context for every session. **Then check the card markers, in the same breath as the rewrite.** The spans between `<!-- BEGIN CARD -->` and `<!-- END CARD -->` are what a shipping session gets instead of this page, this pass is their only maintainer, and a rewrite is exactly when material moves out from between them. Keep the spans short — anchors and the mission, not the page — and move a marker whenever you move what it wrapped.
7. **Regenerate the index** and confirm `check` exits clean.
8. **Re-measure** (§2) and record the numbers in §6.

Never repair a `status` or an `earned_by` from the outside. **Ownership is earned in a session, not granted in housekeeping.**

---

## 4 · Governance — make the rule ride the boot

The load-bearing lesson from the first run, and it survives the layout change intact: **a rule stored as prose in a file that everyone reads by pattern is a rule that quietly stops existing.**

Under the old single-file record that meant smuggling rules into the greppable index. Under this one it is simpler and stronger: **the boot script is the only entry path, so a rule that must survive belongs in what the boot emits or in what the boot enforces.** Level 0 is emitted verbatim on every session; a check that must never be skipped belongs in the script, not in prose someone might not read.

Rules that govern *behaviour over time* belong in two places, both:

- the **schema doc** — the durable why and the exact threshold;
- the **sidecar skill** — the operational instruction the mentor executes.

And anything that changes how the record is *read* must be checked against every entry path: the sidecar's boot section, the script itself, and anything else that names the record. A stale reader whose patterns reference retired field names produces an empty digest and silently falls back to a full read — the measured cause of most unbounded reads found in the first run.

---

## 5 · Verify

- Boot the record and confirm Level 0 and all three derived sections render.
- Render the card (`--card`) and read it as a stranger would: it must carry the anchors and the mission, nothing else from the page, and no warning about missing markers.
- `check` exits clean; the index matches the pages.
- Zero broken anchors.
- No derived field appears in any page's frontmatter — see the derived table in `ref/profile-schema.md`. One is a bug.
- No orphan: every file added under the skill directory is pointed at from `SKILL.md`.

---

## 6 · Baseline log — append one row per run

| date | topics | active | unverified | rusty | broken anchors | wrap-writes | action |
|---|---|---|---|---|---|---|---|
| 2026-06-21 | — | — | — | — | — | — | v6 diet of the single-file profile: rows de-bloated, Apr–May rolled up |
| 2026-08-11 | 57 rows | — | — | — | — | 1 in 9 sessions | governance patched (width valve, wrap contract, dosage); diet deferred |

Note from the single-file era, kept because the pattern outlives the layout: a diet held **7 weeks** before re-bloat. If a pass holds materially shorter, the per-session write discipline is the problem, not the pass.
