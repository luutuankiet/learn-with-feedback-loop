#!/usr/bin/env bash
#
# session-card.sh -- hand a shipping session the learner's name card.
#
#   session-card.sh          emit the card as session-start hook JSON
#   session-card.sh --text   emit the same payload as plain text, for eyeballing
#
# This is the delivery half of the card. `boot.sh --card` decides WHAT the
# payload is; this decides WHO gets it and under what rules. It runs at the
# start of sessions the learner never opened the mentoring skill for, in
# repositories that have nothing to do with the record.
#
# THREE PROPERTIES, EACH LOAD-BEARING.
#
# It is opt-in structurally, not by a runtime check. Nothing registers this
# script except install.sh, and install.sh registers it in the same act as it
# writes the record's address. A machine that never opted in has no hook at all
# -- nothing to fire, nothing to fail, nobody nagged. A hook that exists can
# error, and an error on a machine that never asked for any of this is exactly
# the burden the design has to avoid.
#
# It goes into the AGENT's context and never onto the learner's screen. The
# hook protocol has a field for each; only the context one is used here. That
# is what keeps the standing rule that the learner never reads a status token,
# a slug, a date or a field name about themselves.
#
# It never fails loudly. Every failure -- no marker, a record that is gone, a
# boot that errors -- exits 0 with nothing emitted, because a session start is
# the worst possible moment to hand someone a stack trace about a system they
# are not currently using. The one exception is a marker that names a directory
# which is not there: that is a real repair the agent should offer if learning
# comes up, so it goes into context as a sentence, still without blocking.

set -uo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

MODE=hook
case "${1-}" in
  --text)    MODE=text ;;
  -h|--help) sed -n '3,6p' "$0" | sed 's/^#\{1,\} \{0,1\}//'; exit 0 ;;
  "")        ;;
  *)         exit 0 ;;
esac

# The marker is read through install.sh --where rather than re-parsed here, so
# the block's format has exactly one reader and cannot drift into two.
ADDRESS=""
if [ -x "$HERE/install.sh" ]; then
  ADDRESS="$("$HERE/install.sh" --where 2>/dev/null || true)"
fi

# No marker means this machine never opted in. Say nothing at all.
[ -n "$ADDRESS" ] || exit 0

# ------------------------------------------------------------------ memo ---
#
# The rules travel with the payload rather than living in the user-scope
# instruction file, because they are only true while a card is in context and
# there is no card unless this script put one there.

memo() {
  cat <<'MEMO'
LEARNER CARD — context for you, never for the screen.

A small window onto this machine's learner record, so an ordinary working
session can notice a teaching moment it would otherwise walk past. You have NOT
been asked to mentor; this is not a mentoring session.

WHEN YOU MAY SPEAK. Only when the work in THIS session actually touched
something on the card, and you must name what triggered it. No trigger, no
nudge, however much is sitting there — work that never went near any of it gave
you nothing to notice, and saying so anyway is how a nudge becomes a nag. At
most one per session.

IT NEVER BLOCKS. Never ask a question that halts the turn. Say the thing and
carry on with the task in the same turn — an unattended run or a subagent must
not be derailed by this.

HOW IT LOOKS. In a fenced block, so it survives a wall of build output, with
one symbol per line carrying meaning:

    ▲  a gap the work just walked into
    ◆  reps left open on something already in flight
    ○  never said back in their own words — not safe to build on

For example:

```
learn-with-feedback-loop
◆ retry semantics — came up in the queue consumer you just changed
  Two reps still open on it. Want one, or carry on?
```

PLAIN ENGLISH, ALWAYS. Never show the learner a slug, a status word, a date, a
field name or a path from this card, and never quote it into anything published
— a commit message, a pull request, an issue, a comment, a file.

LOADING THE SKILL STAYS DELIBERATE. The nudge is an offer; only if they accept
do you load the mentoring skill (learn-with-feedback-loop:learn) and open a real
session. Declining costs them one line and nothing else.

MEMO
}

# ------------------------------------------------------------------ card ---

payload() {
  memo
  if [ ! -d "$ADDRESS" ]; then
    # State B, stated rather than acted on: this hook repairs nothing and writes
    # nothing. It is here so that if learning does come up, the agent offers the
    # re-clone instead of quietly starting a second record.
    echo "THE RECORD IS NOT ON THIS MACHINE right now — the address is set but the"
    echo "directory is gone. Do not seed a replacement and do not treat the learner"
    echo "as new. If learning comes up, offer to restore it from their private"
    echo "remote, and otherwise say nothing about it."
    return 0
  fi
  "$HERE/boot.sh" "$ADDRESS" --card 2>/dev/null || return 1
}

CARD="$(payload)" || exit 0
[ -n "$CARD" ] || exit 0

if [ "$MODE" = text ]; then
  printf '%s\n' "$CARD"
  exit 0
fi

# JSON by hand, in awk, for the same reason the rest of this is bash: the
# record gets cloned onto whatever machine the learner is sitting at, and a
# session-start hook is the last place to discover a missing dependency.
escape() {
  awk '
    BEGIN { ORS = "" }
    {
      s = $0
      gsub(/\\/, "\\\\", s)
      gsub(/"/,  "\\\"", s)
      gsub(/\t/, "\\t", s)
      printf "%s\\n", s
    }'
}

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
  "$(printf '%s\n' "$CARD" | escape)"
