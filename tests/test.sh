#!/usr/bin/env bash
set -uo pipefail

REWARD_DIR=/logs/verifier
REWARD_FILE="$REWARD_DIR/reward.txt"
mkdir -p "$REWARD_DIR"
printf '0\n' > "$REWARD_FILE"

SUBMISSION="${1:-/app/submission.json}"
TEST_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
TMP_DIR="$(mktemp -d)" || exit 1
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

fail() {
  printf '0\n' > "$REWARD_FILE"
  echo "FAIL: $*" >&2
  exit 1
}

[ -s "$SUBMISSION" ] || fail "missing or empty submission at $SUBMISSION"
python3 -m zipfile -e "$TEST_DIR/developer-bundle.zip" "$TMP_DIR/unpacked" || fail "could not unpack developer bundle"
VERIFY="$(find "$TMP_DIR/unpacked" -type f -path '*/verifier/verify.py' -print -quit)"
[ -n "$VERIFY" ] || fail "developer bundle does not contain verifier/verify.py"
PROJECT_DIR="$(dirname -- "$(dirname -- "$VERIFY")")"
INPUT="$PROJECT_DIR/data/task_input.json"
KEY="$PROJECT_DIR/oracle/reference_answers.json"
SCHEMA="$PROJECT_DIR/schemas/submission.schema.json"
[ -f "$INPUT" ] && [ -f "$KEY" ] && [ -f "$SCHEMA" ] || fail "developer bundle is missing required verifier inputs"

SCHEMA_OK=1
if [ -f "$PROJECT_DIR/verifier/schema_check.py" ]; then
  python3 "$PROJECT_DIR/verifier/schema_check.py" "$SUBMISSION" "$SCHEMA"
  [ "$?" -eq 0 ] || SCHEMA_OK=0
fi

python3 "$VERIFY" "$SUBMISSION" --input "$INPUT" --key "$KEY" --report "$TMP_DIR/report.json"
VERIFY_EXIT=$?
if [ ! -s "$TMP_DIR/report.json" ]; then
  fail "verifier did not produce a report (exit $VERIFY_EXIT)"
fi

python3 - "$TMP_DIR/report.json" "$REWARD_FILE" "$SCHEMA_OK" <<'PY'
import json, sys
report_path, reward_path, schema_ok = sys.argv[1:]
try:
    report = json.load(open(report_path, encoding="utf-8"))
    score = float(report.get("score", 0.0))
    score = max(0.0, min(100.0, score)) / 100.0
    if schema_ok != "1":
        score = 0.0
except Exception:
    score = 0.0
with open(reward_path, "w", encoding="utf-8") as f:
    f.write(f"{score:.4f}\n")
print(f"Harbor reward: {score:.4f}")
PY

cat "$TMP_DIR/report.json"
[ "$SCHEMA_OK" -eq 1 ] || exit 1
[ "$VERIFY_EXIT" -eq 0 ] || exit 1
