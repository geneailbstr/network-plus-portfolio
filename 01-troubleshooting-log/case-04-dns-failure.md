<!--
SETUP BRIEF — DELETE THIS BLOCK BEFORE PUBLISHING

To introduce the fault: on PC1-Users leave addressing correct but set DNS to
10.10.10.200 (nothing is there). Settings > Network > gear > IPv4 > DNS.

Reveal it with: ping 8.8.8.8 (works), ping google.com (fails to resolve),
nslookup google.com (timeout), cat /etc/resolv.conf, then
nslookup google.com 8.8.8.8 (works - proves the resolver, not the network).

Capture a Wireshark export for this one -> captures/case-04-dns.txt (filter `dns`)

DO NOT fill the output blocks from this brief. Paste real output.
-->

# Case 04 — "The internet is down"

| | |
|---|---|
| **Date** | |
| **Time to resolve** | |
| **Scope** | Single host |
| **Discovery** | Introduced deliberately |

---

## 1. Identify the problem

**Reported symptom:**

**What the user actually means vs. what is actually broken:**

**Scope — who and what is affected:**

---

## 2. Establish a theory of probable cause

**Initial theory:**

**Reasoning:**

---

## 3. Test the theory

The single fastest test for splitting connectivity from name resolution — ping an IP, then ping a name:

```
$ ping -c 4 8.8.8.8

$ ping -c 4 google.com

```

**What this immediately rules out:**

Query the resolver directly:

```
$ nslookup google.com

```

Check which resolver the host is configured to use:

```
$ cat /etc/resolv.conf

```

Prove the resolver is the problem by bypassing it:

```
$ nslookup google.com 8.8.8.8

```

Packet capture — Wireshark filter `dns`:

> Export: [`captures/case-04-dns.txt`](./captures/case-04-dns.txt)

**What the capture shows about the queries and the responses:**

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
$ nslookup google.com

$ nslookup fileserver.lab.local

$ ping -c 4 google.com

```

**Preventive measure taken:**

---

## 7. Documentation and lessons

**Root cause, one sentence:**

**Concept this case demonstrates:**
> Reachability and name resolution are two independent systems, and from a user's chair the failure of either one looks identical: "the internet is down." Pinging an IP and then pinging a name separates them in under ten seconds. If the IP answers and the name doesn't, the network is fine and the resolver is not — and that single test redirects the entire investigation away from cables, switches, and the ISP.

**First thing I'd check if I saw this symptom again:**

**What I misunderstood before working this case:**
