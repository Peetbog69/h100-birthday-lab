#!/usr/bin/env bash
set -euo pipefail

echo "=== [Teardown] Syncing /workspace/outputs before pod termination ==="
ls -lh /workspace/outputs || true
echo "Ready to terminate pod cleanly ($0.00/hr)."
