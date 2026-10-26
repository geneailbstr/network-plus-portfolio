<!--
SETUP BRIEF — DELETE THIS BLOCK BEFORE PUBLISHING

To introduce the fault: on PC1-Users set static 10.10.10.50 with mask
255.255.255.0 (/24) instead of the correct 255.255.255.192 (/26).
Gateway stays 10.10.10.1.

Reveal it with: ip a (mask is easy to skim past), ping a host inside .1-.62
(works), ping something that should route (fails), Wireshark filter `arp`
showing the host ARPing for an address it should have routed to.

Capture a Wireshark export for this one -> captures/case-03-arp.txt

This is the strongest case in the log. Spend the most time on section 7.

DO NOT fill the output blocks from this brief. Paste real output.
-->

# Case 03 — "Some things work, some things don't"

| | |
|---|---|
| **Date** | |
| **Time to resolve** | |
| **Scope** | Single host |
| **Discovery** | Introduced deliberately |

---

## 1. Identify the problem

**Reported symptom:**

**Scope — which destinations work and which don't:**

| Destination | Result |
|---|---|
| 10.10.10.1 (gateway) | |
| 10.10.10.x (same subnet) | |
| 10.10.20.5 (other VLAN) | |
| 8.8.8.8 (internet) | |

**What changed recently:**

---

## 2. Establish a theory of probable cause

**Initial theory:**

**Reasoning:**

---

## 3. Test the theory

Host addressing — read the mask carefully, not just the address:

```
$ ip a

```

```
$ ip route

```

**What the routing table claims is directly connected:**

Reachability tests across the boundary:

```
$ ping -c 4 10.10.10.1

$ ping -c 4 10.10.20.5

```

Packet capture during the failing ping — Wireshark filter `arp`:

> Export: [`captures/case-03-arp.txt`](./captures/case-03-arp.txt)

**What the capture proves the host is doing instead of routing:**

---

## 4. Establish a plan of action

**Change to be made:**

**Potential side effects:**

**Rollback plan:**

---

## 5. Implement the solution

---

## 6. Verify full system functionality

```
$ ip a

$ ip route

$ ping -c 4 10.10.20.5

```

**Preventive measure taken:**

---

## 7. Documentation and lessons

**Root cause, one sentence:**

**Concept this case demonstrates:**
> The subnet mask is what a host uses to answer one question before sending anything: is this destination on my segment, or does it go to the gateway? With an incorrectly wide /24 mask, the host believes 10.10.10.1 through 10.10.10.254 are all local. For any address in .65–.254 it broadcasts an ARP request on the local wire instead of routing the packet. Nothing answers, and the traffic dies with no error that points at the mask. Everything genuinely local keeps working, which is why this gets misdiagnosed as a server problem, a cable problem, or an application problem long before anyone re-reads the mask.

**First thing I'd check if I saw this symptom again:**

**What I misunderstood before working this case:**
