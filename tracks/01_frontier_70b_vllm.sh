#!/usr/bin/env bash
set -euo pipefail

MODEL="${1:-NousResearch/Arete-27B}"
PORT="${2:-8000}"

export HF_HOME=/workspace/hf_cache
export HF_HUB_ENABLE_HF_TRANSFER=1

echo "=== [Track 1] Installing vLLM & Launching $MODEL on H100 (port $PORT) ==="
uv pip install --system -q vllm hf_transfer

exec python3 -m vllm.entrypoints.openai.api_server \
  --model "$MODEL" \
  --host 127.0.0.1 \
  --port "$PORT" \
  --gpu-memory-utilization 0.92 \
  --max-model-len 32768 \
  --enable-auto-tool-choice \
  --tool-call-parser hermes
