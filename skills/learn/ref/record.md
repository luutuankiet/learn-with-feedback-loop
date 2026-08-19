# The learner record

Reference for `learn`, loaded per its routing block: **only when this
session can reach a filesystem and the user-scope instruction file carries a
record address.** Everything that touches a disk on the learner's behalf is
specified here and nowhere else.

If either precondition fails, this file is simply not loaded, and the mentoring
discipline runs without a record. Never mention to the learner a record you
could not read.

## The record

A single, global learner record shared across every project and every learning track. It lives **outside** any one codebase — it spans them — and it is a **tree**, not a file: one page per topic, a generated index, and a hand-written Level 0 that a learning session never writes.

**Resolution returns a root directory, never a filename.** What lives under that root belongs to the record's own layout; this skill hands over a root and asks no further questions about the shape inside it.

**Finding it — the address is stated, never inferred.** Resolve it once at session start and use that root for the rest of the session.

The user-scope instruction file this session already loaded carries a marked block, written once per machine by the install script:

```
<!-- learn-with-feedback-loop:record -->
Learner record: /absolute/path/to/the/record
<!-- /learn-with-feedback-loop:record -->
```

That path is the record root. It is a plain path and **not an import** — the record is the most personal thing the learner has, and it is not pulled into every unrelated session.

**Never infer the address from where this skill happens to sit.** The skill arrives through a plugin cache, so its own location differs on every machine and says nothing about where the record went. Proximity was the old rule and it was wrong: a convention breaks silently the first time a host cannot honour it, and the thing it breaks into is a **second record** — the failure that halves a learning history without anybody noticing. A stated address cannot fail that way. It is either there, or it is missing and says so.

**No marker means _this machine_ was never set up — not that no record exists.** That is state A below, and the distinction is the whole of it: the learner may well already have a record from another workstation, and the setup they need is to clone that one, not to start a rival. Ask before pointing them anywhere; do not go looking for a record yourself, and never create one.

**A pin beats the marker where one exists.** A rebuild track's `learn/CHARTER.md` may name the record for that track. An explicit pointer from the caller wins over the machine-wide one.

**Never guess a path and never create a second record.** Two records is the failure that silently splits a learner's history in half.

- **Structure + rationale:** documented in `ref/profile-schema.md`, sibling of this file. **Read that doc before any non-trivial structural write** — it defines the stored frontmatter, what is derived and must never be stored, the status lifecycle, and how ownership is earned. Don't improvise structure.

## Boot — one call, then hydrate on demand

Never full-read the record; it grows forever. The whole session opening is **one script call**, and the script ships with this skill rather than with the record — the harness gives you the absolute path of the skill it loaded, so run `<skill dir>/bin/boot.sh <record root>`. Everything executable stays inside the plugin, the record stays pure data, and the schema is defined in exactly one place.

That call is the **pseudo-preload**. The harness will never load the record's own instruction file, because the record is never the repo this session was spawned in — so the script emits what a preload would have.

What comes back, in one output:

1. **Level 0, verbatim** — who the learner is: background, fluent anchors, learning traits, coaching points, mentoring preferences, momentum triggers, and the mission. **A learning session never writes this file.** That is what makes many concurrent sessions conflict-free rather than nearly.
2. **The filtered digest, entirely derived** — `ACTIVE` (learning, with open reps, counted against the cap), `RUSTY` (owned and untouched past the threshold), `UNVERIFIED` (never explained aloud), a total-topic count, and one housekeeping line. Nobody maintains any of it; it is computed from every page's frontmatter on each run, which is why it can never disagree with the record.

Then **hydrate one or two topic bodies by name**, on demand, and nothing else. The total-topic line is what keeps the boot bounded a year in: the ledger grows forever, the payload does not.

**`RUSTY` and `UNVERIFIED` are instructions, not decoration.** Both list topics you must not build on until you have probed them — see *Probe before you build* in `SKILL.md`. A topic reading unverified has never been said back in the learner's own words, however recent its date looks.

