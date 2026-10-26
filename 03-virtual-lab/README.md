# Multi-Subnet Virtual Lab

A routed, segmented network built from scratch in virtualization — three right-sized subnets behind a pfSense router, with per-segment DHCP scoping, internal name resolution, and an inter-VLAN firewall policy that is tested in both directions.

This is also the environment every case in the [troubleshooting log](../01-troubleshooting-log/) was worked in.

---

## Topology

> `diagrams/topology.png` — [drawn in diagrams.net, exported as PNG]

```
                    Internet
                        |
                   [ WAN / em0 ]
                   +-------------+
                   |   pfSense   |
                   +-------------+
                    /     |      \
            em1    /   em2|       \  em3
      10.10.10.1  /  10.10.20.1    \ 10.10.30.1
                 /        |          \
          +----------+ +--------+ +------------+
          | VLAN 10  | |VLAN 20 | |  VLAN 30   |
          |  Users   | |Servers | | Management |
          |  /26     | |  /28   | |    /29     |
          +----------+ +--------+ +------------+
```

---

## Build summary

| Component | Implementation |
|---|---|
| Hypervisor | `[VirtualBox / VMware / Proxmox]` |
| Router / firewall | pfSense CE `[version]` |
| Segmentation | `[VirtualBox internal networks / 802.1Q tagging on a managed switch]` |
| Clients | `[OS and count]` |
| DHCP | pfSense, scoped per interface |
| DNS | pfSense DNS Resolver (unbound) with host overrides for `lab.local` |

---

## Documentation

| Document | Contents |
|---|---|
| [`addressing.md`](./addressing.md) | Full addressing scheme with the subnetting math and the sizing reasoning behind each prefix |
| [`firewall-policy.md`](./firewall-policy.md) | Intended inter-VLAN policy, implemented rules, and test evidence for allows and denies |
| [`configs/`](./configs/) | Sanitized pfSense configuration export |
| [`diagrams/`](./diagrams/) | Topology diagram and verification screenshots |

---

## Verification

| Check | Command | Result |
|---|---|---|
| DHCP assigns from correct pool per segment | `ip a` | |
| Correct gateway distributed per segment | `ip route` | |
| Gateway reachable | `ping 10.10.X.1` | |
| Inter-VLAN routing functional where permitted | `ping` across segments | |
| Internal DNS resolves | `nslookup fileserver.lab.local` | |
| External connectivity | `ping 8.8.8.8` | |
| Deny rules actually deny | see [`firewall-policy.md`](./firewall-policy.md) | |

---

## Beyond the original scope

`[Pick at least one and write a paragraph on what you chose, why, and what surprised you. Candidates: a managed switch with real 802.1Q trunking and tagged VLANs; OpenVPN remote access; a monitoring stack (Zabbix/LibreNMS); centralized syslog; IPv6 dual-stack on one segment.]`

---

## Security notes

- Default pfSense credentials changed on first login
- Configuration export in `configs/` is sanitized — password hashes removed before commit
- Management segment uses static addressing with no DHCP, by design
- Lab is isolated from the host machine's physical network; WAN side is NAT only
