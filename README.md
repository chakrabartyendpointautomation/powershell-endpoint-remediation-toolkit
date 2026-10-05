# PowerShell Endpoint Remediation Toolkit

**Portfolio project · Windows endpoint operations · Demonstration only**

Practical, reviewable PowerShell examples for checking common Windows endpoint health signals and safely addressing a small, defined service issue. The toolkit is designed to show how endpoint automation can be documented, scoped, and validated before it is deployed through Microsoft Intune.

## What this demonstrates

- Read-only checks for OS/device details, BitLocker, Microsoft Defender, storage, and Windows Update service health.
- A combined JSON health summary suitable for review or further processing.
- A BITS recovery example that makes no change unless `-Apply` is supplied and supports `-WhatIf`.
- Intune Remediations detection/remediation examples with documented exit codes.
- Deployment notes covering permissions, pilot scope, assignment, logging, and rollback.

## Contents

| Path | Purpose |
| --- | --- |
| `scripts/Get-DeviceHealth.ps1` | Read-only OS, boot time, device, and domain-join signals |
| `scripts/Get-BitLockerStatus.ps1` | Read-only volume protection status |
| `scripts/Get-DefenderStatus.ps1` | Read-only Defender preference and signature status |
| `scripts/Get-DiskHealth.ps1` | Read-only fixed-volume capacity and free-space checks |
| `scripts/Get-WindowsUpdateHealth.ps1` | Read-only update-service and reboot-indicator checks |
| `scripts/Get-EndpointHealthSummary.ps1` | Runs local checks and writes a timestamped JSON summary |
| `remediation/Repair-BITS.ps1` | Starts BITS only when explicitly applied |
| `intune/detection-rules/Detect-BITSService.ps1` | Intune detection: exit 0 when running, 1 otherwise |
| `intune/remediation-examples/Remediate-BITSService.ps1` | Intune remediation: starts BITS and reports the result |
| `docs/deployment-guide.md` | Prerequisites, pilot and Intune deployment workflow |
| `docs/troubleshooting.md` | Common failures and validation guidance |
| `docs/safety-and-privacy.md` | Scope, safety boundaries, data handling, and review checklist |

## Quick start

Run from an elevated Windows PowerShell 5.1 or PowerShell 7 session for the broadest access. The health checks are read-only:

```powershell
.\scripts\Get-EndpointHealthSummary.ps1 -OutputPath .\out
```

The BITS example previews its intended action by default. To make the change, use `-Apply`; `-WhatIf` remains available:

```powershell
.\remediation\Repair-BITS.ps1 -WhatIf
.\remediation\Repair-BITS.ps1 -Apply -WhatIf
.\remediation\Repair-BITS.ps1 -Apply
```

Review the [deployment guide](docs/deployment-guide.md) and [safety and privacy notes](docs/safety-and-privacy.md) before using any example on a managed device.

## Output and exit behavior

Health-check scripts emit PowerShell objects and use exit code `0` for successful collection and `1` for a collection/runtime failure. A health finding such as low disk space is reported as data and does not itself mean script execution failed. The combined summary saves JSON and returns `0` when collection completes, even if a component check reports a warning; component errors are included in the report.

Intune examples follow the Remediations convention: detection exits `0` when the desired state is present and `1` when remediation is needed; remediation exits `0` on success and `1` on failure. Confirm behavior in a pilot because Intune execution context and policy can change the result.

## Important boundaries

- This is sample code, not a vendor-supported Microsoft product or a compliance guarantee.
- Examples contain no real tenant identifiers, credentials, tokens, or client data.
- Checks are read-only. The BITS example only starts a Windows service; it does not change startup type, reset update components, delete caches, or remove files.
- Do not deploy without written authorization, change approval, a small pilot, and a rollback/contact plan.
- Review code and test it against the target Windows build, PowerShell version, security policy, and business requirements first.
- Do not upload health output publicly. It may contain device names, OS details, volume information, and security state.

## Portfolio context

This project pairs with the [Intune Endpoint Health Assessment](../../Intune/Intune-Endpoint-Health-Assessment/README.md). Together they demonstrate assessment workflow and a small set of operational automation patterns. They do not claim a real client deployment.

## License

MIT. See [LICENSE](LICENSE).
