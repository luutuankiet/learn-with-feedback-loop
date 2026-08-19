# learn-with-reps

*(formerly `gsd-mentor` — see Lineage below)*

A pair of Claude Code **skills** that mentor you through any technical or programming concept by making you *write* — because writing is thinking, and reading isn't. For self-directed learners who want to genuinely **own** a concept, a codebase, a PR, or a language feature — not just skim it.

> The model already knows the material. What it's missing is *you* — your fluent language, your gaps, your phrasings. These skills supply both halves: a portable mentoring discipline, and an optional memory of who you are.

<img width="1062" height="1232" alt="demo" src="https://github.com/user-attachments/assets/41fca8b3-bff4-4ff0-a65b-0a25a66ede47" />



## The three skills

| Skill | What it is | Needs a filesystem? |
|---|---|---|
| **`learn-with-reps`** | The mentoring discipline. Dense, Socratic, never spoon-feeds. Builds a picture of you on the fly and drills write-to-think reps until you can teach the concept back. | **No** — fully portable. Any Claude Code session, any agent, even pasted into a bare chat. |
| **`learn-with-reps-gsd`** | An optional **sidecar** that adds a persistent learner-profile. Reads who you are at session start (via ripgrep), distills what you learned at the end. Auto-loads alongside the generic skill when a filesystem is reachable. | **Yes** — reads/writes a `PROFILE.md`. |
| **`rebuild-to-own`** | Turns a codebase you own on paper but never wrote into an exercism-style rebuild curriculum: one branch per topic, the agent scrapes each module into a scaffold, you rebuild it, and the shipped implementation in the same repo is the answer key. Runs on both skills above. | **Yes** — git-native; it lives on branches and worktrees. |

The split is deliberate: the discipline is valuable on its own and stays environment-blind, so you can lift it anywhere. All file-I/O and profile specifics live in the sidecar.

## The pitch — why "reps"

Most LLM tutors explain well and leave you nodding. You read, you feel like you understood, you move on — and nothing sticks. The only knowledge that lasts is the kind you produced yourself. So `learn-with-reps` flips the success metric: **a turn succeeds only when it gets you to write** — to articulate your understanding, to attempt the rep it set, to expose the gap it should drill next. Every turn ends with an invitation to write. You succeed when you can explain it to someone else.

It does this with **dense, Socratic** turns: rich context (concept + rationale + the shape + a worked example with the punchline missing + an anchor to what you already know) followed by a substantive question — then it stops and waits. It never leaks the answer. It makes it safe to be wrong, celebrates real wins, and ends each turn with a plain-English recap so you always know where you are.

## Install

```bash
# 1. Clone (or just grab the skills/ folder)
git clone https://github.com/luutuankiet/gsd-mentor.git ~/dev/gsd-mentor
cd ~/dev/gsd-mentor

# 2. Copy the skills into your Claude Code project (or ~/.claude for global use)
mkdir -p ~/dev/myproject/.claude/skills
cp -r skills/learn-with-reps     ~/dev/myproject/.claude/skills/
cp -r skills/learn-with-reps-gsd ~/dev/myproject/.claude/skills/   # optional — only if you want a persistent profile
cp -r skills/rebuild-to-own      ~/dev/myproject/.claude/skills/   # optional — the rebuild-a-codebase curriculum
```

The generic skill works immediately. To use the profile sidecar, one more step:

```bash
# 3. Seed your profile beside the skills you just installed
cp PROFILE.template.md ~/dev/myproject/PROFILE.md
$EDITOR ~/dev/myproject/PROFILE.md     # background, fluent anchors, what you're learning
```

There is no path to configure. The sidecar looks for `PROFILE.md` at the root of whatever
project loaded it — the directory containing the `.claude/skills/` it came from — then falls
back to any location a project or a rebuild track has pinned, and asks you if it finds
neither. **Put that project on a private remote:** the profile is the most personal file in
the system, and it grows for years.

