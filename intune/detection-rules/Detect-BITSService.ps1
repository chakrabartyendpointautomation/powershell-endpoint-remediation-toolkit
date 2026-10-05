# Intune Remediations detection script.
# Exit 0 = desired state present; exit 1 = remediation needed.
$ErrorActionPreference = 'Stop'
try {
    $service = Get-Service -Name BITS -ErrorAction Stop
    if ($service.Status -eq 'Running') {
        Write-Output 'Compliant: BITS is running.'
        exit 0
    }
    Write-Output "Noncompliant: BITS state is $($service.Status)."
    exit 1
}
catch {
    Write-Output "Noncompliant: BITS status could not be confirmed. $($_.Exception.Message)"
    exit 1
}
