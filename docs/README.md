# Documentation

Every page here is written for a maintainer six months from now who opened
exactly this file from a search result and has nothing else loaded.

This index is generated. Run `scripts/gen-docs-index.sh` after adding or
renaming a page; `--check` fails if it is stale.

<!-- BEGIN GENERATED INDEX -- edit the pages, not this block -->

## Where things live

One page per area of the system. Read before going looking for where
something is implemented.

| page | covers | verified |
|---|---|---|
| [The graded rebuild](architecture/rebuild-to-own.md) | how a learner is taught a codebase they did not write, and why git is doing the work | 2026-08-19 |
| [The learner record](architecture/the-learner-record.md) | where the learner's data actually lives, why it is not in this repo, and what a session is allowed to read of it | 2026-08-19 |
| [The portable boundary](architecture/the-portable-boundary.md) | which half of the skill is allowed to touch the filesystem, and what proves it | 2026-08-19 |

## Traps

Failure modes that produce no error message, indexed by the symptom you
would observe. Read before debugging behaviour that is wrong but not
crashing.

| symptom | page | area | verified |
|---|---|---|---|
| The boot digest gets longer every month, its ACTIVE list is full of things nobody is working on, and lowering the work-in-progress cap changes nothing | [BOOT_DIGEST_KEEPS_GROWING_AND_THE_WIP_CAP_DOES_NOTHING](traps/BOOT_DIGEST_KEEPS_GROWING_AND_THE_WIP_CAP_DOES_NOTHING.md) | learner record | 2026-08-19 |
| I ran a documentation cleanup over the learner record and it stripped the status, dates and progress fields as stale | [DOC_ORGANISER_DELETED_STATUS_AND_DATES](traps/DOC_ORGANISER_DELETED_STATUS_AND_DATES.md) | learner record | 2026-08-19 |

## Reference

Simply true, and expensive to re-derive.

| page | summary | verified |
|---|---|---|
| [What ships from this repository, and what never does](reference/what-ships-and-what-does-not.md) | the publication boundary — which paths are templates, which are gitignored instances, and the one glob that is easy to misread | 2026-08-19 |

## Decisions

Why the repo is the way it is. A merged decision is immutable -- supersede
it with a new one rather than editing it.

- [Move CLAUDE.md's contents into AGENTS.md rather than appending a bridge line](adr/0001-move-claude-md-into-agents-md.md)
- [Merge the three skills into one, with a router and on-demand references](adr/0002-merge-the-three-skills-into-one.md)
- [The plugin manifest carries no version, and owns the skills allowlist](adr/0003-the-plugin-manifest-carries-no-version.md)
- [Name the plugin `learn-with-feedback-loop` and its one skill `learn`](adr/0004-name-the-plugin-and-its-one-skill.md)
- [The session-start hook is the import that was rejected, and it stands](adr/0005-the-session-start-hook-is-the-import-that-was-rejected.md)

<!-- END GENERATED INDEX -->
