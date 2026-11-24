$ErrorActionPreference='Stop'
$adb='C:\platform-tools\adb.exe'
$dir=Join-Path $PSScriptRoot 'device-inspection'
New-Item -ItemType Directory -Force $dir | Out-Null
& $adb get-state
if ($LASTEXITCODE -ne 0) { throw 'Tablet disconnected' }
& $adb shell getprop | Set-Content (Join-Path $dir 'properties.txt')
& $adb shell cmd overlay list --user 0 | Set-Content (Join-Path $dir 'overlays.txt')
foreach ($pkg in @('com.android.systemui','android','com.android.settings')) {
    $paths = & $adb shell pm path $pkg
    $i=0
    foreach ($line in $paths) {
        if ($line -match '^package:(.+)$') {
            $remote=$Matches[1].Trim()
            & $adb pull $remote (Join-Path $dir "$pkg-$i.apk")
            $i++
        }
    }
}
Write-Host "Inspection files saved in $dir. No device files modified."
