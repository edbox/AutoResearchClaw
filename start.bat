@echo off
setlocal EnableExtensions
title AutoResearchClaw - Windows 11 All-in-One

cd /d "%~dp0"
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
if not errorlevel 1 goto PY_OK
py --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Khong tim thay Python.
    echo [HINT] Cai Python 3.11+ va bat "Add python.exe to PATH".
    pause
    exit /b 1
)
:PY_OK

REM 2) Ensure source exists
if exist "pyproject.toml" goto SOURCE_READY
if exist "AutoResearchClaw\pyproject.toml" (
    cd /d "AutoResearchClaw"
    goto SOURCE_READY
)

echo [INFO] Chua tim thay source. Dang tai tu GitHub: https://github.com/edbox/AutoResearchClaw
where git >nul 2>&1
if errorlevel 1 goto DOWNLOAD_ZIP

git clone https://github.com/edbox/AutoResearchClaw.git AutoResearchClaw
if not errorlevel 1 goto ENTER_SOURCE

echo [WARN] Clone that bai. Repo co the can dang nhap GitHub.
set /p GH_USER=Nhap GitHub username: 
if "%GH_USER%"=="" (
    echo [ERROR] Username khong duoc de trong.
    pause
    exit /b 1
)
set /p GH_TOKEN=Nhap GitHub token/password: 
if "%GH_TOKEN%"=="" (
    echo [ERROR] Token/password khong duoc de trong.
    pause
    exit /b 1
)
call git clone https://%%GH_USER%%:%%GH_TOKEN%%@github.com/edbox/AutoResearchClaw.git AutoResearchClaw
if errorlevel 1 (
    echo [ERROR] Clone source that bai ngay ca khi da nhap tai khoan.
    pause
    exit /b 1
)
goto ENTER_SOURCE

:DOWNLOAD_ZIP
echo [WARN] Khong tim thay git. Thu tai ban zip...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://github.com/edbox/AutoResearchClaw/archive/refs/heads/main.zip' -OutFile 'AutoResearchClaw.zip'"
if errorlevel 1 (
    echo [ERROR] Tai source that bai.
    echo [HINT] Neu repo private, hay cai git va chay lai de nhap tai khoan GitHub.
    pause
    exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path 'AutoResearchClaw.zip' -DestinationPath '.' -Force"
if exist "AutoResearchClaw-main" ren "AutoResearchClaw-main" "AutoResearchClaw"
del /f /q "AutoResearchClaw.zip" >nul 2>&1

:ENTER_SOURCE
if not exist "AutoResearchClaw\pyproject.toml" (
    echo [ERROR] Khong tim thay source hop le sau khi tai.
    pause
    exit /b 1
)
if errorlevel 1 (
    py --version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Khong tim thay Python.
        echo [HINT] Cai Python 3.11+ va bat "Add python.exe to PATH".
        pause
        exit /b 1
    )
)

REM 2) Ensure source exists (or download from GitHub)
if exist "pyproject.toml" goto :SOURCE_READY
if exist "AutoResearchClaw\\pyproject.toml" (
    cd /d "AutoResearchClaw"
    goto :SOURCE_READY
)

echo [INFO] Chua tim thay source AutoResearchClaw. Bat dau tai source tu GitHub...
where git >nul 2>&1
if errorlevel 1 (
    echo [WARN] Khong tim thay git. Thu tai zip tu GitHub...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://github.com/edbox/AutoResearchClaw/archive/refs/heads/main.zip' -OutFile 'AutoResearchClaw.zip'"
    if errorlevel 1 (
        echo [ERROR] Tai source that bai.
        echo [HINT] Co the repo can dang nhap GitHub. Hay cai git va chay lai de nhap tai khoan.
        pause
        exit /b 1
    )
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path 'AutoResearchClaw.zip' -DestinationPath '.' -Force"
    if exist "AutoResearchClaw-main" ren "AutoResearchClaw-main" "AutoResearchClaw"
    del /f /q "AutoResearchClaw.zip" >nul 2>&1
    if not exist "AutoResearchClaw\\pyproject.toml" (
        echo [ERROR] Khong giai nen duoc source dung cau truc.
        pause
        exit /b 1
    )
    cd /d "AutoResearchClaw"
    goto :SOURCE_READY
)

echo [INFO] Dang clone source: https://github.com/edbox/AutoResearchClaw
git clone https://github.com/edbox/AutoResearchClaw.git AutoResearchClaw
if errorlevel 1 (
    echo [WARN] Clone khong thanh cong. Repo co the yeu cau dang nhap GitHub.
    set /p GH_USER=Nhap GitHub username: 
    set /p GH_TOKEN=Nhap GitHub token/password: 
    if "!GH_USER!"=="" (
        echo [ERROR] Username khong duoc de trong.
        pause
        exit /b 1
    )
    if "!GH_TOKEN!"=="" (
        echo [ERROR] Token/password khong duoc de trong.
        pause
        exit /b 1
    )
    git clone https://!GH_USER!:!GH_TOKEN!@github.com/edbox/AutoResearchClaw.git AutoResearchClaw
    if errorlevel 1 (
        echo [ERROR] Clone source that bai ngay ca khi da nhap tai khoan.
        pause
        exit /b 1
    )
)

cd /d "AutoResearchClaw"

:SOURCE_READY
if not exist "pyproject.toml" (
    echo [ERROR] Source khong hop le: thieu pyproject.toml.
    pause
    exit /b 1
)

REM 3) Update source from GitHub
where git >nul 2>&1
if errorlevel 1 (
    echo [WARN] Khong tim thay git. Bo qua cap nhat source.
) else (
    if exist ".git" (
        echo [INFO] Dang cap nhat source (git pull --ff-only)...
        git pull --ff-only
        if errorlevel 1 echo [WARN] git pull that bai. Tiep tuc voi source hien tai.
    ) else (
        echo [WARN] Khong co .git. Bo qua cap nhat source.
    )
)

REM 4) Create .venv
REM 3) Update source from GitHub (if this is a git clone)
where git >nul 2>&1
if errorlevel 1 (
    echo [WARN] Khong tim thay git. Bo qua buoc cap nhat source.
) else (
    if exist ".git" (
        echo [INFO] Dang cap nhat source tu GitHub (git pull --ff-only)...
        git pull --ff-only
        if errorlevel 1 (
            echo [WARN] Khong the git pull tu remote. Tiep tuc voi source hien tai.
        )
    ) else (
        echo [WARN] Thu muc hien tai khong phai git repo (.git khong ton tai). Bo qua cap nhat source.
    )
)

REM 4) Create virtual environment if missing
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

REM 5) Install dependencies
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

REM 6) Setup + init config
echo [INFO] Dang chay researchclaw setup...
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

REM 7) API key + topic
if "%OPENAI_API_KEY%"=="" set /p OPENAI_API_KEY=Nhap OPENAI_API_KEY: 
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

REM 8) Run
REM 8) Run pipeline
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
