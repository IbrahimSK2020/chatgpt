#!/usr/bin/env bash
set -euo pipefail
SOLUTION_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM
python3 -m zipfile -e "$SOLUTION_DIR/developer-bundle.zip" "$TMP_DIR/unpacked"
ORACLE="$(find "$TMP_DIR/unpacked" -type f -path '*/oracle/oracle.py' -print -quit)"
if [ -z "$ORACLE" ]; then
  echo "REFERENCE_SOLUTION_ERROR: developer bundle does not contain oracle/oracle.py" >&2
  exit 2
fi
mkdir -p /app
python3 "$ORACLE" --output /app/submission.json
