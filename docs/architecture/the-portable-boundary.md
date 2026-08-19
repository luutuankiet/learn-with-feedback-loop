---
title: The portable boundary
covers: which half of the skill is allowed to touch the filesystem, and what proves it
verified: 2026-08-19
---

# The portable boundary

The system is one skill, `skills/learn-with-reps/`. Its `SKILL.md` opens with a
routing block and then carries the entire mentoring discipline. Two capabilities
that need a disk live beside it as reference files, loaded only when their
precondition holds. Knowing which side of that line you are editing is the single
most useful thing to hold before changing anything here.

| file | holds |
|---|---|
| `SKILL.md` | the router, and the entire mentoring discipline: probing, adjacency ranking, first principles, rep shapes, grading, the loop, the anti-patterns |
| `ref/record.md` | the persistent learner record — finding it, booting it, harvesting durable artifacts, the end-of-session write |
| `ref/rebuild.md` | the graded branch-per-topic track over a repo the learner never wrote — branches, scaffolds, the diff ladder |

`SKILL.md` is always loaded and must stay runnable where there is no filesystem at
all — a chat window, another vendor's agent, a sandbox. It may name its own bundled
relative references, because those are inert when absent: a session holding only
that file follows no pointer and falls through to the discipline, which is complete
on its own. It may never contain an absolute path, a home directory, or the
record's address.

## What proves it

Three assertions at the end of `skills/learn-with-reps/bin/smoke.sh`:

- `SKILL.md` names no absolute path and no home directory
- `SKILL.md` does not carry the record's address marker
- every `ref/*.md` the router names actually exists on disk

The third matters as much as the first two. A router pointing at a file that was
renamed or deleted produces a session that teaches without the capability and says
nothing about it — the failure is invisible from inside.

This was three separate skills until they were merged, and blindness was a file
boundary rather than a section boundary. `docs/adr/0002-merge-the-three-skills-into-one.md`
records why that changed and what it cost.

## Which side does a new rule go on?

Adding a rule about **how to teach** goes in `SKILL.md`, even if it was discovered
while running a rebuild. Adding a rule about **where something is stored, what gets
written, or which artifacts move** goes in the reference file that owns it.

Where the two seem to touch, the line is: the discipline owns how a turn is built —
density, the rep block, the wait, the one-screen grade, momentum, psychological
safety. A reference file owns what is being learned and which artifacts move.

## The general rule

When a system has a portable core and environment-specific capabilities, the core
must not depend on any capability being present. That survived the merge: the
dependency still runs one way, and the router's pointers are the only thing the
core says about the capabilities — a name and a precondition, never a location.

The change is that the rule is now checked. While the split existed it was enforced
by convention alone, and nothing failed if you broke it. Do not weaken the
assertions in `bin/smoke.sh` to make an edit pass; the assertion is the only thing
standing between this design and a silent regression.
