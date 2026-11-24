$ErrorActionPreference='Stop'
$adb='C:\platform-tools\adb.exe'
& $adb root
& $adb wait-for-device
if ((& $adb shell id) -notmatch 'uid=0') { throw 'Root ADB required' }
$launcherPackage='com.android.launcher3'
& $adb shell pm enable --user 0 $launcherPackage
$component=(& $adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME -p $launcherPackage | Select-Object -Last 1).Trim()
if ($component -notmatch '^com\.android\.launcher3/') { throw 'Native launcher not found; leaving Woz Shell installed' }
& $adb shell cmd package set-home-activity --user 0 $component
if ($LASTEXITCODE -ne 0) { throw 'Cannot restore native launcher' }
& $adb shell am start -n $component
& $adb uninstall com.wozos.shell
$backup=Join-Path $PSScriptRoot ('native-before-'+(Get-Date -Format yyyyMMddHHmmss)+'.txt')
& $adb shell cmd overlay list --user 0 | Set-Content $backup
Get-Content $backup | ForEach-Object {
    if ($_ -match '^\s*\[x\]\s+(com\.android\.shell:Woz\S+)') {
        & $adb shell cmd overlay disable --user 0 $Matches[1]
    }
}
$disabled=@('org.lineageos.etar','org.lineageos.jelly','org.lineageos.recorder','org.lineageos.eleven','org.lineageos.twelve','org.lineageos.audiofx')
$installed=& $adb shell pm list packages --user 0
foreach ($pkg in $disabled) {
    if ($installed -contains "package:$pkg") { & $adb shell pm disable-user --user 0 $pkg }
}
& $adb shell settings delete secure theme_customization_overlay_packages
& $adb shell cmd uimode night yes
foreach ($key in @('window_animation_scale','transition_animation_scale','animator_duration_scale')) {
    & $adb shell settings put global $key 0.5
}
& $adb shell wm density reset
& $adb shell settings put system font_scale 1.0
& $adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME
Write-Host 'Native profile applied. System APKs retained. Overlay inventory:' $backup
