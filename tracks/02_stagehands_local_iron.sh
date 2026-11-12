#!/usr/bin/env bash
set -euo pipefail

echo "=== [Track 2] Cloning Sovereign & Stagehands v1.0.0 and benchmarking against local H100 vLLM ==="
cd /workspace
if [ ! -d hermes-stagehands ]; then
  git clone https://github.com/Peetbog69/hermes-stagehands.git
fi
cd hermes-stagehands
python3 demo.py --fast
python3 -m unittest discover -s tests -v
