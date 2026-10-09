#!/usr/bin/env bash
# extract_changelog.sh — print the CHANGELOG section for one version.
#
# Purpose: release.yaml uses this to build GitHub Release notes and to refuse
# a release whose version has no CHANGELOG entry.
#
# Usage: .github/scripts/extract_changelog.sh <version> [changelog_path]
#   Prints the lines after the exact header "## <version>" up to the next
#   "## " header (or EOF), trimmed of leading/trailing blank lines.
#   Exits 1 with an error on stderr if the section is missing or empty.
set -euo pipefail

version="${1:?usage: extract_changelog.sh <version> [changelog_path]}"
changelog="${2:-CHANGELOG.md}"

# Exact string match on the header (no regex), so 0.1.0+1 and 0.10.0 never
# collide with 0.1.0.
body=$(awk -v h="## ${version}" '$0==h{f=1;next} f&&/^## /{exit} f{print}' "$changelog" \
  | sed -e '/./,$!d')  # drop leading blank lines; $(...) drops trailing ones

if [ -z "$body" ]; then
  echo "CHANGELOG.md has no \"## ${version}\" section" >&2
  exit 1
fi

printf '%s\n' "$body"
