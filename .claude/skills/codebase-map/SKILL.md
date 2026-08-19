---
name: codebase-map
description: Where behaviour lives in this repo — a per-area map of which files own what, so you can open the right file instead of searching for it. Use before hunting for where something is specified, before adding a rule that touches existing behaviour, and when a change seems to need edits in more places than expected.
---

# Where things live

This repo is prose, not code, and its files are long enough that finding the right
one costs more than reading it. The pages below are maps: for each area, which
files own it and roughly where in them.

**Pick the area, open that one page, then go straight to the file.** Do not read
every page — that defeats the point.

<!-- BEGIN GENERATED INDEX -- edit the pages, not this block -->

## Where things live

One page per area of the system. Read before going looking for where
something is implemented.

| page | covers | verified |
|---|---|---|
| [rebuild-to-own — the graded rebuild](../../../docs/architecture/rebuild-to-own.md) | how a learner is taught a codebase they did not write, and why git is doing the work | 2026-08-19 |
| [The learner record](../../../docs/architecture/the-learner-record.md) | where the learner's data actually lives, why it is not in this repo, and what a session is allowed to read of it | 2026-08-19 |
| [The blind half and the sidecar](../../../docs/architecture/the-two-halves.md) | which skill is allowed to touch the filesystem, and why the mentoring rules live somewhere else | 2026-08-19 |

<!-- END GENERATED INDEX -->

The same table, browsable, is [docs/README.md](../../../docs/README.md).

## How to read a location

Every entry names a file and the heading or section that owns the behaviour.
**Section names are a starting point, not an address.** They drift with every
commit that reorganises the file above them, and nothing regenerates them.

So: search for roughly that heading, then confirm you are in the right place by
what the prose says, not by where it sat. If a section has moved or been renamed,
fix it in the page and re-date it — that is a one-line edit and it is how the map
stays worth having.

Locations are given at all because the files that matter most here are big:
`skills/rebuild-to-own/SKILL.md` is 282 lines and `skills/learn-with-reps/SKILL.md`
is 216. "It's in the skill file" is not an answer.

## What this map does not tell you

It tells you **where**, not **why it is dangerous**. Some areas below have failure
modes that produce no error at all — this repository has no test runner, so
nothing here fails loudly. Those are catalogued separately, by symptom, in the
`repo-maintenance` skill and in [docs/README.md](../../../docs/README.md).

The single most fragile path is `skills/learn-with-reps/SKILL.md`. It is
**filesystem-blind by design**, and adding any path, filename or storage reference
to it silently destroys the portability the whole two-skill split exists to
protect. Nothing detects that. If you are about to edit it, read
`docs/architecture/the-two-halves.md` first.

## Keeping it accurate

A map that lies is worse than none, because it sends people confidently to the
wrong file. Two habits keep it honest:

- **Re-date what you touch.** If you worked in an area and the page was right,
  bump `verified:`. If it was wrong, fix it and bump.
- **Add an area when you create one, not later.** A new skill with no page is
  invisible; the next person re-derives its shape from scratch.

To add a page, follow the same rules as any other doc — see the `repo-maintenance`
skill. Frontmatter for an area page is `title`, `covers` (what someone would be
looking for, phrased as they would phrase it), and `verified`. Then run
`scripts/gen-docs-index.sh`; the block above is generated and hand edits to it are
overwritten.
