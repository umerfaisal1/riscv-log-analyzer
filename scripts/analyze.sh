#!/bin/bash

set -euo pipefail

print_help() {
echo "
Usage:
  analyze.sh <logfile> [options]

Options:
  --format text|csv
  --output <path>
  --verbose
  --help
  "

}

if [ $# -lt 1 ]; then
echo "Usage: $0 <logfile>"
exit 1
fi

LOGFILE="$1"

if [ ! -f "$LOGFILE" ]; then
echo "[ERROR] File not found: $LOGFILE"
exit 1
fi 

echo "=== RISC-V Simulation Log Analysis ==="
echo "Log file: $LOGFILE"
echo "Analysis date: $(date '+%Y-%m-%d %H:%M:%S')"
echo


echo "---Results Summary---"

PASS_COUNT=$(grep -c "TEST PASS:" "$LOGFILE" || true)

FAIL_COUNT=$(grep -c "TEST FAIL:" "$LOGFILE" || true)

SKIP_COUNT=$(grep -c "TEST SKIP:" "$LOGFILE" || true)

TOTAL_TESTS=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
echo "Total tests: $TOTAL_TESTS"

PASS_PERCENT=$(awk "BEGIN { printf \"%.1f\", ($PASS_COUNT/$TOTAL_TESTS)*100 }")
FAIL_PERCENT=$(awk "BEGIN { printf \"%.1f\", ($FAIL_COUNT/$TOTAL_TESTS)*100 }")
SKIP_PERCENT=$(awk "BEGIN { printf \"%.1f\", ($SKIP_COUNT/$TOTAL_TESTS)*100 }")

echo "Passed: $PASS_COUNT (${PASS_PERCENT}%)"
echo "Failed: $FAIL_COUNT (${FAIL_PERCENT}%)"
echo "Skipped: $SKIP_COUNT (${SKIP_PERCENT}%)"


if [ $FAIL_COUNT -gt 0 ]; then
echo "---Failed Tests---"
FAILED_TESTS=$(grep "TEST FAIL:" "$LOGFILE" | awk '{print $5}' | nl -w2 -s". ")
echo "$FAILED_TESTS"
fi

if [ $FAIL_COUNT -gt 0 ]; then
echo "---Verdict: FAIL---";
exit 1
fi

echo "---Verdict: PASS---";
