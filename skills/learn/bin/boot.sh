#!/usr/bin/env bash
#
# boot.sh -- the learner record's one-call session opening.
#
#   boot.sh <record-root>                   the boot digest
#   boot.sh <record-root> --check           exit 1 if the index is stale
#   boot.sh <record-root> --query <pred>    filter the same table
#   boot.sh <record-root> --card            the session-start name card
#
# This ships with the skill and never with the record. The record stays pure
# data, everything executable stays in one place, and the schema therefore has
# exactly one home. Dependency-free bash + awk on purpose: the record is a
# notebook, not a development environment, and it gets cloned onto whatever
# machine the learner happens to be sitting at.
#
# Everything printed below is DERIVED from the topic pages on every run.
# Nothing in the digest is stored anywhere, which is the only reason it cannot
# drift from the record. The stored fields are documented in
# ref/profile-schema.md; anything in that document's "derived -- never written"
# table appearing inside a file is a bug, not an input.

set -euo pipefail

RUSTY_DAYS=${LEARN_RUSTY_DAYS:-60}
STALE_GAP_DAYS=${LEARN_STALE_GAP_DAYS:-180}
WIP_CAP=${LEARN_WIP_CAP:-3}
HOUSEKEEP_DAYS=${LEARN_HOUSEKEEP_DAYS:-30}
# The card's window. Days bound it in practice; the row cap is what makes the
# ceiling assertable, because a burst week is not bounded by a date range.
CARD_DAYS=${LEARN_CARD_DAYS:-30}
CARD_ROWS=${LEARN_CARD_ROWS:-12}

BEGIN_MARK="<!-- BEGIN GENERATED INDEX -- edit the pages, not this block -->"
END_MARK="<!-- END GENERATED INDEX -->"
CARD_BEGIN="<!-- BEGIN CARD"
CARD_END="<!-- END CARD"
TAB="$(printf '\t')"

usage() { sed -n '3,8p' "$0" | sed 's/^#\{1,\} \{0,1\}//'; }

# -------------------------------------------------------------- arguments ---

ROOT=""; MODE=boot; PRED=""
while [ $# -gt 0 ]; do
  case "$1" in
    --check)   MODE=check; shift ;;
    --query)   MODE=query; PRED="${2-}"; shift; [ $# -gt 0 ] && shift ;;
    --card)    MODE=card; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "boot.sh: unknown option $1" >&2; exit 2 ;;
    *)         ROOT="$1"; shift ;;
  esac
done

if [ -z "$ROOT" ]; then
  echo "boot.sh: no record root given" >&2
  usage >&2
  exit 2
fi

# The one failure this script can see for itself: the setup pointer names a
# directory that is not there. It is never this script's job to seed a
# replacement -- a second record is the failure that silently halves a learning
# history -- so it reports, exits on a distinct code, and the caller stops.
if [ ! -d "$ROOT" ]; then
  echo "RECORD MISSING  $ROOT" >&2
  echo "The setup pointer names a directory that is not there. Stop, offer the" >&2
  echo "re-clone, and write nothing. Do not seed a second record." >&2
  exit 3
fi

ROOT="$(cd -- "$ROOT" && pwd)"
TOPICS="$ROOT/topics"
INDEX="$ROOT/INDEX.md"
LEVEL0="$ROOT/AGENTS.md"
TODAY="$(date +%Y-%m-%d)"

TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT
SCAN="$TMP/scan.tsv"

# ------------------------------------------------------------------ scan ---
#
# One pass over every topic page, producing the table that every mode reads.
# The frontmatter is flat by design, and that flatness is the entire reason
# this is awk rather than a YAML dependency. Both list spellings are accepted,
# inline `[a, b]` and block `- a`, because a human writes these pages by hand
# and will not be consistent about it.

