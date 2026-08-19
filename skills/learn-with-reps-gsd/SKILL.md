---
name: learn-with-reps-gsd
description: Sidecar for learn-with-reps. To be loaded whenever learn-with-reps is invoked in a session.
user-invocable: true
---

# learn-with-reps-gsd

Sidecar to **learn-with-reps**. That skill is filesystem-blind by design. This one adds the **persistent learner-profile** when the session can reach the filesystem.

**Load trigger (lives HERE, never in learn-with-reps):** when `learn-with-reps` is active AND this session has filesystem access, load this skill and hydrate the profile before drilling. learn-with-reps stays blind — the awareness that a profile exists is this skill's job, so the generic skill remains portable to any environment.

## The profile

A single, global learner-profile shared across every project and every learning track. It lives **outside** any one codebase — it spans them.

**Finding it — resolution order, first hit wins. Resolve it once at session start and use that path for the rest of the session.**

1. **Beside the skills directory** — the repo that hosts this skill: `<repo-root>/PROFILE.md`, where `<repo-root>` is the directory containing the `.claude/skills/` that loaded this file. This is the default home and the one to assume unless something says otherwise. Keep the profile in a **private** repo — it is the most personal file in the system.
2. **A path recorded by the caller** — a rebuild track's `learn/CHARTER.md` records the profile location for that track; a project's own instructions may pin one. An explicit pointer beats the default.
3. **Ask.** No profile found and none pinned — say so, offer to seed one from `PROFILE.template.md` (shipped in the gsd-mentor repo alongside this skill), and record where it landed.

**Never guess a path and never create a second profile.** Two profiles is the failure that silently splits a learner's history in half.

- **Structure + rationale:** documented in `ref/profile-schema.md`, sibling of this file. **Read that doc before any non-trivial structural write** — it defines the tiers, the header grammar, the status lifecycle, and the rollup rules. Don't improvise structure.

## Read discipline — ripgrep-in, hydrate on demand

Never full-read the profile (it grows forever). At session start:

1. `rg -o '^### \[\w+\] .{0,80}' <profile>` — the **Topic Ledger truncated index** (~5KB): status + topic + head of each model line, every track, one shot. The 80-char cap is deliberate — rows can bloat wider than the schema allows; never pull full rows at boot.
2. `rg '^## track:' <profile>` — the active tracks.

**The index's first rows are `### [ops]` rows under `## track: _meta` — they are INSTRUCTIONS to you, not learner topics.** They carry read-discipline, a compaction-due flag, and the wrap contract. Act on them; they ride the index precisely so no agent can miss them by grepping headers and skipping the prose at the top of the file. Governance that only lives in prose above the title is invisible to a header-grep boot — that is why it is duplicated here as data.
3. Read **Tier 1 (Learner Core)** at the top — who the learner is + their **concurrent active foci** (they context-switch across many sessions a day; this is NOT one-agent-one-session — use the foci list to locate which track *this* session belongs to).
4. Hydrate **one or two topic bodies only** — the concepts this session actually touches.

That outline ≈ the whole profile for onboarding. Detailed body reads are JIT, by touched topic.

## Write discipline — distill-out at wrap

The end-of-session write is itself a distillation: turn a verbose session into a few durable deltas. Keep it ~300–600 tokens, inline, no ceremony.

**Wrap contract (2026-08-11 — non-negotiable):** a learning session may NOT end without either (a) ≥1 profile edit or (b) an explicit "no durable delta this session" line in the closing recap. Silent no-write is the measured #1 leak (1 write in 9 sessions; one explicit "update my profile" instruction dropped). Two width rules make every-session writes safe forever: **≤60 words per ledger row**, and **open reps are ledgered, not lost** — reps posed but unanswered go into the touched row's tail as `reps:answered/posed` so the next session re-drills them. Unanswered reps are a spaced-retrieval feature when recorded, a leak when not.

