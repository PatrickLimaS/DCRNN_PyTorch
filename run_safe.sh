#!/data/data/com.termux/files/usr/bin/bash
# Runs diagnose.sh and redacts tokens from all output so it's safe to share.

LOG="/tmp/push_output.log"

./diagnose.sh 2>&1 | tee "$LOG"

# Redact GitHub tokens (ghp_, gho_, ghu_, ghs_, ghr_, github_pat_) from the log
sed -i -E \
  -e 's/(gh[pousr]_)[A-Za-z0-9]{20,}/\1REDACTED/g' \
  -e 's/(github_pat_)[A-Za-z0-9_]{20,}/\1REDACTED/g' \
  "$LOG"

echo ""
echo "================================================"
echo "Safe-to-share log saved at: $LOG"
echo "View it with:  cat $LOG"
echo "================================================"
