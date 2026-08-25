#!/bin/sh
set -eu

fail()
{
  printf '%s\n' "manifest generation failed: $*" >&2
  exit 1
}

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repository_root"

command -v git >/dev/null 2>&1 || fail "git is required"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
  fail "run this script from a Git checkout"

temporary_directory=$(mktemp -d "${TMPDIR:-/tmp}/unijacprym-manifest.XXXXXX")
file_list="$temporary_directory/files"
new_manifest="$temporary_directory/MANIFEST.sha256"

cleanup()
{
  rm -rf "$temporary_directory"
}
trap cleanup EXIT HUP INT TERM

# Git's index defines the curated release.  The manifest excludes itself so
# that rerunning this script is deterministic after MANIFEST.sha256 is tracked.
LC_ALL=C git ls-files -z -- . ':(exclude)MANIFEST.sha256' >"$file_list"
[ -s "$file_list" ] || fail "the Git index contains no release files"

if command -v shasum >/dev/null 2>&1; then
  xargs -0 shasum -a 256 <"$file_list" >"$new_manifest"
elif command -v sha256sum >/dev/null 2>&1; then
  xargs -0 sha256sum <"$file_list" >"$new_manifest"
else
  fail "neither shasum nor sha256sum is available"
fi

mv "$new_manifest" MANIFEST.sha256
printf '%s\n' 'Wrote MANIFEST.sha256 for all tracked release files.'
