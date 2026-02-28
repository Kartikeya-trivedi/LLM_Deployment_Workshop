<div align="center">

# 🚀 InferenceX

### LLM Deployment Workshop

**Deploy your own LLM in minutes.**

Hands-on workshop by [**MLSA KIIT**](https://mlsakiit.com) — serve **Llama-3.2-3B-Instruct** with a stunning chat UI.

[![Modal](https://img.shields.io/badge/Modal-Serverless_GPU-6366f1?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHJ4PSI0IiBmaWxsPSIjNjM2NmYxIi8+PC9zdmc+)](https://modal.com)&nbsp;
[![Ollama](https://img.shields.io/badge/Ollama-Run_Locally-000000?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHJ4PSI0IiBmaWxsPSIjMDAwIi8+PC9zdmc+)](https://ollama.com)&nbsp;
[![vLLM](https://img.shields.io/badge/vLLM-Fast_Inference-a78bfa?style=for-the-badge)](https://github.com/vllm-project/vllm)

</div>

---

## 🎯 What You'll Build

A fully working **LLM chat application** — pick your deployment path:

| | Option | Platform | GPU | Cost | One-Click |
|---|--------|----------|-----|------|-----------|
| ☁️ | **[Modal](https://modal.com) + vLLM** | Cloud | A10G | Pay-per-use | `setup_modal.bat` |
| 🏠 | **[Ollama](https://ollama.com)** | Your machine | CPU / local GPU | Free | `setup_ollama.bat` |

> 💡 Both options share the **same chat interface** — the UI auto-detects which backend it's connected to.

---

## ☁️ Option A — Modal (Cloud GPU)

> Deploy to a cloud A10G GPU via **[Modal](https://modal.com)** — no infrastructure to manage.

### Prerequisites

- ✅ Python 3.11+
- ✅ [Modal account](https://modal.com) (free tier available)
- ✅ [HuggingFace access](https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct) to Llama 3.2 + HF token added as a Modal secret

### 🚀 One-Click Setup

```
setup_modal.bat
```

**Or step by step:**

```bash
pip install uv
uv init --no-readme
uv add modal
uv run modal setup                    # authenticate (one-time)
uv run modal deploy modal_model.py    # deploy!
```

Modal prints two HTTPS URLs — open the **UI** one in your browser and start chatting.

---

## 🏠 Option B — Ollama (Local)

> Run entirely on your machine via **[Ollama](https://ollama.com)** — free, private, no cloud needed.

### Prerequisites

- ✅ Python 3.11+
- ✅ [Ollama](https://ollama.com/download) installed and running

### 🚀 One-Click Setup

```
setup_ollama.bat
```

**Or step by step:**

```bash
pip install uv
uv init --no-readme
uv add fastapi uvicorn httpx
ollama pull llama3.2:3b
uv run python ollama_model.py
```

Open **http://localhost:8000** and start chatting.

---

## 📡 API Reference

Both backends expose the same API:

```
POST /generate
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prompt` | `string` | *(required)* | The input prompt |
| `temperature` | `float` | `0.7` | Creativity (0 = deterministic, 1.5 = wild) |
| `max_tokens` | `int` | `256` | Max response length |

<details>
<summary><b>📋 cURL Example</b></summary>

```bash
curl -X POST http://localhost:8000/generate ^
  -H "Content-Type: application/json" ^
  -d "{\"prompt\":\"What is gravity?\",\"temperature\":0.7,\"max_tokens\":128}"
```

**Response:**
```json
{ "response": "Gravity is a fundamental force..." }
```

</details>

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
│   └── index.html            # Chat web interface
│
└── 📖 README.md
```

---

## 🛠️ How It Works

```
┌─────────────────────────────────────────────┐
│               Chat UI (index.html)          │
│         auto-detects Modal vs Local         │
└──────────────┬──────────────┬───────────────┘
               │              │
       *.modal.run        localhost:8000
               │              │
     ┌─────────▼──────┐  ┌───▼───────────┐
     │  modal_model.py │  │ ollama_model  │
     │  vLLM · A10G    │  │ FastAPI proxy │
     └─────────────────┘  └───────┬───────┘
                                  │
                          ┌───────▼───────┐
                          │    Ollama     │
                          │  llama3.2:3b  │
                          └───────────────┘
```

---

<div align="center">

**InferenceX** · LLM Deployment Workshop

Organized by [**MLSA KIIT**](https://mlsakiit.com)

Built with [Modal](https://modal.com) · [Ollama](https://ollama.com) · [vLLM](https://github.com/vllm-project/vllm)

</div>
