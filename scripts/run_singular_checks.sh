#!/bin/sh
set -eu

fail()
{
  printf '%s\n' "Singular verification failed: $*" >&2
  exit 1
}

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repository_root"

command -v Singular >/dev/null 2>&1 || fail "Singular is not installed"

temporary_directory=$(mktemp -d "${TMPDIR:-/tmp}/unijacprym-singular.XXXXXX")
singular_output="$temporary_directory/output.txt"

cleanup()
{
  rm -rf "$temporary_directory"
}
trap cleanup EXIT HUP INT TERM

singular_status=0
if [ -n "${UNIJACPRYM_RELEASE_LABEL:-}" ]; then
  Singular -q --no-rc --user-option="$UNIJACPRYM_RELEASE_LABEL" \
    singular/contact_fitting_blowup_checks.sing \
    >"$singular_output" 2>&1 || singular_status=$?
else
  Singular -q --no-rc singular/contact_fitting_blowup_checks.sing \
    >"$singular_output" 2>&1 || singular_status=$?
fi
cat "$singular_output"

[ "$singular_status" -eq 0 ] ||
  fail "the Singular process exited with status $singular_status"

failure_status=0
grep -n '^FAIL:' "$singular_output" >&2 || failure_status=$?
case "$failure_status" in
  0)
    fail "the certificate reported a failed assertion"
    ;;
  1)
    ;;
  *)
    fail "could not inspect the Singular output"
    ;;
esac

last_nonempty_line=$(awk 'NF { line = $0 } END { print line }' "$singular_output")
[ "$last_nonempty_line" = 'ALL SINGULAR CHECKS PASSED' ] ||
  fail "the final success sentinel is missing"
