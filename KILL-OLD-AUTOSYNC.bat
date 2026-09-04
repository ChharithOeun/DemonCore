@echo off
title DemonCore - kill old auto-sync task
echo.
echo Removing the OLD every-5-minute DemonCore-AutoSync task
echo (the one that flashes a PowerShell window every 5 minutes).
echo.
echo This does NOT install the new watcher — it just stops the flashing.
echo To install the on-activity watcher afterwards, run:
echo   INSTALL-AUTO-SYNC-WATCH.bat
echo.
choice /c YN /m "Remove the old task"
if errorlevel 2 goto CANCEL

schtasks /Delete /TN "DemonCore-AutoSync" /F
if errorlevel 1 (
    echo.
    echo Task was not present or already removed.
) else (
    echo.
    echo Old task removed. Flashing stops immediately.
    echo Remember: without the watcher installed, changes won't push
    echo automatically. Run PUSH-UPDATE.bat manually or install the
    echo watcher via INSTALL-AUTO-SYNC-WATCH.bat.
)
echo.
pause
exit /b

:CANCEL
echo Cancelled.
pause
