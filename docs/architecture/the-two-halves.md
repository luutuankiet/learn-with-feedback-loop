---
title: The blind half and the sidecar
covers: which skill is allowed to touch the filesystem, and why the mentoring rules live somewhere else
verified: 2026-08-19
---

# The blind half and the sidecar

The mentoring system is deliberately split across two skills that could easily
have been one file. Knowing which half you are editing is the single most
load-bearing fact about this repository, because the split is enforced by
convention alone — nothing fails if you break it.

## Where each half lives

| file | what it owns |
|---|---|
| `skills/learn-with-reps/SKILL.md` (216 lines) | the entire mentoring discipline: probing, adjacency ranking, rep shapes, grading, the loop, the anti-patterns |
| `skills/learn-with-reps-gsd/SKILL.md` (132 lines) | everything that touches a disk: finding the record, booting it, harvesting artifacts, the end-of-session write |

`learn-with-reps` contains **no path, no filename, and no reference to storage of
any kind.** That is not an oversight to tidy up. It is the property the split
exists to protect: the discipline has to run unchanged in an environment with no
filesystem at all — a chat window, another vendor's agent, a sandbox.

## The load trigger points the other way

The natural design would have `learn-with-reps` say "if you can reach a disk, also
load the sidecar". It does not, and must not. The trigger lives in the sidecar
instead — `skills/learn-with-reps-gsd/SKILL.md`, near the top:

> **Load trigger (lives HERE, never in learn-with-reps):** when `learn-with-reps`
> is active AND this session has filesystem access, load this skill and boot the
> record before drilling.

The inversion is the whole trick. If the generic skill knew the sidecar's name, it
would carry knowledge of a storage layer, and it would stop being portable —
quietly, with nothing to observe. Putting the awareness in the half that already
depends on a filesystem costs nothing and keeps the other half genuinely blind.

## What this means when you edit

Adding a rule about *how to teach* goes in `learn-with-reps`, even if it is only
ever useful when a record exists. Adding a rule about *what to persist* goes in
the sidecar, even if it reads like teaching advice. When a rule seems to need
both, it almost always splits into two — the discipline in one, the storage
consequence in the other. That is how probing landed: the rule to probe before
building on an assumed-owned topic sits in `learn-with-reps`, while the
`RUSTY`/`UNVERIFIED` lists that tell a session *which* topics to probe are emitted
by the sidecar's boot.

**The general rule:** when a system has a portable core and an environment-specific
shell, the dependency arrow points from the shell to the core and never back. Any
edit that makes the core name the shell has removed the reason the two were ever
separate files.
