#!/usr/bin/env bash
#
# install.sh -- put the learner record on this machine, and write down where.
#
#   install.sh <private-git-url> [record-path]
#   install.sh --where                        print the recorded path, or nothing
#
# Plugins have no install hook, so nothing runs when the skill arrives. The
# agent locates this script from the skill path the harness handed it and runs
# it once per machine. That is the whole setup ceremony.
#
# The URL is an ARGUMENT and never a default. This script ships publicly; a
# private remote written into it would be published with it. The path is a
# second argument with a convenience default, because the path is not a secret.
#
# Run with no URL, this prints a QUESTION rather than an instruction: have you
# already created a private repository for this? The old text said "create an
# empty private repository" unconditionally, which is correct on the first
# machine and manufactures a second record on every one after it. The script
# itself was always safe -- hand it a URL whose remote already has a record and
# it adopts rather than seeds -- so the only hole was the sentence a human
# reads. Uncertainty resolves to YES, because the costs are wildly asymmetric.
#
# What it does, in order: clone the record, seed it if the remote is empty,
# write the record's location into the user-scope instruction file as a marked
# block, and register the session-start card hook. Re-running replaces both in
# place -- it never duplicates either and never rewrites the prose around them.
#
# The marked block is the single source of truth for both. Delete it and the
# hook still fires but finds no address, so it emits nothing and exits clean:
# one edit turns the whole thing off, without a settings file to go and find.
#
# WHY A STATED ADDRESS AND NOT A CONVENTION: the skill arrives by plugin cache,
# so its own location differs on every machine and tells you nothing about where
# the record went. A convention breaks silently the first time a host cannot
# honour it -- and the failure it produces is a SECOND record, which halves a
# learning history without anybody noticing. A stated address cannot fail that
# way: it is either there, or it is missing and says so.

set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$(dirname -- "$HERE")/templates/record"

DEFAULT_PATH="$HOME/.learner-record"
AGENTS_FILE="${LEARN_AGENTS_FILE:-$HOME/.claude/CLAUDE.md}"

BEGIN_MARK="<!-- learn-with-feedback-loop:record -->"
END_MARK="<!-- /learn-with-feedback-loop:record -->"

usage() { sed -n '3,6p' "$0" | sed 's/^#\{1,\} \{0,1\}//'; }
say()   { printf '%s\n' "$*"; }
die()   { printf 'install.sh: %s\n' "$*" >&2; exit 2; }

# ---------------------------------------------------------------- reading ---

# recorded_path -- what the marker currently says, or empty. Reading is separate
# from writing so a session can ask "is this machine set up?" without the risk
# of setting it up as a side effect.
recorded_path() {
  [ -f "$AGENTS_FILE" ] || return 0
  awk -v b="$BEGIN_MARK" -v e="$END_MARK" '
    index($0, b) == 1 { on = 1; next }
    index($0, e) == 1 { on = 0; next }
    on && /^Learner record:/ {
      sub(/^Learner record:[ \t]*/, "")
      print
      exit
    }' "$AGENTS_FILE"
}

if [ "${1-}" = "--where" ]; then recorded_path; exit 0; fi
if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; exit 0; fi

# -------------------------------------------------------------- arguments ---

URL="${1-}"
RECORD="${2-$DEFAULT_PATH}"

if [ -z "$URL" ]; then
  usage
  say ""
  say "No URL given. The record lives in ONE private repository you own, and every"
  say "machine you use clones that SAME repository. So answer this first:"
  say ""
  say "  Have you already created a private repository for your learner record?"
  say ""
  say "  NO  -- this is your first machine. Create an EMPTY, PRIVATE repository on"
  say "         whatever host you use, then run this script again with its clone"
  say "         URL. It is seeded from the template shipped beside this script, so"
  say "         an empty repository is the expected starting point -- not a problem"
  say "         to solve first."
  say ""
  say "  YES -- this is another machine. Run this script again with the SAME clone"
  say "         URL you used the first time. This script clones what is already"
  say "         there and seeds nothing over it."
  say ""
  say "If you are not sure, answer YES and try a URL you might already own. Being"
  say "wrong that way costs a failed clone and one more question. Being wrong the"
  say "other way costs a SECOND record -- a learning history split in half, with"
  say "nothing downstream able to notice."
  exit 2
fi

command -v git >/dev/null 2>&1 || die "git is not on PATH"
[ -d "$TEMPLATE" ] || die "the seed template is missing at $TEMPLATE"

