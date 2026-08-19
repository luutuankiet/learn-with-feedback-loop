---
title: What ships from this repository, and what never does
summary: the publication boundary — which paths are templates, which are gitignored instances, and the one glob that is easy to misread
verified: 2026-08-19
---

# What ships from this repository, and what never does

This repository is public from its first commit and carries personal-learning
material, so the boundary between *structure* and *instance* is enforced in
`.gitignore` rather than by care. This page is that boundary, written out.

## The rule

**Structure ships. Instances never do.** Anything committed here must be useful to
someone who is not the author. A filled-in learner record, a tailored syllabus, a
pointer file naming someone's machines — none of those qualify, and all of them
have a template counterpart that does.

## What is excluded, and why

| path | why |
|---|---|
| `PROFILE.md`, `PROFILE-*.md` | the learner's actual record — the most personal file in the system. `PROFILE.template.md` is explicitly re-included |
| `skills/*/pilots.md` | per-user pointers to active rebuild tracks: host names and paths |
| `gsd-lite/` | project meta-state |
| `raw/letters/`, `raw/medium/` | personal long-form writing and clipped reading, `.gitkeep` aside |
| `_archive/` | surfaces retired across earlier versions |
| `_ref/` | reference repositories cloned in for study |
| `.claude/agents/gsd-lite.md`, `.claude/commands/gsd/` | scaffolder leftovers from a tool this repo does not ship |
| `tmp/`, `.claude/worktrees/` | scratch and agent worktrees — local working state |

**None of these directories currently exist in a fresh clone.** The ignore rules
are there because they existed in the predecessor tree and will exist again in any
working copy the author uses. Do not delete an ignore rule because its target is
absent.

## The glob that is easy to misread

`skills/*/pilots.md` looks as though it excludes every `pilots.md` under `skills/`.
It does not — a gitignore `*` never matches a `/`, so the pattern matches exactly
one directory level. That is deliberate:

```
skills/rebuild-to-own/pilots.md             ignored   (a real user's pointers)
skills/rebuild-to-own/templates/pilots.md   tracked   (the template that ships)
```

Both files exist in a working tree, have the same name, and have opposite
publication status. Confirm with `git check-ignore -v <path>` before assuming
either way; a one-level-deeper pattern would silently stop shipping the template,
and a one-level-shallower one would publish someone's host list.

## Before writing anything into this repository

The disclosure bar is absolute and there is no private backstop: no credentials,
cloud project ids, account emails, absolute home paths, employer or client names,
internal table names, or host names — in any file, commit message, issue or
comment. Refer to a machine by the role it plays — *the authoring host*, *a second
workstation*, *a remote VM*.
