<!-- TEMPLATE. Copy to <syllabus-worktree>/learn/topics/NN-slug.md and fill the <angle brackets>.
     A cold agent must be able to compile a full teaching session from this file ALONE -
     no re-derivation, no re-reading the codebase. Ten `## ` sections, all required,
     menu-indexed. Keep the headings verbatim: `rg '^## '` is how they are found. -->

# <NN-slug> - <topic title>

## Menu

| section | holds | read when |
|---|---|---|
| Why | place in the arc | planning |
| Lineage | the problem that existed first, and the surviving trade-off | teaching (read FIRST) |
| Concepts | high-level and low-level split | teaching |
| Synergy | the seams to neighbouring modules | teaching + grading |
| Anchor | bridges to what the learner already knows | teaching |
| Ground truth | ANSWER KEY - never pasted to the learner | scaffolding + grading |
| Exercise spec | flavor, scrape level, scaffold contents | scaffolding |
| Acceptance | the exit rep | grading |
| Prereqs / unlocks | DAG edges | planning |
| State | status + rep debt | every session |

## Why

<The answer to "why am I learning this", in terms of the ownership goal in CHARTER.
One short paragraph.>

## Lineage

<The first-principles block, and the reason this template exists. In order:
1. The problem that existed FIRST - what broke, what hurt, what hack preceded this.
2. The origin - who built the answer, when, and what it replaced or killed.
3. The design pressures that produced THIS shape, in THIS codebase.
4. The trade-off that survives - what the design gave up, so the learner can judge
   when NOT to use it.
Label conjecture explicitly: "I think - verify if it matters: ...". Never invent history.
This is taught BEFORE the stub is shown. A learner shown the stub first optimizes for
filling the stub; a learner shown the pressure first can re-derive it.>

## Concepts

**High level** - <the architectural idea; what a designer decides>

**Low level** - <the mechanics; what the code actually does, line by line>

## Synergy

<The seams. For each neighbouring module: what crosses the boundary, in which direction,
and what breaks downstream if this changes. This is what turns a set of exercises into
a roadmap - one topic's edges are the next topic's candidates.>

| neighbour | what crosses | direction | breaks if changed |
|---|---|---|---|

## Ground truth

**ANSWER KEY - never pasted wholesale to the learner.**

- **Reference ref:** `<sha or branch>` - the exact ref the finished code lives on. Name it
  explicitly; "the default branch" is not a ref, it moves.
- **Files:** `<path>:<line range>` per file that implements this topic.
- **Read with:** `git show <ref>:<path>` / `git diff <ref> -- <path>`

<Evidence PASTED IN VERBATIM below - the actual code, the actual error, the actual config.
A cold agent grading this must not have to go find it. Label each block Evidence A / B / C.>

**Shipped gotchas:** <bugs, footguns, or non-obvious constraints that are IN the reference
implementation. The learner will hit these; grading against them is the point.>

## Exercise spec

- **Flavor:** <greenfield (orphan branch, blank slate) | excavation (cut from default, holes punched)>
- **Scrape level:** <what is removed - whole files / function bodies / one module>
- **Scaffold contains:** <signatures, contract-comments, failing tests where the logic is pure>
- **Scaffold commit message:** <the seed - topic slug + one-line intent + doc coordinate.
  This is the ONLY doc that ships on an exercise branch; doc files pollute the graded diff.>

## Acceptance

<The exit rep - the one thing that, done unaided, means this topic is owned. Not a checklist.>

## Prereqs / unlocks

- **Prereqs:** <NN-slug, NN-slug | none>
- **Unlocks:** <NN-slug, NN-slug>

## State

- **Status:** <queued | scaffolded | building | graded | owned>
- **Branch:** `learn/<NN-slug>` @ scaffold `<sha>`
- **Sittings:** <N>
- **Rep debt:** <answered/posed, or none>
