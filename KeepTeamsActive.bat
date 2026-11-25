@echo off
setlocal EnableDelayedExpansion
title Microsoft Teams - Always Active

:: Navigate to script directory
cd /d "%~dp0"

:: Check if KeepTeamsActive.ps1 exists
if not exist "%~dp0KeepTeamsActive.ps1" (
    echo [!] KeepTeamsActive.ps1 was not found in this folder.
    echo Please make sure KeepTeamsActive.ps1 is placed in the same folder as this .bat file.
    echo.
    pause
    exit /b 1
)

:: Run PowerShell script bypassing execution policy restrictions
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0KeepTeamsActive.ps1"

:: If terminated with an unexpected error code, pause so the user can see the error
if %ERRORLEVEL% neq 0 (
    if %ERRORLEVEL% neq 1 (
        echo.
        echo [!] Script exited with code %ERRORLEVEL%.
        pause
    )
)
