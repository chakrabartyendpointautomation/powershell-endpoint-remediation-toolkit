[CmdletBinding()]
param(
    [ValidateRange(1, 99)]
    [int]$WarningThresholdPercent = 15
)

$ErrorActionPreference = 'Stop'
try {
    $volumes = Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3'
    foreach ($volume in $volumes) {
        $freePercent = if ($volume.Size -gt 0) { [math]::Round(($volume.FreeSpace / $volume.Size) * 100, 1) } else { $null }
        [pscustomobject]@{
            DeviceId                 = $volume.DeviceID
            VolumeName               = $volume.VolumeName
            SizeGB                   = if ($null -ne $volume.Size) { [math]::Round($volume.Size / 1GB, 2) } else { $null }
            FreeGB                   = if ($null -ne $volume.FreeSpace) { [math]::Round($volume.FreeSpace / 1GB, 2) } else { $null }
            FreePercent              = $freePercent
            BelowWarningThreshold    = ($null -ne $freePercent -and $freePercent -lt $WarningThresholdPercent)
            WarningThresholdPercent  = $WarningThresholdPercent
        }
    }
    exit 0
}
catch {
    Write-Error "Disk health collection failed: $($_.Exception.Message)"
    exit 1
}
