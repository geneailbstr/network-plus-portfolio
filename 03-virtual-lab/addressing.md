# IP Addressing Scheme

Designed before anything was built. Each subnet is sized to its host count rather than defaulting every segment to a /24 — a flat /24 everywhere wastes 200+ addresses per segment and gives no indication of intended scale to whoever inherits the network.

**Allocation:** `10.10.0.0/16` (RFC 1918 private space)

---

## The scheme

| VLAN | Purpose | Hosts needed | Network | Mask | Usable range | Broadcast | Gateway | DHCP |
|---|---|---|---|---|---|---|---|---|
| 10 | Users | ~30 | `10.10.10.0/26` | 255.255.255.192 | .1 – .62 | .63 | 10.10.10.1 | .10 – .60 |
| 20 | Servers | ~5 | `10.10.20.0/28` | 255.255.255.240 | .1 – .14 | .15 | 10.10.20.1 | .5 – .14 |
| 30 | Management | ~3 | `10.10.30.0/29` | 255.255.255.248 | .1 – .6 | .7 | 10.10.30.1 | none — static |

---

## Sizing reasoning

### VLAN 10 — Users — /26

Requirement is roughly 30 user devices, plus the gateway, plus room to grow.

A `/27` yields 30 usable addresses. That is mathematically enough for 30 devices only if the gateway doesn't need one, which it does, so a /27 is already over capacity on day one. A `/26` yields 62 usable, leaving the gateway plus ~31 addresses of headroom.

```
/26  →  32 - 26 = 6 host bits  →  2^6 = 64 addresses  →  62 usable
```

Chosen because it is the smallest prefix that accommodates the requirement with meaningful growth room.

### VLAN 20 — Servers — /28

Five servers plus the gateway. A `/29` yields 6 usable, which fits exactly and leaves zero headroom — and servers are the segment where "we need one more box" happens on short notice.

```
/28  →  32 - 28 = 4 host bits  →  2^4 = 16 addresses  →  14 usable
```

A /28 gives 14 usable: the gateway, five servers, and room for eight more without renumbering.

### VLAN 30 — Management — /29

Three management interfaces plus the gateway. This segment is deliberately the smallest in the network.

```
/29  →  32 - 29 = 3 host bits  →  2^3 = 8 addresses  →  6 usable
```

**DHCP is deliberately not enabled here.** Management interfaces are assigned statically so that an address always maps to a known device, and so that a host accidentally connected to this segment does not silently receive a working lease. A rogue or misplugged device on the management segment should fail loudly, not join quietly.

---

## Host assignments

| Address | Device | Type | VLAN |
|---|---|---|---|
| 10.10.10.1 | pfSense (em1) | Gateway | 10 |
| 10.10.10.10 – .60 | User workstations | DHCP pool | 10 |
| 10.10.20.1 | pfSense (em2) | Gateway | 20 |
| 10.10.20.5 | `fileserver.lab.local` | Static | 20 |
| 10.10.30.1 | pfSense (em3) | Gateway | 30 |
| 10.10.30.5 | Admin workstation | Static | 30 |

---

## Prefix reference

The relationship that drives all of the above — every bit added to the prefix halves the host count:

| Prefix | Mask | Addresses | Usable |
|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /29 | 255.255.255.248 | 8 | 6 |
| /30 | 255.255.255.252 | 4 | 2 |

Two addresses in every subnet are unusable by hosts: the all-zeros host portion identifies the network itself, and the all-ones host portion is the directed broadcast.

---

## Room left in the allocation

`10.10.0.0/16` leaves substantial space for additional segments without renumbering anything above. Reserved for planned expansion:

| Planned | Purpose |
|---|---|
| `10.10.40.0/28` | IoT / untrusted devices |
| `10.10.50.0/29` | Guest wireless |
| `10.10.99.0/30` | Point-to-point transit links |
