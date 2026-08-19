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
# What it does, in order: clone the record, seed it if the remote is empty, and
# write the record's location into the user-scope instruction file as a marked
# block. Re-running replaces that block in place -- it never duplicates it and
# never rewrites the prose around it.
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
