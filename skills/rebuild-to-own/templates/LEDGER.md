<!-- TEMPLATE. Copy to <syllabus-worktree>/learn/LEDGER.md and fill the <angle brackets>.
     Read by: `rg '^## ' learn/*.md` for the menu, `rg '^#### ' learn/LEDGER.md` for the log index.
     APPEND-ONLY below the bookmark. Never whole-file overwrite - concurrent sessions write here. -->

# LEDGER - <repo name>

## Menu

| section | holds | read when |
|---|---|---|
| Bookmark | where we stopped, what happens next | FIRST thing, every session |
| Branch registry | which branch belongs to which topic, and its worktree | before any git operation |
| Session log | dated entries, newest at the bottom | only when a specific session is cited |

## Bookmark

- **Last touched:** <NN-slug> on <YYYY-MM-DD>
- **State:** <what exists on disk right now - scaffolded? learner mid-build? awaiting grade?>
- **Next action:** <the single next move, specific enough to act on cold>
- **Open rep debt:** <topic: answered/posed, or none>

## Branch registry

| topic | branch | worktree | scaffold commit | status |
|---|---|---|---|---|
| <NN-slug> | `learn/<NN-slug>` | `<tmp/worktrees/NN-slug>` | `<sha>` | <scaffolded/building/graded> |

## Session log

<!-- One `#### ` entry per session, dated + topic-keyed so two concurrent sessions cannot
     collide. Append at the bottom. Every entry ends with the next section a cold agent
     should read. -->

#### <YYYY-MM-DD> - <NN-slug> - <what this sitting did>

- **Mode:** <survey | teach | grade>
- **What happened:** <2-4 lines. What was taught, scaffolded, or graded.>
- **What the learner produced:** <their commit sha + one line on what it got right/wrong>
- **Durable delta:** <what changed in the map, the brief, or the learner profile>
- **Next:** <the section or topic a cold agent should read next>
