[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
try {
    $serviceNames = 'wuauserv', 'BITS', 'UsoSvc'
    $services = foreach ($name in $serviceNames) {
        $service = Get-Service -Name $name -ErrorAction SilentlyContinue
        if ($service) {
            [pscustomobject]@{ Name = $service.Name; Status = [string]$service.Status; StartType = [string]$service.StartType }
        }
        else {
            [pscustomobject]@{ Name = $name; Status = 'NotFoundOrUnavailable'; StartType = $null }
        }
    }
    $rebootKeys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    )
    $pendingReboot = @($rebootKeys | Where-Object { Test-Path -LiteralPath $_ }).Count -gt 0
    [pscustomobject]@{ Services = @($services); PendingRebootIndicator = $pendingReboot; CollectedAtUtc = [datetime]::UtcNow }
    exit 0
}
catch {
    Write-Error "Windows Update health collection failed: $($_.Exception.Message)"
    exit 1
}
