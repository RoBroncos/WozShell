param([switch]$Rollback)
$ErrorActionPreference='Stop'
$adb='C:\platform-tools\adb.exe'
$state=Join-Path $PSScriptRoot 'ultralight-disabled.txt'
& $adb get-state
if ($LASTEXITCODE -ne 0) { throw 'Tablet disconnected' }
if ($Rollback) {
    if (Test-Path $state) { Get-Content $state | ForEach-Object { & $adb shell pm enable --user 0 $_ } }
    exit
}
$optional=@('org.lineageos.etar','org.lineageos.jelly','org.lineageos.recorder','org.lineageos.eleven','org.lineageos.twelve','org.lineageos.audiofx','org.lineageos.aperture','org.lineageos.glimpse','com.android.dreams.basic','com.android.dreams.phototable','com.android.wallpaper.livepicker','com.android.printspooler','com.android.bips','com.android.bluetoothmidiservice','com.android.egg','com.android.soundrecorder','com.android.musicfx','com.android.stk','com.android.stk2','com.android.cellbroadcastreceiver')
# Preserve emergency alerts and SIM services even on Wi-Fi models.
$optional=$optional | Where-Object { $_ -notin @('com.android.cellbroadcastreceiver','com.android.stk','com.android.stk2') }
$enabled=@(& $adb shell pm list packages -e --user 0 | ForEach-Object { $_.Trim() -replace '^package:','' })
foreach ($pkg in $optional) {
    if ($enabled -contains $pkg) {
        $result=& $adb shell pm disable-user --user 0 $pkg
        $result
        if ($LASTEXITCODE -eq 0 -and "$result" -match 'disabled-user') { Add-Content $state $pkg }
    }
}
if ($enabled -contains 'com.wozos.shell') { & $adb shell pm disable-user --user 0 com.wozos.shell }
foreach ($key in @('window_animation_scale','transition_animation_scale','animator_duration_scale')) { & $adb shell settings put global $key 0 }
& $adb shell cmd uimode night yes
& $adb shell pm list packages -e --user 0
Write-Host 'Ultralight profile applied. Optional camera/gallery/printing disabled. Personal installed apps retained.'
