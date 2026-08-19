# Move CLAUDE.md's contents into AGENTS.md rather than appending a bridge line

`CLAUDE.md` carried the whole project schema — layout, operating rules, lineage —
and was the only navigational surface in the repository. Converting to the
`AGENTS.md` convention normally means leaving an existing `CLAUDE.md` untouched and
adding `@AGENTS.md` as its first line, because that prose belongs to whoever wrote
it. Here the two files would then have said the same thing twice, and both are
loaded on every request of every session, so the duplication would have been paid
for continuously. The contents were moved instead, and `CLAUDE.md` reduced to the
eleven-byte bridge.

## Considered options

**Append `@AGENTS.md` and leave `CLAUDE.md` as it was.** The safe default, and the
one the conversion route prescribes for a brownfield repository. Rejected because
it would have taken always-resident cost from 3,678 bytes to roughly 8,000 for no
new information — the same facts, in two files, free to drift apart.

**Keep `CLAUDE.md` and write no `AGENTS.md` at all.** Rejected because `AGENTS.md`
is read by tools other than Claude Code, and this repository is published for
readers who are not its author.

## Consequences

The operating-rules section did not survive the move. Those rules restated what
`skills/learn-with-reps/SKILL.md` and `skills/learn-with-reps-gsd/SKILL.md`
already say, and a resident summary of a skill file is a second store of truth
that nothing keeps in step — this session found it had already drifted. The skills
are now the only statement of the mentoring discipline, and `AGENTS.md` points at
them rather than paraphrasing them.

`AGENTS.md` is 4,277 bytes, slightly over the 4 KB ceiling this format aims at.
The overage is the hard-constraints section, which is the part a cold agent most
needs before it writes anything, so it was kept.