**Tip — symlink instead of copy** if you use these across several projects, so edits to the
skill never drift between copies:

```bash
ln -s ~/dev/gsd-mentor/skills/learn-with-reps     ~/dev/myproject/.claude/skills/learn-with-reps
ln -s ~/dev/gsd-mentor/skills/learn-with-reps-gsd ~/dev/myproject/.claude/skills/learn-with-reps-gsd
ln -s ~/dev/gsd-mentor/skills/rebuild-to-own      ~/dev/myproject/.claude/skills/rebuild-to-own
```

## Usage

Just talk in natural language — no slash commands:

```
"Help me learn closures in JS — here's the page I'm reading: <paste>"
"Walk me through this PR so I can own it before I take over."
"I'm reading the Next.js routing docs, here's where I'm stuck: <paste>"
```

The generic skill starts mentoring. If you installed the sidecar and you're in a filesystem-capable session, it auto-loads, greps your profile so the mentor already knows your level, and persists what you learned when you wrap up. You never read the profile — everything reaches you in plain English, in the conversation.

## Running a session — end to end

Three ways to use the family. The dividing line is **which memory a session loads**, and each has a different kickoff. You never type a slash command — the skills load on meaning — but you do need to know which scenario you're in.

### Scenario A — learn a concept, no repo involved

**Loads:** `learn-with-reps` (+ `learn-with-reps-gsd` if you keep a profile). Nothing is written to any repo; the only durable output is a profile delta.

| turn | you | the agent |
|---|---|---|
| 1 | "Teach me `<concept>`. Ground it first — I want real sources, not vibes." Paste whatever you're reading, if anything. | Boots your profile by ripgrep so it already knows your level and fluent languages. Echoes back a few bullets of what it understood (so you can correct it before it drills), then teaches dense: the problem that existed first → the origin → the shape with its gotchas → a worked example with the punchline missing → an anchor to a language you already know. Ends with reps. |
| 2 | Write your answers. Batch them; take an hour if you want. | Replays each rep and your answer side by side with a per-claim verdict, fills the gaps, then re-asks the teach-back — saying the corrected model back **is** the moment it sticks. |
| 3 | "That's enough for today." | Closing recap: what you own, what's half-owned, what wasn't covered. Writes what landed to your profile. |

### Scenario B — own something in a codebase you didn't write

The most common real case. Often it runs as **two sessions: ship first, then rebuild** — but the entry is anything you can point at: a commit an agent just landed, a module you've never read, or a bare *"how does auth work here?"*

**Session 1 — ship (no learning skills loaded).** Drive the work however you normally do; let the agent build the feature properly and review it. The point is to reach a *correct, idiomatic, reviewed* implementation. That finished code becomes the answer key — so it's worth getting right before you try to reproduce it.

**Session 2 — rebuild.** Fresh session (or compact first). **Loads:** `rebuild-to-own`, which pulls in `learn-with-reps` + `learn-with-reps-gsd` automatically.

| turn | you | the agent |
|---|---|---|
| 1 | *"Build me a syllabus from what we just shipped"* — or *"I want to learn how X works here."* | First checks whether this repo already has a track — two git commands, no re-exploration. Then surveys: a commit range if you pointed at one, or **outward from the module you named** through what it imports and what imports it. Comes back with a **menu of 3–8 topics**, one line each — plus, explicitly, **what it surveyed and chose to leave out**, so you can see the shape of what you're skipping. |
| 2 | Approve the menu, then pick one to start. | Records **every** candidate — the one you picked as a full brief, the rest as one-line queued rows tagged with where they came from, so this menu is never brainstormed again. Then writes the brief (answer key pinned to an exact commit), creates the exercise branch and worktree, scrapes the reference down to signatures + contract comments (+ failing tests where the logic is pure), and commits that scaffold. **You run no git commands.** |
| — | *Good place to compact.* Everything durable is on disk. | |
| 3 | "Teach it." | The full lesson: the problem that existed before this component, its origin, the design pressures that produced *this* shape, how it wires to its neighbours and what breaks downstream if that seam moves, the trade-off that survives — **then** the exercise. Closing line names a worktree that already exists with the stubs in it. |
| 4 | Write the code. Commit it. Compact freely between attempts — your commits are the state. | Idle. **No agent writes code on an exercise branch** — that's the whole point. Stuck learners get taught, never patched. |
| 5 | "Committed — grade it." | Walks a diff ladder (log → stat → hunks → convergence against the reference), never re-reading files the diff already shows. Replays the exercise and your code claim by claim, and classifies every divergence from the reference as *defensible design choice* or *gap* — a divergence you can justify from the design pressures is a pass, not a miss. Where the shipped code has a defect you avoided, it says so. |
| 6 | "Wrap up." | Bumps the topic's status, logs the session, updates your profile. Next session picks up from the bookmark. |