AWK_SCAN='
function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
function unquote(s,   q) {
  s = trim(s)
  if (length(s) < 2) return s
  # The apostrophe is built rather than written: a hex escape is not in every
  # awk, and a literal one cannot survive the shell quoting around this program.
  q = sprintf("%c", 39)
  if (substr(s, 1, 1) == "\"" && substr(s, length(s), 1) == "\"") return substr(s, 2, length(s) - 2)
  if (substr(s, 1, 1) == q    && substr(s, length(s), 1) == q)    return substr(s, 2, length(s) - 2)
  return s
}
# Days since the civil epoch. Portable arithmetic on purpose: mktime is gawk
# only and `date -d` is GNU only, and age has to compute correctly on every
# host the record is ever cloned onto.
function daynum(y, m, d,   era, yoe, doy, doe) {
  y -= (m <= 2)
  era = int((y >= 0 ? y : y - 399) / 400)
  yoe = y - era * 400
  doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
  doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
  return era * 146097 + doe - 719468
}
function age(date,   p) {
  if (date == "") return 99999
  if (split(date, p, "-") != 3) return 99999
  return todaynum - daynum(p[1] + 0, p[2] + 0, p[3] + 0)
}
function nn(v) { return (v == "null" || v == "~") ? "" : v }

function flush(   r, ra, rp, ags, seen1, opens, i) {
  if (slug == "") return
  split(nn(f["reps"]) "", r, "/")
  ra = (r[1] == "" ? 0 : r[1] + 0)
  rp = (r[2] == "" ? 0 : r[2] + 0)
  ags = age(nn(f["last"]))
  seen1 = (seen_n > 0 ? seen[1] : "")
  opens = ""
  for (i = 1; i <= open_n; i++) opens = opens (i > 1 ? "," : "") open[i]
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%s\t%d\t%s\t%s\n",
    slug,
    (nn(f["status"])    == "" ? "gap"      : nn(f["status"])),
    (nn(f["track"])     == "" ? "-"        : nn(f["track"])),
    (nn(f["earned_by"]) == "" ? "asserted" : nn(f["earned_by"])),
    (nn(f["model"])     == "" ? "0" : "1"),
    nn(f["anchor"]), ra, rp, open_n,
    (nn(f["touches"]) == "" ? 0 : nn(f["touches"]) + 0),
    (nn(f["last"]) == "" ? "-" : nn(f["last"])), ags, seen1, opens
}

function reset(   p, n) {
  n = split(FILENAME, p, "/")
  slug = p[n]; sub(/\.md$/, "", slug)
  delete f; delete seen; delete open
  seen_n = 0; open_n = 0; infm = 0; curkey = ""
}

function pushlist(key, val,   items, i, n, v) {
  gsub(/^\[|\]$/, "", val)
  n = split(val, items, ",")
  for (i = 1; i <= n; i++) {
    v = unquote(items[i])
    if (v == "") continue
    if (key == "seen_in")   seen[++seen_n] = v
    if (key == "open_reps") open[++open_n] = v
  }
}

BEGIN { FS = "\n" }

FNR == 1 { flush(); reset(); if ($0 == "---") infm = 1; next }

infm && $0 == "---" { infm = 0; next }
!infm { next }

# A block-list continuation belongs to whichever key opened it.
/^[ \t]*-[ \t]+/ {
  if (curkey != "") {
    v = $0
    sub(/^[ \t]*-[ \t]+/, "", v)
    v = unquote(v)
    if (v != "") {
      if (curkey == "seen_in")   seen[++seen_n] = v
      if (curkey == "open_reps") open[++open_n] = v
    }
  }
  next
}

