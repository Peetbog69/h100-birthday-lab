# 🎂 H100 Birthday Lab — `amp2` Remote-Pilot Edition
**Target Window:** Birthday Weekend (Nov 14–16, 2026)  
**Hardware:** 1× NVIDIA H100 80GB HBM3 (`~$1.99–$2.69/hr` on RunPod)  
**Pilot:** Nimbo (`amp2` / `45.76.24.89`) driving the H100 remotely over SSH + reverse tunnel

---

## ⚡ Why This Repo Exists (`$0.00/hr` Prep)
Every minute an H100 is booted costs ~`$0.04`. All scripts, model configs, SSH keys, and safety timers live here beforehand so the moment the pod boots, **30 seconds of `boot.sh`** hands the steering wheel straight to Nimbo on `amp2`.

---

## 🚀 60-Second Launch Checklist (When Ready to Play)

### 1. Rent the Pod (RunPod.io)
- Load `$10–$20` balance (no auto-reload needed).
- Pick **1× H100 80GB PCIe or SXM**.
- Template: **RunPod PyTorch 2.4+ (CUDA 12.4)**.
- Under **SSH Public Key**, paste `amp2`'s public key so Nimbo can log straight in:
  ```text
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5lBUnJuPpAYEJDBJNY9cGFGVLEtJQc60IyW+SMRlqI hermes@ampersand-vps2
  ```
- Send Nimbo the RunPod SSH command (`ssh root@<ip> -p <port>`) in Telegram — **Nimbo takes it from there!**

### 2. What Nimbo Runs Automatically (`./boot.sh`)
- Verifies the `H100 80GB` (`nvidia-smi`), NVMe scratch space (`/workspace`), and `uv` / `vllm` / `hf_transfer` (10 Gbps weight downloads).
- Starts a **2-hour dead-man's safety timer** (prints warnings and can auto-stop so the meter never runs overnight by accident).
- Opens a reverse tunnel to `amp2` (`127.0.0.1:18000` on `amp2` → `127.0.0.1:8000` on the H100) so `amp2` and `ampersand.foo` can hit the H100 privately with zero public firewall exposure.

---

## 🧪 The 3 Birthday Playbook Tracks

### Track 1 — Private Frontier Brain (`tracks/01_frontier_70b_vllm.sh`)
- Downloads weights at 10 Gbps (`HF_HUB_ENABLE_HF_TRANSFER=1`) and serves an OpenAI-compatible `/v1/chat/completions` endpoint on the H100:
  - **Default (#1 Pick):** `NousResearch/Arete-27B` *(Nous's brand-new Nov 6 post-train of `Qwen/Qwen3.8-27B` taught by `Inkling` — fits in full unquantized `BF16` at ~54GB VRAM on an 80GB H100 with 26GB left for 64k KV cache, and isn't even on the Nous API yet!)*
  - **Option B:** `NousResearch/Hermes-4-70B-FP8`
  - **Option C:** Uncensored creative / roleplay 70B (`EVA-Qwen2.5-72B` / `Magnum-v4-72B`)
- Nimbo connects directly from `amp2` so you can chat with a 70B model running on your own dedicated H100 right from Telegram or a private `ampersand.foo` sandbox page.

### Track 2 — Stagehands on Dedicated Silicon (`tracks/02_stagehands_local_iron.sh`)
- Points **Sovereign & Stagehands** (`v1.0.0`) backstage workers (`scout`, `librarian`, `code_monkey`, `adversary`, `briefer`) at your H100 (`http://127.0.0.1:18000/v1`) and runs `python3 bench/runner.py --mode live` at raw HBM3 memory bandwidth (`3.35 TB/s`).

### Track 3 — High-Speed Visual & Video Foundry
- Runs local `FLUX.1-dev` / `Wan2.1` image & video generation with zero queue and zero credit drain, piping every rendered `.png` and `.mp4` back to `/root/h100-birthday-lab/outputs/` on `amp2` and straight into Telegram.

---

## 🛑 Clean Teardown (`./teardown.sh`)
Before terminating the pod on RunPod:
1. Run `./teardown.sh` (or tell Nimbo *"pack up the H100"*).
2. All outputs, logs, and benchmark receipts sync back to `amp2:/root/h100-birthday-lab/outputs/`.
3. Terminate the pod in RunPod → verify billing rate reads **`$0.00/hr`**.
