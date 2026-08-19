# SOP — Learner-profile housekeeping

Load on demand. This is the **maintenance** workflow for the learner profile (resolve its path per the sidecar's resolution order; every `PROFILE.md` below means that resolved file, and every command runs from its directory) — not a mentoring workflow. It is a meta-session: the learner is the *subject*, not the student, so the plain-English/never-leak rule of the mentoring skill is relaxed here (paths, byte counts and status tags may be discussed openly — they are the material).

First full run: **2026-08-11**. Cadence: **monthly**, or immediately when a valve in `ref/profile-schema.md` trips.

---

## 0 · When to run

Any one is sufficient:

| Trigger | Detect |
|---|---|
| Width valve | Tier-2 ledger >25KB, or any row >60 words |
| Length valve | Tier 3 >25 entries, or file >700 lines |
| Flag present | an `[ops] COMPACTION-DUE` row sits in the `_meta` track of the index |
| Hydration feels heavy | boot cost noticeably above ~8k tokens |
| Calendar | ~monthly, even if nothing tripped — catches slow drift |

---

## 1 · Measure before touching anything

Never diagnose from feel. Three measurements, all cheap.

**A. Byte decomposition per tier** — locates *where* the weight is:

```bash
cd <profile-dir>
awk '/^# TIER 1/{t="tier1"} /^# TIER 2/{t="tier2"} /^# TIER 3/{t="tier3"} \
     {b[t]+=length($0)+1} END{for(k in b) printf "%s=%dB\n", k, b[k]}' PROFILE.md
wc -l -c PROFILE.md
```

**B. Row-width distribution** — the schema says one line, ≤60 words; find the liars:

```bash
rg -N '^### \[' PROFILE.md \
  | awk '{n=NF; if(n>60) printf "%3d words | %s\n", n, substr($0,1,70)}' \
  | sort -rn | head -20
rg -c '^### \[' PROFILE.md          # total row count
```

**C. Read-shape audit** — are agents actually booting the disciplined way? Counts unbounded profile reads across the session corpus:

```bash
cd <agent-session-transcript-dir>
rg -o '\{"path":"[^"]*PROFILE\.md"[^}]*\}' *.jsonl \
  | sed 's/.*PROFILE\.md"//' \
  | awk '{ if ($0 ~ /^\}/) full++; else bounded++ } \
          END{ printf "full=%d bounded=%d\n", full, bounded }'
```

> Sanity-check the output shape before trusting the number — transcript JSON layout drifts between Claude Code versions. If the counts look absurd, print a few raw matches and adjust the filter rather than reporting the number.

**D. Behavior audit (optional, the expensive one)** — wrap-write rate and rep-completion, over learning sessions in the window. Worth doing once a quarter, or when the profile feels stale despite sessions happening. Delegate to a subagent with an explicit no-fan-out instruction; have it report a table of: date · topic · human turns · reps posed/answered · whether a profile edit occurred · boot shape.

---

## 2 · Diagnose — the two failure modes, and how to tell them apart

| Symptom | Root cause | Fix |
|---|---|---|
| Ledger KB high, line count normal | **Width drift** — rows grew into paragraphs | §3 row diet |
| Line count high, rows lean | **Length growth** — Tier 3 accumulating | §3 archive rollup |
| Boot cost high but file is lean | **Undisciplined readers** — something full-reads | §4 governance |
| Profile stale, sessions happening | **Write starvation** — wraps not landing | §4 wrap contract |

Width and length are independent, and the length valve is blind to width — that is exactly how the 2026-08 bloat happened at only 475 lines. Always check both.

---

## 3 · Compact (the diet) — a dedicated session, never a tail-end task

This is a large rewrite. Give it its own session with a fresh context window. Read `ref/profile-schema.md` in full first — it defines tier grammar and what is allowed to move where.

1. **Archive first, always.** `cp PROFILE.md _archive/PROFILE.v<N>-<YYYY-MM-DD>.md`. Nothing is deleted, only relocated — the archive is what makes aggressive compaction safe.
2. **Diet the rows.** Every `### [status]` row → one line, ≤60 words: status · topic · one-line model-or-gap · anchor · date. Detail moves *down* into the Tier-3 session body, never up into the row.
3. **Deduplicate against Tier 1.** Per-topic analogy hooks duplicated in the recall-currency block collapse into the post-diet row; Tier 1 keeps only the signature cross-cutting anchors and verbatim quotes.
4. **Roll up Tier 3.** Oldest session blocks → `_archive/`, leaving one rolled summary line each. Promote any durable quote or analogy to Tier 1 *before* archiving its session.
5. **Re-stamp the header note** with the new version, date, and what changed.
6. **Clear the `[ops] COMPACTION-DUE` row** from the `_meta` track, or update it with the new measurement.
7. **Re-measure** (§1 A+B) and record the numbers in §6.

Safety: exact-match edits only, never whole-file overwrite; re-read a section immediately before editing it (concurrent sessions write here too).

---

## 4 · Patch governance — make the rule ride the index

The load-bearing lesson from the first run: **a rule stored as prose in a file that everyone reads by pattern is a rule that quietly stops existing.** Boot greps the header index; prose above the title is invisible to it.

So: any rule that must survive goes in as an `[ops]` row under `## track: _meta`, matching the boot pattern `^### \[\w+\]` — front-loaded, because the index truncates at 80 characters.

```
### [ops] <imperative-first-4-words> — <detail> · <MM-DD>
```

The three standing rows are read-discipline, COMPACTION-DUE, and wrap-contract. Add rows for new rules; retire rows whose rule is dead. Keep it under ~5 rows — this is a control panel, not a second ledger.

Rules that govern *behavior over time* (not a one-off flag) belong in two places, both:
- the **schema doc** — the durable why + the exact threshold;
- the **sidecar skill** — the operational instruction the mentor executes.

And anything that changes how the profile is *read* must also be checked against every entry path: the sidecar skill's boot steps, and any agent definition that names the profile (a stale agent def whose grep patterns reference retired section names produces an empty outline and silently falls back to a full read — the measured cause of most unbounded reads found in the first run).

---

## 5 · Verify

- Boot the disciplined way and confirm the `_meta` `[ops]` rows appear in the first lines of index output.
- Re-run §1A/1B; ledger under the width cap, no row over 60 words.
- Confirm the archive copy exists and the header note names it.
- Confirm no orphan: every file added under the skill directory is pointed at from `SKILL.md`.

---

## 6 · Baseline log — append one row per run

| date | lines | total | tier1 | ledger | rows | tier3 | unbounded reads (31d) | wrap-writes | action |
|---|---|---|---|---|---|---|---|---|---|
| 2026-06-21 | — | — | — | — | — | — | — | — | v6 diet: rows de-bloated, Apr–May rolled up |
| 2026-08-11 | 475 | 170.6KB | 10.6KB (+18.3KB recall-currency) | 73KB | 57 | 65.4KB | 38 full reads | 1 in 9 sessions | governance patched (`[ops]` rows, width valve, wrap contract, dosage); **diet deferred** |

Note from the first run: the v6 diet held for **7 weeks** before re-bloat. That is the natural cadence — if a diet holds materially shorter, the row-writing discipline is the problem, not the diet.