**`ACTIVE` is where a session resumes by default**, and a hydrated page's open reps are the resume point. Rep debt answered days later in a fresh session is the **preferred** outcome, not a make-up.

**Sibling modes** — same script, same scan, no second store:

| invocation | what it does |
|---|---|
| `boot.sh <root>` | the digest above; regenerates the index if it has gone stale |
| `boot.sh <root> --query <predicate>` | a filter over the same table — terms ANDed, e.g. `'owned & last>60d'`, or `all` for the full ledger |
| `boot.sh <root> --check` | exits non-zero when the generated index is stale, and writes nothing |
| `boot.sh <root> --card` | the session-start name card — see below. Read-only, and never regenerates the index |

Predicate terms: `all` · `gap` / `learning` / `owned` · `rusty` · `unverified` · `active` · `broken-anchor` · `track=<slug>` · `anchor=<slug>` · `earned_by=<value>` · `last>Nd` / `last<Nd`.

`broken-anchor` is the only term judged against the whole record rather than the row: it selects pages whose `anchor` names a page that does not exist. It is the drill-down behind the boot's broken-anchor count.

### The name card — who, for a session that never asked

A mentoring session can afford the boot above. A **shipping** session cannot: it
never opened this skill, and everything here costs it tokens it came for
something else with. The card is the small payload that still tells an agent who
it is working with — the marked spans of Level 0, plus the topics touched
recently, and nothing else.

Two terms, chosen by measurement rather than taste. The hand-written page is
constant in size at every record size, so trimming topic rows while it is uncut
saves nothing; an anchors-plus-mission subset of it is a fraction of the whole.
And nothing else in the digest is bounded — the active list grows monotonically
because an abandoned learning thread never retires, and a complete owned list is
linear in record size with no cap available, since completeness is all it is
for. A **recent-activity window** is the one term bounded in practice: bounded
by how much the learner touches, not by how much they have learned.

**The card is a window, and it says so.** Never conclude a topic is new because
it is absent from a card — it may simply be older than the window, or below the
row cap. When certainty matters, the query mode is one call away. That is what
makes the small payload safe rather than merely small.

**The page subset is delimited by markers in the page, never found by heading
name.** Heading-matching fails silently: rename a heading and the card quietly
empties, everything keeps working, and the guidance just gets worse with nothing
to announce it. A missing marker is announced instead. Housekeeping is the only
writer of Level 0, so it is also the only maintainer of those markers —
`profile-housekeeping.md` carries the step.

**Setup is a sibling script, run once per machine.** `<skill dir>/bin/install.sh <private-git-url> [path]` clones the record, seeds it from `template/` if the remote is empty, writes the marker, and boots once to prove it reads. `install.sh --where` prints the recorded path without changing anything, which is how you check whether this machine is set up. **The URL is always an argument** — this script ships publicly, so a private remote inside it would ship with it.

**Exit codes carry the failure state.** `3` means the root does not exist — that is state B in the table below, and the answer is to stop and offer the re-clone, never to seed a replacement. `2` is a usage error. The script never creates a record.

## Harvest — durable artifacts only, and say what you had

A learning session opens by looking at what the learner actually shipped since the last one. It reads **durable artifacts only** — commits, diffs, pull-request bodies, and the shipping repository's own documentation. **Never a session transcript.** Those are deliberately discarded, and that is a feature: re-deriving a cold decision is a rep, where re-reading a transcript is consumption.

**Zero learning-specific residue in shared repositories.** No trailer, no note, no marker, no file — nothing about learning is ever written into a repository the learner ships in. That is what removes any need for team buy-in, and it is not traded away for convenience.

**The documentation is an input you consume, never one you mandate.** It is ordinary engineering practice with independent value, maintained during shipping sessions for shipping reasons, by whatever the shipping side uses. You are a consumer, and consumers do not get to dictate their inputs. So:

