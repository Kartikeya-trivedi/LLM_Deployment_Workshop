"""
Modal LLM Deployment — Qwen2.5-1.5B-Instruct via vLLM
======================================================
Deploy:  modal deploy modal_model.py
Test:    modal run modal_model.py

Endpoints:
  GET  /ui         → serves the chat web interface
  GET  /info       → returns model name and backend info
  POST /generate   → runs inference and returns {"response": "..."}
"""

import modal
import pathlib

# ---------------------------------------------------------------------------
# Modal setup
# ---------------------------------------------------------------------------

app = modal.App("llm-model")

MODEL_NAME = "HuggingFaceTB/SmolLM2-1.7B-Instruct"
FRONTEND_DIR = pathlib.Path(__file__).parent / "frontend"

# Container image with vLLM + frontend baked in
vllm_image = (
    modal.Image.debian_slim(python_version="3.11")
    .pip_install("vllm", "fastapi[standard]")
    .add_local_file(
        FRONTEND_DIR / "index.html",
        remote_path="/frontend/index.html",
        copy=True,
    )
)

SYSTEM_PROMPT = """You are a conversational AI assistant named SmolLM. Your job is to answer the user's questions clearly and helpfully. 

Rules:
- Always respond AS the assistant, never as the user
- Never repeat or continue the user's message
- Answer questions directly
- Be concise and friendly"""


# ---------------------------------------------------------------------------
# Inference class
# ---------------------------------------------------------------------------

@app.cls(
    image=vllm_image,
    gpu="A10G",
    scaledown_window=3600,
)
class Model:
    """Wraps vLLM for single-shot text generation."""

    @modal.enter()
    def load_model(self):
        from vllm import LLM, SamplingParams  # noqa: F401
        self.llm = LLM(model=MODEL_NAME)
        self.SamplingParams = SamplingParams

    def _format_prompt(self, user_msg: str) -> str:
        """Wrap user input in a chat template with system prompt."""
        return (
            f"<|im_start|>system\n{SYSTEM_PROMPT}<|im_end|>\n"
            f"<|im_start|>user\n{user_msg}<|im_end|>\n"
            f"<|im_start|>assistant\n"
        )

    # ---- POST /generate ----
    @modal.fastapi_endpoint(method="POST")
    def generate(self, item: dict):
        prompt = item.get("prompt", "")
        temperature = float(item.get("temperature", 0.7))
        max_tokens = int(item.get("max_tokens", 256))

        formatted = self._format_prompt(prompt)
        params = self.SamplingParams(
            temperature=temperature,
            max_tokens=max_tokens,
            stop=["<|im_end|>"],
        )
        outputs = self.llm.generate([formatted], params)
        text = outputs[0].outputs[0].text.strip()

        return {"response": text}

    # ---- GET /info — model metadata ----
    @modal.fastapi_endpoint(method="GET")
    def info(self):
        return {"model": MODEL_NAME, "backend": "modal"}

    # ---- GET /ui — serve the web UI ----
    @modal.fastapi_endpoint(method="GET")
    def ui(self):
        from fastapi.responses import HTMLResponse

        html_path = pathlib.Path("/frontend/index.html")
        html = html_path.read_text(encoding="utf-8")
        return HTMLResponse(content=html, status_code=200)


# ---------------------------------------------------------------------------
# Quick CLI smoke-test
# ---------------------------------------------------------------------------

@app.local_entrypoint()
def main():
    model = Model()
    result = model.generate.remote({"prompt": "Explain what a neural network is in 2 sentences.", "temperature": 0.7, "max_tokens": 128})
    print("Response:", result["response"])

