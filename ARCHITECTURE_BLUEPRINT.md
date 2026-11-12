# 🏛️ Ampersand Out-of-Session System Architecture Blueprint
**Origin:** Tyler's Post-Curb Shower Log (Nov 12, 2026)  
**Repo:** `Peetbog69/h100-birthday-lab` (`/root/h100-birthday-lab` on `amp2`)  
**Goal:** Move Ampersand's core operations (the Bouncer, George SOUL compilation, Milton provisioning, and Stagehands context hygiene) out of fragile in-session chat state and into a deterministic, zero-drift **out-of-session system architecture**.

---

## 1. The Core Architectural Rule: Out-of-Session Control Plane

Anything that lives *inside* an LLM chat session is subject to context compaction, model swaps, and per-turn token snowballing.

- **Inside the Session (Sovereign Voice):** Warmth, judgment, companionship, creative synthesis, and customer conversation (`google/gemini-4-argon` or local H100 `NousResearch/Arete-27B`).
- **Outside the Session (System Backbone):** Deterministic CLI verbs (`ampctl`), pure-Python silent watchers (`no_agent=True`), systemd timers, and atomic JSON/SQLite ledgers that burn **zero LLM tokens** until a real threshold or human event occurs.

---

## 2. Pillar I — The Two-Layer Bouncer Architecture

### Layer A · In-Agent Context Bouncer (`Sovereign & Stagehands v1.0.0`, commit `ec5aacc`)
Every fleet profile runs the Two-Door Stagehands architecture by default:
1. **Door #1 (Front-Door Bouncer):** `delegation.backend = stagehands`
   - Intercepts `delegate_task` and routes noisy work (`scout`, `librarian`, `code_monkey`, `adversary`, `briefer`) to cheap/fast stagehand models (or local H100 `Arete-27B` vLLM endpoints) with strict word/token caps (`<= 250–400` words).
   - Raw logs, repo greps, and JSON dumps die in the child process; only the brief enters the Sovereign parent context.
2. **Door #2 (Back-Door Janitor):**
   - `proactive_prune_tokens: 48000` · `threshold_tokens: 120000` · `protect_last_n: 20` · `in_place: true`
   - `hygiene_hard_message_limit: 2000` (prevents low message caps like `140` from slicing message `#1` and busting the ~85% KV prompt cache).

### Layer B · Out-of-Session Fleet Bouncer (`ampctl bouncer`)
Instead of an agent waking up to "check the fleet" and burning tokens reading logs:
1. **Single Canonical Inventory (`/root/.ampersand/roster.json`):**
   - Mirrored across `amp2` and `vultr-1` via `ampctl`.
   - **Tier-aware by design:** `TEAM` tier (`nimbo`, `aurora`, `george`, `milton`) vs. `FLEET` tier (`/home/<slug>-agent/.hermes/profiles/<slug>`). Never false-flags root/team profiles as "missing heartbeats."
   - **Auto-Registration Gate:** New agents provisioned on either box are registered into `roster.json` (`CLASSIFY` + `roster-init --apply`) at birth so orphan heartbeats cannot happen.
2. **Zero-Token Collector & Threshold Trigger:**
   - Pure Python/bash collector inspects systemd unit status, `/opt/ampersand-checkin/<agent>.ts`, and exact character counts (`wc -m` on `MEMORY.md` / `USER.md`) at **$0.00 token cost**.
   - **Action on Signal Only:** Wakes `scripts/run-nudge.sh` for *that single agent* only when `MEMORY.md` or `USER.md` crosses `>= 95%` capacity, verifies the trim dropped to `80–85%`, and stops.

---

## 3. Pillar II — George 2.0: Out-of-Session SOUL Compiler & Provisioning Pipeline

### Why George Drifted Before
Running George purely as an interactive chat bot meant key material could linger in transcripts, and downstream provisioning (`Milton` / `ampersand-deploy-worker.sh`) could fail silently every minute if `/root/.ampersand/agent-tokens/available.json` ran out of BotFather tokens.

