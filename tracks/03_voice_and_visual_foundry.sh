#!/usr/bin/env bash
set -euo pipefail

echo "=== [Track 3] Sequential Time-Block: Local GPU Voice Stockpile & Visual Foundry ==="
echo "NOTE: Stop Track 1 vLLM first (Ctrl+C or pkill -f vllm.entrypoints) so the full 80GB H100 VRAM is free."
nvidia-smi --query-gpu=memory.used,memory.free --format=csv
mkdir -p /workspace/outputs/voice_stockpile /workspace/outputs/renders
echo "Ready for batch GPU TTS voice-pack rendering or FLUX / Wan2.1 video generation into /workspace/outputs/."