{
  i = index($0, ":")
  if (i == 0) next
  k = trim(substr($0, 1, i - 1))
  v = trim(substr($0, i + 1))
  if (k ~ /[^A-Za-z0-9_]/) next
  curkey = k
  if (v == "") next
  if (v ~ /^\[/) { pushlist(k, v); next }
  f[k] = unquote(v)
}

END { flush() }
'

AWK_DAYNUM='
function daynum(y, m, d,   era, yoe, doy, doe) {
  y -= (m <= 2)
  era = int((y >= 0 ? y : y - 399) / 400)
  yoe = y - era * 400
  doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
  doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
  return era * 146097 + doe - 719468
}
'

TODAYNUM="$(printf '%s\n' "$TODAY" | awk -F- "$AWK_DAYNUM"'{ print daynum($1 + 0, $2 + 0, $3 + 0) }')"

scan() {
  [ -d "$TOPICS" ] || return 0
  local files
  files="$(find "$TOPICS" -maxdepth 1 -name '*.md' ! -name 'INDEX.md' | LC_ALL=C sort)"
  [ -n "$files" ] || return 0
  printf '%s\n' "$files" | tr '\n' '\0' |
    xargs -0 awk -v todaynum="$TODAYNUM" "$AWK_SCAN"
}

scan > "$SCAN"
TOTAL="$(wc -l < "$SCAN" | tr -d ' ')"

# section <header> <rows-file> -- pad every column but the last to the widest
# entry in that column, so the digest scans as a table without being one. Two
# passes over the same small file; the first only measures.
section() {
  local hdr="$1" rows="$2" n
  n="$(wc -l < "$rows" | tr -d ' ')"
  if [ "$n" -eq 0 ]; then
    return 0
  fi
  printf '\n%s\n' "$hdr"
  awk -F'\t' '
    NR == FNR {
      for (i = 1; i <= NF; i++) if (length($i) > w[i]) w[i] = length($i)
      if (NF > cols) cols = NF
      next
    }
    {
      line = "  "
      for (i = 1; i <= NF; i++) {
        line = line (i < cols ? sprintf("%-*s  ", w[i], $i) : $i)
      }
      print line
    }' "$rows" "$rows"
}

# ------------------------------------------------------------------ card ---
#
# The name card: the smallest payload that tells an agent who it is working
# with, for a SHIPPING session that cannot afford the skill body. It is not a
# smaller digest -- it is a different question. The digest answers "where were
# we", the card answers "who is this".
#
# Two terms and nothing else, because measurement said so. The hand-written
# Level 0 page is ~694 tokens and CONSTANT at every record size, so trimming
# topic rows while it is uncut achieves nothing; an anchors-plus-mission subset
# of it is ~178. And nothing else in the digest is bounded -- the active list
# grows monotonically because an abandoned learning thread never retires, and a
# complete owned list is strictly linear in record size with no cap available,
# since completeness is the only thing it is for. A recent-activity window is
# the one term bounded in practice: bounded by how much the learner touches,
# not by how much they have learned.
#
# READ-ONLY, and early on purpose. This runs at the start of sessions the
# learner never opened a mentoring skill for, in repositories that have nothing
# to do with the record. Regenerating the index from there would write to the
# record on every unrelated session start; the digest is where that belongs.

if [ "$MODE" = card ]; then
  # The page subset is delimited by explicit markers, never found by heading
  # name. Heading-matching fails silently -- rename a heading and the card
  # quietly empties, everything keeps working, and the nudges just get worse
  # with nothing to announce it. A marker is assertable; a heading is a guess.
  HAVE_MARKERS=0
  if [ -f "$LEVEL0" ] && grep -Fq "$CARD_BEGIN" "$LEVEL0" && grep -Fq "$CARD_END" "$LEVEL0"; then
    HAVE_MARKERS=1
  fi

  echo "LEARNER — name card"
  if [ "$HAVE_MARKERS" -eq 1 ]; then
    # Every marked span, in file order, verbatim. Several spans are allowed so
    # a record adds markers where the material already sits, instead of moving
    # a human's page around to make one contiguous region.
    awk -v b="$CARD_BEGIN" -v e="$CARD_END" '
      index($0, b) == 1 { on = 1; if (any) print ""; next }
      index($0, e) == 1 { on = 0; next }
      on { print ($0 == "" ? "" : "  " $0); any = 1 }' "$LEVEL0"
  else
    # Loud, and on stdout where the agent will actually see it. The whole point
    # of markers is that their absence cannot pass for an empty card.
    echo "  ⚠ This record's page carries no card markers, so the card has no"
    echo "    who-is-this half — only the window below. The next housekeeping"
    echo "    pass adds them; it is the only writer of that page."
  fi

  # The status column carries `never-said-back` when the topic was never
  # explained aloud. It is the one field of the digest's judgement the card
  # cannot derive for itself, and the thing a nudge most needs to know: a topic
  # that has only ever been read at the learner is not safe to build on, however
  # recently it was touched.
  awk -F'\t' -v OFS='\t' -v d="$CARD_DAYS" '$12 <= d {
      print $12, $1, $3, ($4 == "asserted" ? $2 " · never-said-back" : $2), $7 "/" $8, $12 "d", ($13 == "" ? "-" : $13)
    }' "$SCAN" | LC_ALL=C sort -t"$TAB" -k1,1n -k2,2 | cut -f2- > "$TMP/window.all"
  WINDOW_N="$(wc -l < "$TMP/window.all" | tr -d ' ')"
  head -n "$CARD_ROWS" "$TMP/window.all" > "$TMP/window"
  SHOWN_N="$(wc -l < "$TMP/window" | tr -d ' ')"

  CARD_HDR="RECENT — touched in the last ${CARD_DAYS}d ($WINDOW_N)"
  if [ "$SHOWN_N" -lt "$WINDOW_N" ]; then
    CARD_HDR="RECENT — touched in the last ${CARD_DAYS}d (newest $SHOWN_N of $WINDOW_N)"
  fi
  # A row carries its track and one recognition handle, never a bare slug:
  # `watermarks` means one thing in stream processing and another in image
  # work, and an agent guessing wrong nudges about the wrong topic. The slug
  # itself stays untouched -- it is the identifier the anchor graph points at,
  # so renaming it is a graph migration where widening the row is free.
  if [ "$WINDOW_N" -eq 0 ]; then
    # An empty window is a fact about the last few weeks, not a broken card, so
    # it is stated rather than left as a missing section.
    printf '\n%s\n' "$CARD_HDR"
    printf '  %s\n' "nothing touched in this window"
  else
    section "$CARD_HDR" "$TMP/window"
  fi

  # The line that makes the small payload safe. Never conclude a topic is new
  # from its absence here; when certainty is needed, the query mode is free.
  printf '\n%s\n' "This is a recent window, not the record ($TOTAL topics). A topic missing"
  printf '%s\n' "here is one that has not been touched lately, never one that is new. For"
  printf '%s\n' "certainty, ask the record: boot.sh <record root> --query all"
  exit 0
