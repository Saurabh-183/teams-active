# Microsoft Teams - Always Active (Green)

A lightweight, safe, and reliable script to keep your Microsoft Teams status permanently **Available (Active / Green Checkmark)** until you choose to stop it.

---

## 🚀 How to Run

1. Simply **double-click** [`KeepTeamsActive.bat`](file:///c:/Users/saura/Desktop/Practice/Teams-online/KeepTeamsActive.bat).
2. A command prompt window will open showing:
   - Status: **ACTIVE (Running)**
   - Live activity counter & uptime
   - Keep-alive pings sent every 60 seconds
3. As long as this window is open, Teams will stay **Available (Green)**.

---

## 🛑 How to Stop

To stop the script at any time:
- Press **`Ctrl + C`** inside the console window, or
- Simply **close (click X)** the console window.

Your computer's normal idle timer and sleep behavior will immediately be restored.

---

## ⚙️ How It Works (Safe & Non-Intrusive)

Most simple scripts either flash your keyboard lights (CapsLock/ScrollLock) or disrupt your mouse cursor. This script uses three safe methods simultaneously:

1. **Micro-Cursor Nudge (1 Pixel)**:
   - Moves the mouse cursor by 1 pixel and immediately moves it back within 25 milliseconds.
   - It is visually imperceptible to you, but triggers Windows' `WM_MOUSEMOVE` event, resetting Teams' 5-minute inactivity timer.
2. **Harmless Virtual Key (F15)**:
   - Sends a virtual `F15` keypress.
   - Windows recognizes `F15` as user keyboard input, but virtually no application has any shortcut or character assigned to F15 (unlike CapsLock or ScrollLock, no LED lights flash, and no characters are typed).
3. **Screen Sleep & Auto-Lock Prevention**:
   - Uses the official Windows `SetThreadExecutionState` API to prevent corporate screensavers, display sleep, or system lock timeouts while running.

---

## 🛠️ Files Included

- [`KeepTeamsActive.bat`](file:///c:/Users/saura/Desktop/Practice/Teams-online/KeepTeamsActive.bat): 1-click batch launcher (bypasses PowerShell execution policies automatically).
- [`KeepTeamsActive.ps1`](file:///c:/Users/saura/Desktop/Practice/Teams-online/KeepTeamsActive.ps1): The main PowerShell script with live console dashboard.
