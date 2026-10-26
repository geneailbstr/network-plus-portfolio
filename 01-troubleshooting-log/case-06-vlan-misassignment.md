<!--
SETUP BRIEF — DELETE THIS BLOCK BEFORE PUBLISHING

To introduce the fault: shut down PC2-Servers. In VirtualBox, Settings >
Network > Adapter 1, change Internal Network from vlan20-servers to
vlan10-users. Boot it.

Reveal it with: ip a shows an address from the WRONG DHCP pool (10.10.10.x
instead of 10.10.20.x). That single line identifies the broadcast domain the
host is actually sitting in.

This is the virtual equivalent of a patch cable in the wrong port, or a switch
port assigned to the wrong VLAN - one of the most common real causes of
"it worked yesterday" after an office move.

DO NOT fill the output blocks from this brief. Paste real output.
-->

# Case 06 — "The server came back up on the wrong network"

| | |
|---|---|
| **Date** | |
| **Time to resolve** | |
| **Scope** | Single host |
| **Discovery** | Introduced deliberately |

---

## 1. Identify the problem

**Reported symptom:**

**Scope — who can and can't reach the host:**

**What changed recently:**

---

## 2. Establish a theory of probable cause

**Initial theory:**

**Reasoning:**

---

## 3. Test the theory

Host addressing — the address itself is the diagnosis here:

```
$ ip a

```

**Which pool this address came from, and what that proves:**

```
$ ip route

```

Confirm which gateway is answering:

```
$ ping -c 4 10.10.10.1

$ ping -c 4 10.10.20.1

```

Confirm the DHCP lease source — pfSense: Status → DHCP Leases

**What the lease table shows:**

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

$ ping -c 4 10.10.20.1

```

**Confirm the host is reachable from where it should be, and not from where it shouldn't:**

**Preventive measure taken:**

---

## 7. Documentation and lessons

**Root cause, one sentence:**

**Concept this case demonstrates:**
> A host's address tells you which broadcast domain it is physically sitting in, regardless of where you believe you connected it. When a machine pulls a lease from an unexpected pool, the switch port, cable, or virtual adapter is in the wrong VLAN — the host is working exactly as designed, in the wrong place. In production this is a patch panel error or a mis-assigned access port, and the fix is at the switch, not the server.

**First thing I'd check if I saw this symptom again:**

**What I misunderstood before working this case:**
