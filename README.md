# Network Engineering Portfolio

**Eugene "Gene" Silva-Davis** — Farmington, NM
CompTIA Network+ — in progress, self-study
[lbstrempire.geneai@gmail.com](mailto:lbstrempire.geneai@gmail.com) · [linkedin.com/in/eugene-silva-davis](https://linkedin.com/in/eugene-silva-davis)

Open to: NOC Technician · Network Support Technician · Help Desk (network-focused) · Field Network Technician — remote or San Juan County

---

Three hands-on projects built while preparing for Network+. The lab is the foundation; the troubleshooting log and the audit are where the actual work is.

| Project | What it demonstrates | Status |
|---|---|---|
| **[Troubleshooting Case Log](./01-troubleshooting-log/)** | Structured fault isolation, CLI diagnostics, packet analysis | In progress |
| **[Network Audit & Redesign](./02-network-audit/)** | Wireless survey, segmentation, hardening, cost justification | In progress |
| **[Multi-Subnet Virtual Lab](./03-virtual-lab/)** | Subnetting, VLANs, inter-VLAN routing, DHCP/DNS, firewall policy | Design complete, build in progress |

> This repository is being built in the open while I study. The addressing scheme and firewall policy are finished design work; the lab build and the case log are in progress. Status above is current.

Full build methodology: **[docs/BUILD-GUIDE.md](./docs/BUILD-GUIDE.md)**

---

## 1. Troubleshooting Case Log

[**→ Open the log**](./01-troubleshooting-log/)

Seven documented network failures worked end to end, each following CompTIA's seven-step methodology: identify, theorize, test, plan, implement, verify, document.

Six are faults I introduced deliberately into my lab to practice isolating a known class of problem. One was unplanned — I broke something I didn't mean to and didn't know why. That case is marked, and it includes the theories I got wrong before I got it right.

**Tools:** `ping` · `traceroute` · `nslookup`/`dig` · `ip`/`ipconfig` · `arp` · `ss`/`netstat` · Wireshark

---

## 2. Network Audit & Redesign

[**→ Open the audit**](./02-network-audit/)

Assessment of a live network — inventory, topology, wireless survey, firmware status, exposed services, and segmentation — followed by a costed, phased redesign proposal.

Performed with documented authorization. See [`authorization.md`](./02-network-audit/authorization.md).

---

## 3. Multi-Subnet Virtual Lab

[**→ Open the lab**](./03-virtual-lab/)

Three right-sized subnets behind a pfSense router, with per-VLAN DHCP scoping, internal DNS, and an explicit inter-VLAN firewall policy that is tested in both directions — allow rules and deny rules both proven.

Addressing scheme and the sizing reasoning behind it: [`addressing.md`](./03-virtual-lab/addressing.md)
Firewall policy and test evidence: [`firewall-policy.md`](./03-virtual-lab/firewall-policy.md)

---

## Background

`[2–3 sentences. Draft starting point below — rewrite in your own voice.]`

> Over a decade in pipeline services and oilfield operations, where the job was diagnosing failures in the field with incomplete information, documenting what happened, and explaining it to people who needed the outcome rather than the detail. Moving into networking because it is the same work on different infrastructure. Self-taught Python developer; I automate the repetitive parts of whatever I'm doing.

---

## Repository Structure

```
.
├── README.md
├── docs/
│   └── BUILD-GUIDE.md
├── 01-troubleshooting-log/
│   ├── README.md              # case index
│   ├── _TEMPLATE.md
│   ├── case-01 … case-07.md
│   └── captures/              # Wireshark exports
├── 02-network-audit/
│   ├── README.md
│   ├── authorization.md
│   ├── inventory.md
│   ├── wireless-survey.md
│   ├── findings.md
│   ├── redesign-proposal.md
│   └── diagrams/
└── 03-virtual-lab/
    ├── README.md
    ├── addressing.md
    ├── firewall-policy.md
    ├── configs/
    └── diagrams/
```
