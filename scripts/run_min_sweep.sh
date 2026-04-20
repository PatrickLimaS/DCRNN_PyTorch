#!/usr/bin/env bash
set -u  # nao usa -e: queremos continuar mesmo se uma variante falha

VARIANTS=(graph_core local_only abl_no_graph abl_no_aggregation abl_graph_no_skip abl_agg_no_skip)
LOG_DIR="results/min_sweep"
mkdir -p "$LOG_DIR"

TOTAL=${#VARIANTS[@]}
i=0
for v in "${VARIANTS[@]}"; do
    i=$((i + 1))
    LOG="$LOG_DIR/${v}.log"
    echo "=== [$i/$TOTAL] $v start $(date +%T) ==="
    python dcrnn_train_pytorch.py \
        --config_filename="data/model/dcrnn_la_probingnoise_${v}.yaml" \
        > "$LOG" 2>&1
    RC=$?
    if [ $RC -eq 0 ]; then
        echo "=== [$i/$TOTAL] $v done $(date +%T) ==="
        tail -n 1 "$LOG" | sed 's/^/  /'
    else
        echo "=== [$i/$TOTAL] $v FAILED rc=$RC ==="
        tail -n 5 "$LOG" | sed 's/^/  /'
    fi
done

echo ""
echo "=== sweep complete, results in $LOG_DIR ==="
