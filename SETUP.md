# 📋 Setup Guide

Step-by-step instructions for setting up the InferenceX LLM Deployment Workshop.

---

## Prerequisites

| Requirement | Required for | How to get it |
|-------------|-------------|---------------|
| **Windows 10/11** | Everything | You're probably already here |
| **winget** | Auto-installing tools | Built into Windows 10 1709+ / Windows 11 |
| **Internet connection** | Downloading models & dependencies | — |
| **Modal account** | Cloud deployment only | [modal.com](https://modal.com) (free tier) |

> 💡 You do **not** need Python pre-installed — `uv` handles Python automatically.

---

## ☁️ Option A — Modal (Cloud GPU)

Deploy your LLM to Modal's cloud on an A10G GPU. Best for workshops where attendees have varying hardware.

### One-Click Setup

```
setup_modal.bat
```

Double-click or run in a terminal. The script will:

1. Install `uv` (Python package manager) via `winget`
2. Initialize the project and virtual environment
3. Install the `modal` package
4. Open a browser to authenticate with Modal
5. Deploy `modal_model.py` to Modal's cloud
6. Open the chat UI automatically

### Manual Setup

If you prefer doing it step by step:

```bash
# 1. Install uv
winget install --id=astral-sh.uv -e

# 2. Initialize project (skip if pyproject.toml exists)
uv init --no-readme

# 3. Add Modal
uv add modal

# 4. Authenticate with Modal (opens browser — one-time)
uv run modal setup

# 5. Deploy
uv run modal deploy modal_model.py
```

Modal prints endpoint URLs — open the **UI** one in your browser.

### Redeploying after code changes

```
uv run modal deploy modal_model.py
```

No need to re-authenticate or re-install anything.

### Changing the model

Edit `MODEL_NAME` in `modal_model.py`:

```python
MODEL_NAME = "HuggingFaceTB/SmolLM2-1.7B-Instruct"  # current default
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for a list of ungated models that work without authentication.

---

## 🏠 Option B — Ollama (Local)

Run the LLM entirely on your machine. Free, private, no cloud needed.

### One-Click Setup

```
setup_ollama.bat
```

The script will:

1. Install Ollama via `winget` (if not already installed)
2. Install `uv` via `winget` (if not already installed)
3. Initialize the project and virtual environment
4. Install Python dependencies (`fastapi`, `uvicorn`, `httpx`)
5. Start the Ollama service and pull the model
6. Launch the FastAPI server and open the chat UI

### Manual Setup

```bash
# 1. Install Ollama
winget install --id Ollama.Ollama -e

# 2. Install uv
winget install --id=astral-sh.uv -e

# 3. Initialize project
uv init --no-readme

# 4. Add dependencies
uv add fastapi uvicorn httpx

# 5. Pull the model (downloads ~2 GB)
ollama pull llama3.2:3b

# 6. Start the server
uv run python ollama_model.py
```

Open **http://localhost:8000** in your browser.

### Changing the model

1. Pull a different model:
   ```
   ollama pull smollm2:1.7b
   ```

2. Edit `MODEL_NAME` in `ollama_model.py`:
   ```python
   MODEL_NAME = "smollm2:1.7b"
   ```

3. Restart the server:
   ```
   uv run python ollama_model.py
   ```

---

## 🔄 Command Reference

| Command | What it does |
|---------|-------------|
| `setup_modal.bat` | Full cloud setup + deploy (one-click) |
| `setup_ollama.bat` | Full local setup + launch (one-click) |
| `uv run modal deploy modal_model.py` | Redeploy to Modal |
| `uv run modal setup` | Authenticate with Modal |
| `uv run python ollama_model.py` | Start local Ollama server |
| `ollama serve` | Start Ollama background service |
| `ollama pull <model>` | Download a model |
| `ollama list` | List downloaded models |

---

## ❓ Having Issues?

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for solutions to common problems.
