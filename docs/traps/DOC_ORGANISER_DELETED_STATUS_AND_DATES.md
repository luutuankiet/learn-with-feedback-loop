---
symptom: "I ran a documentation cleanup over the learner record and it stripped the status, dates and progress fields as stale"
area: learner record
verified: 2026-08-19
---

# A documentation organiser deleted the learner record's status fields

## Symptom

A general-purpose docs organiser, tidy-up pass, or "remove stale content" sweep is
run over the learner's record tree. It comes back having removed `status:`,
`last:`, `touches:`, `reps:` and anything that reads like sprint state or a
progress marker. The tree still parses. The next boot produces a digest that is
confidently wrong, and no error is raised at any point.

## Mechanism

Every serious documentation-sorting discipline — including the one that produced
the `docs/` tree you are reading — carries a rule that says roughly: *status,
dates, version pins and plans are not documentation; delete them.*

That rule is correct for a codebase, where status is a snapshot of something that
has since moved on. It is exactly inverted here, because **the learner record
is status.** A topic page's entire value is that it says this person got to
`learning` on this date, said it back in their own words or did not, and has two
unanswered reps outstanding. Strip the fields and the remaining prose is a topic
list anyone could have written.

`skills/learn-with-reps/ref/record.md` states the prohibition directly:

> **No general-purpose documentation organiser is ever run over this tree**, and
> there is nothing to fork from one.

## Fix

There is nothing to repair after the fact — the deleted fields were the only
record of when and how each topic was earned, and no other copy exists. The damage
is a silent downgrade of the learner's history, not a corruption you can detect.

So the fix is procedural, and it is the only one available:

- Run `skills/learn-with-reps/ref/profile-housekeeping.md` and nothing else. It is
  a schema-aware runbook for exactly this tree: prune dead topics, merge
  duplicates, repair broken anchor edges, regenerate the index.
- Give a housekeeping pass its **own session with a fresh context window**. Never
  tack it onto the end of a mentoring session.
- Note that ownership is never granted by a maintenance pass. A topic moves to
  `owned` because the learner explained it in a session, and housekeeping has no
  authority to decide it did.

## How to verify

Before any bulk edit to the record, confirm the pass you are about to run knows
the frontmatter schema in
`skills/learn-with-reps/ref/profile-schema.md`. If it does not — if it infers
structure rather than being told it — it is the wrong tool. After the pass, the
boot's derived digest should still distinguish `ACTIVE`, `RUSTY` and `UNVERIFIED`;
if every topic has collapsed into one bucket, fields were removed.

**The general rule:** a rule about what is stale is a rule about a specific domain,
not a universal one. Before running any organiser over a tree, ask what that tree's
data *is* — where the payload is genuinely the metadata, a sort discipline tuned
for prose will delete the whole thing and report success.
