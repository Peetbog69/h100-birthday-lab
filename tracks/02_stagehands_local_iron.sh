#!/usr/bin/env bash
set -euo pipefail

ENDPOINT="${1:-http://127.0.0.1:8000/v1}"
MODEL="${2:-NousResearch/Arete-27B}"

echo "=== [Track 2] Testing Sovereign & Stagehands v1.0.0 + Non-Argon Tool Calling against $MODEL ($ENDPOINT) ==="
mkdir -p /workspace/outputs
cd /workspace
if [ ! -d hermes-stagehands ]; then
  git clone https://github.com/Peetbog69/hermes-stagehands.git
fi
cd hermes-stagehands

python3 demo.py --fast
python3 -m unittest discover -s tests -v

echo "=== [Live Non-Argon delegate_task Tool-Call Smoke Test against $MODEL] ==="
python3 - "$ENDPOINT" "$MODEL" << 'PY'
import sys, json, time, urllib.request

endpoint, model = sys.argv[1], sys.argv[2]
body = {
    "model": model,
    "temperature": 0.1,
    "max_tokens": 300,
    "messages": [
        {"role": "user", "content": "Delegate a fast log scan of /var/log/syslog to a backstage scout worker using delegate_task."}
    ],
    "tools": [{
        "type": "function",
        "function": {
            "name": "delegate_task",
            "description": "Spawn a typed Stagehands worker subagent.",
            "parameters": {
                "type": "object",
                "properties": {
                    "tasks": {
                        "type": "array",
                        "items": {
                            "type": "object",
                            "properties": {
                                "goal": {"type": "string"},
                                "worker": {"type": "string", "enum": ["scout", "librarian", "code_monkey", "adversary", "briefer"]}
                            },
                            "required": ["goal", "worker"]
                        }
                    }
                },
                "required": ["tasks"]
            }
        }
    }],
    "tool_choice": "auto"
}
t0 = time.time()
req = urllib.request.Request(
    f"{endpoint}/chat/completions",
    data=json.dumps(body).encode(),
    headers={"Content-Type": "application/json"},
)
resp = json.loads(urllib.request.urlopen(req, timeout=60).read().decode())
elapsed = round(time.time() - t0, 3)
msg = resp["choices"][0]["message"]
usage = resp.get("usage", {})
receipt = {
    "model": model,
    "elapsed_s": elapsed,
    "tok_per_s": round(usage.get("completion_tokens", 0) / max(elapsed, 0.001), 1),
    "tool_calls": msg.get("tool_calls"),
    "content": msg.get("content"),
    "usage": usage,
}
open("/workspace/outputs/arete_stagehands_receipt.json", "w").write(json.dumps(receipt, indent=2))
print(json.dumps(receipt, indent=2))
PY
