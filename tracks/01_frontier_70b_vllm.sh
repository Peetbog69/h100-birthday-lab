#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-arete}"
PORT="${2:-8000}"

export HF_HOME=/workspace/hf_cache
export HF_HUB_ENABLE_HF_TRANSFER=1

case "$TARGET" in
  arete|Arete|NousResearch/Arete-27B)
    MODEL="NousResearch/Arete-27B"
    PARSER="qwen3_coder"
    MAX_LEN="${3:-32768}"
    DTYPE="bfloat16"
    EXTRA_FLAGS=()
    if python3 -m vllm.entrypoints.openai.api_server --help 2>&1 | grep -q -- "--language-model-only"; then
      EXTRA_FLAGS+=(--language-model-only)
    else
      EXTRA_FLAGS+=(--limit-mm-per-prompt '{"image":0,"video":0}')
    fi
    ;;
  hermes|hermes3|NousResearch/Hermes-3-Llama-3.1-70B)
    MODEL="NousResearch/Hermes-3-Llama-3.1-70B"
    PARSER="hermes"
    MAX_LEN="${3:-65536}"
    DTYPE="bfloat16"
    EXTRA_FLAGS=()
    ;;
  hermes-fp8|NousResearch/Hermes-3-Llama-3.1-70B-FP8)
    MODEL="NousResearch/Hermes-3-Llama-3.1-70B-FP8"
    PARSER="hermes"
    MAX_LEN="${3:-131072}"
    DTYPE="float8"
    EXTRA_FLAGS=()
    ;;
  llama33|Llama-3.3-70B-Instruct|meta-llama/Llama-3.3-70B-Instruct)
    MODEL="meta-llama/Llama-3.3-70B-Instruct"
    PARSER="llama3_json"
    MAX_LEN="${3:-65536}"
    DTYPE="bfloat16"
    EXTRA_FLAGS=()
    ;;
  qwen72b|Qwen2.5-72B-Instruct|Qwen/Qwen2.5-72B-Instruct)
    MODEL="Qwen/Qwen2.5-72B-Instruct"
    PARSER="qwen3_coder"
    MAX_LEN="${3:-65536}"
    DTYPE="bfloat16"
    EXTRA_FLAGS=()
    ;;
  *)
    MODEL="$TARGET"
    PARSER="${4:-auto}"
    MAX_LEN="${3:-32768}"
    DTYPE="auto"
    EXTRA_FLAGS=()
    ;;
esac

echo "=== [Track 1] Launching $MODEL (vLLM on port $PORT, parser: $PARSER, max_len: $MAX_LEN, dtype: $DTYPE) ==="

exec python3 -m vllm.entrypoints.openai.api_server \
  --model "$MODEL" \
  --host 127.0.0.1 \
  --port "$PORT" \
  --dtype "$DTYPE" \
  --trust-remote-code \
  --gpu-memory-utilization 0.92 \
  --max-model-len "$MAX_LEN" \
  --enable-auto-tool-choice \
  --tool-call-parser "$PARSER" \
  "${EXTRA_FLAGS[@]}"
