<!-- TEMPLATE. Copy to <record root>/pilots.md - inside the learner's own private record,
     NOT next to the skill - and fill the <angle brackets>. The skill arrives replicated and
     its location differs per host; the record root is the same everywhere and is writable.

     What this file is FOR: the tracks live inside the repos being learned, so nothing in
     this repo knows they exist. This is the index that does - one row per active track,
     plus your own runbook for launching a session. -->

# pilots - active rebuild tracks (personal, untracked)

| repo | host | repo path | syllabus worktree | learner profile |
|---|---|---|---|---|
| <repo name> | <local, or MCP host + call class> | <path from that host's root> | `tmp/worktrees/syllabus` | <host + path> |

<Per-repo warnings go directly under the table, loud. The one that matters most:>

**<repo name> push posture: <LOCAL ONLY | pushable>.** <One line of why - e.g. "collaborator
repo; never push `learn/*`, never commit to its default branch.">

Cold boot for any track:

```
rg '^## '    <syllabus-worktree>/learn/*.md    # doc menus
rg '^### \['  <syllabus-worktree>/learn/MAP.md  # topic index + bookmark
```

<Toolchain quirks per host - anything a session will trip on: a login shell needed for
node, expired credentials, a deploy that must run from a different machine.>

## Runbook - what to type, per mode

| I want to... | I say (fresh session) | loads |
|---|---|---|
| learn a concept, no code | "teach me `<X>`, ground it first" | reps discipline + profile sidecar |
| ship work on a project | normal working prompt | project-memory protocol only - no learning skills |
| get a menu of what to learn here | "what's there to learn in this repo" | learn, which loads the rebuild reference |
| own what a sprint just built | "build me a syllabus from what we just shipped" | learn, which loads the rebuild reference |
| continue an open track | "resume my <repo> rebuild" | learn, which loads the rebuild reference |
| be graded | "committed - grade it" | learn, which loads the rebuild reference |

**Never mix ship mode and learn mode in one session.** Ship mode loads project memory and
writes code; learn mode loads the profile and refuses to write code on an exercise branch.
Compact or start fresh between them.

### The rhythm for one sitting

```
session 1  menu -> pick a topic -> brief written + branch scaffolded
           [COMPACT HERE - everything durable is on disk]
           full lesson + reps delivered
           [COMPACT HERE - the brief holds everything the lesson needed]
session 2  you write code in the worktree, commit
           [compact freely between attempts - commits are the state]
session 3  "grade it" -> diff ladder -> one-screen grading -> teach-back
           "wrap up" -> status bumped, session logged, profile updated
```

The wrap is not optional - a sitting that ends without it is lost. If runway is short, say
"wrap up" early; grading can resume next session from the bookmark.
