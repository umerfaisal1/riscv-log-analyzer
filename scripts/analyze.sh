#!/bin/bash

set -euo pipefail

OUTPUT_FILE=""

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

write() {
    if [ -n "$OUTPUT_FILE" ]; then
        echo "$1" >> "$OUTPUT_FILE"
    else
        echo "$1"
    fi
}

if [ -n "$OUTPUT_FILE" ]; then
    > "$OUTPUT_FILE"
fi

if [ $# -lt 1 ]; then
echo "Usage: $0 <logfile>"
exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            LOGFILE="$1"
            shift
            ;;
    esac
done

if [ ! -f "$LOGFILE" ]; then
echo "[ERROR] File not found: $LOGFILE"
exit 1
fi 

PASS_COUNT=$(grep -c "TEST PASS:" "$LOGFILE" || true)

FAIL_COUNT=$(grep -c "TEST FAIL:" "$LOGFILE" || true)

SKIP_COUNT=$(grep -c "TEST SKIP:" "$LOGFILE" || true)

TOTAL_TESTS=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))


PASS_PERCENT=$(awk "BEGIN { printf \"%.1f\", ($PASS_COUNT/$TOTAL_TESTS)*100 }")
FAIL_PERCENT=$(awk "BEGIN { printf \"%.1f\", ($FAIL_COUNT/$TOTAL_TESTS)*100 }")
SKIP_PERCENT=$(awk "BEGIN { printf \"%.1f\", ($SKIP_COUNT/$TOTAL_TESTS)*100 }")

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


write "=== RISC-V Simulation Log Analysis ==="
write "Log file: $LOGFILE"
write "Analysis date: $(date '+%Y-%m-%d %H:%M:%S')"



write "---Results Summary---"


write "Total tests: $TOTAL_TESTS"
write "Passed: $PASS_COUNT (${PASS_PERCENT}%)"
write "Failed: $FAIL_COUNT (${FAIL_PERCENT}%)"
write "Skipped: $SKIP_COUNT (${SKIP_PERCENT}%)"


if [ "$FAIL_COUNT" -gt 0 ]; then
write "---Failed Tests---"
FAILED_TESTS=$(grep "TEST FAIL:" "$LOGFILE" | awk '{print $5}' | nl -w2 -s". ")
write "$FAILED_TESTS"
fi



write "--- Timing Statistics ---"
write "MIN TIME: ${MIN_TIME}s"
write "MAX TIME: ${MAX_TIME}s"
write "AVG TIME: ${AVG_TIME}s"


if [ "$FAIL_COUNT" -gt 0 ]; then
write "---Verdict: FAIL---";
exit 1
fi

write "---Verdict: PASS---";
