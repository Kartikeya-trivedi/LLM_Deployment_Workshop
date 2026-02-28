# 🛠️ Troubleshooting Guide

Common issues and fixes for the InferenceX LLM Deployment Workshop.

---

## 🔒 Gated HuggingFace Models

Some models on HuggingFace are **gated** — you need to request access before downloading them. This includes popular models like **Llama 3**, **Mistral**, and **Gemma**.

### How to tell if a model is gated

If you see this error during deployment:

```
GatedRepoError: 401 Client Error
Cannot access gated repo for url https://huggingface.co/...
Access to model ... is restricted.
```

The model is gated.

### Option 1: Use an ungated model instead (easiest)

These models work **without any authentication**:

| Model | HuggingFace ID | Size | Origin |
|-------|----------------|------|--------|
| SmolLM2 1.7B | `HuggingFaceTB/SmolLM2-1.7B-Instruct` | 1.7B | HuggingFace 🇫🇷 |
| SmolLM2 360M | `HuggingFaceTB/SmolLM2-360M-Instruct` | 360M | HuggingFace 🇫🇷 |
| Phi-3.5 Mini | `microsoft/Phi-3.5-mini-instruct` | 3.8B | Microsoft 🇺🇸 |
| TinyLlama Chat | `TinyLlama/TinyLlama-1.1B-Chat-v1.0` | 1.1B | Community |
| StableLM 2 | `stabilityai/stablelm-2-zephyr-1_6b` | 1.6B | Stability AI 🇬🇧 |
| OLMo 1B | `allenai/OLMo-1B` | 1B | AI2 🇺🇸 |

Just change `MODEL_NAME` in `modal_model.py`:

```python
MODEL_NAME = "HuggingFaceTB/SmolLM2-1.7B-Instruct"
```

### Option 2: Set up HuggingFace authentication

If you want to use a gated model (e.g., Llama 3.2):

**Step 1 — Request access**
1. Go to the model page (e.g., [meta-llama/Llama-3.2-3B-Instruct](https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct))
2. Click **"Agree and access"** — approval can take minutes to hours

**Step 2 — Create a HuggingFace token**
1. Go to [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)
2. Click **"New token"** → give it a name → select **Read** access
3. Copy the token (starts with `hf_`)

**Step 3 — Add the token to Modal**
```bash
modal secret create huggingface HF_TOKEN=hf_your_token_here
```

**Step 4 — Update your code**

Add `secrets` to the `@app.cls()` decorator in `modal_model.py`:

```python
@app.cls(
    image=vllm_image,
    gpu="A10G",
    scaledown_window=300,
    secrets=[modal.Secret.from_name("huggingface")],  # ← add this
)
```

**Step 5 — Redeploy**
```bash
uv run modal deploy modal_model.py
```

### Common gated models

| Model | Gated? | Access |
|-------|--------|--------|
| `meta-llama/Llama-3.2-*` | ✅ Yes | Request on HuggingFace |
| `mistralai/Mistral-*` | ✅ Yes | Request on HuggingFace |
| `google/gemma-*` | ✅ Yes | Accept Google's terms |
| `HuggingFaceTB/SmolLM2-*` | ❌ No | Open access |
| `microsoft/Phi-3*` | ❌ No | Open access |
| `TinyLlama/*` | ❌ No | Open access |

---

## General

### `'.' is not recognized as an internal or external command`

You're using Linux/Mac syntax on Windows. Use:

```
setup_modal.bat        ← correct
.\setup_modal.bat      ← also correct (backslash)
./setup_modal.bat      ← WRONG (forward slash)
```

### `winget` is not recognized

`winget` requires **Windows 10 1709+** or **Windows 11**. If missing:

1. Install [App Installer](https://apps.microsoft.com/detail/9nblggh4nns1) from the Microsoft Store
2. Restart your terminal

### SmartScreen warning when running `.bat` files

This happens when files are downloaded from the internet. Click **"More info" → "Run anyway"**. This is safe — `.bat` files don't need execution policy changes (that's PowerShell-only).

### `uv` or `ollama` not found after install

The terminal session doesn't see newly installed programs. Fix:

1. **Close and reopen** VS Code / terminal entirely
2. Or restart your PC
3. The `setup_ollama.bat` script auto-refreshes PATH, but VS Code sometimes caches the old one

---

## ☁️ Modal (Cloud)

### `module 'modal' has no attribute 'Mount'`

`modal.Mount` was removed in Modal 1.0+. Use `Image.add_local_file()` or `Image.add_local_dir()` instead:

