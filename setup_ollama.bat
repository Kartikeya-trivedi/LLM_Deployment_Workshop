@echo off
title LLM Workshop - Ollama Setup
color 0B

echo ============================================
echo   LLM Deployment Workshop - Ollama Setup
echo ============================================
echo.

:: Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH.
    echo         Download from https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [OK] Python found

:: Check Ollama
ollama --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Ollama is not installed.
    echo         Download from https://ollama.com/download
    echo.
    echo         After installing, re-run this script.
    pause
    exit /b 1
)
echo [OK] Ollama found

:: Install uv
echo.
echo [1/5] Installing uv (fast Python package manager)...
pip install uv
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install uv.
    pause
    exit /b 1
)
echo [OK] uv installed

:: Init project (creates pyproject.toml + .venv)
echo.
echo [2/5] Initializing project...
if not exist pyproject.toml (
    uv init --no-readme
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to initialize project.
        pause
        exit /b 1
    )
) else (
    echo       pyproject.toml already exists, skipping init.
)
echo [OK] Project initialized

:: Add Python deps
echo.
echo [3/5] Adding Python dependencies...
uv add fastapi uvicorn httpx
if %errorlevel% neq 0 (
    echo [ERROR] Failed to add dependencies.
    pause
    exit /b 1
)
echo [OK] Dependencies added

:: Pull model
echo.
echo [4/5] Pulling Llama 3.2 3B model (this may take a few minutes)...
ollama pull llama3.2:3b
if %errorlevel% neq 0 (
    echo [ERROR] Failed to pull model. Is Ollama running?
    echo         Start Ollama and try again.
    pause
    exit /b 1
)
echo [OK] Model ready

:: Launch server
echo.
echo [5/5] Starting local server...
echo.
echo ============================================
echo   Opening http://localhost:8000
echo   Press Ctrl+C to stop the server.
echo.
echo   To restart later:
echo     uv run python ollama_model.py
echo ============================================
echo.
start http://localhost:8000
uv run python ollama_model.py
pause
