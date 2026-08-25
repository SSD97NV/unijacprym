#!/bin/sh
set -eu

fail()
{
  printf '%s\n' "verification failed: $*" >&2
  exit 1
}

require_command()
{
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$repository_root"

require_command git
require_command lake
require_command awk
require_command grep
require_command Singular

[ -f lake-manifest.json ] || fail "the committed lake-manifest.json is missing"
git diff --quiet HEAD -- lake-manifest.json ||
  fail "lake-manifest.json differs from the committed dependency state"

temporary_directory=$(mktemp -d "${TMPDIR:-/tmp}/unijacprym-verify.XXXXXX")
manifest_snapshot="$temporary_directory/lake-manifest.json"
source_scan="$temporary_directory/source-scan.txt"
axiom_output="$temporary_directory/axioms.txt"
cp lake-manifest.json "$manifest_snapshot"

cleanup()
{
  rm -rf "$temporary_directory"
}
trap cleanup EXIT HUP INT TERM

scan_lean_sources()
{
  description=$1
  pattern=$2
  scan_status=0
  git grep -nE "$pattern" -- '*.lean' >"$source_scan" || scan_status=$?
  case "$scan_status" in
    0)
      printf '%s\n' "forbidden $description found in Lean source:" >&2
      cat "$source_scan" >&2
      return 1
      ;;
    1)
      return 0
      ;;
    *)
      fail "git grep failed while scanning for $description"
      ;;
  esac
}

printf '%s\n' '=== Tool versions ==='
lake --version
lake env lean --version
Singular --version

printf '%s\n' '=== Lean source trust scan ==='
scan_lean_sources 'proof placeholder (sorry or admit)' \
  '(^|[^[:alnum:]_])(sorry|admit)([^[:alnum:]_]|$)' || exit 1
scan_lean_sources 'custom axiom declaration' \
  '(^|[^[:alnum:]_])(axiom|constant)([^[:alnum:]_]|$)|^[[:space:]]*(axioms|constants)[[:space:]]' ||
  exit 1

printf '%s\n' '=== Lean build ==='
lake build

printf '%s\n' '=== Thesis-facing axiom audit ==='
if ! lake env lean verification/AxiomScan.lean >"$axiom_output" 2>&1; then
  cat "$axiom_output" >&2
  fail "Lean could not evaluate verification/AxiomScan.lean"
fi
cat "$axiom_output"

for declaration in \
  PrymLean.universalNode_matrixFactorization \
  PrymLean.universalNode_presentationFittingOne \
  PrymLean.contactDefect_relation_redundant \
  PrymLean.contactOdd_square_eq_principal_mul_defect \
  PrymLean.contactOdd_even_powers \
  PrymLean.eulerCharacteristic_plus_modEq_iff \
  PrymLean.eulerCharacteristic_minus_modEq_iff \
  PrymLean.centralCurve_schurComplement_certificate \
  PrymLean.moduleCurve_schurComplement_certificate
do
  grep -Fq "'$declaration'" "$axiom_output" ||
    fail "missing axiom report for $declaration"
done

awk '
  BEGIN {
    expected = 9
    seen = 0
    bad = 0
  }

  /depends on axioms:/ {
    seen++
    line = $0
    sub(/^.*depends on axioms: \[/, "", line)
    sub(/\].*$/, "", line)
    count = split(line, names, ",")
    for (i = 1; i <= count; i++) {
      name = names[i]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
      if (name != "propext" && name != "Classical.choice" && name != "Quot.sound") {
        print "unexpected axiom: " name > "/dev/stderr"
        bad = 1
      }
    }
    next
  }

  /does not depend on any axioms/ {
    seen++
    next
  }

  END {
    if (seen != expected) {
      print "expected " expected " axiom results, found " seen > "/dev/stderr"
      bad = 1
    }
    exit bad
  }
' "$axiom_output" || fail "the axiom allowlist audit did not pass"

printf '%s\n' '=== Singular checks ==='
sh scripts/run_singular_checks.sh

cmp -s "$manifest_snapshot" lake-manifest.json ||
  fail "verification changed lake-manifest.json"
git diff --quiet HEAD -- lake-manifest.json ||
  fail "verification changed the committed dependency state"

printf '%s\n' 'ALL VERIFICATION STEPS PASSED'
