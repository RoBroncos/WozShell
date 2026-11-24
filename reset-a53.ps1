$ErrorActionPreference = 'Stop'
$adb = 'C:\platform-tools\adb.exe'
if ((& $adb shell getprop ro.product.device).Trim() -ne 'gtowifi') { throw 'Wrong device' }
$overlays = & $adb shell cmd overlay list --user 0
$overlays | Set-Content "$PSScriptRoot\overlay-before-zune.txt"
foreach ($line in $overlays) {
 if ($line -match '^\[x\]\s+(com\.android\.shell:Woz(?:Accent|Dark|_system_\S+|QSColumns))$') {
  & $adb shell cmd overlay disable --user 0 $Matches[1]
 }
}
& $adb shell cmd overlay disable --user 0 org.lineageos.overlay.font.rubik
& $adb shell cmd overlay disable --user 0 com.android.theme.icon.roundedrect
& $adb shell cmd uimode night yes
