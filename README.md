# 🎂 H200 / H100 Birthday Lab — `amp2` Remote-Pilot Edition (MoA Hardened)
**Target Window:** Birthday Weekend (Nov 14–16, 2026)  
**Hardware:** 1× NVIDIA H200 141GB HBM3e (`~$3.50–$3.80/hr` on RunPod) or H100 80GB (`~$1.99–$2.69/hr`)  
**Pilot:** Nimbo (`amp2` / `45.76.24.89`) driving the GPU remotely over SSH tunnel  
**Primary Models:**  
- 👑 **`NousResearch/Hermes-3-Llama-3.1-70B`** (Crown Jewel Agentic Brain, native BF16 or FP8, `--tool-call-parser hermes`)
- ⚡ **`NousResearch/Arete-27B`** (`50.98 GB` BF16, hybrid linear attention, `--tool-call-parser qwen3_coder`)

---

## ⚡ Why This Repo Exists (`$0.00/hr` Prep)
Every minute on an H200 costs ~`$0.06`. All scripts, model flags, disk guards, SSH keys, and safety timers are hardened here beforehand so **30 seconds of `boot.sh`** hands the steering wheel straight to Nimbo on `amp2`.

---

## 🚀 60-Second Launch Checklist (When Ready to Play)

### 1. Rent the Pod (`runpod.io`)
- Load `$15–$25` prepaid balance (**leave Auto-Reload OFF**).
- Pick **1× H200 141GB PCIe/SXM** (or **H100 80GB**).
- Template: **RunPod vLLM** (or **RunPod PyTorch 2.4+ / CUDA 12.4**).
- **IMPORTANT — Volume Disk:** Set `/workspace` Volume Disk to **`150–200 GB`** so weights for Hermes 3 70B (`~140 GB`) and Arete-27B (`51 GB`) have room.
- Under **SSH Public Key**, paste `amp2`'s public key so Nimbo can log straight in:
  ```text
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5lBUnJuPpAYEJDBJNY9cGFGVLEtJQc60IyW+SMRlqI hermes@ampersand-vps2
  ```
- Text Nimbo the RunPod SSH command (`ssh root@<ip> -p <port>`) in Telegram — **Nimbo takes it from there!**

### 2. What Nimbo Runs Automatically (`./boot.sh`)
- Verifies GPU specs (`nvidia-smi`) and enforces disk preflight checks on `/workspace`.
- Arms a **2-hour dead-man's safety timer** in the background (`/tmp/h100_deadman.pid`).
- Enables `HF_HUB_ENABLE_HF_TRANSFER=1` (~`1 GB/s` datacenter weight pulls).
- Verifies `vLLM` + dependencies.
- From `amp2`, Nimbo opens the private SSH port forward:
  ```bash
  ssh -f -N -o ServerAliveInterval=30 -o ExitOnForwardFailure=yes -L 18000:127.0.0.1:8000 -p <RUNPOD_PORT> root@<RUNPOD_IP>
  ```
  Instantly, `http://127.0.0.1:18000/v1` on `amp2` **is your GPU supercluster** with zero public ports exposed.

---

## ⏱️ The Birthday Runbook

| Track | Script / Target | Action |
|---|---|---|
| **Track 1A (Hermes 3)** | `./tracks/01_frontier_70b_vllm.sh hermes` | Pull `NousResearch/Hermes-3-Llama-3.1-70B` and serve via `vLLM` with `--tool-call-parser hermes` (64k–128k context). Connect Nimbo directly as the front-chair brain! |
| **Track 1B (Arete-27B)** | `./tracks/01_frontier_70b_vllm.sh arete` | Pull `NousResearch/Arete-27B` (`50.98 GB` BF16) with `--tool-call-parser qwen3_coder` + `--language-model-only`. |
| **Track 2 (Stagehands)** | `./tracks/02_stagehands_local_iron.sh` | Live non-Argon validation of **Sovereign & Stagehands `v1.0.0`** (`delegate_task` tool-call smoke test + tok/sec receipt). |
| **Track 3 (Voice & Visual)** | `./tracks/03_voice_and_visual_foundry.sh` | Batch-render custom local GPU TTS voice packs + `FLUX.1-dev` / `Wan2.1` video clips into `/workspace/outputs/`. *(On a 141GB H200, smaller visual/audio jobs can even co-reside!)* |
| **Track 4 (Teardown)** | `./teardown.sh` | Generate `SHA256SUMS.txt`, `rsync` `/workspace/outputs/` back to `amp2:/root/h100-birthday-lab/outputs/`, and click **Terminate** (not Stop) in RunPod to return to **`$0.00/hr`**. |
