<!-- TEMPLATE. Copy to <syllabus-worktree>/learn/CHARTER.md and fill the <angle brackets>.
     Read by: `rg '^## ' learn/*.md`. Every `## ` heading below is a menu row - keep the
     headings verbatim, or the boot grep stops finding them. -->

# CHARTER - <repo name> rebuild track

## Menu

| section | holds | read when |
|---|---|---|
| Why this track | the ownership goal in one paragraph | every planning session |
| What owning it means | the exit condition - how we know the track is done | when scoping a topic |
| Learner calibration | fluent anchors, gaps, density preference, cognitive dose | every teaching session |
| Environment | host, repo path, worktree root, how to run the code | before scaffolding anything |
| Push posture | REQUIRED - what may be pushed to this remote, and what may never | before ANY git write |
| Profile location | where the learner profile lives | at wrap time |
| Locked decisions | choices already made, with rejected alternatives | before re-litigating anything |

## Why this track

<One paragraph. What was built, by whom, and what the learner is on the hook for that
they cannot currently produce. Concrete - "I approved the specs for the auth flow and
cannot write a line of it" beats "I want to learn the codebase".>

## What owning it means

<The exit condition, stated as a capability, not a topic count. e.g. "Can scaffold a new
child app end to end - route, auth guard, data fetch, deploy - without reading the
existing ones." This is what the topic menu is derived to serve.>

## Learner calibration

- **Fluent anchors:** <languages / domains to hang analogies on>
- **Known gaps:** <the specific things that are new here>
- **Density:** <meaty multi-topic turns vs tight back-and-forth>
- **Dose:** <topics per sitting - default ONE deep topic, the rest parked>

## Environment

| what | value |
|---|---|
| host | <where the repo lives - local, or an MCP host name> |
| repo path | <path from that host's root> |
| worktree root | <gitignored scratch dir, e.g. `tmp/worktrees/`> |
| default branch | <the branch that holds the finished code - the answer key> |
| run/test command | <how the learner verifies their own work> |
| toolchain notes | <anything non-obvious: node not on PATH, a login shell needed, etc.> |

## Push posture

**REQUIRED FIELD. An agent that cannot read a decision here treats the remote as read-only.**

- **Remote writable?** <NO by default. YES only with explicit per-repo consent from the learner.>
- **Default branch:** never committed to, never pushed to. Non-negotiable in every track.
- **`learn/*` branches:** <local-only | pushable> - <one line of why>

## Profile location

<host + path of the learner profile. Lives OUTSIDE this repo - it spans tracks.>

## Locked decisions

| decision | chosen | rejected, and why |
|---|---|---|
| <e.g. language for the rebuild> | <TypeScript from sprint 1> | <plain JS then port - two migrations to learn instead of one> |
