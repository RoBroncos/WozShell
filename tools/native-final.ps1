param([switch]$Rollback)
$adb='C:\platform-tools\adb.exe'
$state=Join-Path $PSScriptRoot 'native-final-disabled.txt'
& $adb get-state
if ($LASTEXITCODE -ne 0) { throw 'Tablet disconnected' }
if ($Rollback) {
    if (Test-Path $state) { Get-Content $state | Sort-Object -Unique | ForEach-Object { & $adb shell pm enable --user 0 $_ } }
    exit
}
$optional=@('org.lineageos.backgrounds','org.lineageos.camelot','com.android.DeviceAsWebcam','com.android.gallery3d','com.android.printservice.recommendation','com.android.bookmarkprovider','com.android.calculator2','com.android.contacts','com.android.deskclock')
$enabled=@(& $adb shell pm list packages -e --user 0 | ForEach-Object { $_.Trim() -replace '^package:','' })
foreach ($pkg in $optional) {
    if ($enabled -contains $pkg) {
        $result=& $adb shell pm disable-user --user 0 $pkg
        $result
        if ($LASTEXITCODE -eq 0 -and "$result" -match 'disabled-user') { Add-Content $state $pkg }
    }
}
& $adb shell dumpsys meminfo
