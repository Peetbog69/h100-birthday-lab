#!/usr/bin/env bash
set -euo pipefail

echo "=== [Track 4 — Clean Teardown & Checksum Verification] ==="
mkdir -p /workspace/outputs
cd /workspace/outputs
sha256sum * 2>/dev/null | tee SHA256SUMS.txt || true
ls -lh /workspace/outputs

echo ""
echo "From amp2, pull all verified outputs before terminating the pod:"
echo "  rsync -avz -e 'ssh -p <RUNPOD_PORT>' root@<RUNPOD_IP>:/workspace/outputs/ /root/h100-birthday-lab/outputs/"
echo ""
echo "Once rsync completes, click TERMINATE (not Stop) in RunPod to return to \$0.00/hr."
