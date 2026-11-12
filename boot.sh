#!/usr/bin/env bash
set -euo pipefail

echo "=== [🎂 H100 Birthday Lab Bootstrap] ==="
date
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv

mkdir -p ~/.ssh /workspace/outputs /workspace/hf_cache
chmod 700 ~/.ssh

# Authorize amp2 (Nimbo) SSH key if not already present
AMP2_PUB="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5lBUnJuPpAYEJDBJNY9cGFGVLEtJQc60IyW+SMRlqI hermes@ampersand-vps2"
grep -qF "$AMP2_PUB" ~/.ssh/authorized_keys 2>/dev/null || echo "$AMP2_PUB" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

export HF_HOME=/workspace/hf_cache
export HF_HUB_ENABLE_HF_TRANSFER=1

pip install -q --upgrade uv hf_transfer huggingface_hub

echo "=== [Bootstrap Complete — Ready for Track 1 / 2 / 3] ==="
