param([switch]$Rollback)
$ErrorActionPreference = 'Stop'
$adb = 'C:\platform-tools\adb.exe'
function Device([string]$cmd) {
    $out = & $adb shell $cmd
    if ($LASTEXITCODE -ne 0) { throw "Device command failed: $cmd" }
    $out
}
& $adb get-state
if ($LASTEXITCODE -ne 0) { throw 'Connect tablet first' }
$names = @()
$palette = [ordered]@{100='fff5f5f5';200='ffe0e0e0';300='ffc4c4c4';400='ffa8a8a8';500='ff888888';600='ff666666';700='ff444444';800='ff222222';900='ff080808'}
$resources = [ordered]@{}
foreach ($family in @('accent1','accent2','accent3','neutral1','neutral2')) {
    foreach ($tone in $palette.Keys) { $resources["system_${family}_$tone"] = $palette[$tone] }
}
foreach ($r in $resources.Keys) { $names += "WozMono_$r" }
if ($Rollback) {
    foreach ($n in $names) { & $adb shell "cmd overlay disable --user 0 com.android.shell:$n" }
    Write-Host 'Monochrome overlays disabled.'
    exit
}
& $adb root
& $adb wait-for-device
if ((Device 'id') -notmatch 'uid=0') { throw 'Root ADB required' }
$backup = Join-Path $PSScriptRoot ("overlay-before-" + (Get-Date -Format yyyyMMddHHmmss) + ".txt")
Device 'cmd overlay list --user 0' | Set-Content $backup
foreach ($r in $resources.Keys) {
    $n = "WozMono_$r"
    $value = $resources[$r]
    try {
        Device "cmd overlay fabricate --target android --name $n android:color/$r 0x1c 0x$value"
        Device "cmd overlay enable --user 0 com.android.shell:$n"
        Device "cmd overlay set-priority com.android.shell:$n highest"
    } catch { Write-Warning "$r not applied: $_" }
}
Device 'cmd uimode night yes'
Device 'cmd overlay list --user 0'
Write-Host "Overlay inventory saved to $backup"
Write-Host 'Rollback: run this script with -Rollback. Dark mode can be changed in Display settings.'
