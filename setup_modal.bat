@echo off
title LLM Workshop - Modal Setup

echo ==================================================
echo   MLSA KIIT LLM Deployment Workshop - Modal Setup
echo ==================================================
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

:: Install uv
echo.
echo [1/4] Installing uv (fast Python package manager)...
winget install --id=astral-sh.uv  -e
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install uv.
    pause
    exit /b 1
)
echo [OK] uv installed

:: Init project (creates pyproject.toml + .venv)
echo.
echo [2/4] Initializing project...
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

:: Add Modal
echo.
echo [3/4] Adding Modal dependency...
uv add modal
if %errorlevel% neq 0 (
    echo [ERROR] Failed to add Modal.
    pause
    exit /b 1
)
echo [OK] Modal added

:: Modal auth
echo.
echo [4/4] Authenticating with Modal...
echo       A browser window will open — log in to your Modal account.
uv run modal setup
if %errorlevel% neq 0 (
    echo [ERROR] Modal setup failed.
    pause
    exit /b 1
)
echo [OK] Modal authenticated

:: Deploy and capture output
echo.
echo Deploying to Modal...
chcp 65001 >nul 2>&1
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"
set "DEPLOY_LOG=%TEMP%\modal_deploy_output.txt"
uv run modal deploy modal_model.py > "%DEPLOY_LOG%" 2>&1
type "%DEPLOY_LOG%"

:: Extract the UI URL (look for .modal.run URLs containing "ui")
set "UI_URL="
for /f "tokens=*" %%A in ('findstr /i "modal.run" "%DEPLOY_LOG%"') do (
    for %%U in (%%A) do (
        echo %%U | findstr /i "modal.run" >nul
        if not errorlevel 1 (
            echo %%U | findstr /i "ui" >nul
            if not errorlevel 1 set "UI_URL=%%U"
        )
    )
)

echo.
echo ============================================
echo   Deployment complete!
if defined UI_URL (
    echo   Opening chat UI: %UI_URL%
    start "" "%UI_URL%"
) else (
    echo   Check the URLs printed above.
    echo   Open the UI URL in your browser.
)
echo.
echo   To re-deploy later:
echo     uv run modal deploy modal_model.py
echo ============================================
pause
