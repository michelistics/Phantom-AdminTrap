# Phantom-AdminTrap


# ShadowAdminTrap

ShadowAdminTrap is a Drosera security trap that continuously monitors privileged storage slots of a target contract and triggers an alert when administrative authority changes unexpectedly.

This trap is designed to detect silent control takeovers that do not emit events and do not require bytecode changes.

---

## What This Trap Detects

The trap fires when any of the following occur:

- Owner address changes
- Proxy admin slot changes (EIP-1967)
- A previously inactive guardian role becomes active
- A previously inactive operator role becomes active

These events commonly indicate:

- Unauthorized upgrades
- Hidden admin activation
- Compromised multisigs
- Re-initialization attacks
- Governance or emergency backdoor activation

This detection works even if:

- No upgrade event is emitted
- No function call is visible
- Bytecode remains unchanged

---

## Detection Strategy

The trap compares privileged storage values across consecutive blocks.

If a privileged slot changes between samples, the trap emits a response payload describing the authority mutation.

The system does not rely on ABI assumptions or event logs.

---

## Storage Slots Monitored

| Slot | Description |
|------|-------------|
| slot 0 | Common owner pattern |
| EIP-1967 admin | Proxy admin slot |
| keccak256("guardian") | Emergency role |
| keccak256("operator") | Operational role |

These represent the most commonly abused administrative control paths in deployed protocols.

---

## Architecture

