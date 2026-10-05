# Safety and privacy

## Scope

The health scripts query local Windows management interfaces and do not contact a tenant, upload data, or change device configuration. The BITS recovery example starts one service only after explicit opt-in locally, or when assigned through the paired Intune example. It does not set startup type, reset update components, clear queues, delete files, modify registry values, or reboot.

## Before a client deployment

- Obtain written authorization and agree device scope, purpose, collection fields, schedule, operator, and retention.
- Review each script with the client or system owner. Confirm policy, licensing, Windows versions, security tooling, user impact, and change approval.
- Run read-only checks first and pilot on IT-owned devices. Record expected behavior and a stop/rollback plan.
- Keep generated reports and logs in client-approved storage with access controls. Do not commit real reports, device names, tenant information, usernames, serial numbers, tokens, or screenshots to a public repository.
- Remove local report files after the approved retention period. The repository ignores common report formats, but operators remain responsible for checking before commit.

## Limitations

Collected signals are point-in-time indicators, not proof of compliance, complete security posture, or root cause. A missing signal is unknown, not a healthy state. Validate findings with the organization’s management tools and policies.