```python
# OLD (broken)
mounts=[modal.Mount.from_local_dir(FRONTEND_DIR, remote_path="/frontend")]

# NEW (correct)
.add_local_file(FRONTEND_DIR / "index.html", remote_path="/frontend/index.html", copy=True)
```

### `container_idle_timeout` deprecation warning

Renamed in Modal 1.0:

```python
# OLD
container_idle_timeout=300

# NEW
scaledown_window=300
```

### `web_endpoint` deprecation warning

Renamed in Modal 1.0:

```python
# OLD
@modal.web_endpoint(method="POST")

# NEW
@modal.fastapi_endpoint(method="POST")
```

### `GatedRepoError: 401 Unauthorized` (HuggingFace)

The model is **gated** and requires authentication. Options:

1. **Switch to an ungated model** (easiest):
   ```python
   MODEL_NAME = "HuggingFaceTB/SmolLM2-1.7B-Instruct"  # no auth needed
   ```

2. **Set up HuggingFace auth**:
   - Request access at the model's HuggingFace page
   - Create a token at [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)
   - Add it as a Modal secret:
     ```
     modal secret create huggingface HF_TOKEN=hf_xxxxx
     ```
   - Add to your code:
     ```python
     @app.cls(secrets=[modal.Secret.from_name("huggingface")], ...)
     ```

### `'charmap' codec can't encode character '\u2713'`

Unicode encoding error on Windows. Add these lines before running `modal deploy` in your `.bat` script:

```batch
chcp 65001 >nul 2>&1
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"
```

### UI endpoint shows a blank page

Ensure the frontend file is baked into the container image with `copy=True`:

```python
.add_local_file(
    FRONTEND_DIR / "index.html",
    remote_path="/frontend/index.html",
    copy=True,   # ← important: bakes into image layer
)
```

### Model gives nonsensical / rambling responses

The model needs a **system prompt and chat template**. Raw text completion ≠ chat. Wrap prompts in ChatML format:

```python
SYSTEM_PROMPT = "You are a helpful AI assistant."

def _format_prompt(self, user_msg):
    return (
        f"<|im_start|>system\n{SYSTEM_PROMPT}<|im_end|>\n"
        f"<|im_start|>user\n{user_msg}<|im_end|>\n"
        f"<|im_start|>assistant\n"
    )
```

And add a stop token:

```python
params = self.SamplingParams(
    temperature=temperature,
    max_tokens=max_tokens,
    stop=["<|im_end|>"],
)
```

### Cold start takes 30-60 seconds

**This is normal.** Modal spins down the GPU container after 5 min of idle time to save credits. When you visit the URL again, it boots up a new container. Subsequent requests within the idle window are fast.

---

## 🏠 Ollama (Local)

### `Failed to pull model. Is Ollama running?`

Ollama's background service isn't running. Fix:

```
ollama serve
```

Then in a new terminal:

```
ollama pull llama3.2:3b
```

The `setup_ollama.bat` script handles this automatically.

### `Connection refused` on `localhost:11434`

Same as above — the Ollama service isn't running. Start it with `ollama serve` or launch the Ollama desktop app.

### `Connection refused` on `localhost:8000`

The Python FastAPI server isn't running:

```
uv run python ollama_model.py
```

### Model is very slow locally

- **CPU-only** inference is slow for larger models — this is expected
- Try a smaller model:
  ```
  ollama pull smollm2:1.7b
  ```
- If you have an NVIDIA GPU, make sure Ollama detects it (`ollama --version` shows GPU info)

### `ollama pull` is stuck / downloading slowly

Large models take time. `llama3.2:3b` is ~2GB. If your connection is slow, try a smaller model:

```
ollama pull smollm2:1.7b     # ~1 GB
ollama pull tinyllama         # ~640 MB
```

---

## 🌐 Frontend / Chat UI

### Chat shows raw markdown instead of formatted text

The frontend loads `marked.js` from a CDN. If you're offline or the CDN is blocked, markdown won't render. The chat will still work — it just shows plain text.

### API URL mismatch on Modal

The frontend auto-detects the backend by checking if the hostname ends with `.modal.run`. If you see CORS errors, make sure you're accessing the **UI endpoint URL**, not the generate endpoint directly.

---

## 💡 Quick Reference

| Command | What it does |
|---------|-------------|
| `uv run modal deploy modal_model.py` | Deploy to Modal cloud |
| `uv run modal setup` | Authenticate with Modal (first time) |
| `uv run python ollama_model.py` | Start local Ollama server |
| `ollama serve` | Start Ollama background service |
| `ollama pull <model>` | Download a model |
| `ollama list` | List downloaded models |
