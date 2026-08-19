---
symptom: "The boot digest gets longer every month, its ACTIVE list is full of things nobody is working on, and lowering the work-in-progress cap changes nothing"
area: learner record
verified: 2026-08-19
---

# The boot digest keeps growing, and the work-in-progress cap does not bound it

## Symptom

A session opens against a record that has been in use for a while. The digest's
`ACTIVE` section lists far more topics than anyone is actually working on —
threads started once, months ago, and never touched since. The header says
something like `ACTIVE — learning, open reps (36) — cap is 3`, which reads as if
a cap is being enforced somewhere.

Lowering `LEARN_WIP_CAP` does not shorten it. Nothing errors, the digest is
correct, and it simply costs more every month.

## Mechanism

Two independent things, both easy to mistake for the other.

**The active list has no retirement.** The section is a filter over the scan and
nothing else — `skills/learn/bin/boot.sh` selects `status == "learning"` with at
least one open rep, sorted by last touch:

```awk
$2 == "learning" && $9 > 0 { ... }
```

There is no recency predicate and no retired state, so **a thread that was opened
and abandoned stays active forever.** The list therefore grows with the number of
topics ever *begun*, not with the number in flight. `--query active` has the same
definition, so the query agrees with the digest and neither can catch it.

**The cap is a sentence, not a filter.** `WIP_CAP` is read once, and its only
effect is which of two header strings gets printed:

```sh
ACTIVE_HDR="ACTIVE — learning, open reps ($ACTIVE_N)"
if [ "$ACTIVE_N" -gt "$WIP_CAP" ]; then
  ACTIVE_HDR="ACTIVE — learning, open reps ($ACTIVE_N) — cap is $WIP_CAP"
fi
```

That is deliberate — active foci are derived, so there is no list to be full and
nothing to enforce — but the header reads like a bound being applied, which is
what sends people to the cap when the digest gets long.

**Measured against the running script**, on a synthetic record of 200 topics all
left `learning` with an open rep and last touched 953 days ago:

| what | result |
|---|---|
| `ACTIVE` header | `ACTIVE — learning, open reps (200) — cap is 3` |
| rows printed | 200, every one of them stale by more than two years |
| digest size | 11,876 bytes |
| the same digest with `LEARN_WIP_CAP=500` | 11,863 bytes — the 13 bytes of the header suffix, and nothing else |
| `--query active` | `200 of 200 topics` |

Two neighbouring terms behave differently and are worth knowing about when you
are trying to shrink a payload. The hand-written Level 0 page is **constant** at
every record size (~694 tokens), so it is the whole payload on a small record and
trimming topic rows while it is uncut achieves nothing. A complete owned list is
strictly **linear** and admits no cap at all, since completeness is the only thing
it is for. Only a recent-activity window is bounded in practice — bounded by how
much the learner touches, not by how much they have learned, which is why the
session-start card is a window and not a ledger.

## Fix

**Retire the thread in the record, not in the reader.** A topic nobody has
returned to in months is not in flight; the honest edit is to close its open reps
or move it out of `learning`, in a housekeeping pass. `skills/learn/ref/profile-housekeeping.md`
carries the step, beside pruning dead gaps. Ownership is still never granted by a
maintenance pass — retiring an abandoned thread is not the same as deciding it was
learned.

**Do not add a recency filter to the active query.** The digest would get shorter
and the record would go on lying: the thing that is wrong is the record saying a
thread is in flight, and hiding it in the one place anyone looks removes the only
prompt to fix it.

**Do not reach for the cap.** It is a nudge to the reader, and changing it changes
one line of text.

## How to verify

Build a record where every topic is `learning` with an open rep and a `last` date
two years old, run `skills/learn/bin/boot.sh <root>`, and count the rows under
`ACTIVE`. If the count tracks the number of topics rather than the number in
flight, nothing has changed. Run it again with `LEARN_WIP_CAP` set high and diff
the two outputs — a difference of only the header's `— cap is N` suffix is the
whole story.

**The general rule:** a threshold that only changes what is printed will be read
as a threshold that changes what is computed, and someone will spend an afternoon
tuning it. Either enforce it or name it as advice in the output itself.
