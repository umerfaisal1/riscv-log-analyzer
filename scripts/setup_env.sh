#!/bin/bash

set -euo pipefail

TOOLS=(bash grep awk sed bc)

for tool in "${TOOLS[@]}"; do

if which "$tool" > /dev/null; then
echo "[AVAILABLE] $tool"
else
echo "[NOT AVAILABLE] $tool"
echo "Setup failed"
exit 1
fi
done

echo "All tools are available"