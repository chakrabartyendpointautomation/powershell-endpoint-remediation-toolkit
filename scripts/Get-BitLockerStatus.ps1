[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
try {
    if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction SilentlyContinue)) {
        throw 'Get-BitLockerVolume is unavailable. Run on a supported Windows edition with the BitLocker PowerShell module.'
    }
    Get-BitLockerVolume | Select-Object MountPoint, VolumeType, VolumeStatus, ProtectionStatus, EncryptionPercentage, EncryptionMethod
    exit 0
}
catch {
    Write-Error "BitLocker status collection failed: $($_.Exception.Message)"
    exit 1
}
