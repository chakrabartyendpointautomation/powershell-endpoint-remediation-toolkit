# Intune Remediations remediation script.
# Starts BITS only; does not change its startup type or reset related components.
$ErrorActionPreference = 'Stop'
try {
    $service = Get-Service -Name BITS -ErrorAction Stop
    if ($service.Status -ne 'Running') {
        Start-Service -Name BITS
        $service = Get-Service -Name BITS
        $service.WaitForStatus('Running', [timespan]::FromSeconds(20))
        $service = Get-Service -Name BITS
    }
    if ($service.Status -ne 'Running') { throw 'BITS did not reach Running state within 20 seconds.' }
    Write-Output 'Remediated: BITS is running.'
    exit 0
}
catch {
    Write-Output "Remediation failed: $($_.Exception.Message)"
    exit 1
}