fi


# ----------------------------------------------------------------- index ---
#
# The generated router. It *is* the aggregate table, so no second store exists;
# if it ever outgrows awk it is a markdown table DuckDB reads as-is, which is
# zero migration and the reason this cannot be got wrong now.

render_index() {
  printf '%s\n\n' "$BEGIN_MARK"
  printf '| topic | status | track | reps | open | last | anchor | seen in |\n'
  printf '|---|---|---|---|---|---|---|---|\n'
  LC_ALL=C sort -t"$TAB" -k1,1 "$SCAN" | awk -F'\t' '
    function cell(s) { gsub(/\|/, "\\|", s); return (s == "" ? "-" : s) }
    { printf "| [%s](topics/%s.md) | %s | %s | %d/%d | %d | %s | %s | %s |\n",
        $1, $1, cell($2), cell($3), $7, $8, $9, cell($11), cell($6), cell($13) }'
  printf '\n%s\n' "$END_MARK"
}

scaffold_index() {
  cat > "$INDEX" <<EOF
# Index

Generated from the frontmatter of every page in \`topics/\`. Edit the pages,
never this block -- it is rewritten whenever a session boots against a changed
record, so nothing here is a source of truth.

$BEGIN_MARK
$END_MARK
EOF
}

STALE=0

splice_index() {
  local needs_scaffold=0
  if [ ! -f "$INDEX" ]; then
    needs_scaffold=1
  elif ! grep -Fq "$BEGIN_MARK" "$INDEX" || ! grep -Fq "$END_MARK" "$INDEX"; then
    needs_scaffold=1
  fi

  if [ "$needs_scaffold" -eq 1 ]; then
    if [ "$MODE" = check ]; then
      echo "FAIL  INDEX.md is missing or has lost its generated-block markers" >&2
      STALE=1
      return 0
    fi
    scaffold_index
  fi

  local blk="$TMP/block.md" out="$TMP/index.md"
  render_index > "$blk"
  awk -v begin="$BEGIN_MARK" -v end="$END_MARK" -v block="$blk" '
    index($0, begin) == 1 { while ((getline line < block) > 0) print line; skip = 1; next }
    index($0, end)   == 1 { skip = 0; next }
    !skip
  ' "$INDEX" > "$out"

  if cmp -s "$out" "$INDEX"; then
    return 0
  fi
  if [ "$MODE" = check ]; then
    echo "FAIL  INDEX.md is stale -- a boot regenerates it" >&2
    STALE=1
    return 0
  fi
  # Concurrent regeneration is harmless: the block is a pure function of the
  # pages, so two sessions racing here write byte-identical output.
  cat -- "$out" > "$INDEX"
}

splice_index

if [ "$MODE" = check ]; then
  if [ "$STALE" -ne 0 ]; then
    exit 1
  fi
  echo "ok    INDEX.md is current ($TOTAL topics)"
  exit 0
fi

# ----------------------------------------------------------------- query ---
#
# A filter over the same scan -- same script, same table, no second store.
# Terms are ANDed: `owned & last>60d`.
#
# The scan is read twice. The first pass only collects which slugs exist, which
# is what `broken-anchor` needs and no other term does: a dangling edge is not a
# property of the row, it is a property of the row against the whole record. The
# boot's warning line counts the same thing; this is where you find out *which*
# pages it is counting, and repairing them is impossible without that list.

if [ "$MODE" = query ]; then
  if [ -z "$PRED" ]; then
    echo "boot.sh: --query needs a predicate (try: all)" >&2
    exit 2
  fi
  awk -F'\t' -v pred="$PRED" -v rusty="$RUSTY_DAYS" '
    function fail(m) { print "boot.sh: " m > "/dev/stderr"; bad = 1; exit 2 }
    function match_term(t,   k, v, i) {
      if (t == "all")                   return 1
      if (t ~ /^(gap|learning|owned)$/) return ($2 == t)
      if (t == "rusty")                 return ($2 == "owned" && $12 > rusty)
      if (t == "unverified")            return ($4 == "asserted")
      if (t == "active")                return ($2 == "learning" && $9 > 0)
      if (t == "broken-anchor")         return ($6 != "" && !($6 in have))
      if (t ~ /^last>[0-9]+d$/) { v = t; gsub(/[^0-9]/, "", v); return ($12 > v + 0) }
      if (t ~ /^last<[0-9]+d$/) { v = t; gsub(/[^0-9]/, "", v); return ($12 < v + 0) }
      i = index(t, "=")
      if (i > 0) {
        k = substr(t, 1, i - 1); v = substr(t, i + 1)
        if (k == "status")    return ($2 == v)
        if (k == "track")     return ($3 == v)
        if (k == "earned_by") return ($4 == v)
        if (k == "anchor")    return ($6 == v)
      }
      fail("unknown predicate term: " t)
    }
    BEGIN {
      n = split(pred, terms, "&")
      for (i = 1; i <= n; i++) gsub(/^[ \t]+|[ \t]+$/, "", terms[i])
      printf "%-28s %-9s %-16s %-6s %-11s %s\n", "topic", "status", "track", "reps", "last", "age"
    }
    NR == FNR { have[$1]; next }
    {
      for (i = 1; i <= n; i++) if (!match_term(terms[i])) next
      printf "%-28s %-9s %-16s %-6s %-11s %dd\n", $1, $2, $3, $7 "/" $8, $11, $12
      hits++
    }
    END { if (!bad) printf "\n%d of %d topics\n", hits + 0, FNR }
  ' "$SCAN" "$SCAN"
  exit 0
fi

# ------------------------------------------------------------------ boot ---

echo "LEARNER"
if [ -f "$LEVEL0" ]; then
  # Level 0, verbatim. This is the pseudo-preload: the harness will never load
  # the record's own instruction file, because the record is never the repo the
  # session was spawned in, so the script emits what a preload would have.
  # The card markers are machinery for the other mode; a mentoring session gets
  # the whole page and has no use for the boundary inside it.
  awk -v b="$CARD_BEGIN" -v e="$CARD_END" '
       NR == 1 && $0 == "---" { fm = 1; next }
       fm && $0 == "---"      { fm = 0; next }
       index($0, b) == 1 || index($0, e) == 1 { next }
       !fm                    { print ($0 == "" ? "" : "  " $0) }' "$LEVEL0"
else
  echo "  No Level 0 yet -- this record has never been told who the learner is."
  echo "  It is written during housekeeping, never during a learning session."
fi

# ACTIVE -- learning, with open reps, most recently touched first. This is
# where a session resumes by default, and the seen_in fragment is what makes a
# topic recognisable without hydrating its page.
awk -F'\t' -v OFS='\t' '$2 == "learning" && $9 > 0 {
    print $1, $7 "/" $8, $12 "d", ($13 == "" ? "-" : $13), $11
  }' "$SCAN" | LC_ALL=C sort -t"$TAB" -k5,5r | cut -f1-4 > "$TMP/active"
ACTIVE_N="$(wc -l < "$TMP/active" | tr -d ' ')"

# The cap is a nudge, not a gate: active foci are derived, so there is no list
# to be full and nothing to enforce. Over the cap, prefer closing rep debt to
# opening a new topic -- capturing is cheap, opening is spend.
ACTIVE_HDR="ACTIVE — learning, open reps ($ACTIVE_N)"
if [ "$ACTIVE_N" -gt "$WIP_CAP" ]; then
  ACTIVE_HDR="ACTIVE — learning, open reps ($ACTIVE_N) — cap is $WIP_CAP"
fi
section "$ACTIVE_HDR" "$TMP/active"

# RUSTY -- owned, and gone cold. An instruction, not decoration: probe before
# building on any of these.
awk -F'\t' -v OFS='\t' -v d="$RUSTY_DAYS" '$2 == "owned" && $12 > d {
    print $1, $12 "d", "probe first", $12
  }' "$SCAN" | LC_ALL=C sort -t"$TAB" -k4,4nr | cut -f1-3 > "$TMP/rusty"
RUSTY_N="$(wc -l < "$TMP/rusty" | tr -d ' ')"
section "RUSTY — owned, untouched >${RUSTY_DAYS}d ($RUSTY_N)" "$TMP/rusty"

# UNVERIFIED -- never said back in the learner's own words, however recent the
# date looks. No date rescues an asserted topic.
awk -F'\t' -v OFS='\t' '$4 == "asserted" {
    print $1, "asserted", $11, $12
  }' "$SCAN" | LC_ALL=C sort -t"$TAB" -k4,4nr | cut -f1-3 > "$TMP/unverified"
UNVERIFIED_N="$(wc -l < "$TMP/unverified" | tr -d ' ')"
section "UNVERIFIED — never explained aloud ($UNVERIFIED_N)" "$TMP/unverified"

# The total is what keeps the boot bounded a year in: the ledger grows forever,
# the payload does not.
printf '\n%s topics total. Full ledger: boot.sh %s --query all\n' "$TOTAL" "$ROOT"

# ------------------------------------------------------------ housekeeping ---
#
# One line, and ignorable. Backlog is not an emergency; only a broken anchor is
# genuine corruption, because it is an edge the adjacency ranking walks into
# and falls off.

STALE_GAP_N="$(awk -F'\t' -v d="$STALE_GAP_DAYS" '$2 == "gap" && $12 > d' "$SCAN" | wc -l | tr -d ' ')"
BROKEN_N="$(awk -F'\t' 'NR == FNR { have[$1]; next } $6 != "" && !($6 in have)' "$SCAN" "$SCAN" | wc -l | tr -d ' ')"

if [ "$((UNVERIFIED_N + RUSTY_N + STALE_GAP_N + BROKEN_N))" -gt 0 ]; then
  ANCHOR_WORD="broken anchors"
  if [ "$BROKEN_N" -eq 1 ]; then
    ANCHOR_WORD="broken anchor"
  fi
  printf '\n⚠ %s unverified · %s rusty · %s gap >%sd · %s %s\n' \
    "$UNVERIFIED_N" "$RUSTY_N" "$STALE_GAP_N" "$STALE_GAP_DAYS" "$BROKEN_N" "$ANCHOR_WORD"

  # The one date this script cannot derive from the pages. It is read from
  # Level 0 -- written only by housekeeping, the very session that would update
  # it -- so it stays optional and non-load-bearing rather than becoming a
  # stored counter that drifts.
  HK=""
  if [ -f "$LEVEL0" ]; then
    HK="$(awk 'NR == 1 && $0 == "---" { fm = 1; next }
               fm && $0 == "---" { exit }
               fm && /^housekept:/ {
                 sub(/^housekept:[ \t]*/, "")
                 gsub(/[^0-9-]/, "")
                 print; exit
               }' "$LEVEL0")"
  fi

  if [ -n "$HK" ]; then
    HK_AGE="$(printf '%s\n%s\n' "$TODAY" "$HK" | awk -F- "$AWK_DAYNUM"'
      NR == 1 { t = daynum($1 + 0, $2 + 0, $3 + 0); next }
      NR == 2 { print t - daynum($1 + 0, $2 + 0, $3 + 0) }')"
    if [ "$BROKEN_N" -gt 0 ] || [ "${HK_AGE:-0}" -gt "$HOUSEKEEP_DAYS" ]; then
      printf '  housekeeping run suggested (last: %sd)\n' "$HK_AGE"
    fi
  elif [ "$BROKEN_N" -gt 0 ]; then
    printf '  housekeeping run suggested — a broken anchor is real corruption\n'
  fi
fi
