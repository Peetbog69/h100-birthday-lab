# 🎂 H100 Birthday Lab — `amp2` Remote-Pilot Edition (MoA Hardened)
**Target Window:** Birthday Weekend (Nov 14–16, 2026)  
**Hardware:** 1× NVIDIA H100 80GB HBM3 (`~$1.99–$2.69/hr` on RunPod)  
**Pilot:** Nimbo (`amp2` / `45.76.24.89`) driving the H100 remotely over SSH tunnel  
**Default Model:** `NousResearch/Arete-27B` (`50.98 GB` across 18 `.safetensors` shards, `Qwen3_5ForConditionalGeneration`)

---

## ⚡ Why This Repo Exists (`$0.00/hr` Prep)
Every minute an H100 is booted costs ~`$0.04`. All scripts, model flags, disk guards, SSH keys, and safety timers are hardened here beforehand so **30 seconds of `boot.sh`** hands the steering wheel straight to Nimbo on `amp2`.

---

## 🚀 60-Second Launch Checklist (When Ready to Play)

### 1. Rent the Pod (`runpod.io`)
- Load `$10–$15` prepaid balance (**leave Auto-Reload OFF**).
- Pick **1× H100 80GB PCIe or SXM**.
- Template: **RunPod vLLM** (or **RunPod PyTorch 2.4+ / CUDA 12.4**).
- **IMPORTANT — Volume Disk:** Set `/workspace` Volume Disk to **`100 GB`** (`boot.sh` enforces `>= 60 GB` free so the `50.98 GB` `Arete-27B` download never hits disk-full).
- Under **SSH Public Key**, paste `amp2`'s public key so Nimbo can log straight in:
  ```text
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5lBUnJuPpAYEJDBJNY9cGFGVLEtJQc60IyW+SMRlqI hermes@ampersand-vps2
  ```
- Text Nimbo the RunPod SSH command (`ssh root@<ip> -p <port>`) in Telegram — **Nimbo takes it from there!**

### 2. What Nimbo Runs Automatically (`./boot.sh`)
- Verifies `H100 80GB` (`nvidia-smi`) and enforces `>= 60 GB` free on `/workspace`.
- Arms a **2-hour dead-man's safety timer** in the background (`/tmp/h100_deadman.pid`).
- Enables `HF_HUB_ENABLE_HF_TRANSFER=1` (~`1 GB/s` datacenter weight pulls -> `50.98 GB` in ~50s).
- Verifies `vLLM` + `transformers>=5.12.1` support for `Qwen3_5ForConditionalGeneration`.
- From `amp2`, Nimbo opens the private SSH port forward:
  ```bash
  ssh -f -N -o ServerAliveInterval=30 -o ExitOnForwardFailure=yes -L 18000:127.0.0.1:8000 -p <RUNPOD_PORT> root@<RUNPOD_IP>
  ```
  Instantly, `http://127.0.0.1:18000/v1` on `amp2` **is your H100** with zero public ports exposed.

---

## ⏱️ The Council's 120-Minute Birthday Runbook (Sequential Time-Blocks)

| Min | Track | Action |
|---:|---|---|
| **0–10** | **Setup** | Boot H100 (`100 GB` `/workspace`), run `./boot.sh`, open SSH tunnel to `amp2:18000`. |
| **10–45** | **Track 1 (`tracks/01_frontier_70b_vllm.sh`)** | Pull `NousResearch/Arete-27B` (`50.98 GB` BF16) and serve via `vLLM` with `--tool-call-parser qwen3_coder` + `--language-model-only` (`32k` default, `64k` optional — hybrid linear attention uses only `~4.2 GB` KV cache at `64k`!). Connect Nimbo/Hermes from `amp2`. |
| **45–75** | **Track 2 (`tracks/02_stagehands_local_iron.sh`)** | Live non-Argon validation of **Sovereign & Stagehands `v1.0.0` (`ec5aacc`)** against `Arete-27B` (`delegate_task` tool-call smoke test + tok/sec & TTFT receipt saved to `/workspace/outputs/arete_stagehands_receipt.json`) + **Ampersand Out-of-Session Architecture Blueprint** (`ARCHITECTURE_BLUEPRINT.md`: Two-Layer Bouncer + George 2.0 Stateless SOUL Compiler). |
| **75–110** | **Track 3 (`tracks/03_voice_and_visual_foundry.sh`)** | Stop `vLLM` to free all `80 GB` VRAM -> batch-render custom local GPU TTS voice packs + `FLUX.1-dev` / `Wan2.1` video clips into `/workspace/outputs/`. |
| **110–120** | **Track 4 (`./teardown.sh`)** | Generate `SHA256SUMS.txt`, `rsync` `/workspace/outputs/` back to `amp2:/root/h100-birthday-lab/outputs/`, and click **Terminate** (not Stop) in RunPod to return to **`$0.00/hr`**. |
