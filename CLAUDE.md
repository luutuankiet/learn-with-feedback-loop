# learn-with-reps — Schema (v4 — 2026-06-01)

A personal learning system delivered as two Claude Code skills + one persistent learner profile. The model is the librarian; you drive where learning goes.

**v4 vision:** the mentoring discipline is a portable skill (`learn-with-reps`) usable by any agent in any environment. An optional sidecar (`learn-with-reps-gsd`) persists a forever-growing, multi-track learner profile. The model already knows the material; what persistent storage holds is **who the learner is** — anchors, gaps, phrasings, preferences. Everything else was retired across v0.2–v0.4.

## Layout (public)

```
skills/
  learn-with-reps/SKILL.md                    generic, filesystem-blind mentoring discipline
  learn-with-reps-gsd/SKILL.md                sidecar — profile read/write (ripgrep-in / distill-out)
  learn-with-reps-gsd/ref/profile-schema.md   the locked profile structure + rationale
  learn-with-reps-gsd/profile-housekeeping.md  the maintenance runbook (load on demand)
  rebuild-to-own/SKILL.md                     graded rebuild curriculum over a repo you never wrote
  rebuild-to-own/DESIGN.md                    its rationale, flow diagrams, decision log
  rebuild-to-own/templates/                   the syllabus docs a track is stamped out from
PROFILE.template.md                           seed template (3-tier schema)
README.md                                     install + usage + pitch
```

**Templates only.** This repo publishes structure, never instances. A personal profile, a
`pilots.md`, a filled-in syllabus — all live in the user's own private space and are
gitignored here. Anything committed to this repo must be useful to someone who is not the author.

## Layout (private — gitignored, never published)

```
gsd-lite/      project meta-state (gitignored)
raw/ _archive/ _ref/   personal writing, retired surfaces, reference repos
skills/*/pilots.md     per-user pointers to active rebuild tracks
```

The learner's actual `PROFILE.md` **no longer lives here** — it moved out to the user's own
private repo, found via the sidecar's resolution order (beside the skills directory that
loaded it). This repo keeps only `PROFILE.template.md`.

## Operating rules

- **Onboarding:** one call. The sidecar runs the boot script shipped beside it against the resolved record root; it emits Level 0 verbatim plus a fully derived digest (active / rusty / unverified). Hydrate 1–2 topic bodies on demand. Never full-read.
- **Mentoring:** see `skills/learn-with-reps/SKILL.md`. Core rule — reading ≠ thinking; the learner thinks by writing. Show the shape, never the filled answer; ask, then wait. Probe before building on anything assumed owned; rank what to teach by adjacency to what is genuinely held.
- **Record writes:** inline at wrap, ~300–600 tokens; pull --rebase immediately before the write. Only what the learner wrote about moves off `gap`, and `owned` requires they said it back in their own words. Structure rules in `skills/learn-with-reps-gsd/ref/profile-schema.md`.
- **Privacy:** the learner never reads the record or any note; everything reaches them in plain English. The record, `gsd-lite/`, `raw/`, `_archive/` are gitignored.

## Lineage

Began as `gsd-mentor` (a single always-on agent + curated wiki). Successive versions cut everything that wasn't pulling its weight: v0.2 retired concept pages, v0.3 went profile-only and dropped the skills, **v0.4 retired the agent itself** in favor of the two portable skills above and migrated the profile to the 3-tier schema. That history lived in the predecessor repository and does not travel here; this tree starts from its endpoint.
