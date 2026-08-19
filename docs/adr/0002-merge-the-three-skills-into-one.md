# Merge the three skills into one, with a router and on-demand references

The system shipped as three skills: `learn-with-reps` (the mentoring discipline,
filesystem-blind), `learn-with-reps-gsd` (a sidecar owning every disk operation),
and `rebuild-to-own` (a graded, branch-per-topic track over a repo the learner
never wrote). They are now one skill, `learn-with-reps`, whose `SKILL.md` is a
router over two reference files under `ref/`.

This supersedes the architecture page *The blind half and the sidecar*, replaced
by *The portable boundary*, and it rewrites the filesystem-blindness constraint in
`AGENTS.md` rather than removing it.

## Why the split was built, and why that reason expired

The split existed to protect one property: the discipline had to run unchanged in
an environment with no filesystem at all — a chat window, another vendor's agent,
a sandbox. Every disk-touching rule was therefore exiled to the sidecar, and the
load trigger was inverted so the generic half never named the sidecar, on the
argument that a core naming its shell has stopped being portable.

The property was real. The demand for it was not. In practice the owner uploads
the single markdown file to a hosted-chat profile and then does not use it;
essentially every real session runs on a filesystem with the record loaded. The
split was being paid for continuously to serve a case that does not occur.

## What the split cost

**A load order nothing enforced.** The rebuild skill opened by declaring a
three-step load order "NON-NEGOTIABLE" and then conceding that a session teaching
without the other two loaded is a protocol violation. Nothing detected it. The
architecture page defending the split admitted the same of the split itself —
enforced by convention alone, nothing fails if you break it.

**Rules written three times.** A rule that must hold in every file, in a world
where any file might load alone, has to be restated in each. The plain-English
prohibition existed in all three skills; the first-principles ladder existed in
two, in near-identical prose that had already drifted — the rebuild copy had grown
to five steps including the synergy seam, while the discipline's copy still had
three. The merge kept the fuller ladder and deleted the stale one.

**Three names to invoke, install, and allowlist** for one workflow.

## Considered options

**Keep the three skills and fix only the load order.** Rejected: there is no
mechanism to fix it with. The load order is prose asking an agent to remember,
and the duplication would have remained.

**Merge the record sidecar in, keep the rebuild track separate.** Rejected once
the chat-window case was known to be unused. It preserves two names and one
duplicated rule to protect a boundary nothing was crossing.

**Merge all three.** Taken. The discipline stays whole and always loaded; the two
disk-bound capabilities become reference files the router loads only when their
precondition holds.

## What this does not buy

Not a smaller context. The three skill bodies measured 640 lines and 65,797 bytes,
and a skill body already loads on invocation rather than always — progressive
disclosure was in force at the skill level before the merge. Per-session load
lands within about two kilobytes either way. Anyone reopening this decision
expecting a token saving will not find one; the gains are reliability and the
removal of duplicated rules.

## The cost that had to be paid down

Blindness was a **file** boundary, mechanically provable: no path appeared in a
file that had no business holding one. It is now a **section** boundary, and a
path drifting into `SKILL.md` would break chat portability silently — the exact
failure mode the original constraint was written against.

So the constraint was made precise instead of being dropped. `SKILL.md` may name
its own bundled relative references, which are inert when absent — a session
holding only that file falls through to the discipline, which is complete alone.
It may never contain an absolute path, a home directory, or the record's address.
Three assertions in `bin/smoke.sh` prove it, including that every reference the
router names actually resolves. The rule is enforced now, which it never was
while the split existed.
