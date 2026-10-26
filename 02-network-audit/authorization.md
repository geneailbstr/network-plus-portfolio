# Authorization

Active scanning — host discovery, port scanning, service enumeration — was performed only against a network I am authorized to assess.

| | |
|---|---|
| **Network assessed** | `[description — e.g. "private residence, single-owner"]` |
| **Relationship** | `[owned by me / assessed with written permission]` |
| **Authorization obtained** | `[date]` |
| **Authorization form** | `[self-owned / written permission on file]` |
| **Scope agreed** | `[what was in scope and what was explicitly excluded]` |
| **Assessment window** | `[dates]` |

---

## Scope boundaries

**In scope:**
- `[e.g. all devices on the 192.168.1.0/24 internal network]`
- `[wireless survey of the physical premises]`

**Explicitly out of scope:**
- Any host outside the authorized network
- The ISP's equipment upstream of the customer demarcation point
- Neighboring wireless networks — observed passively for channel utilization only; no interaction, no association attempts

---

## Note on method

Wireless observation was passive: channel and signal-strength readings only. Networks belonging to third parties appear in the survey data solely as sources of RF interference affecting the assessed network. No attempt was made to interact with, associate to, or assess any network other than the authorized one.

Port scanning is a legitimate assessment technique against a network you own or have permission to test, and unauthorized scanning is a criminal offense in most jurisdictions. Documenting authorization before scanning is standard professional practice and is recorded here for that reason.

---

## Anonymization

Public IP addresses, physical addresses, device serial numbers, and any personally identifying details have been redacted from the published findings. Internal RFC 1918 addresses and MAC prefixes are retained where they are necessary to the technical narrative.
