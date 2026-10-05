[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
try {
    $service = Get-Service -Name BITS -ErrorAction Stop
    if ($service.Status -eq 'Running') {
        [pscustomobject]@{ Service = 'BITS'; Before = 'Running'; After = 'Running'; Changed = $false; Result = 'AlreadyHealthy' }
        exit 0
    }
    if (-not $Apply) {
        [pscustomobject]@{ Service = 'BITS'; Before = [string]$service.Status; After = [string]$service.Status; Changed = $false; Result = 'PreviewOnly'; NextStep = 'Rerun with -Apply after approval.' }
        exit 0
    }
    if ($PSCmdlet.ShouldProcess('BITS service', 'Start service')) {
        Start-Service -Name BITS
        (Get-Service -Name BITS).WaitForStatus('Running', [timespan]::FromSeconds(20))
        $verified = Get-Service -Name BITS
        if ($verified.Status -ne 'Running') { throw 'BITS did not reach Running state within 20 seconds.' }
        [pscustomobject]@{ Service = 'BITS'; Before = [string]$service.Status; After = 'Running'; Changed = $true; Result = 'Remediated' }
    }
    exit 0
}
catch {
    Write-Error "BITS recovery failed: $($_.Exception.Message)"
    exit 1
}