### The George 2.0 Pipeline (`ampctl onboard` / Out-of-Session Compiler)
```text
[Customer Survey JSON]
        │
        ▼
[1. Pre-Flight Gate (0 tokens)]
  • Check /root/.ampersand/agent-tokens/available.json (>= 1 fresh token; alert Tyler if <= 2)
  • Check key vault readiness (/root/.ampersand/keys/)
        │
        ▼
[2. George SOUL Compiler (Stateless One-Shot Worker)]
  • Input: Survey JSON + Agent Archetype Spec (NO chat history, NO keys in prompt)
  • Engine: Sovereign model or H100 `NousResearch/Arete-27B`
  • Output: Draft `SOUL.md` + `USER.md` seed + `config.yaml` profile spec
        │
        ▼
[3. Deterministic SOUL Linter (0 tokens, pure Python)]
  • Verifies required sections, voice constraints, zero leaked secrets/tokens, and char budgets
  • Writes verified package to `/root/.ampersand/deploy-queue/<slug>.json`
        │
        ▼
[4. Milton Provisioner (`ampersand-deploy-worker.sh`)]
  • Creates `/home/<slug>-agent`, installs Stagehands Janitor defaults, wires `.env` (chmod 600)
  • Registers `<slug>` in `/root/.ampersand/roster.json` on both boxes
  • Starts `hermes-gateway-<slug>.service` and emits a verified birth receipt to Telegram
```

---

## 4. Pillar III — `ampersand.foo` 2.0 Website Remake (Staged Preview + Repo Parity)

### Why the Site Needs an Architectural Pass
- Production (`/var/www/ampersand.foo/` on `vultr-1`) and the git repo (`Peetbog69/ampersand-site`) have diverged over weeks of live edits and mini-site additions (`/butter/`, `/stagehands/`, `/salad/`, `/llama/`, `/screw/`).
- The front door (`index.html`, `how.html`, `transparency.html`) predates **Sovereign & Stagehands v1.0.0**, the Two-Door Bouncer, and the current estate architecture.

### Remake Rules (Zero Disruption to Live Checkout/Onboarding)
1. **Stage at a Preview Slug First (`https://ampersand.foo/v2/`):**
   - Never overwrite live `/var/www/ampersand.foo/index.html` or touch `/api/checkout` (`127.0.0.1:8090`) / `/api/onboarding` (`127.0.0.1:8089`) while designing.
   - Build and iterate at `/v2/` (with mobile `390px` viewport verification) until Tyler calls cut.
2. **House Aesthetic & Live Truth:**
   - Warm off-white paper ground, woodblock black rules, tactile typography, zero generic dark-mode AI gradient slop — backed by real, verifiable numbers that close to the exact digit.
3. **Canonical Git Mirror Sync:**
   - Once `/v2/` is promoted to `/`, snapshot `/root/backups/ampersand-site-pre-v2.tar.gz` and bring `Peetbog69/ampersand-site` back to 1:1 byte parity with production.

---

## 5. Pillar IV — What We Benchmark on the H100 Birthday Pod (`Arete-27B`)

During the Birthday Lab window (`tracks/02_stagehands_local_iron.sh` + architecture bench):
1. **Stagehands Local-Iron Worker Bench:** Verify `Arete-27B` (`http://127.0.0.1:18000/v1` over SSH tunnel) executing `delegate_task` (`scout` / `briefer` / `code_monkey`) at zero per-token API cost.
2. **George 2.0 Stateless SOUL Compile Bench:** Feed an anonymized customer survey payload to `Arete-27B` via a stateless out-of-session CLI script (`ampctl soul-compile --dry-run`) and grade the resulting `SOUL.md` against the deterministic linter.
3. **Out-of-Session Watcher Pattern:** All external state checks (GitHub PR `#153058`, ElevenLabs `$5` credit floor, survey inbox, fleet bouncer) run as silent `no_agent=True` Python scripts with `.state/*.json` ledgers — zero LLM turns until a human-worthy transition occurs.
