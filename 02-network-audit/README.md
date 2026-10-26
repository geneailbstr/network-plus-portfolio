# Network Audit & Redesign

Assessment of a live network, followed by a costed, phased redesign proposal written for the network's owner rather than for an engineer.

Performed with documented authorization — see [`authorization.md`](./authorization.md). Active scanning was confined to the authorized network; third-party wireless networks appear only as passively observed interference sources.

---

## Contents

| Document | What's in it |
|---|---|
| [`authorization.md`](./authorization.md) | Scope, permission, and anonymization method |
| [`inventory.md`](./inventory.md) | Every device on the network, with firmware and support status |
| [`wireless-survey.md`](./wireless-survey.md) | Channel utilization, coverage by location, throughput |
| [`findings.md`](./findings.md) | Findings with severity ratings and defended reasoning |
| [`redesign-proposal.md`](./redesign-proposal.md) | Phased plan with real part numbers and real prices |
| [`diagrams/`](./diagrams/) | Current and proposed topology |

---

## Method

1. **Inventory** — DHCP lease table, router client list, and `nmap -sn` sweep to catch statically addressed hosts
2. **Topology** — physical and logical mapping, wired vs. wireless, link speeds
3. **Wireless survey** — channel occupancy in both bands, signal strength walked room by room, throughput at multiple locations
4. **Patch status** — firmware version and vendor support status for every network device
5. **Exposed services** — `nmap -sV` against infrastructure to enumerate open ports and running services
6. **Segmentation** — guest network isolation tested by connecting to it and attempting to reach the management interface

---

## Headline findings

| # | Finding | Severity |
|---|---|---|
| 1 | | |
| 2 | | |
| 3 | | |

Full detail and remediation: [`findings.md`](./findings.md)

---

## Anonymization

Public IPs, physical addresses, serial numbers, and personally identifying details are redacted. Internal RFC 1918 addressing is retained where the technical narrative requires it.
