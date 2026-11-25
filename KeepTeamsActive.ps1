<#
.SYNOPSIS
    KeepTeamsActive.ps1
    Keeps Microsoft Teams status permanently 'Available' (Green checkmark)
    by simulating micro-activity and preventing Windows sleep / idle lock.

.DESCRIPTION
    - Moves mouse cursor by 1 pixel and back (undetectable, triggers OS idle reset).
    - Sends an F15 keypress via WScript.Shell (harmless virtual key, no side effects).
    - Tells Windows to prevent display sleep / system idle sleep (SetThreadExecutionState).
    - Can be stopped at any time by pressing Ctrl + C or closing the console window.
#>

[CmdletBinding()]
param(
    [int]$IntervalSeconds = 60
)

# Set window title
[Console]::Title = "Microsoft Teams - Always Active"

# Try loading Windows sleep-blocker API (SetThreadExecutionState)
$sleepBlockerAvailable = $false
try {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public static class SleepBlocker {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern uint SetThreadExecutionState(uint esFlags);
        public const uint ES_CONTINUOUS = 0x80000000;
        public const uint ES_SYSTEM_REQUIRED = 0x00000001;
        public const uint ES_DISPLAY_REQUIRED = 0x00000002;

        public static void PreventSleep() {
            SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED);
        }
        public static void AllowSleep() {
            SetThreadExecutionState(ES_CONTINUOUS);
        }
    }
"@ -ErrorAction Stop
    $sleepBlockerAvailable = $true
} catch {
    # If compilation fails or is restricted by AppLocker, continue gracefully
    $sleepBlockerAvailable = $false
}

# Load System.Windows.Forms for cursor positioning
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create WScript.Shell for virtual keypresses
$wscript = New-Object -ComObject Wscript.Shell

# Banner
Clear-Host
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "         MICROSOFT TEAMS - ALWAYS ACTIVE (GREEN)            " -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Status   : " -NoNewline; Write-Host "ACTIVE (Running)" -ForegroundColor Green
Write-Host " Interval : " -NoNewline; Write-Host "Every $IntervalSeconds seconds" -ForegroundColor Yellow
Write-Host " Methods  : " -NoNewline; Write-Host "1px Micro-Nudge + Virtual F15 Key" -ForegroundColor White
if ($sleepBlockerAvailable) {
    Write-Host " Display  : " -NoNewline; Write-Host "Screen Sleep / Auto-Lock Blocked" -ForegroundColor Green
} else {
    Write-Host " Display  : " -NoNewline; Write-Host "Standard Idle Prevention" -ForegroundColor Gray
}
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " >>> TO STOP: Press [Ctrl + C] or simply close this window! <<<" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$count = 0
$startTime = Get-Date

try {
    # Keep screen awake initially
    if ($sleepBlockerAvailable) {
        [SleepBlocker]::PreventSleep()
    }

    while ($true) {
        $count++
        $timestamp = (Get-Date).ToString("hh:mm:ss tt")
        $elapsed = (Get-Date) - $startTime
        $elapsedFormatted = "{0:D2}h:{1:D2}m:{2:D2}s" -f $elapsed.Hours, $elapsed.Minutes, $elapsed.Seconds

        # 1. Micro mouse wiggle (1 pixel right, then back)
        try {
            $pos = [System.Windows.Forms.Cursor]::Position
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(($pos.X + 1), $pos.Y)
            Start-Sleep -Milliseconds 25
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($pos.X, $pos.Y)
        } catch {
            # In case cursor is on a secondary screen edge, fallback silently
        }

        # 2. Virtual keypress: F15 (has no mapped function in apps, resets Teams idle timer)
        try {
            $wscript.SendKeys("{F15}")
        } catch {}

        # 3. Refresh display sleep prevention
        if ($sleepBlockerAvailable) {
            [SleepBlocker]::PreventSleep()
        }

        # Update console title with live stats
        [Console]::Title = "Teams Active | Running: $elapsedFormatted | Pings: $count"

        # Log line
        Write-Host "[$timestamp] " -NoNewline -ForegroundColor DarkGray
        Write-Host "#$count " -NoNewline -ForegroundColor Yellow
        Write-Host "- Keep-alive ping sent (Teams Active) " -NoNewline -ForegroundColor Green
        Write-Host "[Uptime: $elapsedFormatted]" -ForegroundColor DarkCyan

        # Wait for the next interval
        Start-Sleep -Seconds $IntervalSeconds
    }
} finally {
    # Restore normal Windows sleep behavior upon exit
    if ($sleepBlockerAvailable) {
        try {
            [SleepBlocker]::AllowSleep()
        } catch {}
    }
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " Script stopped. Microsoft Teams status restored to normal. " -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Red
}
