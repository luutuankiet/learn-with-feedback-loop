#!/usr/bin/env bash
#
# smoke.sh -- prove boot.sh still honours its output contract.
#
#   bin/smoke.sh            run every check against a throwaway record
#
# boot.sh has a *published* contract: named sections, an ignorable housekeeping
# line, and exit codes a caller branches on. A contract with no guard is a
# contract that rots, so this builds a record from scratch, asserts against the
# real output, and cleans up after itself. It writes nothing outside its own
# temporary directory and never touches a real record.
#
# Every fixture date is generated relative to *today*, so the age thresholds
# mean the same thing a year from now as they do this afternoon. A fixture with
# hard-coded dates passes until it silently stops testing anything.

set -uo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BOOT="$HERE/boot.sh"
[ -x "$BOOT" ] || { echo "smoke.sh: $BOOT is not executable" >&2; exit 2; }

WORK="$(mktemp -d)"
trap 'rm -rf -- "$WORK"' EXIT
R="$WORK/record"
mkdir -p "$R/topics"

PASS=0; FAIL=0
ok()   { PASS=$((PASS + 1)); printf '  ok    %s\n' "$1"; }
bad()  { FAIL=$((FAIL + 1)); printf '  FAIL  %s\n' "$1" >&2; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 -- wanted [$3], got [$2]"; fi; }

# ago <n> -- the date n days before today, without GNU date or gawk. The
# calendar arithmetic is the inverse of the one boot.sh uses for ages.
ago() {
  date +%Y-%m-%d | awk -F- -v back="$1" '
    function daynum(y, m, d,   era, yoe, doy, doe) {
      y -= (m <= 2)
      era = int((y >= 0 ? y : y - 399) / 400)
      yoe = y - era * 400
      doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
      doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
      return era * 146097 + doe - 719468
    }
    function civil(z,   era, doe, yoe, y, doy, mp, m, d) {
      z += 719468
      era = int((z >= 0 ? z : z - 146096) / 146097)
      doe = z - era * 146097
      yoe = int((doe - int(doe / 1460) + int(doe / 36524) - int(doe / 146096)) / 365)
      y = yoe + era * 400
      doy = doe - (365 * yoe + int(yoe / 4) - int(yoe / 100))
      mp = int((5 * doy + 2) / 153)
      d = doy - int((153 * mp + 2) / 5) + 1
      m = mp + (mp < 10 ? 3 : -9)
      y += (m <= 2)
      return sprintf("%04d-%02d-%02d", y, m, d)
    }
    { print civil(daynum($1 + 0, $2 + 0, $3 + 0) - back) }'
}

page() { # page <slug> <frontmatter-body>
  local slug="$1"; shift
  { printf -- '---\n%s\n---\n\n# %s\n' "$1" "$slug"; } > "$R/topics/$slug.md"
}

# ------------------------------------------------------------- the record ---

cat > "$R/AGENTS.md" <<EOF
---
housekept: $(ago 94)
---
# Who this learner is

**Background.** Ships pipelines; weak on distributed failure modes.

<!-- BEGIN CARD -->
**The mission.** Stop being the person who can fix it but not explain it.
<!-- END CARD -->
EOF

# active: learning with open reps, inline list, block seen_in, quoted model
cat > "$R/topics/lookback-windows.md" <<EOF
---
status: learning
track: data-pipelines
earned_by: rubber-duck
model: "reprocess a trailing slice; no state to get wrong"
anchor: batch-reprocessing
reps: 1/5
open_reps: [trace-late-arrival, watermark-failure]
touches: 2
last: $(ago 8)
seen_in:
  - the nightly DAG rewrite
  - the warehouse cost spike
---

# lookback windows
EOF

# active: block-form open_reps, and an apostrophe inside a quoted value
cat > "$R/topics/idempotent-merges.md" <<EOF
---
status: learning
track: data-pipelines
earned_by: rubber-duck
model: 'running it twice lands the same rows'
anchor: lookback-windows
reps: 2/4
open_reps:
  - dedup-key-choice
touches: 3
last: $(ago 3)
seen_in:
  - the warehouse cost spike
---

# idempotent merges
EOF

# learning but NO open reps -- must not appear under ACTIVE
page window-functions "status: learning
track: sql
earned_by: rubber-duck
model: \"a running total that never collapses the rows\"
reps: 3/3
open_reps: []
touches: 2
last: $(ago 2)"

# owned and cold -- rusty
page watermarking "status: owned
track: data-pipelines
earned_by: rubber-duck
model: \"the line past which I promise not to change my mind\"
anchor: lookback-windows
reps: 4/4
touches: 5
last: $(ago 91)"

# owned and fresh -- must NOT be rusty
page batch-reprocessing "status: owned
track: data-pipelines
earned_by: rubber-duck
model: \"throw the output away and build it again from the inputs\"
anchor: null
reps: 3/3
touches: 6
last: $(ago 4)"

# asserted with a recent date -- unverified anyway; no date rescues it
page retry-backoff "status: owned
track: distributed
earned_by: asserted
model: null
anchor: watermarking
reps: 0/2
touches: 1
last: $(ago 5)"

# anchor pointing at a page that does not exist -- the one real corruption
page partition-pruning "status: gap
track: sql
earned_by: asserted
model: null
anchor: query-planner-internals
reps: 0/0
touches: 1
last: $(ago 222)"

# a page nobody ever stamped -- must not crash the scan
printf '# a page written by hand and never stamped\n' > "$R/topics/bare-page.md"

# ----------------------------------------------------------------- checks ---

echo "boot"
OUT="$($BOOT "$R" 2>&1)"; RC=$?
check "exits clean" "$RC" "0"

# sect <header> -- the indented rows under one section header. A section ends
# at the first line that is not an indented row, which is what keeps the footer
# and the housekeeping line out of the counts.
sect() {
  printf '%s\n' "$OUT" | awk -v s="$1" '
    index($0, s) == 1 { on = 1; next }
    on && /^  / { print; next }
    on && NF    { exit }'
}

ACTIVE="$(sect 'ACTIVE')"
check "ACTIVE holds only learning-with-open-reps" \
  "$(printf '%s\n' "$ACTIVE" | awk '{print $1}' | LC_ALL=C sort | tr '\n' ' ')" \
  "idempotent-merges lookback-windows "
check "ACTIVE is ordered most-recently-touched first" \
  "$(printf '%s\n' "$ACTIVE" | awk 'NR == 1 {print $1}')" "idempotent-merges"
# Only the FIRST seen_in survives into the digest -- it is a recognition handle,
# not a history. lookback-windows lists two; the DAG rewrite is the one shown.
check "ACTIVE carries the first seen_in fragment" \
  "$(printf '%s\n' "$ACTIVE" | grep -c 'nightly DAG rewrite')" "1"
check "ACTIVE shows one fragment per row, not the whole list" \
  "$(printf '%s\n' "$ACTIVE" | grep -c 'warehouse cost spike')" "1"

check "RUSTY is owned-and-cold only" \
  "$(sect 'RUSTY' | awk '{print $1}' | tr '\n' ' ')" "watermarking "
check "UNVERIFIED catches a recent asserted topic" \
  "$(sect 'UNVERIFIED' | grep -c 'retry-backoff')" "1"
check "UNVERIFIED is every asserted topic" \
  "$(sect 'UNVERIFIED' | wc -l | tr -d ' ')" "3"

check "Level 0 is emitted verbatim" \
  "$(printf '%s\n' "$OUT" | grep -c 'Stop being the person')" "1"
check "the total-topics line counts every page, listed or not" \
  "$(printf '%s\n' "$OUT" | grep -c '^8 topics total')" "1"
check "the broken anchor is counted, and reads singular" \
  "$(printf '%s\n' "$OUT" | grep -c '1 broken anchor$')" "1"
check "housekeeping is one ignorable line" \
  "$(printf '%s\n' "$OUT" | grep -c 'housekeeping run suggested')" "1"
check "the WIP cap nudges rather than gates" \
  "$(printf '%s\n' "$OUT" | grep -c 'cap is')" "0"

echo "index"
check "the index is current straight after a boot" \
  "$($BOOT "$R" --check >/dev/null 2>&1; echo $?)" "0"
printf '\n## Hand-written note\nThis must survive.\n' >> "$R/INDEX.md"
page brand-new "status: gap
track: sql
last: $(ago 1)"
check "a new page makes the index stale" \
  "$($BOOT "$R" --check >/dev/null 2>&1; echo $?)" "1"
$BOOT "$R" >/dev/null 2>&1
check "prose outside the markers survives regeneration" \
  "$(grep -c 'This must survive.' "$R/INDEX.md")" "1"
check "the new page appears in the index" \
  "$(grep -c 'brand-new' "$R/INDEX.md")" "1"
cp "$R/INDEX.md" "$WORK/idx.before"
$BOOT "$R" >/dev/null 2>&1
check "regeneration is byte-identical" \
  "$(cmp -s "$WORK/idx.before" "$R/INDEX.md" && echo same || echo differs)" "same"

echo "query"
check "a predicate ANDs its terms" \
  "$($BOOT "$R" --query 'owned & last>60d' | awk 'NR > 1 && NF && $1 != "" && $1 !~ /topics$/ {print $1}' | head -1)" \
  "watermarking"
check "an unknown term is refused" \
  "$($BOOT "$R" --query 'wat' >/dev/null 2>&1; echo $?)" "2"

# The runbook's urgent trigger. `broken-anchor` is the only term judged against
# the whole record rather than the row, so it is the only one that can be broken
# by a change to how the scan is read -- and the count it reports must be the
# same number the boot's warning line prints, or the two disagree in front of
# the maintainer at the one moment either is authoritative.
check "broken-anchor names the page carrying the dangling edge" \
  "$($BOOT "$R" --query 'broken-anchor' | awk 'NR > 1 && /^[a-z]/ {print $1}')" \
  "partition-pruning"
check "broken-anchor agrees with the boot's warning count" \
  "$($BOOT "$R" --query 'broken-anchor' | awk '$2 == "of" {print $1}')" "1"
# Reading the scan twice must not double the denominator.
check "the ledger counts every topic once" \
  "$($BOOT "$R" --query all | awk '$2 == "of" {print ($1 == $3 ? "equal" : $1 "!=" $3)}')" \
  "equal"

echo "card"
#
# The card is the shipping session's payload: the marked spans of Level 0 plus
# a recent window, and nothing else. Two properties are worth guarding, because
# both fail quietly. A boundary found by heading name empties the card the day
# somebody renames a heading, with everything still working and nothing to
# announce it -- so the boundary is a marker, and its absence is announced. And
# a payload with no ceiling is a payload that is fine until the record is big,
# which is exactly when nobody is looking.
CARD="$($BOOT "$R" --card 2>&1)"; CRC=$?
check "the card exits clean" "$CRC" "0"
check "the card carries the marked span" \
  "$(printf '%s\n' "$CARD" | grep -c 'Stop being the person')" "1"
check "the card carries ONLY the marked span" \
  "$(printf '%s\n' "$CARD" | grep -c 'Ships pipelines')" "0"
check "the card says it is a window, and where to get certainty" \
  "$(printf '%s\n' "$CARD" | grep -c -- '--query all')" "1"
check "a card row carries its track and its recognition handle" \
  "$(printf '%s\n' "$CARD" | grep -c 'idempotent-merges .*data-pipelines .*warehouse cost spike')" "1"
check "the window excludes what is older than the window" \
  "$(printf '%s\n' "$CARD" | grep -c 'watermarking')" "0"

# The card must never write. It fires at the start of sessions that have
# nothing to do with the record, in repositories that have nothing to do with
# it either; regenerating an index from there is a surprise write.
QUIET="$WORK/quiet"
mkdir -p "$QUIET/topics"
cp "$R/AGENTS.md" "$QUIET/AGENTS.md"
cp "$R/topics/lookback-windows.md" "$QUIET/topics/"
$BOOT "$QUIET" --card >/dev/null 2>&1
check "the card writes nothing -- no index is generated" \
  "$([ -e "$QUIET/INDEX.md" ] && echo wrote || echo silent)" "silent"

# An unmarked page is the silent-failure case the markers exist to prevent.
BARE="$WORK/bare"
mkdir -p "$BARE/topics"
printf '# Who this learner is\n\n**The mission.** Unmarked, so unreadable.\n' > "$BARE/AGENTS.md"
BARECARD="$($BOOT "$BARE" --card 2>&1)"
check "an unmarked page is announced, not silently empty" \
  "$(printf '%s\n' "$BARECARD" | grep -c 'no card markers')" "1"
check "an unmarked page does not leak the whole page instead" \
  "$(printf '%s\n' "$BARECARD" | grep -c 'Unmarked, so unreadable')" "0"

# The ceiling, measured where it matters: a record far larger than the one
# above, every page touched inside the window, so nothing but the cap is
# holding the payload down. Bytes stand in for tokens at the usual ~4:1, so
# 6000 bytes is the 1500-token budget with the slack a fixture deserves.
BIG="$WORK/big"
mkdir -p "$BIG/topics"
cp "$R/AGENTS.md" "$BIG/AGENTS.md"
i=0
while [ "$i" -lt 200 ]; do
  printf -- '---\nstatus: learning\ntrack: data-pipelines\nearned_by: asserted\nreps: 0/3\nopen_reps: [a-rep]\ntouches: 1\nlast: %s\nseen_in:\n  - the warehouse cost spike\n---\n\n# big-%03d\n' \
    "$(ago 2)" "$i" > "$BIG/topics/big-$(printf '%03d' "$i").md"
  i=$((i + 1))
done
BIGCARD="$($BOOT "$BIG" --card 2>&1)"
check "the window is capped however much was touched" \
  "$(printf '%s\n' "$BIGCARD" | grep -c '^  big-')" "12"
check "the cap says what it is hiding" \
  "$(printf '%s\n' "$BIGCARD" | grep -c 'newest 12 of 200')" "1"
check "the card stays under its byte ceiling on a big record" \
  "$([ "$(printf '%s\n' "$BIGCARD" | wc -c)" -le 6000 ] && echo under || echo over)" "under"

echo "failure states"
check "a missing root exits 3, not 0 and not 1" \
  "$($BOOT "$WORK/not-a-record" >/dev/null 2>&1; echo $?)" "3"
check "a missing root creates nothing" \
  "$([ -e "$WORK/not-a-record" ] && echo created || echo absent)" "absent"
check "no argument is a usage error" \
  "$($BOOT >/dev/null 2>&1; echo $?)" "2"
mkdir -p "$WORK/empty"
check "an empty record boots rather than failing" \
  "$($BOOT "$WORK/empty" >/dev/null 2>&1; echo $?)" "0"

# ---------------------------------------------------------------- install ---
#
# install.sh has a contract too, and its two load-bearing properties are exactly
# the kind that rot without a guard: re-running must not duplicate the marker,
# and a second host must not re-seed a record the remote already has. The second
# one is the failure this whole design exists to prevent -- a second record.
#
# Runs in a subshell with HOME redirected, so nothing here can touch the real
# machine's instruction file or clone anything into a real home directory.
(
  INSTALL="$HERE/install.sh"
  [ -x "$INSTALL" ] || { echo "  FAIL  install.sh is not executable" >&2; exit 1; }

  echo "install"
  export HOME="$WORK/fakehome"
  export LEARN_AGENTS_FILE="$HOME/.claude/CLAUDE.md"
  export GIT_AUTHOR_NAME=smoke GIT_AUTHOR_EMAIL=smoke@example.invalid
  export GIT_COMMITTER_NAME=smoke GIT_COMMITTER_EMAIL=smoke@example.invalid
  mkdir -p "$HOME/.claude"
  printf '# notes\n\nprose that was here first.\n' > "$LEARN_AGENTS_FILE"
  git init -q --bare "$WORK/remote.git"

  # Opting in is the marked block and nothing else. The hook now arrives with
  # the plugin, so what has to hold is that a machine which never ran this
  # script still sees NOTHING -- and that this script never writes to the
  # settings file, which it has no business touching now that registration
  # moved into the plugin manifest.
  SETTINGS="$HOME/.claude/settings.json"
  export LEARN_SETTINGS_FILE="$SETTINGS"
  printf '{\n  "a-setting-that-was-here-first": true\n}\n' > "$SETTINGS"
  check "the card says nothing before there is an address" \
    "$("$HERE/session-card.sh" 2>&1 | wc -c | tr -d ' ')" "0"
  check "the card is a clean exit before there is an address" \
    "$("$HERE/session-card.sh" >/dev/null 2>&1; echo $?)" "0"

  check "no URL is a usage error, not a guess" \
    "$($INSTALL >/dev/null 2>&1; echo $?)" "2"
  check "no URL writes no marker" \
    "$(grep -c 'learn-with-feedback-loop:record' "$LEARN_AGENTS_FILE")" "0"

  # The no-URL text is the only thing standing between a second workstation and
  # a rival record. The script is already safe -- it adopts a remote that has a
  # record -- so what has to hold is that the human is ASKED which machine this
  # is, told where the second machine's URL comes from, and pushed toward
  # adopting when unsure. Told "create an empty private repository" flatly, they
  # will, and nothing downstream can tell it happened.
  NOURL="$($INSTALL 2>&1 || true)"
  check "no URL asks whether a record already exists" \
    "$(printf '%s\n' "$NOURL" | grep -c 'already created a private repository')" "1"
  check "no URL routes another machine to the same clone URL" \
    "$(printf '%s\n' "$NOURL" | grep -c 'SAME clone')" "1"
  check "no URL resolves uncertainty toward adopting, not seeding" \
    "$(printf '%s\n' "$NOURL" | grep -c 'answer YES')" "1"

  $INSTALL "$WORK/remote.git" "$HOME/rec" >/dev/null 2>&1
  check "a first install seeds and records the address" \
    "$($INSTALL --where)" "$HOME/rec"
  check "the seed is the tree, not a profile file" \
    "$([ -f "$HOME/rec/AGENTS.md" ] && [ -d "$HOME/rec/topics" ] && echo tree)" "tree"

  $INSTALL "$WORK/remote.git" "$HOME/rec" >/dev/null 2>&1
  check "re-running does not duplicate the marker" \
    "$(grep -c 'learn-with-feedback-loop:record' "$LEARN_AGENTS_FILE")" "2"
  check "prose around the marker survives" \
    "$(grep -c 'prose that was here first' "$LEARN_AGENTS_FILE")" "1"

  # ------------------------------------------------------- the session card ---
  #
  # The delivery half. Its whole design is about what it does NOT do on a
  # machine that never asked: no registration, no output, no failure. Every one
  # of those is silent when it breaks, so every one of them is asserted here.

  echo "session card"
  CARDHOOK="$HERE/session-card.sh"
  [ -x "$CARDHOOK" ] || bad "session-card.sh is not executable"

  # The registration is the plugin's, not ours. These three say the installer
  # keeps its hands off the settings file entirely -- the failure they guard is
  # a machine carrying two registrations and injecting the card twice, which
  # produces no error and no symptom, just a quietly doubled context.
  check "installing writes no hook into the settings file" \
    "$(grep -c 'SessionStart' "$SETTINGS")" "0"
  check "installing leaves no resolver behind in user scope" \
    "$([ -e "$HOME/.claude/hooks/learn-with-feedback-loop-card.sh" ] && echo present || echo absent)" "absent"
  check "settings that were already there survive untouched" \
    "$(grep -c 'a-setting-that-was-here-first' "$SETTINGS")" "1"

  # The manifest is the one registration, and it must name the active plugin
  # through the harness variable rather than any path this repo can compute.
  MANIFEST="$(dirname -- "$(dirname -- "$(dirname -- "$HERE")")")/hooks/hooks.json"
  check "the plugin declares the session-start hook itself" \
    "$([ -f "$MANIFEST" ] && echo declared || echo missing)" "declared"
  check "the declared command resolves through the harness, not a fixed path" \
    "$(grep -c 'CLAUDE_PLUGIN_ROOT' "$MANIFEST")" "1"
  check "the declared command points at the card" \
    "$(grep -c 'skills/learn/bin/session-card.sh' "$MANIFEST")" "1"
  check "the declaration is valid json" \
    "$(python3 -c 'import json,sys;json.load(open(sys.argv[1]));print("ok")' "$MANIFEST" 2>/dev/null || echo bad)" "ok"

  # The record cloned above is the template seed, so give it something to say.
  cat >> "$HOME/rec/AGENTS.md" <<'EOF'

<!-- BEGIN CARD -->
**The mission.** Stop being the person who can fix it but not explain it.
<!-- END CARD -->
EOF
  cat > "$HOME/rec/topics/retry-semantics.md" <<EOF
---
status: learning
track: services
earned_by: asserted
reps: 1/3
open_reps: [trace-a-retry]
touches: 2
last: $(ago 1)
seen_in:
  - the queue consumer rewrite
---

# retry-semantics
EOF

  HOOKOUT="$("$CARDHOOK")"; HOOKRC=$?
  check "the hook exits clean" "$HOOKRC" "0"
  check "the hook emits one line of hook JSON" \
    "$(printf '%s\n' "$HOOKOUT" | wc -l | tr -d ' ')" "1"
  # Context, never the screen: the protocol has a field for each, and putting
  # the card on the screen would break the standing rule that the learner never
  # reads a status token, a slug or a date about themselves.
  check "the payload goes to context and not to the screen" \
    "$(printf '%s\n' "$HOOKOUT" | grep -c '"additionalContext"')" "1"
  check "nothing is addressed to the learner" \
    "$(printf '%s\n' "$HOOKOUT" | grep -c 'systemMessage')" "0"
  check "the payload carries the card" \
    "$(printf '%s\n' "$HOOKOUT" | grep -c 'Stop being the person')" "1"
  check "the payload carries the trigger rule that keeps it from nagging" \
    "$(printf '%s\n' "$HOOKOUT" | grep -c 'No trigger, no')" "1"
  check "a row says when a topic was never said back" \
    "$("$CARDHOOK" --text | grep -c 'never-said-back')" "1"

  # Opting out is one edit to the block that opted in. The hook stays registered
  # -- it is the plugin's, and removing the plugin is a different act -- so it
  # fires, finds no address, says nothing, and exits clean. This is now the only
  # thing an un-opted-in machine relies on, so it is asserted twice: silence,
  # and a zero exit.
  cp "$LEARN_AGENTS_FILE" "$WORK/agents.keep"
  : > "$LEARN_AGENTS_FILE"
  check "no address means no output at all" "$("$CARDHOOK" | wc -c | tr -d ' ')" "0"
  check "no address is still a clean exit" "$("$CARDHOOK" >/dev/null 2>&1; echo $?)" "0"
  cat "$WORK/agents.keep" > "$LEARN_AGENTS_FILE"

  # A record whose directory has gone is the one failure worth putting into
  # context -- the repair belongs to a mentoring session, and the danger is a
  # second record being seeded by something that meant well.
  mv "$HOME/rec" "$HOME/rec.away"
  GONE="$("$CARDHOOK")"
  check "a missing record is still a clean exit" \
    "$("$CARDHOOK" >/dev/null 2>&1; echo $?)" "0"
  check "a missing record is reported to the agent, not repaired" \
    "$(printf '%s\n' "$GONE" | grep -c 'NOT ON THIS MACHINE')" "1"
  check "a missing record seeds nothing" \
    "$([ -e "$HOME/rec" ] && echo seeded || echo untouched)" "untouched"
  mv "$HOME/rec.away" "$HOME/rec"

  # The plugin is cached per source commit, so the directory the skill lives in
  # changes on every update. Nothing here may name one. The harness expands
  # CLAUDE_PLUGIN_ROOT to whichever version it loaded, and the only defence
  # against drifting back to a hand-resolved path is that no shipped file
  # contains a cache path or a commit-shaped directory at all -- a pin fails by
  # running an old copy forever, which reports success and changes nothing.
  # The needle is split so this file does not match its own search.
  NEEDLE="plugins""/cache"
  PINS="$(grep -rIl "$NEEDLE" "$(dirname -- "$(dirname -- "$(dirname -- "$HERE")")")" \
          --exclude-dir=.git --exclude-dir=tmp --exclude-dir=docs 2>/dev/null | wc -l | tr -d ' ')"
  check "no shipped file names the plugin cache" "$PINS" "0"

  # The card locates boot.sh and install.sh as its own siblings, so wherever the
  # harness points it, it drags the matching versions with it. Running it from
  # an unrelated working directory must change nothing.
  check "the card does not depend on the working directory" \
    "$(cd / && "$CARDHOOK" --text | grep -c 'Stop being the person')" "1"

  # The one that matters: a second machine cloning the SAME remote must adopt
  # the existing record, never seed a rival one.
  export HOME="$WORK/fakehome2"
  export LEARN_AGENTS_FILE="$HOME/.claude/CLAUDE.md"
  mkdir -p "$HOME/.claude"
  $INSTALL "$WORK/remote.git" "$HOME/rec" >/dev/null 2>&1
  check "a second host adopts rather than re-seeds" \
    "$(git -C "$HOME/rec" rev-list --count HEAD)" "1"

  printf '%s %s\n' "$PASS" "$FAIL" > "$WORK/install.tally"
)
if [ -f "$WORK/install.tally" ]; then
  read -r P2 F2 < "$WORK/install.tally"
  PASS="$P2"; FAIL="$F2"
else
  bad "the install section did not finish"
fi

# --- the portable boundary -------------------------------------------------
# SKILL.md is the always-loaded half. It must stay runnable where there is no
# filesystem at all, so it may name its own bundled relative references (inert
# when absent) but never an absolute path, a home directory, or the record's
# address. Before the three skills were merged this was a file boundary anyone
# could prove; now it is a section boundary, and these are what prove it.
SKILL_DIR="$(dirname -- "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)")"
SKILL_MD="$SKILL_DIR/SKILL.md"

check "the always-loaded half names no absolute path" \
  "$(grep -cE '(^|[^a-zA-Z0-9._/-])(/[a-zA-Z]|~/)' "$SKILL_MD")" "0"
check "the always-loaded half does not carry the record address" \
  "$(grep -c 'learn-with-feedback-loop:record' "$SKILL_MD")" "0"

# The other half of the same guard: the reference an agent reads must pose the
# question rather than declare the machine a first-timer.
check "the record reference asks before treating a machine as the first" \
  "$(grep -c 'have you already created a private repository' "$SKILL_DIR/ref/record.md")" "1"

# A pointer the router names must resolve, or a session silently teaches without it.
MISSING=0
for r in $(grep -oE 'ref/[a-z-]+\.md' "$SKILL_MD" | sort -u); do
  [ -f "$SKILL_DIR/$r" ] || MISSING=$((MISSING + 1))
done
check "every reference the router names exists" "$MISSING" "0"

printf '\n%s passed, %s failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
