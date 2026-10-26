# Troubleshooting Case Log

Seven network failures worked start to finish in a lab I built myself. Each follows CompTIA's seven-step methodology: identify the problem, establish a theory, test the theory, establish a plan of action, implement, verify, document.

Six were introduced deliberately to practice isolating a known class of fault. **Case 07 was not** — it was an unplanned failure I didn't understand at the outset, and the write-up keeps the theories I got wrong.

All command output in these cases is real output from the lab, not reconstructed.

---

## Cases

| # | Symptom as reported | Root cause | Scope | Time |
|---|---|---|---|---|
| [01](./case-01-default-gateway.md) | "I can see the printer but I can't get online" | | Single host | |
| [02](./case-02-duplicate-ip.md) | "It works sometimes and not others" | | Two hosts | |
| [03](./case-03-subnet-mask.md) | "Some things work, some things don't" | | Single host | |
| [04](./case-04-dns-failure.md) | "The internet is down" | | Single host | |
| [05](./case-05-firewall-block.md) | "I can't reach the file server" | | One VLAN | |
| [06](./case-06-vlan-misassignment.md) | "The server came back up on the wrong network" | | Single host | |
| [07](./case-07-unplanned.md) | **[Unplanned]** | | | |

---

## Environment

All cases worked against the lab documented in [`../03-virtual-lab/`](../03-virtual-lab/) — three subnets behind a pfSense router, per-VLAN DHCP, internal DNS, explicit inter-VLAN firewall policy.

VM snapshots were taken before each fault was introduced so every case starts from an identical known-good baseline.

## Tools

`ping` · `traceroute` · `nslookup` / `dig` · `ip a` / `ip route` · `arp` · `ss` · Wireshark · pfSense system logs

Packet capture exports and log screenshots are in [`captures/`](./captures/).

## Template

[`_TEMPLATE.md`](./_TEMPLATE.md) — the structure every case follows.
