# Inter-VLAN Firewall Policy

Segmentation is only real if it is enforced and verified. This document states the intended policy, the rules implementing it, and the test evidence for each — **including the denies**. A rule that was configured but never tested is an assumption, not a control.

---

## Intended policy

| Source | Destination | Allowed | Rationale |
|---|---|---|---|
| Users (10) | Internet | ✅ | Normal work traffic |
| Users (10) | Servers (20) | ⚠️ Specific ports only | File and print access, not full host access |
| Users (10) | Management (30) | ❌ | End users have no reason to reach device admin interfaces |
| Servers (20) | Internet | ✅ | Updates and patching |
| Servers (20) | Users (10) | ❌ | A compromised server should not be able to initiate connections toward workstations |
| Servers (20) | Management (30) | ❌ | Same reasoning |
| Management (30) | All | ✅ | Administrative access must reach everywhere |

**Design principle:** default deny between segments, with specific allows added only where a documented need exists. pfSense enforces this naturally — optional interfaces begin with no rules, and anything not explicitly permitted is dropped.

---

## Implemented rules

> Rules are evaluated top to bottom; first match wins. Order matters, and the deny rules are placed above the broad allow on each interface.

### LAN / VLAN 10 (Users)

| # | Action | Protocol | Source | Destination | Port | Description |
|---|---|---|---|---|---|---|
| 1 | Block | Any | LAN net | 10.10.30.0/29 | — | Block users from management segment |
| 2 | Pass | TCP | LAN net | 10.10.20.0/28 | `[ports]` | Permit file services to server segment |
| 3 | Block | Any | LAN net | 10.10.20.0/28 | — | Deny all other server-segment access |
| 4 | Pass | Any | LAN net | Any | — | Permit internet |

### OPT1 / VLAN 20 (Servers)

| # | Action | Protocol | Source | Destination | Port | Description |
|---|---|---|---|---|---|---|
| 1 | Block | Any | OPT1 net | 10.10.10.0/26 | — | No server-initiated traffic to users |
| 2 | Block | Any | OPT1 net | 10.10.30.0/29 | — | No server-initiated traffic to management |
| 3 | Pass | Any | OPT1 net | Any | — | Permit internet for updates |

### OPT2 / VLAN 30 (Management)

| # | Action | Protocol | Source | Destination | Port | Description |
|---|---|---|---|---|---|---|
| 1 | Pass | Any | OPT2 net | Any | — | Full administrative access |

---

## Test evidence

Each row below is verified from a host on the source segment. **Both outcomes are tested** — an allow that works and a deny that doesn't block are equally broken.

| Test | From | Command | Expected | Actual | Evidence |
|---|---|---|---|---|---|
| Users → internet | PC1 | `ping -c 4 8.8.8.8` | Reply | | |
| Users → server (permitted port) | PC1 | | Success | | |
| Users → server (other port) | PC1 | | Blocked | | |
| Users → management | PC1 | `ping -c 4 10.10.30.5` | **Blocked** | | |
| Servers → internet | PC2 | `ping -c 4 8.8.8.8` | Reply | | |
| Servers → users | PC2 | `ping -c 4 10.10.10.50` | **Blocked** | | |
| Servers → management | PC2 | `ping -c 4 10.10.30.5` | **Blocked** | | |
| Management → users | PC3 | `ping -c 4 10.10.10.50` | Reply | | |
| Management → servers | PC3 | `ping -c 4 10.10.20.5` | Reply | | |

Screenshots: [`diagrams/`](./diagrams/) and pfSense firewall logs confirming the drops.

---

## Notes

**Stateful return traffic.** pfSense is a stateful firewall: a connection permitted outbound automatically permits its return traffic. The deny rules above block *initiation* from the named segment, not responses to connections that segment legitimately started.

**Blocked, not rejected.** Rules use Block rather than Reject, so denied traffic is dropped silently rather than returning an ICMP unreachable. Reject is friendlier for internal troubleshooting; block gives an attacker less information. The tradeoff is noted here deliberately — on an internal segment there's a reasonable argument either way.

**Default credentials.** The pfSense web interface password was changed from the default on first login. Default credentials on a network device are among the most commonly exploited weaknesses in small networks.
