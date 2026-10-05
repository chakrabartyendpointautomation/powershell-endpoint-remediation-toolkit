[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
try {
    $status = Get-MpComputerStatus
    [pscustomobject]@{
        AMServiceEnabled       = $status.AMServiceEnabled
        AntivirusEnabled      = $status.AntivirusEnabled
        RealTimeProtection    = $status.RealTimeProtectionEnabled
        BehaviorMonitor       = $status.BehaviorMonitorEnabled
        NISEnabled            = $status.NISEnabled
        AntivirusSignatureAge = $status.AntivirusSignatureAge
        AntivirusSignature    = $status.AntivirusSignatureVersion
        CollectedAtUtc        = [datetime]::UtcNow
    }
    exit 0
}
catch {
    Write-Error "Defender status collection failed: $($_.Exception.Message)"
    exit 1
}
