<div align="center">

# 🚀 InferenceX

### LLM Deployment Workshop

**Deploy your own LLM in minutes.**

Hands-on workshop by [**MLSA KIIT**](https://mlsakiit.com) — deploy and chat with an LLM using a stunning web UI.

[![Modal](https://img.shields.io/badge/Modal-Serverless_GPU-6366f1?style=for-the-badge)](https://modal.com)&nbsp;
[![Ollama](https://img.shields.io/badge/Ollama-Run_Locally-000000?style=for-the-badge)](https://ollama.com)&nbsp;
[![vLLM](https://img.shields.io/badge/vLLM-Fast_Inference-a78bfa?style=for-the-badge)](https://github.com/vllm-project/vllm)

</div>

---

## 🎯 What You'll Build

A fully working **LLM chat application** with a polished dark-glass UI, markdown rendering, and dynamic model detection — pick your deployment path:

| | Option | Platform | GPU | Cost | One-Click |
|---|--------|----------|-----|------|-----------|
| ☁️ | **Modal + vLLM** | Cloud | A10G | Pay-per-use | `setup_modal.bat` |
| 🏠 | **Ollama** | Your machine | CPU / local GPU | Free | `setup_ollama.bat` |

> 💡 Both options share the **same chat interface** — the UI auto-detects which backend it's connected to.

---

## ⚡ Quick Start

### ☁️ Cloud (Modal)

```
setup_modal.bat
```

### 🏠 Local (Ollama)

```
setup_ollama.bat
```

That's it. The script handles everything — installing tools, dependencies, authentication, deployment, and opens the chat UI.

> 📋 For step-by-step manual setup, see [**SETUP.md**](SETUP.md).

---

## 📡 API

Both backends expose the same endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/ui` | Chat web interface |
| `GET` | `/info` | Model name & backend info |
| `POST` | `/generate` | Run inference |

### POST /generate

```bash
curl -X POST http://localhost:8000/generate ^
  -H "Content-Type: application/json" ^
  -d "{\"prompt\":\"What is gravity?\",\"temperature\":0.7,\"max_tokens\":128}"
```

**Response:**
```json
{ "response": "Gravity is a fundamental force..." }
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prompt` | `string` | *(required)* | The input prompt |
| `temperature` | `float` | `0.7` | Creativity (0 = deterministic, 1.5 = creative) |
| `max_tokens` | `int` | `256` | Max response length |

---

## 🧠 Supported Models

### Ungated (no authentication needed)

| Model | ID | Size |
|-------|----|------|
| **SmolLM2** *(default)* | `HuggingFaceTB/SmolLM2-1.7B-Instruct` | 1.7B |
| Phi-3.5 Mini | `microsoft/Phi-3.5-mini-instruct` | 3.8B |
| TinyLlama | `TinyLlama/TinyLlama-1.1B-Chat-v1.0` | 1.1B |
| StableLM 2 | `stabilityai/stablelm-2-zephyr-1_6b` | 1.6B |

### Gated (requires HuggingFace token)

| Model | ID | Size |
|-------|----|------|
| Llama 3.2 | `meta-llama/Llama-3.2-3B-Instruct` | 3B |
| Gemma 2 | `google/gemma-2-2b-it` | 2B |
| Mistral | `mistralai/Mistral-7B-Instruct-v0.3` | 7B |

> 🔒 See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#-gated-huggingface-models) for how to set up HuggingFace authentication.

---

## 📂 Project Structure

```
llm_deployment/
│
├── 🔧 setup_modal.bat       # One-click → cloud deploy
├── 🔧 setup_ollama.bat      # One-click → local deploy
│
├── ☁️  modal_model.py        # Modal app (vLLM + A10G GPU)
├── 🏠 ollama_model.py       # FastAPI server → Ollama
│
├── 🎨 frontend/
│   └── index.html            # Chat interface (markdown, dark UI)
│
├── 📋 SETUP.md               # Detailed setup instructions
├── 🛠️ TROUBLESHOOTING.md     # Common issues & fixes
└── 📖 README.md              # This file
```

---

## 🛠️ How It Works

```
┌─────────────────────────────────────────────────┐
│           Chat UI (frontend/index.html)         │
│   auto-detects backend · markdown rendering     │
│   fetches model name from /info endpoint        │
└──────────────┬──────────────┬───────────────────┘
               │              │
       *.modal.run        localhost:8000
               │              │
     ┌─────────▼──────┐  ┌───▼───────────┐
     │  modal_model.py │  │ ollama_model  │
     │  vLLM · A10G    │  │ FastAPI proxy │
     │  system prompt  │  └───────┬───────┘
     └─────────────────┘          │
                          ┌───────▼───────┐
                          │    Ollama      │
                          │  local model   │
                          └───────────────┘
```

---

## ❓ Troubleshooting

Having issues? See [**TROUBLESHOOTING.md**](TROUBLESHOOTING.md) for solutions to common problems including:

- Gated HuggingFace models
- Modal API changes & deprecations
- Unicode encoding errors on Windows
- Model giving nonsensical responses
- Ollama service not running

---

<div align="center">

**InferenceX** · LLM Deployment Workshop

Organized by [**MLSA KIIT**](https://mlsakiit.com)

Built with [Modal](https://modal.com) · [Ollama](https://ollama.com) · [vLLM](https://github.com/vllm-project/vllm)

</div>
