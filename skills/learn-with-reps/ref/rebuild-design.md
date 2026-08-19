# Rebuild to own - design notes

Why the skill is shaped the way it is, what the artifacts are, and the three end-to-end flows. `SKILL.md` is the operating manual and is self-sufficient for running a session; **this file is for changing the rig, not running it.**

## Menu

| section | holds | read when |
|---|---|---|
| The problem | the cognitive debt this exists to pay | orienting; pitching it to someone |
| The core bet | git as the exercise substrate | questioning the branch model |
| Artifact graph | every file/branch and who writes it | adding or moving an artifact |
| Flow: TAILOR | surveying and menu-building | first run on a repo, or extending the map |
| Flow: TEACH | scaffolding + teaching one topic | the common path |
| Flow: GRADE | reviewing a commit | grading |
| Decisions | chosen vs rejected, with reasons | before relitigating anything |
| Invariants | what must never break | any change to the rig |
| Skill family | how the three skills compose | wiring or porting |
| Open questions | unresolved | when they bite |

## The problem

Agent-built codebases create a specific debt: the human approved the specs, discussed the architecture, reviewed the PRs - and cannot produce a line of it. Comprehension mentoring ("explain this PR to me") treats the symptom; the person can *narrate* the code and still not be able to *write* it. Reading is not thinking. Only production proves ownership.

The conventional fix - go do a course, do exercism - fails on relevance: generic katas don't build the specific system the person is on the hook for. What's wanted is exercism's format (one topic, one exercise, graded, incremental) pointed at **the actual repo**.

## The core bet: git IS the exercise substrate

Every rebuild curriculum needs three things: a blank slate to build into, a spec of what to build, and an answer key to grade against. A git repo that already contains the finished implementation supplies all three for free:

| need | supplied by |
|---|---|
| blank slate | `git worktree add --orphan` - a working dir containing only `.git` |
| spec | the scaffold commit (contract-comments + failing tests), authored by scraping the reference |
| answer key | `git show <default-branch>:<file>` and `git diff <default-branch>` - work across unrelated histories, no merge-base needed |

This is the load-bearing discovery. Because plain diff is tree-vs-tree, an orphan branch with zero shared history can still be diffed against the shipped code. No copies, no fixtures, no separate answer repo, no network. The whole rig is one repo plus branches.

Second-order consequence: **grading is a diff read, not a code read.** That is what makes the token budget of a GRADE turn bounded and why `SKILL.md` codifies a diff ladder.

## Artifact graph

```mermaid
graph TD
  subgraph agent["Agent's own skill repo - portable, shared"]
    S[SKILL.md<br/>operating manual]
    D[DESIGN.md<br/>this file]
    LWR[learn-with-reps<br/>mentoring discipline]
    GSD[ref/record.md<br/>the learner record]
    T[template/<br/>new-record seed]
  end
  subgraph learner["Learner's own private record - spans all tracks"]
    PROF[AGENTS.md + topics/<br/>who the learner is]
    P[pilots.md<br/>active tracks]
  end
  subgraph target["Target repo - usually SOMEONE ELSE'S"]
    MAIN[default branch<br/>the reference / answer key]
    SYL[branch learn/syllabus<br/>CHARTER + MAP + LEDGER + topics/]
    EX[branches learn/NN-slug<br/>scaffold then learner commits]
  end
  S --> LWR
  S --> GSD
  GSD --> PROF
  T -.seeds.-> PROF
  S -.TAILOR authors.-> SYL
  MAIN -.scraped into.-> EX
  MAIN -.answer key for.-> EX
  SYL -.brief drives.-> EX
  P -.points at.-> SYL
```

**Who writes what:** the agent writes `learn/syllabus` (docs) and the scaffold commits on exercise branches. The learner writes everything else on exercise branches. Nobody writes the default branch, ever.

## Flow: TAILOR - survey and build the menu

```mermaid
flowchart TD
  A["Ask: what is here to learn?<br/>or: a module / a commit range"] --> B{"Syllabus exists?<br/>git rev-parse learn/syllabus"}
  B -->|no| C[Create learn/syllabus orphan<br/>CHARTER + MAP + LEDGER]
  B -->|yes| D[Read its menu<br/>EXTEND - never fork a 2nd track]
  C --> E{Survey shape}
  D --> E
  E -->|wayfinder| F[Seed module, walk the seams:<br/>imports, importers, shared data]
  E -->|breadth| G[Whole tree or commit range<br/>line counts, dense vs bulk]
  F --> H[Propose 3-8 candidates<br/>+ WHAT IS LEFT OUT]
  G --> H
  H --> I[STOP - learner approves the scope]
  I -->|revise| E
  I -->|approved| J["Write ALL candidates:<br/>pick = full brief<br/>rest = queued rows with from:ref"]
  J --> K[Update sync stamp + LEDGER]
```

