[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath = '.\out',
    [ValidateRange(1, 99)]
    [int]$DiskWarningThresholdPercent = 15
)

$ErrorActionPreference = 'Stop'
$results = [ordered]@{ ComputerName = $env:COMPUTERNAME; CollectedAtUtc = [datetime]::UtcNow; Checks = [ordered]@{} }
$checks = 'Device', 'BitLocker', 'Defender', 'Disk', 'WindowsUpdate'
foreach ($checkName in $checks) {
    try {
        $output = switch ($checkName) {
            'Device' {
                $computer = Get-CimInstance -ClassName Win32_ComputerSystem
                $os = Get-CimInstance -ClassName Win32_OperatingSystem
                [pscustomobject]@{ ComputerName = $env:COMPUTERNAME; Manufacturer = $computer.Manufacturer; Model = $computer.Model; DomainJoined = [bool]$computer.PartOfDomain; Domain = if ($computer.PartOfDomain) { $computer.Domain } else { $null }; OS = $os.Caption; Version = $os.Version; BuildNumber = $os.BuildNumber; LastBoot = $os.LastBootUpTime }
            }
            'BitLocker' {
                if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction SilentlyContinue)) { throw 'Get-BitLockerVolume is unavailable.' }
                Get-BitLockerVolume | Select-Object MountPoint, VolumeType, VolumeStatus, ProtectionStatus, EncryptionPercentage, EncryptionMethod
            }
            'Defender' {
                $status = Get-MpComputerStatus
                [pscustomobject]@{ AMServiceEnabled = $status.AMServiceEnabled; AntivirusEnabled = $status.AntivirusEnabled; RealTimeProtection = $status.RealTimeProtectionEnabled; BehaviorMonitor = $status.BehaviorMonitorEnabled; NISEnabled = $status.NISEnabled; AntivirusSignatureAge = $status.AntivirusSignatureAge; AntivirusSignature = $status.AntivirusSignatureVersion }
            }
            'Disk' {
                foreach ($volume in (Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3')) {
                    $freePercent = if ($volume.Size -gt 0) { [math]::Round(($volume.FreeSpace / $volume.Size) * 100, 1) } else { $null }
                    [pscustomobject]@{ DeviceId = $volume.DeviceID; SizeGB = [math]::Round($volume.Size / 1GB, 2); FreeGB = [math]::Round($volume.FreeSpace / 1GB, 2); FreePercent = $freePercent; BelowWarningThreshold = ($null -ne $freePercent -and $freePercent -lt $DiskWarningThresholdPercent); WarningThresholdPercent = $DiskWarningThresholdPercent }
                }
            }
            'WindowsUpdate' {
                $services = foreach ($name in 'wuauserv', 'BITS', 'UsoSvc') {
                    $service = Get-Service -Name $name -ErrorAction SilentlyContinue
                    if ($service) { [pscustomobject]@{ Name = $service.Name; Status = [string]$service.Status; StartType = [string]$service.StartType } }
                    else { [pscustomobject]@{ Name = $name; Status = 'NotFoundOrUnavailable'; StartType = $null } }
                }
                $keys = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
                [pscustomobject]@{ Services = @($services); PendingRebootIndicator = (@($keys | Where-Object { Test-Path -LiteralPath $_ }).Count -gt 0) }
            }
        }
        $results.Checks[$checkName] = [ordered]@{ Succeeded = $true; Output = @($output); Error = $null }
    }
    catch {
        $results.Checks[$checkName] = [ordered]@{ Succeeded = $false; Output = @(); Error = $_.Exception.Message }
    }
}
try {
    $directory = [System.IO.Path]::GetFullPath($OutputPath)
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $fileName = 'endpoint-health-{0}-{1}.json' -f $env:COMPUTERNAME, (Get-Date -Format 'yyyyMMdd-HHmmss')
    $destination = Join-Path $directory $fileName
    $results | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $destination -Encoding UTF8
    Write-Output "Health summary saved to: $destination"
    exit 0
}
catch {
    Write-Error "Could not save health summary: $($_.Exception.Message)"
    exit 1
}
