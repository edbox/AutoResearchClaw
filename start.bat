@echo off
setlocal EnableExtensions
chcp 65001 >nul
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8

title AutoResearchClaw (All-in-One)
cd /d "%~dp0"

echo ==========================================
echo   AutoResearchClaw (All-in-One)
echo ==========================================
echo.

REM 1) Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Khong tim thay Python.
    echo [HINT] Cai Python 3.11+ va Add python.exe vao PATH.
    pause
    exit /b 1
)

REM 2) Download source if missing
if not exist "AutoResearchClaw\pyproject.toml" (
    echo [INFO] Download AutoResearchClaw...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://github.com/edbox/AutoResearchClaw/archive/refs/heads/main.zip' -OutFile 'AutoResearchClaw.zip'"
    if errorlevel 1 (
        echo [ERROR] Khong tai duoc repo zip.
        pause
        exit /b 1
    )

    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path 'AutoResearchClaw.zip' -DestinationPath '.' -Force"
    if errorlevel 1 (
        echo [ERROR] Khong giai nen duoc repo.
        pause
        exit /b 1
    )

    if exist "AutoResearchClaw-main" ren "AutoResearchClaw-main" "AutoResearchClaw"
    del /f /q "AutoResearchClaw.zip" >nul 2>&1
)

if not exist "AutoResearchClaw\pyproject.toml" (
    echo [ERROR] Khong tim thay source hop le (thieu pyproject.toml).
    pause
    exit /b 1
)

cd /d "AutoResearchClaw"

REM 3) Create .venv if not exists
if not exist ".venv\Scripts\python.exe" (
    echo [INFO] Creating .venv...
    python -m venv .venv
    if errorlevel 1 (
        echo [ERROR] Khong tao duoc .venv.
        pause
        exit /b 1
    )
)

call ".venv\Scripts\activate.bat"
if errorlevel 1 (
    echo [ERROR] Khong kich hoat duoc .venv.
    pause
    exit /b 1
)

REM 4) Install dependencies
python -m pip install --upgrade pip setuptools wheel
if errorlevel 1 (
    echo [ERROR] Khong nang cap duoc pip/setuptools/wheel.
    pause
    exit /b 1
)

python -m pip install -e .
if errorlevel 1 (
    echo [ERROR] Khong cai duoc AutoResearchClaw.
    pause
    exit /b 1
)

REM 5) Setup and init config
researchclaw setup
if errorlevel 1 (
    echo [ERROR] researchclaw setup that bai.
    pause
    exit /b 1
)

if not exist "config.arc.yaml" (
    if exist "config.researchclaw.example.yaml" (
        copy /Y "config.researchclaw.example.yaml" "config.arc.yaml" >nul
    ) else (
        researchclaw init
        if errorlevel 1 (
            echo [ERROR] researchclaw init that bai.
            pause
            exit /b 1
        )
    )
)

REM 6) Prompt required values
if "%OPENAI_API_KEY%"=="" set /p OPENAI_API_KEY=Nhap OPENAI_API_KEY: 
if "%OPENAI_API_KEY%"=="" (
    echo [ERROR] OPENAI_API_KEY khong duoc de trong.
    pause
    exit /b 1
)

set /p RC_TOPIC=Nhap chu de nghien cuu: 
if "%RC_TOPIC%"=="" (
    echo [ERROR] Chu de khong duoc de trong.
    pause
    exit /b 1
)

REM 7) Run research pipeline (khong goi app.py/UI)
researchclaw run --config config.arc.yaml --topic "%RC_TOPIC%" --auto-approve
if errorlevel 1 (
    echo [ERROR] Chay pipeline that bai.
    pause
    exit /b 1
)

echo.
echo [OK] Hoan tat! Kiem tra thu muc artifacts\ de lay ket qua.
pause
endlocal
