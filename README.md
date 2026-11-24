# Woz Shell 0.1
Independent Zune HD-inspired Android home application. Black/white typography, swipe between menu and Quickplay, app list, category shortcuts and native Settings links. No network permission, dependencies, or root requirement. Quickplay is a fixed shortcut list, not a media database. No custom lock screen or playback engine yet.

## Build without local Android SDK
Create a new GitHub repository, upload the contents of this folder including the hidden .github folder, then open Actions > Build Woz Shell > Run workflow. Download the WozShell artifact and extract app-debug.apk. Alternatively run `gradle assembleDebug` with Gradle 8.9, JDK 17 and Android SDK 35 installed. This source has not been compiled or tested in the current environment.

## Install
In PowerShell in C:\platform-tools, run `.\adb.exe install -r .\app-debug.apk` then `.\adb.exe shell am start -a android.settings.HOME_SETTINGS`. Choose Woz Shell. To revert choose Trebuchet in the same settings screen, then optionally `adb uninstall com.wozos.shell`.

Optional reset-a53.ps1 disables prior Woz color and QS column overlays and font/icon overlays, saving the overlay list first. It does not reset Android's wallpaper-derived palette. No system files modified. Keep Trebuchet installed.