- **Docs present** → harvest reads them alongside commits and diffs. Best case, and what the adjacency ranking assumes.
- **Docs absent or stale** → fall back to commits and diffs alone, **and say so in one line.** Fewer candidates surface, and they surface without the *why*, so expect to re-derive more.

That one line is the whole mechanism. It makes the dependency visible at the moment it bites, instead of silently producing a thinner menu that looks exactly like a rich one.

**No nudging.** Never tell the learner to go maintain their repository's documentation. That is a different hat in a different session, and a learning session that starts issuing homework about shipping practice has stopped being a learning session.

Rank whatever the harvest surfaces by **adjacency to what the learner genuinely holds** — the zone-of-proximal-development ordering in `SKILL.md`, walked along the record's anchor edges.

## Write discipline — record engagement, never exposure

The end-of-session write is itself a distillation: a verbose session becomes a few durable deltas. Inline, ~300–600 tokens, no ceremony. The whole wrap is one turn — **pull, write, regenerate the index, commit** — and none of its mechanics reach the learner.

**Pull immediately before the write, never at boot.** `git pull --rebase`, always; `git merge`, never — the history stays linear on a single branch. With many concurrent sessions the hazard is not simultaneous writes, it is a **stale base**: a session that read at boot and writes an hour later. Pulling at wrap collapses that exposure window from a whole session to seconds.

**When the record can't be reached, there are three states, and they need different answers.** Read which one you are in before deciding anything:

| state | condition | behaviour |
|---|---|---|
| **A** | no marked block in the user-scope file | This machine is not set up. **Ask the one question below before anything else**, then direct the learner to `<skill dir>/bin/install.sh <private-git-url>` with the answer's URL. It clones their private record, seeds it from the template beside it only if the remote is empty, and writes the marker. **Seeding is legal only there** — never inside a live session. |
| **B** | marker present, the directory it names is gone | **Stop, and offer the repair in the same breath.** No write, no degraded teaching. |
| **C** | directory present, remote unreachable | **Proceed normally.** Write to the local clone, commit, skip the push, and say in one line that it did not sync. |

**State A asks one plain question first: _have you already created a private repository for this?_** Yes and no lead to different setups, and only the learner knows which they are in.

- **No** — first workstation. They create an empty private repository, and the script seeds it.
- **Yes** — another workstation. They paste the **same clone URL** they used the first time, and the script adopts what is already there.

**Uncertainty resolves to yes.** A wrong *yes* costs a failed clone and one more question. A wrong *no* costs a second record — a learning history permanently halved, with nothing downstream able to notice for months. Never break the tie yourself, and never pick the URL for them: listing their private repositories to help them *find* the one to paste is fine, choosing one is not, because choosing wrong fails in exactly the way nothing detects.

**State C is benign.** Offline is common and nothing about it is dangerous: the clone is the working cache, the commit is real, and the next session's `git pull --rebase` reconciles it. Per-topic pages mean there is nothing to conflict on, and an unpushed commit is not a lost one. The one honest requirement is **the one-line notice** — an unpushed record nobody mentioned is a surprise on the next host.

**State B stops rather than degrades**, because it is the only state where writing would manufacture a **second record** — the failure that silently halves a learning history. And you stop rather than teach-without-saving because the fix is one command: re-clone from the private URL to the path the pointer names. Degraded teaching is the worse offer precisely because the good version is thirty seconds away. So it is a refusal *and* a repair, in one breath, in plain English:

> Your record isn't where your setup points. Re-clone it and we'll pick up exactly where you left off.

**One exception, learner-initiated only.** If they explicitly say *teach anyway, I know nothing will be saved*, oblige. You never choose that yourself — the same rule as scrap: obey the state, never infer it.

### What earns a write

