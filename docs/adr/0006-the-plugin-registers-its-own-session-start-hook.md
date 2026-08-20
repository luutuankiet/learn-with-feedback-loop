# The plugin registers its own session-start hook

Supersedes the section of
`docs/adr/0005-the-session-start-hook-is-the-import-that-was-rejected.md`
titled *"Why the registered command is a generated resolver"*. The rest of
`0005` — why a session-start card is a defensible version of the import that was
rejected, and the three properties that keep it tolerable — still stands
unchanged and is the more important half.

## What changed

The installer no longer registers anything. The plugin declares the hook itself,
in `hooks/hooks.json` at the plugin root:

```json
{"hooks": {"SessionStart": [{"hooks": [{"type": "command",
  "command": "\"${CLAUDE_PLUGIN_ROOT}\"/skills/learn/bin/session-card.sh"}]}]}}
```

`${CLAUDE_PLUGIN_ROOT}` is expanded by the harness to the plugin directory it
actually loaded. That is the whole point: the version question is answered by
the thing that already knows the answer.

## Why the resolver had to go

`0005` argued for a small script at a fixed path in user scope, because this
plugin declares no version and is therefore cached per source commit — a hook
registered against the live path would report a missing command the first time
the plugin updated. That reasoning was sound and the resolver worked. What it
could not do was answer the version question *correctly*, only *plausibly*: it
picked the newest cached copy **by file modification time**, which is a proxy
for "the version the harness loaded" and not the thing itself. Restore a backup,
re-fetch an older commit, or copy the cache with timestamps preserved and the
proxy silently picks a different answer, with no error anywhere.

The contagion is what settles it. `session-card.sh` finds `boot.sh` and
`install.sh` as its own siblings, so one mtime comparison decides the version of
**three** scripts at once, at session start, against a live record.

It is also the last of the four scripts in `bin/` to be resolved that way.
`boot.sh` is reached through the skill path the harness hands the agent;
`install.sh` is run by hand out of the directory the human is looking at;
`smoke.sh` runs from a checkout. Only the card was reached through a copy of
itself that lived outside the plugin, and being outside the plugin was the only
reason it had to guess.

## What was traded away

`0005` leant on the opt-in being **structural**: registration happened in the
installer and nowhere else, so a machine that never ran setup had no hook at
all — nothing to fire and nothing to fail. That is a strictly stronger guarantee
than what replaces it, and it is gone. The hook now fires on every machine that
installs the plugin.

What replaces it is the check that was always there anyway: the card reads the
record's address out of the marked block, and without it emits nothing and exits
zero. `smoke.sh` asserted that before this change and asserts it twice now,
because it went from a second line of defence to the only one.

The residual risk is honest and small: on a machine that never opted in, a bash
process starts once per session, reads one file, finds nothing and exits. What
must never happen is that it fails *loudly* there, so nothing above the address
check may depend on anything that can be missing.

## What guards the new arrangement

Two failures replace the one that was retired.

**A machine carrying both registrations injects the card twice** — no error, no
symptom, just a quietly doubled context. Nothing migrates the old resolver away,
by decision: the affected population is whoever ran the installer before this
change, they are few and known, and a session-start hook that rewrites a
settings file unasked is a worse thing to own than a manual cleanup. `smoke.sh`
asserts the installer writes no `SessionStart` entry and leaves no resolver
behind, so the repo can never start producing new instances of it.

**A path drifting back into a shipped file.** `smoke.sh` asserts that no file
outside `docs/` names the plugin cache. A pin fails by running an old copy
forever, which reports success and changes nothing — the same silent-staleness
failure the missing `version` key in the manifest exists to avoid (`0003`).
