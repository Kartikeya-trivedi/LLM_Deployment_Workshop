@echo off
setlocal EnableDelayedExpansion
title LLM Workshop - Ollama Setup

echo ==================================================
echo   MLSA KIIT LLM Deployment Workshop - Ollama Setup
echo ==================================================
echo.

:: ---- Check Python ----
python --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] Python is not installed or not in PATH.
    echo         Download from https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [OK] Python found

:: ---- Check / Install Ollama ----
ollama --version >nul 2>&1
if !errorlevel! neq 0 (
    echo Ollama not found. Installing Ollama...
    winget install --id Ollama.Ollama -e --accept-source-agreements --accept-package-agreements
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to install Ollama via winget.
        echo         Download manually from https://ollama.com/download
        pause
        exit /b 1
    )
    call :RefreshPath
    ollama --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo [ERROR] Ollama was installed but is not yet visible in PATH.
        echo         Please close VS Code completely, reopen it, and run this script again.
        echo         If the above step didn't fix the issue, restart your PC and re-run the script.
        pause
        exit /b 1
    )
)
echo [OK] Ollama found

:: ---- Check / Install uv ----
echo.
echo [1/5] Checking for uv...
uv --version >nul 2>&1
if !errorlevel! neq 0 (
    echo uv not found. Installing uv...
    winget install --id=astral-sh.uv -e --accept-source-agreements --accept-package-agreements
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to install uv.
        pause
        exit /b 1
    )
    call :RefreshPath
    uv --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo [ERROR] uv was installed but is not yet visible in PATH.
        echo         Please close VS Code completely, reopen it, and run this script again.
        pause
        exit /b 1
    )
)
echo [OK] uv installed

:: ---- Init project (creates pyproject.toml + .venv) ----
echo.
echo [2/5] Initializing project...
if not exist pyproject.toml (
    uv init --no-readme
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to initialize project.
        pause
        exit /b 1
    )
) else (
    echo pyproject.toml already exists, skipping init.
)
echo [OK] Project initialized

:: ---- Add Python deps ----
echo.
echo [3/5] Adding Python dependencies...
uv add fastapi uvicorn httpx
if !errorlevel! neq 0 (
    echo [ERROR] Failed to add dependencies.
    pause
    exit /b 1
)
echo [OK] Dependencies added

:: ---- Ensure Ollama service is running, then pull model ----
echo.
echo [4/5] Pulling Llama 3.2 3B model (this may take a few minutes)...

:: Check whether the Ollama API is already reachable
curl -sf http://localhost:11434/ >nul 2>&1
if !errorlevel! neq 0 (
    echo Ollama service is not running. Starting it now...
    start "" ollama serve
    echo Waiting for Ollama to be ready...
    set "_ready=0"
    for /L %%i in (1,1,15) do (
        if !_ready!==0 (
            timeout /t 2 /nobreak >nul
            curl -sf http://localhost:11434/ >nul 2>&1
            if !errorlevel!==0 set "_ready=1"
        )
    )
    if !_ready!==0 (
        echo [ERROR] Ollama service did not start within 30 seconds.
        echo         Try starting Ollama manually and re-run this script.
        pause
        exit /b 1
    )
)
echo [OK] Ollama service is running

ollama pull llama3.2:3b
if !errorlevel! neq 0 (
    echo [ERROR] Failed to pull model.
    pause
    exit /b 1
)
echo [OK] Model ready

:: ---- Launch server ----
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
endlocal
exit /b 0

:: ===========================================================
:: Subroutine: refresh PATH from the registry so that newly
:: installed programs (Ollama, uv) are found in the current
:: session — this is the key fix for VS Code's terminal.
:: ===========================================================
:RefreshPath
echo Refreshing PATH from registry...
set "NEWPATH="
for /f "tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "NEWPATH=%%B"
for /f "tokens=2,*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "NEWPATH=!NEWPATH!;%%B"
if defined NEWPATH set "PATH=!NEWPATH!"
goto :eof