- **A session where the learner engaged must write.** Silent no-write is the measured leak — one write in nine sessions before it was made explicit. The only session that legitimately writes nothing is one the learner scrapped.
- **Only what the learner wrote about moves off `gap`.** A topic that was mentioned, offered on a menu, or explained at them was **not engaged** — mentioning is not engagement, and no page is created for it. It resurfaces the next time they ship something that touches it.
- **`owned` requires that they said it back** in their own words. Anything less is recorded as asserted, with no model line, however well the session went. A status records *how* it was earned, so a topic skipped for time can never be misread as knowledge — dates alone never catch that. False ownership is the record lying; decay is merely the record being honest.
- **A successful probe does not re-earn what was earned.** A rusty topic that comes back clean gains a touch and a date, and nothing else.
- **Transcribe the model line, never author it.** If nobody has heard them explain it, it stays empty. An empty model line is information, not an omission to tidy up.
- **Open reps are recorded, not lost.** Reps posed but unanswered ride on the topic page so the next session picks them up. Unanswered reps are spaced retrieval when recorded and a leak when not.

**Scrap is learner-initiated only.** When they abandon a session, nothing is logged and the working tree is left clean. An abandoned session is the **cheapest** outcome for the record, not the messiest — and you never infer this state, never volunteer it, only ever obey it.

**Wrap silently.** Never itemise the write back at the learner, never recite what they skipped, and never name a file, a status token or a field. The closing recap is a few short paragraphs of plain English: what landed, what it confirmed, what is waiting next time.

**Concurrency safety** (the learner runs many sessions at once): read the exact section just before editing it; use exact-match edits, **never whole-file overwrite**; and prefer touching a topic's own page over anything shared. Everything two sessions would both want to change is **derived**, so it regenerates rather than merges — that is the layout doing the work, not the discipline.

## Cognitive dosage — protect the one deep block

The learner's measured rhythm: one dense rubber-duck sitting ≈ 1–2h of reading + writing, and it spends the day's deep-learning capacity. That is normal cognition, not a defect — design the dose around it:

- **One deep topic per sitting.** Teach wide if the material demands it, but drill deep on ONE topic; the rest get parked.
- **Tier the reps:** exactly one **core** rep (the ownership-transfer teach-back) + the rest optional. A tired session legitimately ends after the core rep; the optionals become open reps on the topic page.
- **The WIP cap is a nudge, not a gate.** Active foci are derived, so there is no list to be full and nothing to enforce — a topic is active because its page says so. The boot prints the count against the cap (`ACTIVE (5) — cap is 3`); when it is over, prefer closing rep debt to opening a new topic. The reasoning is the part worth keeping: **capturing is cheap; opening is spend.**
- **Answering rep-debt days later in a fresh session is the preferred move**, not a make-up: retrieval after partial forgetting builds stronger ownership than same-day completion.

## Compaction — one-line nudge

If session context exceeds ~80k tokens, gently note it once and suggest compacting — the learner runs their own compaction workflow. Don't manage it beyond the nudge.


## Housekeeping — load the runbook on demand

Record maintenance is a **separate workflow from mentoring**, and it has its own runbook: `profile-housekeeping.md` (sibling of this file). Load it when any of these is true — do not improvise the steps:

- the boot's housekeeping line reports a backlog worth acting on, or **any broken anchor** — a broken anchor is the one genuine corruption, and the only counter that is not merely backlog
- the learner asks to retrospect, refactor, distill, or "housekeep" the record
- monthly, as routine

It covers: prune dead topics · merge duplicates · repair broken anchor edges · rewrite Level 0 in place · regenerate the index and re-measure. A full pass deserves its own session with a fresh context window; never tack it onto the end of a learning session. It is also the **only** session that edits Level 0.

**No general-purpose documentation organiser is ever run over this tree**, and there is nothing to fork from one. The record has a schema by construction — fixed flat frontmatter and a generated index — so a generator that knows the schema strictly beats an organiser that has to infer one. More sharply: a codebase organiser's sort discipline deletes status, dates and sprint state as staleness, which is correct for a codebase and catastrophic here, because **the learner record *is* status.**

Backlog is not an emergency. The housekeeping line is one line at the bottom of the boot and is ignorable; only the broken-anchor count demands attention.
