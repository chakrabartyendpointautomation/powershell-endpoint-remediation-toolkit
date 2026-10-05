# Deployment guide

## Prerequisites

- Supported, organization-managed Windows 10/11 device; validate Windows edition and build before use.
- Windows PowerShell 5.1 or PowerShell 7. `Get-BitLockerVolume` requires the BitLocker module and a supported Windows edition. `Get-MpComputerStatus` requires Microsoft Defender Antivirus cmdlets and may reflect a different active antivirus configuration on third-party protected devices.
- Local administrator rights may be required for some status fields and are generally required to start BITS. Use the least privilege that successfully collects the agreed scope.
- Intune Remediations requires the relevant Intune licensing, enrollment, assignment permissions, and tenant configuration. Verify current tenant prerequisites with the administrator before deployment.
- Change approval, a named owner, a pilot group, a maintenance/support contact, and a rollback or stop plan.

## Run locally

Start with read-only checks and inspect results locally:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
.\scripts\Get-DeviceHealth.ps1
.\scripts\Get-BitLockerStatus.ps1
.\scripts\Get-DefenderStatus.ps1
.\scripts\Get-DiskHealth.ps1 -WarningThresholdPercent 15
.\scripts\Get-WindowsUpdateHealth.ps1
.\scripts\Get-EndpointHealthSummary.ps1 -OutputPath .\out
```

Execution policy settings are governed by organizational policy; do not bypass centrally enforced controls. Reports can expose device and security details. Keep them in an approved location and remove them according to the organization’s retention policy.

## Intune Remediations pilot

1. Review both BITS example scripts line by line and confirm starting BITS is acceptable for the target device group and workload.
2. Save the detection and remediation files separately. In Intune Remediations, configure the platform’s required script settings, including 64-bit execution as appropriate for the tenant. This example uses built-in Windows PowerShell cmdlets and does not require signed-in user data.
3. Assign first to a small IT-owned pilot ring. Observe detection output and remediation results in Intune and locally; confirm BITS is running and that dependent workflows still behave as expected.
4. Expand gradually only after the owner reviews pilot evidence. Set a review date and alert path for failures or unexpected outcomes.
5. To stop future changes, disable or unassign the remediation. The script does not change BITS startup type or undo organization policy; coordinate any service stop with the endpoint owner.

Intune behavior, licensing, and portal labels can change. Confirm the current Microsoft documentation and tenant configuration before deployment. These sample scripts are not a substitute for change control or vendor guidance.

## Expected outputs

- Health scripts emit PowerShell objects; the summary also writes a UTF-8 JSON report to the chosen output folder.
- The summary filename includes the device name and collection time. Treat the JSON as sensitive operational data.
- BITS local remediation reports `AlreadyHealthy`, `PreviewOnly`, or `Remediated`; `-Apply -WhatIf` previews the approved action without performing it.
- Intune detection outputs one concise status line. Exit `0` means compliant; exit `1` means remediation is needed. Remediation exits `0` only after verifying BITS is running.

## Rollback and support

This remediation only requests that BITS start. It leaves startup configuration unchanged. If starting the service causes an issue, stop the assignment and follow the organization’s change process with the service owner. Capture relevant event logs through approved support tooling; avoid publishing logs or report files.
