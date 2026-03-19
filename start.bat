@echo off
setlocal EnableExtensions EnableDelayedExpansion
title AutoResearchClaw - Windows 11 All-in-One

cd /d "%~dp0"

chcp 65001 >nul
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8

echo ==========================================
echo   AutoResearchClaw - Windows 11 All-in-One
echo ==========================================
echo.

REM 1) Check Python
python --version >nul 2>&1
if errorlevel 1 (
    py --version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Khong tim thay Python.
        echo [HINT] Cai Python 3.11+ va bat "Add python.exe to PATH".
        pause
        exit /b 1
    )
)

REM 2) Ensure script is run at project root
if not exist "pyproject.toml" (
    echo [ERROR] Khong tim thay pyproject.toml.
    echo [HINT] Hay dat start.bat trong thu muc goc cua AutoResearchClaw.
    pause
    exit /b 1
)

REM 3) Create virtual environment if missing
if not exist ".venv\Scripts\python.exe" (
    echo [INFO] Dang tao .venv...
    py -3.11 -m venv .venv 2>nul
    if errorlevel 1 (
        python -m venv .venv
        if errorlevel 1 (
            echo [ERROR] Khong tao duoc .venv.
            pause
            exit /b 1
        )
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
    echo [ERROR] Khong cai duoc AutoResearchClaw (pip install -e .).
    pause
    exit /b 1
)

REM 5) Setup + init config
echo [INFO] Dang chay researchclaw setup...
researchclaw setup
if errorlevel 1 (
    echo [ERROR] researchclaw setup that bai.
    pause
    exit /b 1
)

if not exist "config.arc.yaml" (
    if exist "config.researchclaw.example.yaml" (
        echo [INFO] Tao config.arc.yaml tu file mau...
        copy /Y "config.researchclaw.example.yaml" "config.arc.yaml" >nul
    ) else (
        echo [INFO] Tao config.arc.yaml bang researchclaw init...
        researchclaw init
        if errorlevel 1 (
            echo [ERROR] researchclaw init that bai.
            pause
            exit /b 1
        )
    )
)

REM 6) API key + topic
if "%OPENAI_API_KEY%"=="" (
    echo [INFO] Bien OPENAI_API_KEY chua duoc dat.
    set /p OPENAI_API_KEY=Nhap OPENAI_API_KEY: 
)

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

REM 7) Run pipeline
echo [INFO] Dang chay pipeline...
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
