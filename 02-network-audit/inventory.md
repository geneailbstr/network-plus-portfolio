# Device Inventory

Complete enumeration of devices on the assessed network. Sources: router DHCP lease table, router connected-devices list, and `nmap -sn` host discovery to catch statically addressed hosts the router's list may omit.

**Discovery date:** `[date]`
**Network:** `[e.g. 192.168.1.0/24]`

---

## Infrastructure

| Device | Model | Role | IP | Addressing | Firmware | Latest available | Status |
|---|---|---|---|---|---|---|---|
| | | Modem/ONT | | | | | |
| | | Router | | Static | | | |
| | | Switch | | | | | |
| | | Access point | | | | | |

## Endpoints

| Device | Type | IP | MAC prefix | Connection | Addressing | Identified? |
|---|---|---|---|---|---|---|
| | Workstation | | | Wired | DHCP | ✅ |
| | Laptop | | | 5 GHz | DHCP | ✅ |
| | Phone | | | 5 GHz | DHCP | ✅ |
| | | | | | | |

## IoT / embedded

| Device | Type | IP | Connection | Firmware date | Vendor support status |
|---|---|---|---|---|---|
| | | | 2.4 GHz | | |
| | | | 2.4 GHz | | |

---

## Host discovery output

```
$ nmap -sn [network]/24

```

---

## Unidentified devices

> Every device on a network should be accountable. Anything that cannot be identified is itself a finding — not a gap in the inventory.

| MAC | IP | First seen | Resolution |
|---|---|---|---|
| | | | |

**Method used to identify unknowns:** `[MAC OUI lookup, powering devices off one at a time, router client naming, etc.]`

---

## Summary

| Metric | Count |
|---|---|
| Total devices | |
| Wired | |
| Wireless 2.4 GHz | |
| Wireless 5 GHz | |
| IoT / embedded | |
| Running end-of-life firmware | |
| Unidentified at close of assessment | |
