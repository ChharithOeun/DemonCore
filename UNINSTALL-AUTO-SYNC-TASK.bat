@echo off
title DemonCore - uninstall auto-sync
schtasks /Delete /TN "DemonCore-AutoSync" /F
echo.
pause
