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

**The mission.** Stop being the person who can fix it but not explain it.
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

printf '\n%s passed, %s failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