The roadmap is built from the tree and the diff because **docs drift behind code** - in the pilot repo the written notes were materially stale while the tree was ground truth. The approval gate survives from the original design, but its job changed: branches are no longer created here, so what the learner is approving is **a scope**, which is why the proposal must name its exclusions. Wayfinder is the default shape because a years-old codebase exceeds anyone's appetite - the honest unit is a module plus its neighbours, repeated.

## Flow: TEACH - scaffold and teach one topic

```mermaid
flowchart TD
  A[Load learn-with-reps + sidecar + profile] --> B[Syllabus probe + boot greps]
  B --> C{Topic selection}
  C -->|explicit pointer| D{On the map?}
  C -->|bookmark: building row| E[Read that ONE topic brief]
  C -->|else first queued<br/>with prereqs met| E
  C -->|nothing selectable| T[Read menu from MAP<br/>else route to TAILOR]
  D -->|yes| E
  D -->|no| T
  E --> F{Branch scaffolded?}
  F -->|no| G[Scrape reference to scrape-level<br/>commit seed message]
  F -->|yes| H[Teach LINEAGE first:<br/>problem, origin, pressures,<br/>synergy, trade-off]
  G --> H
  H --> I[Dense learn-with-reps blocks<br/>anchored to profile]
  I --> J[Rep = write code, commit it]
  J --> K[Flip MAP row to building]
```

Selection is a **precedence rule, not a mode**: pointer, then bookmark, then the first unblocked queued row, then the menu. A pointer at something the map has never heard of routes back to TAILOR rather than being taught alone - the neighbours are what turn a module into a route.

Lineage-before-stub is the ordering that makes a rebuild possible: a learner shown the stub first optimizes for filling the stub, a learner shown the pressure first can re-derive the stub. This is also what licenses *defensible divergence* at grading time.

## Flow: GRADE - review the commit

```mermaid
flowchart TD
  A[git log scaffold..HEAD<br/>process shape] --> B[git diff --stat<br/>the map]
  B --> C[git diff per file<br/>THE evidence]
  C --> D[git diff default-branch<br/>convergence + divergence]
  D --> E{Hunk ambiguous?}
  E -->|yes| F[rg the symbol<br/>read returned range only]
  E -->|no| G[One-screen replay:<br/>recap rep, digest claims]
  F --> G
  G --> H{Each divergence}
  H -->|justified from pressures| I[PASS - defensible design choice]
  H -->|unjustified| J[GAP - fill it, re-articulate]
  H -->|reference has the defect| K[Senior rep - name it explicitly]
  I --> L[Batched write:<br/>MAP status + LEDGER + menus]
  J --> L
  K --> L
  L --> M[Profile wrap-write per sidecar]
```

## Decisions - chosen vs rejected

