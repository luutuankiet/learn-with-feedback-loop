# The session-start hook is the import that was rejected, and it stands

The learner's record is found through a marked block in the user-scope
instruction file that states a **path**, deliberately not an `@import`. Importing
was rejected on the grounds that it would pull the most personal file the learner
has into every unrelated session — a session about a build failure would carry
the learner's gaps and their mission statement whether anyone wanted it there or
not.

A session-start hook that reads the record and injects a card **is that import,
executing.** This records why it stands anyway, so the point is not re-argued
every time someone notices the contradiction.

## What actually changed

The objection was to sessions the learner never asked for. **The install is the
asking.** Registration happens in exactly one place — the installer, in the same
act that writes the record's address — so a machine that never ran the installer
has no hook at all: nothing to fire, nothing to fail, and no error on a machine
whose owner never opted into any of this. One marked block turns both off, since
the hook reads the address through that block and emits nothing without it.

The other half is that what arrives is not the record. It is a **card** — the
marked spans of the hand-written page plus a recent-activity window — measured
and bounded, where the whole file is neither. An import has no such shape.

## The three properties that keep it tolerable

**It goes to the agent, never to the screen.** The hook protocol has a field for
each and only the context one is used. That preserves the standing rule that the
learner never reads a status token, a slug, a date or a field name about
themselves.

**It never blocks.** No question that halts a turn, ever — an unattended run or a
subagent must not be derailed. Worst case the agent says its one line and carries
on with the task in the same turn.

**It speaks only on a genuine trigger.** The nudge may fire only when the work in
the session actually touched something on the card, and it must name what
triggered it. A quiet week gets no nudge, and that is the system being honest
rather than asleep: if the work never went near the gaps, there was no chance to
notice one. No cooldown state is stored, because the trigger rule prevents most
of what a cooldown would have been for, and the record's first rule is never to
store what can be computed.

## Why the registered command is a generated resolver

The registered command is **not** the skill's own path. This plugin declares no
version, so it is cached per source commit — every update lands in a new
directory. A hook registered against the live path would report a missing command
the first time the plugin updated, permanently, on a machine whose only mistake
was staying current. That failure is the exact burden the opt-in design exists to
avoid, arriving by the back door.

So the installer writes a small resolver at a path that never moves, registers
*that*, and the resolver resolves the newest cached copy on every run, falls back
to the path that was live at install time, and exits silently when it finds
neither. An uninstalled plugin should look like nothing, not like a failure.

It resolves newest-first rather than preferring what it was installed against,
because the cache keeps old versions on disk: pinning to the install-time copy
would survive updates that report success and change nothing, which is the same
silent-staleness failure this plugin's missing `version` key exists to avoid.
