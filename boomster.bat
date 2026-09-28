@echo off
setlocal EnableExtensions
title Game Mode


:: ============================================================
:: TODO BEFORE FIRST RUN
:: [ ] Fill GAMELIST with the .exe names of your games
:: [ ] Review PROCESSLIST (apps closed while gaming)
:: [ ] Review SERVICELIST (services stopped while gaming)
:: [ ] Check the RAMMAP path in the config section
:: ============================================================


:: ============================================================
:: 0. ELEVATION
:: ============================================================

:: Elevation
:: If not admin, relaunch this file elevated + minimized and close this copy
fltmc >nul 2>&1 && goto :Elevated
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs -WindowStyle Minimized"
exit /b


:Elevated

:: Working folder
:: An elevated cmd starts in System32, so go back to the script folder
cd /d "%~dp0"


:: ============================================================
:: 1. CONFIG
:: ============================================================

:: Config
:: Path to RAMMap
set "RAMMAP=C:\Tools\Sysinternals\RAMMap64.exe"


:: Config
:: Power plan GUIDs (Balanced = normal, High performance = gaming)
set "PLAN_BALANCED=381b4222-f694-41f0-9685-ff5bb260df2e"
set "PLAN_HIGH=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"


:: Config
:: How often (seconds) to look for a running game
set "POLL_SECONDS=5"


:: List
:: GAMELIST - game executables to watch for
:: Separate with spaces. Wrap a name in quotes if it contains a space
set "GAMELIST=eldenring.exe cyberpunk2077.exe cs2.exe GTA5.exe RDR2.exe witcher3.exe"
:: Add more games by appending, e.g. remove :: from the line below
:: set "GAMELIST=%GAMELIST% RocketLeague.exe Overwatch.exe"


:: List
:: PROCESSLIST - apps to close while gaming
set "PROCESSLIST=OneDrive.exe Widgets.exe PhoneExperienceHost.exe ms-teams.exe"
:: Optional extras, remove :: to enable
:: set "PROCESSLIST=%PROCESSLIST% msedge.exe chrome.exe"
:: set "PROCESSLIST=%PROCESSLIST% Discord.exe Spotify.exe"
:: set "PROCESSLIST=%PROCESSLIST% GoogleUpdate.exe"


:: List
:: SERVICELIST - service names (not display names) to stop while gaming
:: Only services that were running get restarted afterwards
set "SERVICELIST=SysMain WSearch DiagTrack"
:: Optional extras, remove :: to enable
:: set "SERVICELIST=%SERVICELIST% Spooler"
:: set "SERVICELIST=%SERVICELIST% wuauserv BITS DoSvc"
:: set "SERVICELIST=%SERVICELIST% TabletInputService"


:: List
:: RAMFLAGS - RAMMap lists to empty, run one by one (deep clean)
:: Ew = working sets, Es = system working set, Em = modified list
:: Et = standby list, E0 = priority 0 standby list
set "RAMFLAGS=-Ew -Es -Em -Et -E0"


:: ============================================================
:: 2. WAIT FOR A GAME
:: ============================================================

echo Game Mode is watching for a game from GAMELIST ...

:WaitForGame

:: Detect game
:: Check games in GAMELIST in order, skip the rest once one is found
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
:: 3. BOOST
:: ============================================================

:: Power
:: Switch to High performance (recreate the plan if Windows hid it)
echo Switching to High performance ...
powercfg /setactive %PLAN_HIGH% >nul 2>&1
if errorlevel 1 (
    powercfg /duplicatescheme %PLAN_HIGH% %PLAN_HIGH% >nul 2>&1
    powercfg /setactive %PLAN_HIGH% >nul 2>&1
)


:: Processes
:: Kill everything in PROCESSLIST (never the detected game itself)
echo Closing background processes ...
for %%P in (%PROCESSLIST%) do (
    if /i not "%%~P"=="%ACTIVE_GAME%" taskkill /f /im "%%~P" >nul 2>&1
)


:: Services
:: Stop each running service in SERVICELIST and remember that it was running
:: net stop /y also stops services that depend on it
echo Stopping services ...
for %%S in (%SERVICELIST%) do (
    sc query "%%~S" 2>nul | find "RUNNING" >nul && (
        set "WAS_RUNNING_%%~S=1"
        net stop "%%~S" /y >nul 2>&1
    )
)


:: Explorer
:: Kill the shell to free RAM (no taskbar or desktop until revert)
echo Stopping explorer ...
taskkill /f /im explorer.exe >nul 2>&1


:: RAM
:: Deep clean with RAMMap, one list at a time
:: Done last so the memory freed above is cleaned too
echo Clearing RAM ...
if not exist "%RAMMAP%" (
    echo RAMMap not found at %RAMMAP% - skipping RAM clean
) else (
    for %%F in (%RAMFLAGS%) do (
        start "" /wait "%RAMMAP%" -accepteula %%F
    )
)


:: ============================================================
:: 4. WAIT FOR GAME EXIT OR ENTER
:: ============================================================

:: Wait
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
:: 5. REVERT
:: ============================================================

:: Explorer
:: Bring the desktop and taskbar back first
:: If explorer ends up running as admin, swap in the runas line below
start "" "%SystemRoot%\explorer.exe"
:: runas /trustlevel:0x20000 explorer.exe


:: Power
:: Back to Balanced
powercfg /setactive %PLAN_BALANCED% >nul 2>&1


:: Services
:: Start only the services that were running before we stopped them
for %%S in (%SERVICELIST%) do (
    if defined WAS_RUNNING_%%~S net start "%%~S" >nul 2>&1
)


:: Processes
:: Closed apps are not relaunched - open them yourself if you need them


echo Back to normal.
timeout /t 3 /nobreak >nul
exit /b
