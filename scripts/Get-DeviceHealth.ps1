[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
try {
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    [pscustomobject]@{
        ComputerName      = $env:COMPUTERNAME
        Manufacturer      = $computer.Manufacturer
        Model             = $computer.Model
        DomainJoined      = [bool]$computer.PartOfDomain
        Domain            = if ($computer.PartOfDomain) { $computer.Domain } else { $null }
        OS                = $os.Caption
        Version           = $os.Version
        BuildNumber       = $os.BuildNumber
        LastBoot          = $os.LastBootUpTime
        CollectedAtUtc    = [datetime]::UtcNow
        Status            = 'Collected'
    }
    exit 0
}
catch {
    Write-Error "Device health collection failed: $($_.Exception.Message)"
    exit 1
}
