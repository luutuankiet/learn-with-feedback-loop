---
name: rebuild-to-own
description: Turn a codebase you own on paper but never wrote into a graded, branch-per-topic rebuild curriculum. The agent scrapes modules into scaffolds on exercise branches; the learner rebuilds them; the agent grades the diff against the shipped reference. Modes - TAILOR (survey the code, produce the menu), TEACH (scaffold one topic and deliver the lesson), GRADE (review the learner's commit). One syllabus per repo, always. Runs on learn-with-reps + its profile sidecar.
user-invocable: true
---

# rebuild-to-own

**Contract.** Point this at a repo the learner approved specs for but never implemented. It turns that repo into an exercism-style track: every topic is a branch, every branch is a rebuild exercise, and the shipped implementation - always one `git show` / `git diff` away in the same object store - is the answer key. Success = the learner's committed code converges on the reference, and they can defend every divergence.

**Where it sits.** A comprehension-mode mentor skill proves the learner can *explain* code. This skill proves they can *produce* it. Both run on the learn-with-reps discipline.

**How it was designed + the end-to-end flows:** `DESIGN.md`, sibling of this file - artifact graph, the three modes as flow diagrams, decisions with their rejected alternatives, the invariants. Read it when changing how the rig works, or when a situation isn't covered here. Do NOT read it to run a normal session; this file is self-sufficient for that.

## Load order (NON-NEGOTIABLE - every mode, every session)

1. **learn-with-reps** - the mentoring discipline (dense turns, first-principles teaching, reps, one-screen grading, momentum rules). This skill never restates it; it invokes it.
2. **learn-with-reps-gsd** - the profile sidecar. Its load trigger is *"learn-with-reps active AND filesystem access"*, which this skill ALWAYS satisfies: it is git-native, so a filesystem is guaranteed. It owns ALL profile read/write mechanics - the ripgrep boot, the tier grammar, the wrap contract, the rollup valves. This skill never re-specifies them.
3. **The learner record** - resolved by the sidecar from the stated marker in the user-scope instruction file, which gives back a **root directory, not a file**. A track's `learn/CHARTER.md` may pin a different one, and that pin wins. No marker (new learner) - the record has not been set up on this machine; point them at the sidecar's `bin/install.sh` and stop. **Never seed one from here.** Read it per the sidecar's discipline, never whole.
4. **Establish the syllabus** (next section) - two git commands, before any survey, menu, or lesson.
5. Then dispatch: TAILOR / TEACH / GRADE.

A session that teaches without 1+2 loaded is a protocol violation - the premise is calibrated mentoring, and calibration lives in those two.

**Conflict resolution (the only two that exist):**
- The sidecar hard-codes ONE profile path as its example. **CHARTER wins** - it names the path for THIS track, and a learner may keep tracks and profile on different hosts.
- The sidecar's cognitive-dosage rules (one deep topic per sitting, WIP cap, tiered reps) govern the *session*; this skill's `sittings:N` on a topic row is a *planning estimate*. When they disagree, the sidecar wins - split the topic across sittings rather than overrun the dose.

**The boundary with learn-with-reps (they do not overlap - they compose):** learn-with-reps owns **how a turn is built** - density, the rep block, the WAIT, the one-screen grade, momentum rules, psychological safety. This skill owns **what is being learned and which artifacts move** - topic selection, branches, scaffolds, the diff ladder, the docs. Where they seem to touch, that line decides. This skill changes exactly ONE thing about the reps discipline: the rep's output is **committed code in a worktree** instead of prose in chat, which makes the graded evidence a diff. Everything else about the teaching turn is learn-with-reps', unmodified.

## One syllabus per codebase - the standing invariant

**Exactly one syllabus per repo, and every session establishes whether it exists before doing anything else.** No session may survey a tree, brainstorm a menu, or start a second track without checking first. Re-exploring a codebase that already carries a map is the most expensive waste this rig can commit.

**The probe - two git commands, zero file reads:**

```
git rev-parse --verify learn/syllabus     # does the track exist?
git worktree list                         # is it already mounted on disk?
```

Only then the doc menus (Docs discipline). Branch missing - say so plainly and offer TAILOR. Branch present but worktree missing - re-mount it (`git worktree add tmp/worktrees/syllabus learn/syllabus`); never create a second track.

**Sync stamp.** MAP.md's `## Menu` block carries one line - `synced-at: <sha> (<date>)` - the commit the map was last built against. On boot, compare against the tip:

```
git rev-list --count <synced-at-sha>..HEAD
```

Materially behind (hundreds of commits, or the learner names work the map has never heard of) - say so in one line and offer a TAILOR pass. Never silently teach from a stale map; never silently refresh one either.

**Menu persistence - derive a candidate once, keep it forever.** When TAILOR proposes candidates, ALL of them are recorded, not just the one picked: the chosen topic gets a full brief, every candidate passed over gets a one-line `[queued]` row tagged with the ref it came from. Re-brainstorming the same menu from unchanged code is a defect, not a fresh start. Menus are READ from the map; they are re-derived only when the sync stamp says the code moved.

**Scope.** One syllabus per **git repo** - the branch lives in that repo's object store. A multi-repo product therefore carries one track per repo, and the learner profile is the cross-repo index that knows they exist.

## Verified git mechanics (the load-bearing facts)

- `git worktree add --orphan -b learn/<slug> tmp/worktrees/<slug>` - a worktree containing only `.git`. Genuinely empty tree.
- From inside an orphan worktree, `git diff <default-branch> -- <path>` and `git show <default-branch>:<file>` both work across unrelated histories (plain diff is tree-vs-tree; no merge-base needed). **The answer key is free.**
- An unborn orphan branch has NO ref until its first commit - nothing to delete on abort (`git branch -D` reports "not found"; expected, not an error).
- An orphan branch has NO `.gitignore` - the scaffold commit MUST author one, or `node_modules` becomes trackable.
- The answer key is a **ref, not a branch name**: `git show <ref>:<file>` and `git diff <ref>` work equally against the default branch, a feature branch, or a bare commit. When a topic rebuilds work that shipped last week, pin the answer key to THAT ref (merge commit or branch tip) in the topic brief - the default branch moves, the ref doesn't.

## Repo layout

- **Docs branch `learn/syllabus`** - holds `learn/` (CHARTER.md, MAP.md, LEDGER.md, topics/). DOCS ONLY, never code. Checked out once as a permanent worktree; all reads and writes go through that worktree path on disk - no cross-branch `git show` gymnastics, no races with exercise branches.
- **Exercise branches `learn/NN-slug`** - CODE ONLY. Orphan (greenfield flavor) or cut from the default branch (excavation flavor).
- **The seed on an exercise branch = the scaffold COMMIT MESSAGE** (topic slug + one-line intent + doc coordinate) **+ contract-comments in the stubs.** Never a doc file - doc files pollute the graded diff and drift from the central copy.
- Worktrees live under a gitignored scratch dir (e.g. `tmp/worktrees/`).
- **The `learn/` docs are stamped out from `templates/`, never improvised.** `templates/{CHARTER,MAP,LEDGER}.md` and `templates/topics/NN-slug.md` sit beside this file; copy them into the syllabus worktree at track creation and fill the `<angle brackets>`. They exist because the boot greps (`^## ` for menus, `^### \[` for topic rows, `synced-at:` for staleness) are a CONTRACT: a doc whose headings were phrased differently does not degrade gracefully, it returns nothing and the session falls back to re-reading whole files or re-walking the tree. Content is per-repo; structure is not. Amending a template is a deliberate change to the rig - propagate it to DESIGN.md, not just to one track.
- **The three docs are the track's entire memory**, and they map onto the same triad a project-memory system uses: **CHARTER** = why this track exists, the ownership definition, learner calibration, locked decisions, environment (the vision/contract) - **MAP** = codebase map, topic index, prereq DAG, sync stamp (the structural reference) - **LEDGER** = bookmark plus the dated session log (the journal). Anything worth re-suggesting later - a menu candidate, an observation about the codebase, a shift in what the learner wants - lives in one of the three or it did not happen.

## Who drives what - the agent runs ALL the git plumbing

The learner's job is to write code. Everything else is the agent's, and the split is not negotiable:

| step | who |
|---|---|
| create the exercise branch + worktree | agent |
| scrape the reference into a scaffold (stubs, contract-comments, failing tests) | agent |
| author the `.gitignore`; commit the scaffold with the seed message | agent |
| teach the topic | agent |
| **write the implementation** | **LEARNER** |
| commit their work | learner (agent may hand them the exact command) |
| read the diff, grade, update docs + profile | agent |

Two consequences:

1. **The scaffold lands BEFORE the lesson, in the same turn.** A lesson ending with "now go create a worktree" has handed the learner busywork and broken the flow. When TEACH opens a topic, it scaffolds first and teaches second, and the closing line names a worktree path that already exists on disk with the stubs in it.
2. **No agent writes code on an exercise branch after the scaffold commit.** That commit is the boundary; everything after it must be the learner's keystrokes or the graded diff measures nothing. A stuck learner gets taught, never patched.

## Teach first principles - the core mandate

The learner is a **builder**: the goal is to re-derive the code, not recall it. A learner who owns the problem can reconstruct the solution; a learner who memorized the solution owns nothing. So every topic is taught in this order, BEFORE any stub is shown:

1. **The problem that existed first.** What broke, what hurt, what people did instead. The world before this component - in the industry generally, and in THIS repo specifically (why was this file created at all?).
2. **The origin / history.** Who built the thing this pattern comes from, what it replaced, what it killed. Framework-level history where the concept is framework-shaped; commit-level history where the answer is in this repo's own log (`git log --follow <file>` is the primary source, and the reference commits are readable evidence).
3. **The design pressures that produced THIS shape.** Why the reference looks the way it does rather than the obvious alternative. Name the alternative explicitly.
4. **The synergy - how it wires to its neighbors.** Never teach a component as an island. Name the seam (what crosses it: a cookie, a header, a prop, a return contract), the direction of dependence, and **what breaks downstream if the seam changes**. The rebuild is only real if the learner knows what their module owes the modules around it.
5. **The trade-off that remains.** What the design gave up - so the learner can judge when NOT to use it.

Only then the exercise. **Proportionality** (per learn-with-reps): the full arc is mandatory for foundational, design-shaped concepts; a surface detail (a config key, a flag) gets a one-line why. Don't pad trivia into epics.

**Where it comes from:** the topic brief's `## Lineage` and `## Synergy` sections carry this material, researched when the brief is written and refreshed at TEACH. Where the true history isn't known, label conjecture - never invent history.

**The rebuild-specific payoff:** a learner who was taught the pressure can produce a *defensible divergence* from the reference. That is the highest-value grading outcome the rig can produce, and it's unreachable if the topic was taught as "here's the API."

## Reading the learner's work - diff-first, grep-second, full-read never

The learner's work arrives as commits. **Diffs are the evidence; the working tree is not.** Walk the ladder in order and stop at the first rung that answers the question:

1. `git log --oneline <scaffold-sha>..HEAD` - the shape of their process. One giant commit vs iterative steps is itself gradeable signal, and it costs one line per commit.
2. `git diff --stat <scaffold-sha>..HEAD` - the map: which files, how much moved. Decides where to look; never read a file that isn't in this list.
3. `git diff <scaffold-sha>..HEAD -- <file>` - the hunks. **This is what they wrote, and it is the primary grading input.** Grade from here.
4. `git diff <default-branch>..HEAD -- <paths>` (from inside their worktree) - convergence with the reference, both directions.
5. **Ambiguity escalation ONLY:** a hunk references a symbol the diff doesn't show - `rg '<symbol>' <their-worktree>` and read only the returned range. State the ambiguity out loud before escalating.
6. **Full-file read is the last resort** and needs a stated reason ("the diff is 90% of the file anyway").

**Never:**
- Re-read the reference implementation to "refresh" it - the topic brief's `## Ground truth` already pasted the answer key verbatim when the brief was written. That is precisely why it exists.
- Read the learner's whole file to "see the context" when the hunk already carries it.
- `git diff` with no pathspec on a big commit when `--stat` would have scoped it.

**Budget:** a normal GRADE costs ~3 git commands and at most one grep. Blowing that budget means the topic brief was under-specified when it was written - fix the brief, not the habit.

## Docs discipline - menu first, grep always

Every `learn/` doc opens with `## Menu`: one row per section - what it holds, when to read it. Boot sequence for ANY mode:

```
rg '^## ' <syllabus-worktree>/learn/*.md       # every doc's section menu
rg '^### \[' <syllabus-worktree>/learn/MAP.md  # topic index with states
```

Then read ONLY the menu-selected sections plus the ONE topic brief this session touches. Reading a `learn/` doc whole is an anti-pattern: the docs serve two consumers - a planning agent answering "why are we learning this / what's the arc" and a session agent synthesizing the next lesson - and both must branch out from the same minimal-token menu.

**MAP.md topic row grammar** (state lives in the header text; the grep IS the read):

```
### [status] NN-slug - one-line intent - branch:learn/NN-slug - prereq:NN,NN - sittings:N - reps:a/p - from:<ref>
```

`from:` is the commit, range, or path the candidate was derived from - carried so a later session knows a row's provenance without re-deriving it. A `[queued]` row may be nothing more than a header line with `from:`; that is the cheapest durable form of a menu candidate, and it is enough.

Lifecycle `[queued] -> [scaffolded] -> [building] -> [graded] -> [owned]`. Grep verbs: `rg '^### \[building\]'` = the bookmark - `rg '^### \[owned\]'` = progress - `rg '^### \[queued\]'` = backlog.

**Write rules (concurrent-session safe):**
1. **Menu-echo invariant:** any section appended to any doc gets its Menu row added/updated *in the same batched edit*. A section without a menu row is lost by definition.
2. LEDGER.md session log is append-only, unique-keyed (date + topic). MAP rows are edited by exact match on the full header line. Never whole-file overwrite.
3. Read the exact row/section just before writing it - another session may have moved it.
4. Long bodies are fine; every long entry ends with one line naming the next section a cold agent should read.
5. GRADE's closing write is ONE batch: MAP status bump + LEDGER entry + menu echoes. The learner-profile wrap-write is its own call on the profile's host, same turn.
6. **Candidate rows are written the turn they are proposed**, in the same batch that records the learner's pick - never deferred to "if they come back to it". A candidate that only ever existed in chat is lost at the next compaction, which is exactly how a menu gets brainstormed twice.
7. TAILOR may rewrite `[queued]` rows freely - reorder, re-scope, drop stale ones. It may NOT erase evidence of work: a row at `[building]` or beyond keeps its status, its branch pointer, and its rep debt through any rewrite. Learning state lives in the profile; branch coordinates live only here.

## Topic brief contract (`learn/topics/NN-slug.md`)

A cold agent must be able to compile a full teaching session from the brief alone - no re-derivation. Ten `## ` sections, menu-indexed:

| section | holds |
|---|---|
| **Why** | place in the arc - the answer to "why am I learning this" |
| **Lineage** | the problem that existed first, the origin/history, the design pressures that produced this shape, the surviving trade-off (see Teach first principles). Conjecture labeled. |
| **Concepts** | high-level vs low-level split |
| **Synergy** | the seams to neighboring modules: what crosses, which direction, what breaks downstream if it changes |
| **Anchor** | bridges to the learner's fluent stack, from the profile |
| **Ground truth** | ANSWER KEY - exact files, line ranges, shipped bugs, evidence PASTED IN verbatim. Never pasted wholesale to the learner. |
| **Exercise spec** | flavor, scrape level, scaffold contents |
| **Acceptance** | the exit rep |
| **Prereqs/unlocks** | DAG edges |
| **State** | status + rep debt |

## Modes

Three modes, and the syllabus probe runs before all of them. TAILOR writes docs and never teaches; TEACH moves code and teaches one thing; GRADE reads a diff.

### TAILOR - survey the code, produce the menu (never teaches)

Called whenever the learner asks what there is to learn, points at a region they want mapped, or opens a repo with no track. TAILOR reads code and writes docs. It never scaffolds an exercise branch and never delivers a lesson.

**Two survey shapes - the learner's ask picks one:**

- **Breadth** - a whole tree, or a commit range ("what did this sprint touch?"). Line counts, teaching-dense vs content-bulk. Build the roadmap from the TREE and the DIFF, never from existing project docs - docs drift behind code.
- **Wayfinder** (the common one) - the learner names ONE thing ("how does auth work here"). Start at that module and walk **outward through its seams**: what it imports, what imports it, what shares its data or its request. Propose a small LOCAL roadmap - the named module plus the adjacent ones that make it make sense. The map grows from a tip outward, never top-down. Each topic carries one concept; the concepts connect into a route the learner can keep walking.

**Steps:**
1. Establish the syllabus (the probe). Exists - load its menu and EXTEND it. Missing - create `learn/syllabus` (orphan, permanent worktree) with CHARTER + MAP + LEDGER.
2. Survey per the shape above.
3. **Propose the menu and STOP for approval - always, even for a one-row extension.** 3-8 candidates, one line each: what it teaches, why it is worth owning, rough size. Include standing `[queued]` rows. **The proposal MUST also name what it leaves out** - the regions surveyed and deliberately not offered, one line each. The learner approves a scope, and a scope is defined by its exclusions; they cannot judge what they are choosing to skip if it was never named.
4. On approval, ONE write batch: the rows (ALL candidates, per Menu persistence), the menu echoes, the sync stamp, a LEDGER entry.
5. Hand off. A topic the learner picks now goes to TEACH; branches are created there, not here.

A cold repo plus a bare "teach me X" is a TAILOR ask, not a TEACH one - route it here first.

### TEACH - open ONE topic, scaffold it, teach it

**Topic selection, in precedence order - first hit wins, no mode-switch required:**
1. An explicit pointer from the learner - a topic name, a path, a commit, a range.
2. The bookmark - the `[building]` row.
3. The first `[queued]` row whose prereqs are all `[graded]`/`[owned]`.
4. Nothing selectable - read the menu out of MAP and offer it. That is a READ, never a re-derivation. Menu empty, or no syllabus at all - route to TAILOR.

A pointer at something **not on the map** does not get taught on the spot - route to TAILOR first. One module in isolation teaches an island; its neighbours are what make it a route.

**Steps:**
1. Read that ONE topic brief. Missing or thin (a fresh row from TAILOR) - write it now to the full ten-section contract.
2. Not yet `[scaffolded]` - scaffold now: scrape per the exercise spec, author `.gitignore` if orphan, commit with the seed message. **Local only unless the learner explicitly authorized pushing this repo's remote** (see Blast radius). This lands BEFORE the lesson, same turn (Who drives what).
3. Compile a full learn-with-reps session: **lineage and synergy first** (Teach first principles), then dense blocks, anchors from the profile, reps that end with the learner WRITING CODE into the exercise worktree and committing it.
4. The turn ends with the learner building. Flip the MAP row to `[building]` (write rules apply).

**Scope pointer vs answer key - decide it, never imply it.** A ref the learner points at sets the **scope**. The answer key **defaults to that same ref**, which is what you want when rebuilding work that just shipped. When the region has moved on since, the key may instead be the current tip - or the two may deliberately differ (rebuild what shipped, then read forward to see how it changed). Pick explicitly, tell the learner in one line which they are rebuilding against, and record BOTH refs in the brief's `## Ground truth`.

### GRADE - review the learner's commit
1. Walk the diff ladder (Reading the learner's work). Two comparisons matter: **theirs vs the scaffold** (what they actually wrote) and **theirs vs the shipped reference** (convergence AND divergence).
2. Grade per learn-with-reps' one-screen replay: recap the exercise, digest their code claim-by-claim with checks, classify each divergence as *defensible design choice* vs *gap*. A divergence the learner can justify from the design pressures taught in Lineage is a PASS, not a miss. Where the reference itself carries a shipped defect the learner avoided - say so explicitly; spotting it is the senior rep.
3. Rep debt - the MAP row's `reps:a/p` tail + LEDGER. Status - `[graded]`, or `[owned]` once they defend their divergences in a teach-back.
4. Closing write batch (write rule 5) + profile wrap-write per the sidecar's wrap contract.

## Scrape levels

- **(a) empty file** - signature-less. Rare: only when API-surface discovery IS the lesson.
- **(b) DEFAULT: signature + contract-as-comments + `throw new Error('not implemented')`.** The learner knows WHAT to build and derives HOW.
- **(c) = (b) + real failing tests** - wherever the logic is pure/testable. Most exercism-like; the tests ship in the scaffold commit.

Greenfield sprints scaffold only a `.gitignore` + the seed commit; the "stub" is the brief's exercise spec.

## Session choreography - three phases, and where to compact

A topic spans three phases. They can share one session, but the phases are what matter:

| phase | who works | agent context cost |
|---|---|---|
| **SCAFFOLD + LESSON** | agent | high - reads the reference, writes the brief, scaffolds, compiles a dense lesson |
| **BUILD** | learner | ~zero - the agent is idle while the learner writes code |
| **GRADE** | agent | low - a diff ladder and a replay |

**Safe compaction points** (the learner drives compaction; the agent only nudges):
- After the brief is written and the branch is scaffolded, BEFORE the lesson - all durable state is on disk, so the teaching turn gets a fresh window.
- After the lesson is delivered - the learner is about to spend an hour writing code, and nothing in the teaching turn needs to survive that isn't already in the brief.
- Freely between build iterations - the learner's commits are the state.

**The wrap is never optional.** However a sitting ends - graded, abandoned, or out of runway - the closing turn writes MAP status + LEDGER entry + the profile wrap-write per the sidecar's contract. A sitting that ends without those has lost the session.

## Plain English to the learner

The `learn/` docs, status tags, and this skill's machinery are the AGENT's filing system. Teaching happens in chat: paste the real evidence (the snippet, the diff hunk, the error), never coordinates ("see the map doc") or status tags. The learner MAY read `learn/` - it lives in their repo - but no lesson may REQUIRE it.

## Anti-patterns

- 🚨 Teaching without learn-with-reps + its profile sidecar loaded - an uncalibrated mentor is the whole failure this family of skills exists to prevent.
- 🚨 **Teaching the API instead of the pressure** - "here's what this does" with no problem-that-existed-first, no origin, no seam. The learner can then only recall, never re-derive - which fails the entire premise of a rebuild.
- 🚨 **Teaching a module as an island** - no synergy section means the learner rebuilds a part that fits nothing.
- 🚨 **Reading files to grade instead of reading diffs** - the diff ladder exists because the working tree is noise; the delta is the evidence.
- 🚨 Re-reading the reference implementation during GRADE - the brief's Ground truth already pasted it.
- 🚨 Doc files on exercise branches - graded-diff pollution + drift. The seed is the commit message.
- 🚨 Whole-file reads of `learn/` docs - the menu + grep verbs exist for this.
- 🚨 Section append without its menu-echo (write rule 1).
- 🚨 Scaffolding beyond the declared scrape level - leaking the answer into the stub robs the rep.
- 🚨 Grading as "all good" - divergences vs the reference must be walked in BOTH directions (their gaps AND the reference's shipped defects).
- 🚨 Orphan scaffold without an authored `.gitignore`.
- 🚨 **Writing to the target repo's default branch, or pushing `learn/*` without explicit per-repo consent** - the target is typically a collaborator repo. See Blast radius.
- 🚨 Building the roadmap from existing project docs instead of the tree.
- 🚨 **Surveying a codebase that already has a syllabus** - the probe is two git commands. Skipping it costs a full re-exploration and risks a second competing track, which breaks the one-per-repo invariant permanently.
- 🚨 **Brainstorming a menu twice** - candidates the learner passed over are `[queued]` rows, not throwaway chat. A menu being re-derived from unchanged code means the last session failed to persist it.
- 🚨 **Teaching from a stale map without saying so** - the sync stamp exists to be compared. Teaching a module the map has never heard of means TAILOR was skipped.
- 🚨 **Teaching a lone module on request** - a pointer at something not on the map routes to TAILOR first. One module without its neighbours is an island.
- 🚨 **Proposing a roadmap without naming what it leaves out** - the learner is approving a scope, and exclusions define it.
- 🚨 **An implied answer key** - a topic whose Ground truth does not name the exact ref it grades against. "The default branch" is not a ref; it moves.
- 🚨 Advancing the bookmark without the learner's commit existing - status moves on evidence, not intention.

## Blast radius - the target repo is usually SOMEONE ELSE'S (🚨 read before creating anything)

The whole point of this skill is that the learner did not write the target codebase - which usually means it is a **shared / collaborator repo**. Treat it as read-mostly:

1. **NEVER commit to the target repo's default branch.** Not the skill, not docs, not config. The skill lives in the AGENT's own skill repo (see Distribution), never inside the codebase under study. The syllabus branch is the ONLY thing the rig adds to the repo, and it is a branch, not a commit on theirs.
2. **NEVER push `learn/*` branches** unless the learner explicitly says the remote is theirs to write to, per repo, in that session. Default is LOCAL-ONLY: orphan branches + worktrees on disk, no remote. Consent given for one repo is not consent for another, and consent to create branches is not consent to touch the default branch.
3. Everything the rig needs works offline - the answer key is `git show <default-branch>:<file>` against the LOCAL object store. Nothing about grading requires a remote.
4. Record the push posture explicitly in CHARTER `## Environment`, so no later session has to guess.

## Distribution

The skill ships in the **learn-with-feedback-loop repo** (`skills/rebuild-to-own/`), alongside the mentoring discipline and its record sidecar - never inside the target codebase. A teammate installs the three skills into their own agent, runs the sidecar's `bin/install.sh` once to put their learner record on the machine, then runs TAILOR against whatever repo they want to own.

**Per-user pointers to active tracks do NOT live beside this file.** The skill arrives replicated - through a plugin cache, a copy, or a symlink - so its location differs on every machine and may be read-only. Anything written next to it is per-host state pretending to be shared state, and the first host that cannot honour the convention loses it silently.

`pilots.md` lives **in the learner's record**, at `<record root>/pilots.md` - the root the sidecar resolves from the stated marker, which is the one place on any machine that is private, writable, and the same across hosts. It is also where the tracks belong on the merits: a rebuild track is learner state, not skill state. `templates/pilots.md` is still its seed; `templates/` also carries the four `learn/` doc skeletons a new track is stamped out from.
