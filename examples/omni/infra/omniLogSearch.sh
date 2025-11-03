#!/bin/bash
set -euo pipefail

echo "=== 1. FINDING FIRST MACHINE ID ==="
MACHINE_ID=$(omnictl get machine -o jsonpath='{.items[0].metadata.id}' 2>/dev/null || true)

if [ -z "$MACHINE_ID" ]; then
  echo "ERROR: No machines found. Run 'omnictl get machine' to verify."
  exit 1
fi

echo "Found machine ID: $MACHINE_ID"

echo -e "\n=== 2. PULLING BOOT LOGS ==="
LOG_FILE="talos-boot-${MACHINE_ID:0:8}.log"
omnictl machine-logs "$MACHINE_ID" > "$LOG_FILE"

echo "Logs saved to: $LOG_FILE"

echo -e "\n=== 3. SIDEROLINK / ERROR LINES ==="
if grep -i -E "siderolink|wireguard|wss|443|permission|token|error|fail|denied|timeout|refused" "$LOG_FILE"; then
  echo -e "\nFound SideroLink-related logs above."
else
  echo "No SideroLink or error lines found. Full log in $LOG_FILE"
fi

echo -e "\n=== DONE ==="
echo "Next: Reply with the output above (especially the grep lines)."
