@echo off
setlocal EnableExtensions
title Game Mode


:: ============================================================
:: SETUP
:: ============================================================

:: Elevation
:: Relaunch as Administrator, minimized, and close this copy
fltmc >nul 2>&1 && goto :Elevated
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs -WindowStyle Minimized"
exit /b

:Elevated

:: Working folder
:: An elevated cmd starts in System32, so go back to the script folder
cd /d "%~dp0"


:: ============================================================
:: CONFIG
:: ============================================================

:: Settings
:: RAMMap path, Balanced and High performance plan GUIDs, game check interval in seconds
set "RAMMAP=C:\Tools\Sysinternals\RAMMap64.exe"
set "PLAN_BALANCED=381b4222-f694-41f0-9685-ff5bb260df2e"
set "PLAN_HIGH=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
set "POLL_SECONDS=5"

:: Game list
:: Games to watch for. Space separated, wrap a name in quotes if it has a space
:: Every commented-out set line below is an optional extra: remove :: to enable it
set "GAMELIST=eldenring.exe cs2.exe RDR2.exe"


:: Process list
:: Apps to close while gaming
set "PROCESSLIST="

:: Service list
:: Service names (not display names) to stop while gaming
set "SERVICELIST="

:: RAM flag list
:: RAMMap lists to empty, one by one: working sets, system working set, modified, standby, priority 0 standby
set "RAMFLAGS=-Ew -Es -Em -Et -E0"


:: ============================================================
:: WATCH
:: ============================================================

echo Game Mode is watching for a game from the game list ...

:WaitForGame
:: Game detection
:: Check games in order and stop at the first one running, otherwise retry after the interval
set "ACTIVE_GAME="
for %%G in (%GAMELIST%) do (
    if not defined ACTIVE_GAME tasklist /fi "imagename eq %%~G" /fo csv /nh 2>nul | find /i "%%~G" >nul && set "ACTIVE_GAME=%%~G"
)
if defined ACTIVE_GAME goto :GameDetected
timeout /t %POLL_SECONDS% /nobreak >nul
goto :WaitForGame

:GameDetected
echo Game detected: %ACTIVE_GAME%

:: Game name
:: Strip ".exe" because PowerShell's Get-Process wants the bare name
for %%A in ("%ACTIVE_GAME%") do set "ACTIVE_GAME_NAME=%%~nA"


:: ============================================================
:: BOOST
:: ============================================================

:: High performance
:: Switch plan, recreating it if Windows hid it
echo Switching to High performance ...
powercfg /setactive %PLAN_HIGH% >nul 2>&1
if errorlevel 1 (
    powercfg /duplicatescheme %PLAN_HIGH% %PLAN_HIGH% >nul 2>&1
    powercfg /setactive %PLAN_HIGH% >nul 2>&1
)

:: Close processes
:: Kill every app in the process list except the detected game. They are not relaunched afterwards
echo Closing background processes ...
for %%P in (%PROCESSLIST%) do (
    if /i not "%%~P"=="%ACTIVE_GAME%" taskkill /f /im "%%~P" >nul 2>&1
)

:: Stop services
:: Stop each running service and remember it was running. /y also stops its dependents
echo Stopping services ...
for %%S in (%SERVICELIST%) do (
    sc query "%%~S" 2>nul | find "RUNNING" >nul && (
        set "WAS_RUNNING_%%~S=1"
        net stop "%%~S" /y >nul 2>&1
    )
)

:: Stop explorer
:: Free its RAM. No taskbar or desktop until the revert
echo Stopping explorer ...
taskkill /f /im explorer.exe >nul 2>&1

:: Clear RAM
:: Deep clean with RAMMap, last so the memory freed above is cleaned too
echo Clearing RAM ...
if not exist "%RAMMAP%" (
    echo RAMMap not found at %RAMMAP% - skipping RAM clean
) else (
    for %%F in (%RAMFLAGS%) do (
        start "" /wait "%RAMMAP%" -accepteula %%F
    )
)


:: ============================================================
:: MONITOR
:: ============================================================

:: Wait for exit
:: Block until the game closes OR ENTER is pressed in this window
:: PowerShell exit code: 0 = game closed, 1 = ENTER pressed
echo.
echo Game Mode ON. Reverts when %ACTIVE_GAME% closes, or press ENTER here.
powershell -NoProfile -Command ^
    "$name = $env:ACTIVE_GAME_NAME;" ^
    "while ($true) {" ^
    "    if (-not (Get-Process -Name $name -ErrorAction SilentlyContinue)) { exit 0 }" ^
    "    if ([Console]::KeyAvailable -and [Console]::ReadKey($true).Key -eq 'Enter') { exit 1 }" ^
    "    Start-Sleep -Milliseconds 500" ^
    "}"
set "WAIT_RESULT=%errorlevel%"

if "%WAIT_RESULT%"=="1" (echo ENTER pressed - reverting ...) else (echo Game closed - reverting ...)


:: ============================================================
:: REVERT
:: ============================================================

:: Restore explorer
:: Bring the desktop back first. If explorer runs as admin, use the runas line instead
start "" "%SystemRoot%\explorer.exe"
:: runas /trustlevel:0x20000 explorer.exe

:: Restore power plan
:: Back to Balanced
powercfg /setactive %PLAN_BALANCED% >nul 2>&1

:: Restore services
:: Start only the services that were running before we stopped them
for %%S in (%SERVICELIST%) do (
    if defined WAS_RUNNING_%%~S net start "%%~S" >nul 2>&1
)

echo Back to normal.
timeout /t 3 /nobreak >nul
exit /b
