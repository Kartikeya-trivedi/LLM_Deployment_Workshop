```
#!/bin/bash

# LLM Workshop - Modal Setup (Linux)
# Translated from setup_modal.bat

set -u # Exit on undefined variables

echo "=================================================="
echo "  MLSA KIIT LLM Deployment Workshop - Modal Setup "
echo "=================================================="
echo

# 1. Check for uv (fast Python package manager)
echo "[1/4] Checking for uv..."
if ! command -v uv &> /dev/null; then
    echo "[INFO] uv not found, attempting installation..."
    if ! command -v curl &> /dev/null; then
        echo "[ERROR] curl is not installed. Please install curl first."
        exit 1
    fi
    
    # Install uv via the official shell script
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        echo "[OK] uv installation script completed."
        
        # Add uv to PATH for the current session
        # Typically installed to ~/.local/bin
        export PATH="$HOME/.local/bin:$PATH"
        
        if ! command -v uv &> /dev/null; then
            echo "[ERROR] uv was installed but is not in the PATH."
            echo "Please add ~/.local/bin to your PATH or restart your terminal."
            exit 1
        fi
    else
        echo "[ERROR] Failed to install uv."
        exit 1
    fi
else
    echo "[SKIP] uv is already installed."
fi

# 2. Init project (creates pyproject.toml + .venv)
echo
echo "[2/4] Initializing project..."
if [ ! -f pyproject.toml ]; then
    if ! uv init --no-readme; then
        echo "[ERROR] Failed to initialize project."
        exit 1
    fi
    echo "[OK] Project initialized"
else
    echo "      pyproject.toml already exists, skipping init."
fi

# 3. Add Modal
echo
echo "[3/4] Adding Modal dependency..."
if ! uv add modal; then
    echo "[ERROR] Failed to add Modal."
    exit 1
fi
echo "[OK] Modal added"

# 4. Modal auth
echo
echo "[4/4] Authenticating with Modal..."
echo "      A browser window will open — log in to your Modal account."
if ! uv run modal setup; then
    echo "[ERROR] Modal setup failed."
    exit 1
fi
echo "[OK] Modal authenticated"

# Deploy and capture output
echo
echo "Deploying to Modal (This will take a long time so please wait)..."

# Ensure UTF-8
export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8

DEPLOY_LOG=$(mktemp)
if ! uv run modal deploy modal_model.py 2>&1 | tee "$DEPLOY_LOG"; then
    echo "[ERROR] Deployment failed."
    rm -f "$DEPLOY_LOG"
    exit 1
fi

# Extract the UI URL (look for .modal.run URLs containing "ui")
# We use sed to remove ANSI escape codes before grepping
UI_URL=$(sed 's/\x1B\[[0-9;]*[JKmsu]//g' "$DEPLOY_LOG" | grep -oE 'https://[a-zA-Z0-9./?=_-]*modal\.run[a-zA-Z0-9./?=_-]*' | grep "ui" | head -n 1)

rm -f "$DEPLOY_LOG"

echo
echo "============================================"
echo "  Deployment complete!"
if [ -n "$UI_URL" ]; then
    echo "  Opening chat UI: $UI_URL"
    if command -v xdg-open &> /dev/null; then
        xdg-open "$UI_URL"
    elif command -v open &> /dev/null; then
        open "$UI_URL"
    else
        echo "  Please open the URL manually in your browser."
    fi
else
    echo "  Check the URLs printed above."
    echo "  Open the UI URL in your browser."
fi
echo "============================================"
echo
echo "  To re-deploy later:"
echo "    uv run modal deploy modal_model.py"
echo "============================================"

```