---
title: The learner record
covers: where the learner's data actually lives, why it is not in this repo, and what a session is allowed to read of it
verified: 2026-08-19
---

# The learner record

Every mentoring session opens by reading a record of who the learner is. **That
record is not in this repository, and putting it here would be a defect.** What
ships here is `PROFILE.template.md` — a seed, 56 lines, never an instance.

## Why it lives elsewhere

The record spans every project and every learning track the person has. A record
kept inside one codebase would fragment along codebase boundaries, which is
precisely the wrong axis: the learner is the constant, the repositories are not.
It is also the most personal file in the system, so it belongs in a private repo
this public one never sees.

The sidecar resolves it to a **root directory, never a filename** —
`skills/learn-with-reps-gsd/SKILL.md` states this explicitly, because what lives
under that root is the record's own business and no session should assume a shape.

## It is a tree, not a file

The record used to be a single three-tier `PROFILE.md`. It is now:

- a hand-written **Level 0** that a learning session never writes — background,
  anchors, traits, coaching points, the mission
- **one page per topic**, carrying flat frontmatter (`status`, `earned_by`,
  `anchor`, `reps`, `open_reps`, `touches`, `last`, …)
- a **generated index**

The full structure, and the reasoning behind every field, is in
`skills/learn-with-reps-gsd/ref/profile-schema.md` (121 lines). Read that before
any structural write; it is the only place the schema is defined, and it is not
restated here on purpose.

## Two rules the layout enforces

**Never store what can be computed.** Rusty topics, unverified topics, the active
list, progress, distance-from-owned, every housekeeping counter — all derived from
the topic pages on each boot. A stored copy is a second store of truth that can
disagree with the first.

**A learning session never writes Level 0.** That, plus per-topic pages, is what
makes many concurrent sessions conflict-free rather than nearly so: two sessions
touching different topics touch different files, and everything they would both
want to change is derived, so it regenerates instead of merging.

## What a session actually loads

One script call — `<skill dir>/bin/boot.sh <record root>` — which emits Level 0
verbatim plus a fully derived digest, then one or two topic bodies hydrated on
demand. **Never a full read**; the record grows forever and the boot payload must
not.

It ships with the plugin rather than with the record —
`skills/learn-with-reps-gsd/bin/boot.sh` — so everything executable stays inside
the skill, the record stays pure data, and the schema is defined in one place. The
three modes are flags on the same scan:

```sh
boot.sh <record-root>                 the boot digest
boot.sh <record-root> --check         exit 1 if the index is stale
boot.sh <record-root> --query <pred>  filter the same table
```

**The general rule:** state that grows without bound cannot be loaded eagerly, so
the entry point has to be a query rather than a file. Once the entry point is a
query, everything derivable should be derived, because the query is where the
derivation is free.
