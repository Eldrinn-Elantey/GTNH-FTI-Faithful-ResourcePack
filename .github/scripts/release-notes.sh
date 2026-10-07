#!/usr/bin/env bash
# Prints release notes for files under assets/ changed since the latest tag, grouped by mod.
set -euo pipefail

PREV_TAG="$(git describe --tags --abbrev=0)"

echo "### Date: $(date +%d.%m.%Y)"
for entry in A:Added M:Changed D:Removed; do
  FILES="$(git diff --name-only --no-renames --diff-filter="${entry%%:*}" "refs/tags/$PREV_TAG" HEAD -- assets)"
  [[ -z "$FILES" ]] && continue
  printf '\n#### %s\n\n' "${entry#*:}"
  # git sorts paths, so files of one mod are adjacent and go into one collapsible block
  echo "$FILES" | awk -F/ '
    function flush() { if (mod != "") printf "<details><summary>%s (%d)</summary>\n\n%s\n</details>\n\n", mod, n, list }
    {
      f = $0
      sub("^assets/[^/]+/(textures/)?", "", f)
      sub(/\.png$/, "", f)
      if ($2 != mod) { flush(); mod = $2; n = 0; list = "" }
      n++
      list = list "- " f "\n"
    }
    END { flush() }'
done
