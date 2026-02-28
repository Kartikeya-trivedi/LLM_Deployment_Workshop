"""
Ollama LLM Server — Local Llama-3.2-3B via Ollama
===================================================
Run:  python ollama_model.py

Starts a local FastAPI server on http://localhost:8000 that proxies to Ollama.
Endpoints:
  GET  /           → serves the chat web interface
  POST /generate   → runs inference via Ollama and returns {"response": "..."}

Prerequisites:
  1. Install Ollama: https://ollama.com/download
  2. Pull the model:  ollama pull llama3.2:3b
  3. pip install fastapi uvicorn httpx
"""

import pathlib
import httpx
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from pydantic import BaseModel

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

OLLAMA_URL = "http://localhost:11434"  # default Ollama API
MODEL_NAME = "llama3.2:3b"
FRONTEND_DIR = pathlib.Path(__file__).parent / "frontend"

app = FastAPI(title="LLM Playground — Ollama")


# ---------------------------------------------------------------------------
# Request schema
# ---------------------------------------------------------------------------

class GenerateRequest(BaseModel):
    prompt: str
    temperature: float = 0.7
    max_tokens: int = 256


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.get("/", response_class=HTMLResponse)
async def ui():
    """Serve the chat web interface."""
    html_path = FRONTEND_DIR / "index.html"
    return HTMLResponse(content=html_path.read_text(encoding="utf-8"))


@app.get("/info")
async def info():
    """Return model name and backend info."""
    return {"model": MODEL_NAME, "backend": "ollama"}


@app.post("/generate")
async def generate(req: GenerateRequest):
    """Forward the prompt to Ollama and return the response."""
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": MODEL_NAME,
                "prompt": req.prompt,
                "stream": False,
                "options": {
                    "temperature": req.temperature,
                    "num_predict": req.max_tokens,
                },
            },
        )
        resp.raise_for_status()
        data = resp.json()

    return {"response": data.get("response", "")}


# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import uvicorn

    print(f"Starting LLM Playground (Ollama → {MODEL_NAME})")
    print(f"Open http://localhost:8000 in your browser\n")
    uvicorn.run(app, host="0.0.0.0", port=8000)
