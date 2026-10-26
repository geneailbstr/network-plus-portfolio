<!--
SETUP BRIEF — DELETE THIS BLOCK BEFORE PUBLISHING

To introduce the fault: give two VMs on vlan10-users the same static address,
inside the DHCP range so the conflict is realistic.
  PC1-Users  -> static 10.10.10.20 /26, gw 10.10.10.1
  second VM  -> static 10.10.10.20 /26, gw 10.10.10.1

Reveal it with: ping from a third host, arp -a run repeatedly (watch the MAC
change), Wireshark filter `arp`, journalctl -xe | grep -i duplicate

Capture a Wireshark export for this one -> captures/case-02-arp.txt

DO NOT fill the output blocks from this brief. Paste real output.
-->

# Case 02 — "It works sometimes and not others"

| | |
|---|---|
| **Date** | |
| **Time to resolve** | |
| **Scope** | Two hosts, one subnet |
| **Discovery** | Introduced deliberately |

---

## 1. Identify the problem

**Reported symptom:**

**Scope — who and what is affected:**

**Why intermittent faults are harder:**

**Questions asked / information gathered:**

---

## 2. Establish a theory of probable cause

**Initial theory:**

**Reasoning:**

---

## 3. Test the theory

Repeated ping from an uninvolved host on the same subnet:

```
$ ping -c 20 10.10.10.20

```

ARP table, checked twice a few seconds apart:

```
$ arp -a

```

```
$ arp -a

```

**What changed between the two checks:**

System log on an affected host:

```
$ journalctl -xe | grep -i duplicate

```

Packet capture — Wireshark filter `arp`:

> Export: [`captures/case-02-arp.txt`](./captures/case-02-arp.txt)

**What the capture shows:**

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
$ ping -c 20 10.10.10.20

$ arp -a

```

**Preventive measure taken:**

---

## 7. Documentation and lessons

**Root cause, one sentence:**

**Concept this case demonstrates:**
> IP addresses are how hosts are addressed, but MAC addresses are how frames are actually delivered on the local segment. When two hosts claim one IP, the ARP cache on every other device keeps flip-flopping between two MACs, and delivery becomes a coin toss. Intermittent behaviour is the signature — and intermittent is exactly the kind of fault that gets closed as "user error" when nobody checks the ARP table.

**First thing I'd check if I saw this symptom again:**

**What I misunderstood before working this case:**
