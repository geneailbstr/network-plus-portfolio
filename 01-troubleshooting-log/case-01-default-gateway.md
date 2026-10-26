<!--
SETUP BRIEF — DELETE THIS BLOCK BEFORE PUBLISHING

To introduce the fault: on PC1-Users, set a static IP with a bad gateway.
  Ubuntu Settings > Network > gear > IPv4 > Manual
  Address 10.10.10.50 / Netmask 255.255.255.192 / Gateway 10.10.10.99 / DNS 10.10.10.1

Commands that will reveal it: ip a, ping 10.10.10.1, ping 8.8.8.8, ip route, arp -a

DO NOT fill the output blocks below from this brief. Run the commands and paste
what actually comes back. The real output is the entire point of the artifact.
-->

# Case 01 — "I can see the printer but I can't get online"

| | |
|---|---|
| **Date** | |
| **Time to resolve** | |
| **Scope** | Single host |
| **Discovery** | Introduced deliberately |

---

## 1. Identify the problem

**Reported symptom:**

**Scope — who and what is affected:**

**What changed recently:**

**Questions asked / information gathered:**

---

## 2. Establish a theory of probable cause

**Initial theory:**

**Reasoning:**

---

## 3. Test the theory

Confirm the host's own addressing:

```
$ ip a

```

Test reachability within the local subnet:

```
$ ping -c 4 10.10.10.1

```

Test reachability beyond the local subnet:

```
$ ping -c 4 8.8.8.8

```

**What the split result tells me:**

Inspect the routing table:

```
$ ip route

```

Check whether the gateway address resolves to a real device:

```
$ arp -a

```

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
$ ip route

$ ping -c 4 8.8.8.8

```

**Preventive measure taken:**

---

## 7. Documentation and lessons

**Root cause, one sentence:**

**Concept this case demonstrates:**
> A host only knows how to deliver traffic within its own subnet. Everything else is handed to the default gateway. Point a host at a gateway address that nothing answers to, and every off-subnet destination fails silently while local traffic stays perfectly healthy. That split — local works, remote doesn't — is the fingerprint of a gateway problem, and it narrows the search enormously on the first two pings.

**First thing I'd check if I saw this symptom again:**

**What I misunderstood before working this case:**
