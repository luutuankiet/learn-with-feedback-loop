---
title: The learner record
covers: where the learner's data actually lives, why it is not in this repo, and what a session is allowed to read of it
verified: 2026-08-19
---

# The learner record

Every mentoring session opens by reading a record of who the learner is. **That
record is not in this repository, and putting it here would be a defect.** What
ships here is `skills/learn/templates/record/` — the empty skeleton
`bin/install.sh` seeds a brand-new record from, never an instance.

## Why it lives elsewhere

The record spans every project and every learning track the person has. A record
kept inside one codebase would fragment along codebase boundaries, which is
precisely the wrong axis: the learner is the constant, the repositories are not.
It is also the most personal file in the system, so it belongs in a private repo
this public one never sees.

The sidecar resolves it to a **root directory, never a filename** —
`skills/learn/ref/record.md` states this explicitly, because what lives
under that root is the record's own business and no session should assume a shape.

## The address is stated, never inferred

The skill arrives through a plugin cache, so its own location differs on every
machine and says nothing about where the record went. Resolution therefore reads
a marked block that `bin/install.sh` writes once per machine into the user-scope
instruction file:

```
<!-- learn-with-feedback-loop:record -->
Learner record: /absolute/path/to/the/record
<!-- /learn-with-feedback-loop:record -->
```

The earlier rule was proximity — the record beside the skills directory that
loaded the sidecar — and it was wrong in a way worth recording. A convention
breaks silently the first time a host cannot honour it, and what it breaks into
is a **second record**, which halves a learning history without anybody noticing.
A stated address cannot fail that way: it is either there, or it is missing and
says so. The conventional path demotes to *the default the installer picks*.

The block holds a plain path and **not an import**. An import would preload the
record into every unrelated session on the machine; the pointer costs about ten
tokens and buys the same thing at boot.

## It is a tree, not a file

The record used to be a single three-tier `PROFILE.md`. It is now:

- a hand-written **Level 0** that a learning session never writes — background,
  anchors, traits, coaching points, the mission
- **one page per topic**, carrying flat frontmatter (`status`, `earned_by`,
  `anchor`, `reps`, `open_reps`, `touches`, `last`, …)
- a **generated index**

The full structure, and the reasoning behind every field, is in
`skills/learn/ref/profile-schema.md` (121 lines). Read that before
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
`skills/learn/bin/boot.sh` — so everything executable stays inside
the skill, the record stays pure data, and the schema is defined in one place. The
modes are flags on the same scan:

```sh
boot.sh <record-root>                 the boot digest
boot.sh <record-root> --check         exit 1 if the index is stale
boot.sh <record-root> --query <pred>  filter the same table
boot.sh <record-root> --card          the session-start name card
```

## The card is a different question, not a smaller digest

The digest answers *where were we*; the card answers *who is this*, for a
**shipping** session that never opened the mentoring skill and cannot afford
the skill body. It carries two terms and nothing else — the marked spans of
Level 0, and the topics touched recently — because those are the only two that
measured bounded. The hand-written page is constant in size at every record
size, so trimming topic rows while it is uncut saves nothing. Everything else
in the digest grows: the active list monotonically, since an abandoned learning
thread never retires, and a complete owned list linearly, with no cap available
because completeness is the whole point of it. A recent-activity window is
bounded by how much the learner touches rather than by how much they have
learned.

Two properties keep it honest. **It states that it is a window**, so absence is
never read as newness — the query mode is there when certainty matters, and
that is what makes a small payload safe rather than merely small. And **it is
read-only**: it fires in repositories that have nothing to do with the record,
where regenerating an index would be a surprise write.

The page subset is delimited by `<!-- BEGIN CARD -->` / `<!-- END CARD -->`
markers rather than found by heading name, because heading-matching fails
silently — rename a heading and the card quietly empties with nothing to
announce it. A missing marker is announced instead. The monthly housekeeping
pass is the only writer of Level 0 and therefore the only maintainer of the
markers.

**The general rule:** state that grows without bound cannot be loaded eagerly, so
the entry point has to be a query rather than a file. Once the entry point is a
query, everything derivable should be derived, because the query is where the
derivation is free.
