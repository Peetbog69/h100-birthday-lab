#!/usr/bin/env bash
set -euo pipefail

MODEL="${1:-NousResearch/Arete-27B}"
PORT="${2:-8000}"
MAX_LEN="${3:-32768}"
PARSER="${4:-qwen3_coder}"

export HF_HOME=/workspace/hf_cache
export HF_HUB_ENABLE_HF_TRANSFER=1

echo "=== [Track 1] Installing vLLM & Launching $MODEL on H100 (port $PORT) ==="
uv pip install --system -q vllm hf_transfer

if python3 -m vllm.entrypoints.openai.api_server --help 2>&1 | grep -q -- "--language-model-only"; then
  EXTRA_MM_FLAG=(--language-model-only)
else
  EXTRA_MM_FLAG=(--limit-mm-per-prompt '{"image":0,"video":0}')
fi

exec python3 -m vllm.entrypoints.openai.api_server \
  --model "$MODEL" \
  --host 127.0.0.1 \
  --port "$PORT" \
  --dtype bfloat16 \
  --trust-remote-code \
  --gpu-memory-utilization 0.90 \
  --max-model-len "$MAX_LEN" \
  --enable-auto-tool-choice \
  --tool-call-parser "$PARSER" \
  "${EXTRA_MM_FLAG[@]}"
