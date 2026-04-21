#!/usr/bin/env bash
# Termux-optimized minimum sweep automation.
# - Runs one variant at a time
# - Resumable: skips variants already marked done
# - Heartbeat log every 60s so you can tell if Android killed it
# - Short epoch budget (configurable) to fit within likely wake-lock window
# - Wake-lock acquired at start, released at end

set -u

ROOT="$HOME/DCRNN_PyTorch"
cd "$ROOT" || { echo "repo not found"; exit 1; }

STATE_DIR="$ROOT/results/min_sweep"
STATUS_FILE="$STATE_DIR/auto_status.txt"
HEARTBEAT="$STATE_DIR/heartbeat.log"
mkdir -p "$STATE_DIR"
touch "$STATUS_FILE"

VARIANTS=(
    "graph_core"
    "local_only"
    "abl_no_graph"
    "abl_no_aggregation"
    "divergence_head"
)

EPOCHS_OVERRIDE="${EPOCHS_OVERRIDE:-}"

command -v termux-wake-lock >/dev/null && termux-wake-lock
trap '{ command -v termux-wake-unlock >/dev/null && termux-wake-unlock; }' EXIT

is_done() { grep -q "^DONE $1$" "$STATUS_FILE"; }
mark_done() { echo "DONE $1" >> "$STATUS_FILE"; }
mark_fail() { echo "FAIL $1 $(date +%T)" >> "$STATUS_FILE"; }

heartbeat_loop() {
    while true; do
        echo "$(date +%T) alive pid=$$ variant=$1" >> "$HEARTBEAT"
        sleep 60
    done
}

for v in "${VARIANTS[@]}"; do
    if is_done "$v"; then
        echo "[skip] $v (already DONE)"
        continue
    fi

    YAML="data/model/dcrnn_la_probingnoise_${v}.yaml"
    LOG="$STATE_DIR/${v}.log"

    if [ ! -f "$YAML" ]; then
        echo "[miss] $v ($YAML not found)"
        mark_fail "$v"
        continue
    fi

    echo "=== [$v] start $(date +%T) ==="

    heartbeat_loop "$v" &
    HB_PID=$!

    python dcrnn_train_pytorch.py --config_filename="$YAML" > "$LOG" 2>&1
    RC=$?

    kill "$HB_PID" 2>/dev/null
    wait "$HB_PID" 2>/dev/null

    if [ "$RC" -eq 0 ]; then
        LAST=$(grep -E "Epoch \[[0-9]+/" "$LOG" | tail -n 1)
        echo "[done] $v  $LAST"
        mark_done "$v"
    else
        echo "[fail] $v (rc=$RC)"
        tail -n 5 "$LOG" | sed 's/^/    /'
        mark_fail "$v"
    fi
done

echo ""
echo "=== summary ==="
cat "$STATUS_FILE"
