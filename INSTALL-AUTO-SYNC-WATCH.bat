@echo off
title DemonCore - install file-watcher auto-sync
cd /d "%~dp0"

echo.
echo ============================================================
echo   Install FILE-WATCHER auto-sync (only pushes on activity)
echo ============================================================
echo.
echo This replaces the old 5-minute periodic task with a file-watcher
echo that only runs git add/commit/push when files actually change.
echo Debounced 60 seconds so a burst of edits = one commit.
echo.
echo Idle = no push. Active editing = one commit per burst.
echo.
choice /c YN /m "Install/replace the auto-sync task"
if errorlevel 2 goto CANCEL

echo.
echo [1/2] Removing old periodic task (if present)...
schtasks /Delete /TN "DemonCore-AutoSync" /F 2>nul

echo.
echo [2/2] Creating new watcher task (runs at logon, background)...
schtasks /Create /F /SC ONLOGON ^
    /TN "DemonCore-AutoSync-Watch" ^
    /TR "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%~dp0AUTO-SYNC-WATCH.ps1\"" ^
    /IT
if errorlevel 1 goto FAIL

echo.
echo ============================================================
echo   SUCCESS
echo ============================================================
echo.
echo Watcher installed. It'll auto-start on next logon.
echo To start it now WITHOUT logging out, run:
echo   schtasks /Run /TN DemonCore-AutoSync-Watch
echo.
echo Manual controls:
echo   schtasks /Query  /TN DemonCore-AutoSync-Watch     -- status
echo   schtasks /Run    /TN DemonCore-AutoSync-Watch     -- start now
echo   schtasks /End    /TN DemonCore-AutoSync-Watch     -- stop
echo   schtasks /Delete /TN DemonCore-AutoSync-Watch /F  -- uninstall
echo.
echo Log:  %~dp0AUTO-SYNC.log
echo.
goto DONE

:FAIL
echo.
echo [ERROR] Task install failed. Try running this .bat as Administrator.
goto DONE

:CANCEL
echo Cancelled.

:DONE
pause
