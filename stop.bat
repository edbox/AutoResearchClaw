@echo off
setlocal EnableExtensions EnableDelayedExpansion
title AutoResearchClaw - Stop All Related Processes

cd /d "%~dp0"

chcp 65001 >nul
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8

echo ================================================
echo   AutoResearchClaw - Stop Related Processes
echo ================================================
echo.

echo [INFO] Dang tim va dung cac process lien quan...

REM 1) Stop Python processes whose command line references project/researchclaw/streamlit
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='SilentlyContinue';" ^
  "$targets=@('researchclaw','AutoResearchClaw','streamlit','app.py','config.arc.yaml');" ^
  "$procs=Get-CimInstance Win32_Process | Where-Object { $_.Name -match '^(python|python3|py|streamlit)(\.exe)?$' -or $_.CommandLine -match 'researchclaw|AutoResearchClaw|streamlit|app\.py|config\.arc\.yaml' };" ^
  "$killed=0;" ^
  "foreach($p in $procs){" ^
  "  $cmd=[string]$p.CommandLine;" ^
  "  $name=[string]$p.Name;" ^
  "  $hit=$false;" ^
  "  foreach($t in $targets){ if($cmd -match [regex]::Escape($t)){ $hit=$true; break } }" ^
  "  if($hit -or $name -match 'streamlit'){" ^
  "    try { Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop; $killed++ } catch {}" ^
  "  }" ^
  "}" ^
  "Write-Host ('[INFO] Da dung ' + $killed + ' process Python/Streamlit lien quan.')"

REM 2) Stop streamlit executable if running standalone
taskkill /F /IM streamlit.exe >nul 2>&1

REM 3) Optionally stop Docker containers started by project (name filter)
for /f "usebackq delims=" %%i in (`docker ps --format "{{.ID}} {{.Names}}" 2^>nul ^| findstr /I "researchclaw autoresearchclaw"`) do (
  for /f "tokens=1" %%c in ("%%i") do docker stop %%c >nul 2>&1
)

echo [OK] Lenh stop da thuc thi xong.
echo [NOTE] Neu ban dang chay process khac bang python, hay mo Task Manager de kiem tra lai.
pause
endlocal
