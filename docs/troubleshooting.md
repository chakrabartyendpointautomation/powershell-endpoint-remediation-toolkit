# Troubleshooting

## `Get-BitLockerVolume` is unavailable

Run on a supported Windows edition with the BitLocker PowerShell module. Treat unavailable data as unknown; do not infer that a volume is unencrypted.

## Defender cmdlet fails or returns unexpected values

Confirm the Defender module/cmdlets are available and identify the active antivirus product. Third-party antivirus, platform policy, or limited permissions can affect reported status. Validate with the endpoint owner’s approved management console.

## CIM or service queries return access denied

Check execution context and assigned permissions. Use an approved elevated context only when required and authorized; do not weaken endpoint security policy to make a sample script run.

## BITS fails to start

Review the service error and Windows Service Control Manager events with an authorized administrator. Check dependencies, policy, and device health. This toolkit does not change service startup type, reset Windows Update, clear queues, or bypass policy. Stop the rollout and escalate if the service is intentionally disabled or governed by policy.

## Summary includes failed component output

The combined summary records each check’s output independently so one unavailable module does not prevent other checks from running. Review the `Succeeded` and `Error` fields; a failed collection is not the same as a healthy result. Use the individual script interactively to see the native error.

## Intune reports different results than local execution

Compare execution context, 32/64-bit host, script settings, device assignment, licensing, and policy. Review Intune device status and the script output on a pilot device before expanding scope.