- **Advance touched topics** along the status lifecycle `[gap] → [learning] → [owned]` (+ `[rusty]` if a known one decayed). Sharpen the one-line model / anchor if it improved.
- **Append one session entry** to Tier 3 (dated, unique-keyed). Promote verbatim learner quotes and analogies that landed up to Tier 1 — those are recall currency.
- **Touch Tier 1 only** if a durable trait, anchor, or coaching point genuinely surfaced. Tier 1 is rewritten in place, not grown — distill, don't accumulate (the old profile bloated its strengths section by accumulating).

**Multi-concurrent-session safety (critical — the learner runs many sessions at once):**
- Read the exact section *just before* editing it; another session may have changed it. Don't trust start-of-session state for a wrap write.
- Use exact-match edits, **never whole-file overwrite**. Append unique-keyed entries so two sessions don't collide.
- Tier-1 rewrites are rare; when you do one, re-read it immediately before the edit.

**Rollup valve (keeps the outline bounded forever):** when Tier 3 crosses the length threshold in `ref/profile-schema.md` — or the **width valve** fires (Tier-2 ledger >25KB, or any row >60 words) — archive to `_archive/` beside the profile and leave a one-line rolled summary / rewrite rows back to one-liners. Concepts survive as Tier-2 rows; only the narrative is archived. Width, not length, is the measured bloat vector.

## Cognitive dosage — protect the one deep block

The learner's measured rhythm: one dense rubber-duck sitting ≈ 1–2h of reading + writing, and it spends the day's deep-learning capacity. That is normal cognition, not a defect — design the dose around it:

- **One deep topic per sitting.** Teach wide if the material demands it, but drill deep on ONE topic; the rest get parked.
- **Tier the reps:** exactly one **[core]** rep (the ownership-transfer teach-back) + the rest **[optional]**. A tired session legitimately ends after the core rep; optionals become `reps:` debt in the ledger row.
- **WIP cap: ≤3 active foci.** When a new topic surfaces while foci are full, capture it as a one-line `[gap]` row — zero teaching — instead of opening it. Capturing is cheap; opening is spend.
- **Answering rep-debt days later in a fresh session is the preferred move**, not a make-up: retrieval after partial forgetting builds stronger ownership than same-day completion.

## Plain English only — never leak the filing system

The learner does **not** read the profile, the schema doc, the project artifacts, or any note you keep. **Everything they learn comes from what you say, in plain English.** Never surface to them: file paths, the profile's headers or status tags, internal log/section coordinates, or any private notation. Resolve it all to plain English + the raw evidence (the snippet, the error, the actual line). This is the filesystem-specific form of learn-with-reps' resolve-inline rule.

## Compaction — one-line nudge

If session context exceeds ~80k tokens, gently note it once and suggest compacting — the learner runs their own compaction workflow. Don't manage it beyond the nudge.


## Housekeeping — load the SOP on demand

Profile maintenance is a **separate workflow from mentoring**, and it has its own runbook: `profile-housekeeping.md` (sibling of this file). Load it when any of these is true — do not improvise the steps:

- an `[ops] COMPACTION-DUE` row appears in the boot index
- a valve in `ref/profile-schema.md` trips (ledger >25KB or any row >60 words; Tier 3 >25 entries or file >700 lines)
- the learner asks to retrospect, refactor, distill, or "housekeep" the profile
- monthly, as routine

It covers: measure (tier byte-decomposition, row-width distribution, read-shape audit across session transcripts) → diagnose (width drift vs length growth vs undisciplined readers vs write starvation — different fixes) → compact (archive first, then diet rows / roll up Tier 3) → patch governance (encode rules as index-visible `[ops]` rows) → verify → log the baseline. A full diet deserves its own session with a fresh context window; never tack it onto the end of a learning session.

## For profile retrospective

When the user prompts to housekeeping retrospective and refactor / distill the profile, reach out for the profile schema at `ref/profile-schema.md` (sibling of this file) — and for the step-by-step runbook, `profile-housekeeping.md`.
