#!/usr/bin/env bash
# Prints release notes for files under assets/ changed since the latest tag, grouped by mod.
set -euo pipefail

PREV_TAG="$(git describe --tags --abbrev=0)"

echo "### Date: $(date +%d.%m.%Y)"
for entry in A:Added M:Changed D:Removed; do
  FILES="$(git diff --name-only --no-renames --diff-filter="${entry%%:*}" "refs/tags/$PREV_TAG" HEAD -- assets)"
  [[ -z "$FILES" ]] && continue
  printf '\n#### %s\n\n' "${entry#*:}"
  # git sorts paths, so files of one mod are adjacent and join into one line
  echo "$FILES" | awk -F/ '{
    f = $0
    sub("^assets/[^/]+/(textures/)?", "", f)
    sub(/\.png$/, "", f)
    if ($2 != mod) { if (mod != "") print line; mod = $2; line = "- " mod ": " f }
    else line = line ", " f
  } END { if (mod != "") print line }'
done
