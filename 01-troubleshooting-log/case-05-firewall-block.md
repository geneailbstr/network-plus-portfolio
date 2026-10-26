<!--
SETUP BRIEF — DELETE THIS BLOCK BEFORE PUBLISHING

To introduce the fault: in pfSense, Firewall > Rules > LAN, add a Block rule at
the TOP of the list: source LAN net, destination Network 10.10.20.0/28,
protocol Any. Save and Apply.

Reveal it with: client config checks out perfectly (ip a, ip route, ping gw all
fine) but one specific destination is unreachable. Then go to
Status > System Logs > Firewall and find the drops + the rule ID.

Screenshot the firewall log -> captures/case-05-fw-log.png

DO NOT fill the output blocks from this brief. Paste real output.
-->

# Case 05 — "I can't reach the file server, and I didn't change anything"

| | |
|---|---|
| **Date** | |
| **Time to resolve** | |
| **Scope** | All hosts on one VLAN, one destination |
| **Discovery** | Introduced deliberately |

---

## 1. Identify the problem

**Reported symptom:**

**Scope — is it one host or the whole subnet:**

**What the user says changed vs. what changed on the infrastructure:**

---

## 2. Establish a theory of probable cause

**Initial theory:**

**Reasoning:**

---

## 3. Test the theory

Rule out the client first — addressing, routing, gateway:

```
$ ip a

$ ip route

$ ping -c 4 10.10.10.1

```

**What this establishes about the client:**

Test the specific destination and a control destination:

```
$ ping -c 4 10.10.20.5

$ ping -c 4 8.8.8.8

```

**Why a working control destination matters here:**

**Where I looked next, and why the firewall log is the fastest path once the client is proven healthy:**

> pfSense: Status → System Logs → Firewall
> Screenshot: [`captures/case-05-fw-log.png`](./captures/case-05-fw-log.png)

**Rule ID responsible for the drops:**

---

## 4. Establish a plan of action

**Change to be made:**

**Potential side effects — what else does this rule currently protect:**

**Rollback plan:**

---

## 5. Implement the solution

---

## 6. Verify full system functionality

```
$ ping -c 4 10.10.20.5

```

**Confirm the intended deny rules still work — a fix that opens everything is not a fix:**

```
$ ping -c 4 10.10.30.5

```

**Preventive measure taken:**

---

## 7. Documentation and lessons

**Root cause, one sentence:**

**Concept this case demonstrates:**
> Firewall rules are evaluated top to bottom and the first match wins, so a rule inserted above an existing allow rule silently overrides it. When a client's addressing, routing, and gateway all check out and exactly one destination is unreachable, the problem is almost never on the client. Knowing to stop testing the endpoint and go read the firewall log is the entire skill in this case.

**First thing I'd check if I saw this symptom again:**

**What I misunderstood before working this case:**