### Scenario C — extend the map, any time

*"What's left to learn here?"* / *"Add the billing module."* / *"I want to own this whole repo."*

Surveying and teaching are separate on purpose. This turn only touches docs: the agent extends the existing menu — never starts a second one — proposes the new rows plus what it's leaving out, and **stops for your approval before creating a single branch.** Nothing is taught, nothing is scaffolded. You pick from the menu whenever you're ready, which might be next week.

Two shapes, your choice of ask:

- **Wayfinder** (the usual): name one thing you want to understand. The agent maps it *plus its neighbours* — a short route, not a curriculum — because one module without the things it talks to teaches an island.
- **Breadth**: a whole tree or a whole sprint, when you genuinely want the full picture up front.

**One repo, one syllabus, forever.** Every session checks whether a track already exists before doing anything else — so the codebase is never re-explored, and a menu you've already seen is read back rather than re-invented. If the map has fallen far behind the code, the agent says so and offers to refresh it, rather than quietly teaching from a stale picture.

### The one rule

**You write the code.** The agent creates branches, scrapes scaffolds, teaches, and grades — it never implements the exercise. A graded diff of code you didn't write measures nothing.

## The profile (sidecar only)

The sidecar keeps a single, forever-growing `PROFILE.md` in a **3-tier schema** designed to stay ripgrep-fast no matter how big it gets:

- **Learner Core** — who you are (background, fluent anchors, how you learn, preferences). Bounded; rewritten in place.
- **Topic Ledger** — one line per concept, status-tagged so `rg '^### \['` returns your whole learning map in one shot:<br/>`### [owned] closures — <one-line model> · anchor:python-X · 2026-06-01`
- **Session Log** — dated entries, rolled up into the archive once they pile up, so the outline never bloats.

The full structure and the reasoning behind it ship with the sidecar at `skills/learn-with-reps-gsd/ref/profile-schema.md`. Read that before reshaping a profile. `PROFILE.template.md` is the seed.

## Customization

- **Profile location** — resolved, not configured: `PROFILE.md` at the root of the project whose `.claude/skills/` loaded the sidecar. To keep it somewhere else, pin the path in that project's instructions or in a rebuild track's `learn/CHARTER.md`; the pin wins over the default.
- **Tone / density** — both `SKILL.md` files are plain markdown. Tune the density, anchors, and register to taste.
- **Generic-only** — don't want a persistent profile? Skip the sidecar. The generic skill builds a fresh picture of you each session and persists nothing.

## Lineage

This repo began as `gsd-mentor`, a single always-on mentor *agent* with a curated wiki. Over several versions it shed everything that wasn't pulling its weight — v0.2 retired concept pages, v0.3 went profile-only and dropped its skills, and **v0.4 retired the agent itself** in favor of the two portable skills above, migrating the profile to the 3-tier schema. The retired agent and the full history live in the git log and `releases/`.

## Acknowledgements

- Andrej Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — the architecture this grew from.
- The "writing = thinking, reading ≠ thinking" philosophy — surfaced through real use, now the central discipline.

## License

MIT
