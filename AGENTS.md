# learn-with-feedback-loop

A personal learning system, published as the Claude Code plugin
`learn-with-feedback-loop`; its one skill is invoked as
`learn-with-feedback-loop:learn`. The model already
knows the material; what this project stores is **who the learner is** — anchors,
gaps, phrasings, preferences — so a session resumes where the last one stopped.

## Hard constraints

- **Public from the first commit, with no private backstop.** No credentials,
  cloud project ids, account emails, absolute home paths, employer or client
  names, or host names — in any file, commit message, issue or comment. Name a
  machine by its role: *the authoring host*, *a second workstation*.
- **Templates only — structure ships, instances never do.** A filled-in learner
  record, a `pilots.md`, a tailored syllabus live in the user's private space and
  are gitignored here. What is committed must be useful to a stranger.
- **`SKILL.md` is filesystem-blind on purpose.** Everything touching disk lives in
  a reference file under `ref/`, loaded only when its precondition holds. The
  always-loaded half may name its own bundled relative references — inert when
  absent — but never an absolute path, a home directory, or the record's address.
  `bin/smoke.sh` asserts this; do not weaken the assertion to make an edit pass.
- **The learner's record is not in this repository** and never will be. It is a
  tree in the learner's own private repo, reached by a pointer.
- **The learner never reads the record, or any note about them.** Everything
  reaches them in plain English: no file paths, no field names, no status tokens.

## Layout

```
.claude-plugin/plugin.json    the manifest; its skills[] allowlist names paths,
                              and it carries no version key on purpose (adr 0003)
skills/learn/                 the one skill — router + the mentoring discipline
  SKILL.md                    always loaded; names no path, no storage
  ref/record.md               the learner record: boot, harvest, the wrap-write
  ref/rebuild.md              graded rebuild over a repo the learner never wrote
  ref/rebuild-design.md       the rebuild's rationale and decision log
  ref/profile-schema.md       the record's locked structure, and why
  ref/profile-housekeeping.md the maintenance runbook, loaded on demand
  bin/boot.sh                 the record's one-call session opening
  bin/install.sh              one-per-machine setup: clone, seed, state the address
  templates/record/           the skeleton a brand-new record is seeded from
  templates/track/            the syllabus docs a rebuild track is stamped from
scripts/gen-docs-index.sh     regenerates every index here
```

The two reference files under `ref/` were separate skills until they were merged;
`docs/adr/` records why. Add a capability that needs a disk as a new `ref/` page
and a row in the router, never as prose in `SKILL.md`.

No build step and no linter — this is markdown and bash. Two checks exist:

```sh
skills/learn/bin/smoke.sh       # 34 assertions: boot, install, the boundary
scripts/gen-docs-index.sh --check         # non-zero when a docs index is stale
```

Do not add a toolchain beyond those.

<!-- The appendable seam. Everything ABOVE this comment belongs to the project and
     is never touched on a re-run; everything below is the standard block. Append
     it to whatever AGENTS.md already says. Never replace. The literal string
     "Standard block." on the first line is what check 2 of audit.sh looks for. -->

<!-- Standard block. Everything above belongs to this project; everything below is
     the pointer every repo laid out this way carries. -->

## Documentation

Indexed in [docs/README.md](docs/README.md). Every page is self-contained — it
assumes you opened that one file and have nothing else loaded.

| where | what | read it |
|---|---|---|
| [architecture/](docs/architecture/) | where behaviour lives, one page per area | before going looking for something |
| [traps/](docs/traps/) | failure modes with no error message, indexed by symptom | before debugging something wrong but not crashing |
| [reference/](docs/reference/) | simply true, expensive to re-derive | when you need the detail |
| [adr/](docs/adr/) | why the repo is the way it is | before changing something that looks odd |

## Before you wrap up

Leave the repo holding what this session cost you to find out. Four rules.

1. **Sort it, and expect most of it to go nowhere.** A next action is an issue. A
   durable, expensive-to-re-derive fact is a page. A choice that was hard to
   reverse, surprising without context and a real trade-off is a decision record
   under `docs/adr/`. Status, dates, version pins and plans are none of those —
   delete them.
2. **A doc is the last resort.** Type error → test → comment at the site → doc.
   Name the single line you would have commented instead; if you can name it,
   comment it and stop.
3. **Verify against running code before writing, and date the page `verified:`.**
   Anything remembered from earlier in the session is stale until re-read. Deleting
   a draft because the problem is already fixed is a success.
4. **Append, never rewrite.** Supersede a merged decision record with a new one
   naming what it replaces. A trap filename is an identifier quoted elsewhere:
   edit the body, never the name.

Then run `scripts/gen-docs-index.sh`. Never hand-maintain an index.