| # | Decision | Rejected alternative | Why |
|---|---|---|---|
| 1 | Standalone skill with a mandatory load-order block | Sub-operation inside learn-with-reps | learn-with-reps is deliberately filesystem-blind and portable; embedding a git-native rig would break that. The dependency is declared, not merged. |
| 2 | All docs on one `learn/syllabus` branch | Per-branch embedded doc files | Doc files on exercise branches pollute the graded diff and drift from the central copy. The per-branch seed became the commit message instead. |
| 3 | Seed = scaffold commit message + contract-comments | A `README` in the scaffold | Same pollution argument; a commit message is metadata, not tree content, so it never shows up in a diff. |
| 4 | Status lives in the MAP header text | A separate status field or index file | Makes `rg '^### \['` equivalent to reading the whole map. Same trick the learner profile uses; proven at scale there. |
| 5 | Menu table at the top of every doc | Read the doc, decide as you go | Two consumers (planning agent, session agent) need different slices; the menu is the shared minimal-token entry point. |
| 6 | Grading via diff ladder | Read the learner's files | Bounded cost, and the delta IS the artifact under review. Full reads are the escape hatch, not the default. |
| 7 | Local-only by default | Push branches for backup | The target is usually a collaborator repo. Learned the hard way on the pilot: an initial push had to be rolled back. Consent is per repo, per session. |
| 8 | Rebuild in the reference's language | Rebuild in the language being learned | A different language forfeits the free `git diff` answer key on every sprint. Language migration becomes its own late topic instead. |
| 9 | Skill lives in the agent's skill repo | Skill lives in the target repo | The target isn't ours to write to, and the rig must be reusable across many targets. |
| 10 | TAILOR and TEACH are separate modes | One mode that surveys then teaches | Surveying is cheap and doc-only; teaching is expensive and creates branches. Fusing them makes every "what's here?" question cost a scaffold, and every lesson risk an unapproved survey. |
| 11 | Topic selection is a precedence rule | Separate resume-the-bookmark and open-a-new-topic modes | Once a pointer can be any ref, path, or topic name, the two differ only in how the topic got chosen. That is an argument, not a mode - and the learner should never have to pick a door. |
| 12 | One syllabus per repo, probed before anything else | A syllabus per entry point, or per sprint | Multiple maps mean the codebase is re-explored and menus re-brainstormed forever. Two git commands prevent it permanently. |
| 13 | Every candidate is persisted, not just the chosen one | Write the brief for the pick, discard the rest | The menu is the expensive artifact - it costs a full survey to produce. Discarding what the learner passed over guarantees re-deriving it later from the same unchanged code. |
| 14 | Wayfinder is the default survey shape | Full-tree roadmap up front | The measured behaviour is a couple of modules and then appetite runs out. Growing outward from a tip keeps every survey proportional to intent; breadth stays available on request. |
| 15 | TAILOR may overwrite queued rows freely | Preserve all map history | Learning state lives in the profile; the map only needs current coordinates. Rows at `[building]` or beyond are exempt - that is evidence of work, not a plan. |

## Invariants

1. **The default branch is read-only.** No commits, no pushes, no exceptions.
2. **`learn/*` branches are never pushed without explicit per-repo consent**, and never merged into anything. They are practice history.
3. **Exercise branches carry code only; the syllabus branch carries docs only.** Crossing this is what corrupts graded diffs.
4. **Every doc section has a menu row**, written in the same edit as the section.
5. **Status advances on evidence** (a commit exists, a teach-back happened), never on intention.
6. **The answer key is never pasted wholesale to the learner** - it is agent-facing context that licenses precise grading.
7. **The rig works fully offline.** Any dependency on a remote is a design bug.
8. **One syllabus per repo**, established by the probe before any survey, menu, or lesson.
9. **A candidate surfaced once is recorded forever.** Menus are read from the map; they are re-derived only when the sync stamp says the code moved.
10. **The answer key is a named ref**, recorded in the brief. "The default branch" is not a ref - it moves.

## Skill family

```mermaid
graph LR
  LWR[learn-with-reps<br/>discipline - portable, fs-blind]
  GSD[ref/record.md<br/>record I/O]
  GRILL[comprehension mentor<br/>can you EXPLAIN it]
  RTO[ref/rebuild.md<br/>can you PRODUCE it]
  LWR --> GSD
  LWR --> GRILL
  LWR --> RTO
  GSD --> RTO
  GRILL -.same learner,<br/>earlier stage.-> RTO
```

The division of labor: **learn-with-reps** owns how to teach, **the sidecar** owns learner memory, **this skill** owns the curriculum-from-a-codebase machinery. Any rule that would apply to teaching in general belongs upstream in learn-with-reps, not here - if a change to this file would improve every mentoring session, it is in the wrong file.

## Open questions

- **Excavation flavor is under-exercised.** Cutting a branch from the default branch and deleting a module (rather than starting orphan) is specified but unproven; the pilot is greenfield-first.
- **Multi-learner tracks.** The doc write rules are concurrency-safe for multiple agent sessions, but the MAP assumes one learner's progress. A shared track would need per-learner state.
- **Scrape automation.** Scaffold generation is currently agent-judgment per topic. Whether a mechanical scraper (strip bodies, keep signatures, insert throws) is better than judgment is untested.
- **Decay.** A topic marked owned months ago is not re-verified. The profile has a rusty status for this; the MAP does not yet.
- **Stale threshold is a judgment call.** "Materially behind" on the sync stamp has no number attached. Commit count is a weak proxy - a hundred commits in untouched regions matter less than three in a mapped one. Path-scoped comparison against mapped regions would be sharper, and is unbuilt.
