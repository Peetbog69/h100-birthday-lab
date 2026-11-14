#!/usr/bin/env bash
set -euo pipefail

echo "=== [🎂 H200 / H100 Birthday Lab Bootstrap] ==="
date
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv

mkdir -p ~/.ssh /workspace/outputs /workspace/hf_cache
chmod 700 ~/.ssh

# 1. Disk Preflight Guard (>=60 GB for Arete-27B; >=160 GB recommended for Hermes 3 70B BF16)
FREE_GB=$(df -BG /workspace | awk 'NR==2 {gsub("G","",$4); print $4}')
echo "[DISK] /workspace free space: ${FREE_GB} GB"
if [ "${FREE_GB:-0}" -lt 60 ]; then
  echo "ERROR: /workspace only has ${FREE_GB} GB free! Need >= 60 GB for Arete-27B (50.98 GB) or >= 160 GB for Hermes 3 70B."
  echo "Action: Set RunPod Volume Disk to 150-200 GB before launching."
  exit 1
fi
if [ "${FREE_GB:-0}" -lt 160 ]; then
  echo "[DISK NOTE] ${FREE_GB} GB is plenty for Arete-27B (51 GB) or Hermes-3-70B-FP8 (75 GB)."
  echo "            If pulling Hermes 3 70B in native BF16 (140 GB), ensure volume disk is >= 200 GB."
fi

# 2. Authorize amp2 (Nimbo) SSH key if not already present
AMP2_PUB="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5lBUnJuPpAYEJDBJNY9cGFGVLEtJQc60IyW+SMRlqI hermes@ampersand-vps2"
grep -qF "$AMP2_PUB" ~/.ssh/authorized_keys 2>/dev/null || echo "$AMP2_PUB" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# 3. Start 2-hour (7200s) Dead-Man's Safety Timer in background
if [ ! -f /tmp/h100_deadman.pid ] || ! kill -0 "$(cat /tmp/h100_deadman.pid 2>/dev/null)" 2>/dev/null; then
  nohup bash -c 'sleep 6600; echo "WARNING: H100 110-min mark reached! Run ./teardown.sh soon." >> /workspace/outputs/DEADMAN_ALERT.txt; sleep 600; echo "DEADLINE: 120-min mark reached!" >> /workspace/outputs/DEADMAN_ALERT.txt' >/dev/null 2>&1 &
  echo $! > /tmp/h100_deadman.pid
  echo "[TIMER] 2-hour dead-man safety timer armed (PID $(cat /tmp/h100_deadman.pid))."
fi

# 4. Fast weight download + vLLM / Qwen3_5ForConditionalGeneration preflight
export HF_HOME=/workspace/hf_cache
export HF_HUB_ENABLE_HF_TRANSFER=1

pip install -q --upgrade uv hf_transfer huggingface_hub

if python3 -c "import vllm; from vllm.model_executor.models.registry import ModelRegistry; assert 'Qwen3_5ForConditionalGeneration' in ModelRegistry.get_supported_archs()" 2>/dev/null; then
  echo "[vLLM] Pre-installed vLLM already supports Qwen3_5ForConditionalGeneration!"
else
  echo "[vLLM] Upgrading vLLM + transformers>=5.12.1 for Qwen3_5ForConditionalGeneration (Arete-27B)..."
  uv pip install --system -q --upgrade vllm "transformers>=5.12.1"
fi

echo "=== [Bootstrap Complete — Ready for Track 1 / 2 / 3] ==="
echo "From amp2, open the private tunnel with:"
echo "  ssh -f -N -o ServerAliveInterval=30 -o ExitOnForwardFailure=yes -L 18000:127.0.0.1:8000 -p <RUNPOD_PORT> root@<RUNPOD_IP>"