case "$RECORD" in
  /*) ;;
   *) RECORD="$PWD/$RECORD" ;;
esac

# ----------------------------------------------------------------- clone ----

if [ -e "$RECORD/.git" ]; then
  say "A record is already cloned at $RECORD -- leaving it alone."
elif [ -e "$RECORD" ] && [ -n "$(ls -A "$RECORD" 2>/dev/null)" ]; then
  die "$RECORD exists and is not empty, but is not a git clone. Move it aside first."
else
  say "Cloning the record into $RECORD ..."
  git clone "$URL" "$RECORD" || die "clone failed -- check the URL and your access"
fi

# ------------------------------------------------------------------ seed ----

# Seeding is legal HERE and nowhere else. A live mentoring session that cannot
# reach the record must stop and offer a re-clone; if it were allowed to seed,
# every unreachable-record moment would be a chance to start a second history.
if [ -e "$RECORD/AGENTS.md" ] || [ -d "$RECORD/topics" ]; then
  say "The record already has its structure -- nothing seeded."
else
  say "The remote is empty. Seeding the record's structure ..."
  cp "$TEMPLATE/AGENTS.md" "$RECORD/AGENTS.md"
  cp "$TEMPLATE/INDEX.md"  "$RECORD/INDEX.md"
  mkdir -p "$RECORD/topics"
  cp "$TEMPLATE/topics/.gitkeep" "$RECORD/topics/.gitkeep"

  git -C "$RECORD" add -A
  # A failed commit must not be reported as a safe one. Without an identity
  # configured, git refuses here -- and an uncommitted seed is a record the next
  # host will seed all over again.
  git -C "$RECORD" commit -q -m "Seed the learner record" \
    || die "could not commit the seed. Set your git identity (user.name, user.email) and re-run"
  if git -C "$RECORD" push -q 2>/dev/null; then
    say "Seeded and pushed."
  else
    say "Seeded locally. The push did not go through -- the commit is safe, push when you can."
  fi
fi

# ---------------------------------------------------------------- pointer ---

# The marked block is the record's address, in the one file every session on
# this machine already loads. It is a plain path and NOT an import: importing
# would pull the record's own instructions into every unrelated session, and
# the record is the most personal file the learner has.
mkdir -p "$(dirname -- "$AGENTS_FILE")"
[ -f "$AGENTS_FILE" ] || : > "$AGENTS_FILE"

TMP="$(mktemp)"
trap 'rm -f -- "$TMP"' EXIT

awk -v b="$BEGIN_MARK" -v e="$END_MARK" -v path="$RECORD" '
  function block() {
    print b
    print "Learner record: " path
    print ""
    print "A short profile of this learner arrives in your context at the start of every"
    print "session on this machine. While doing ordinary work, notice when the task walks"
    print "into something on it and nudge gently -- one line, never a question that stops"
    print "the turn, and only when the work actually touched it."
    print ""
    print "Never quote that profile, or anything derived from it, into anything published:"
    print "a commit message, a pull request, an issue, a comment, a file. It is a private"
    print "record of what one person is still learning."
    print e
    done_ = 1
  }
  index($0, b) == 1 { skip = 1; block(); next }
  index($0, e) == 1 { skip = 0; next }
  skip { next }
  { print }
  END {
    if (!done_) {
      if (NR > 0) print ""
      block()
    }
  }' "$AGENTS_FILE" > "$TMP"

cat "$TMP" > "$AGENTS_FILE"

say "Recorded the address in $AGENTS_FILE."

# ------------------------------------------------------------------- hook ---
#
# The session-start hook is registered HERE and nowhere else, in the same act
# that writes the address above. That is what makes opting in structural rather
# than a runtime check: a machine that never ran this script has no hook at
# all, so there is nothing to fire and nothing to fail. A hook that exists can
# error, and an error on a machine that never asked for any of this is exactly
# the burden this has to avoid.
#
# WHY A GENERATED RESOLVER RATHER THAN THE SCRIPT'S OWN PATH. The plugin is
# cached per source commit, so the directory this script is running from changes
# on every plugin update. Registering that path would arm a hook that reports a
# missing command the first time the plugin updates -- a permanent error on a
# machine whose only crime was staying current. The resolver sits at a path that
# never moves, resolves the newest cached copy on every run, falls back to the
# path that was live at install time, and exits silently when it can find neither
# (which is what an uninstalled plugin should look like: nothing, not a failure).

SETTINGS_FILE="${LEARN_SETTINGS_FILE:-$HOME/.claude/settings.json}"
HOOK_DIR="$(dirname -- "$SETTINGS_FILE")/hooks"
HOOK_FILE="$HOOK_DIR/learn-with-feedback-loop-card.sh"
# The plugin's own cache root: <root>/<commit>/skills/learn/bin is where this
# script sits, so its siblings are the other cached versions of this plugin.
PLUGIN_ROOT="$(cd -- "$HERE/../../../.." 2>/dev/null && pwd || true)"

mkdir -p "$HOOK_DIR"
cat > "$HOOK_FILE" <<EOF
#!/usr/bin/env bash
# Generated by learn-with-feedback-loop's install.sh. Delete it to stop the
# session-start card arriving; nothing else reads it.
# The newest cached copy wins, because the cache keeps old versions around and
# preferring the one that was live at install time would pin this to it for as
# long as that directory survives -- an update that reports success and changes
# nothing. The install-time path is the fallback, for an install that came from
# somewhere other than a versioned cache.
BIN=""
ROOT="$PLUGIN_ROOT"
if [ -n "\$ROOT" ] && [ -d "\$ROOT" ]; then
  newest=""
  for c in "\$ROOT"/*/skills/learn/bin/session-card.sh; do
    [ -x "\$c" ] || continue
    if [ -z "\$newest" ] || [ "\$c" -nt "\$newest" ]; then newest="\$c"; fi
  done
  [ -n "\$newest" ] && BIN="\$(dirname -- "\$newest")"
