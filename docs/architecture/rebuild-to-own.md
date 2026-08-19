---
title: The graded rebuild
covers: how a learner is taught a codebase they did not write, and why git is doing the work
verified: 2026-08-19
---

# The graded rebuild

`skills/learn-with-reps/ref/rebuild.md` (roughly 300 lines, plus 196 of design in
`ref/rebuild-design.md`) is the largest reference in the repository and the least
like anything else in it. Where the discipline in `SKILL.md` mentors a
conversation, this one runs a **curriculum over a real repository the learner
never wrote**, one topic at a time. It was a separate skill until the merge
recorded in `docs/adr/0002-merge-the-three-skills-into-one.md`; the router in
`SKILL.md` loads it only when the learner wants a rebuild and a git repo is
reachable.

## The core bet: git is the exercise substrate

The design's central claim, argued in `skills/learn-with-reps/ref/rebuild-design.md`, is that a
version-controlled repository already contains everything an exercise generator
would otherwise have to synthesise:

- **the answer key** — the real implementation, at a known commit
- **the blank** — that same code removed, which is a diff, not authored content
- **the grade** — the learner's attempt diffed against what actually shipped

Nothing has to be invented, and nothing can drift out of sync with the codebase,
because the codebase *is* the material. A hand-written exercise about a file
rots the moment the file changes; a diff against `HEAD` cannot.

## What a track is made of

A track is stamped out from `skills/learn-with-reps/templates/track/`:

| template | what it becomes |
|---|---|
| `CHARTER.md` | the track's contract — what repo, what scope, where the learner's record lives |
| `MAP.md` | the codebase as the learner will traverse it |
| `LEDGER.md` | what has been attempted and graded |
| `topics/NN-slug.md` | one topic brief per unit of work |
| `pilots.md` | per-user pointers to active tracks — **gitignored, never shipped** |

Only the templates are in this repository. A stamped-out track lives with the
learner, alongside their record, for the same reason the record does.

## Where to look before changing it

The reference is the largest file in the repository at roughly 29 KB. Its modes and
session choreography are **currently being reconsidered** — the mode structure
described in `ref/rebuild-design.md` is not a settled part of the design, and this
page deliberately does not enumerate it so that it cannot go stale. Read that
decision log first; it records what was chosen and, more usefully, what was
rejected.

**The general rule:** when teaching material about an artifact can be *derived*
from the artifact, derive it. Any exercise you write by hand becomes a second copy
of the thing it teaches, and second copies rot silently.
