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

if [[ "${1:-}" == "--help" ]]; then
    print_help
    exit 0
fi

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


if [ "$FAIL_COUNT" -gt 0 ]; then
echo "---Failed Tests---"
FAILED_TESTS=$(grep "TEST FAIL:" "$LOGFILE" | awk '{print $5}' | nl -w2 -s". ")
echo "$FAILED_TESTS"
fi

# Extract execution times (only PASS and FAIL lines)
mapfile -t TIMES < <(
grep -E "TEST (PASS|FAIL):" "$LOGFILE" \
| grep -oE '[0-9]+\.[0-9]+s' \
| tr -d 's'
)

if [ ${#TIMES[@]} -eq 0 ]; then
    MIN_TIME=0
    MAX_TIME=0
    AVG_TIME=0
else

    MIN_TIME=${TIMES[0]}
    MAX_TIME=${TIMES[0]}
    SUM=0


    for t in "${TIMES[@]}"; do
        # compare min
        if (( $(echo "$t < $MIN_TIME" | bc -l) )); then
            MIN_TIME=$t
        fi

        # compare max
        if (( $(echo "$t > $MAX_TIME" | bc -l) )); then
            MAX_TIME=$t
        fi

        # sum
        SUM=$(echo "$SUM + $t" | bc)
    done

        AVG_TIME=$(echo "scale=2; $SUM / ${#TIMES[@]}" | bc)

fi

echo "--- Timing Statistics ---"
echo "MIN TIME: ${MIN_TIME}s"
echo "MAX TIME: ${MAX_TIME}s"
echo "AVG TIME: ${AVG_TIME}s"


if [ "$FAIL_COUNT" -gt 0 ]; then
echo "---Verdict: FAIL---";
exit 1
fi

echo "---Verdict: PASS---";