fi
[ -n "\$BIN" ] || BIN="$HERE"
[ -x "\$BIN/session-card.sh" ] || exit 0
exec "\$BIN/session-card.sh"
EOF
chmod +x "$HOOK_FILE"

# Merging into a settings file nobody else owns lines of is the one job here
# that json actually needs a parser for. Two are tried, and the third branch
# hands the human the exact snippet rather than half-editing their settings --
# a mangled settings.json is worse than no card.
register_hook() {
  if [ -f "$SETTINGS_FILE" ] && ! grep -q '[^[:space:]]' "$SETTINGS_FILE"; then
    rm -f -- "$SETTINGS_FILE"
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$SETTINGS_FILE" "$HOOK_FILE" <<'PY'
import json, os, sys
path, cmd = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    with open(path) as fh:
        try:
            data = json.load(fh)
        except ValueError:
            sys.exit(3)
    if not isinstance(data, dict):
        sys.exit(3)
hooks = data.setdefault("hooks", {})
groups = hooks.get("SessionStart") or []


def ours(group):
    entries = group.get("hooks") if isinstance(group, dict) else None
    for entry in entries or []:
        if "learn-with-feedback-loop-card" in (entry.get("command") or ""):
            return True
    return False


groups = [g for g in groups if not ours(g)]
groups.append({"hooks": [{"type": "command", "command": cmd}]})
hooks["SessionStart"] = groups
tmp = path + ".learn-tmp"
with open(tmp, "w") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
os.replace(tmp, path)
PY
    return $?
  fi
  if command -v jq >/dev/null 2>&1; then
    [ -f "$SETTINGS_FILE" ] || printf '{}\n' > "$SETTINGS_FILE"
    local tmp="$SETTINGS_FILE.learn-tmp"
    jq --arg c "$HOOK_FILE" '
      .hooks = (.hooks // {}) |
      .hooks.SessionStart = (
        ((.hooks.SessionStart // [])
          | map(select([.hooks[]?.command // ""]
                       | map(test("learn-with-feedback-loop-card"))
                       | any | not)))
        + [{"hooks": [{"type": "command", "command": $c}]}]
      )' "$SETTINGS_FILE" > "$tmp" || return 3
    mv -- "$tmp" "$SETTINGS_FILE"
    return 0
  fi
  return 4
}

if register_hook; then
  say "Registered the session-start card in $SETTINGS_FILE."
else
  say ""
  say "COULD NOT register the session-start hook automatically."
  say "Everything else is set up; only the card is missing. Add this to the"
  say "\"hooks\" object in $SETTINGS_FILE by hand:"
  say ""
  say "  \"SessionStart\": [{\"hooks\": [{\"type\": \"command\", \"command\": \"$HOOK_FILE\"}]}]"
  say ""
  say "If that file already has a SessionStart list, add the entry to it rather"
  say "than replacing it."
fi

# ---------------------------------------------------------------- verify ----

if [ -x "$HERE/boot.sh" ]; then
  if "$HERE/boot.sh" "$RECORD" >/dev/null 2>&1; then
    say "A session boots against it cleanly."
  else
    die "the record was set up but boot.sh could not read it -- do not start a session yet"
  fi
fi

say ""
say "Done. Nothing else to configure -- every session from here reads that address."
