# Network+ Portfolio — Complete Build Guide

Everything here assumes you know nothing. Concepts are explained in plain language first, then the actual commands and clicks. Work through it in order.

**Build order is not the same as portfolio order.** The README shows the troubleshooting log first because that's what impresses people. But you have to *build* the lab first, because you can't break a network you haven't built.

| Order | Project | Time |
|---|---|---|
| 1st | Virtual Lab | 8–15 hours |
| 2nd | Troubleshooting Log | 10–20 hours |
| 3rd | Network Audit | 4–8 hours |

---

# PART 0 — Before You Start

## What you need

- A computer with **16 GB RAM** (8 GB will work but everything will be slow)
- **60 GB free disk space**
- A stable internet connection for downloads

## Turn on virtualization

**Plain English:** Your computer normally runs one operating system. Virtualization lets it pretend to be several separate computers at once. Each fake computer is a "virtual machine," or VM. You're going to build a whole network out of fake computers inside your one real computer.

This feature ships turned off on a lot of machines. Turn it on:

1. Restart your computer and press the BIOS key repeatedly as it boots — usually `F2`, `F10`, `DEL`, or `ESC`. The boot screen usually says which.
2. Look for a setting called **Intel VT-x**, **Intel Virtualization Technology**, **AMD-V**, or **SVM Mode**. It's usually under Advanced, CPU Configuration, or Security.
3. Set it to **Enabled**.
4. Save and exit (usually `F10`).

To confirm it worked, on Windows open Task Manager → Performance → CPU. Bottom right should say **Virtualization: Enabled**.

## Vocabulary you'll need immediately

| Term | Plain English |
|---|---|
| **IP address** | The street address of a device. `192.168.1.50` |
| **Subnet mask** | Tells a device which addresses are "on my street" vs "somewhere else in the city." `255.255.255.0` |
| **Default gateway** | The one road out of your street. If a device wants to reach anything not on its street, it hands the traffic here. |
| **Switch** | A device that connects computers *on the same street* to each other. Doesn't know how to leave the street. |
| **Router** | A device that connects *different streets* to each other. Knows how to get from one to another. |
| **VLAN** | An invisible wall drawn inside one physical switch, splitting it into multiple separate streets that can't hear each other. |
| **Broadcast domain** | The group of devices that hear each other when one of them shouts. One VLAN = one broadcast domain. |
| **DHCP** | A clerk that hands out IP addresses automatically so you don't have to type them into every device. |
| **DNS** | The phone book. Turns `google.com` into an IP address, because devices only understand numbers. |
| **NIC** | Network Interface Card. The port a network cable plugs into. Virtual machines have fake ones. |

---

# PART 1 — The Virtual Lab

**What you're building:** Three separate networks (VLANs) that can't talk to each other unless a router lets them, with automatic address assignment and a working internal phone book. Then you'll deliberately control which of them are allowed to reach which.

**Why it matters:** This is genuinely how a small office is built. Employees on one network, servers on another, management interfaces on a third that almost nobody can reach. It's the single most common design pattern in the job you're applying for.

---

## Step 1.1 — Plan the addressing on paper first

Do not skip this and do not do it in your head. Professionals plan addressing before touching hardware, and the plan itself is a portfolio artifact.

### Understanding the slash number

**Plain English:** An IP address has 32 bits — 32 tiny on/off switches, written as four numbers for human convenience. The slash number says *how many of those switches identify the street*, and the rest identify the individual house.

`/24` means 24 bits are the street, leaving 8 bits for houses. 8 bits = 2⁸ = 256 addresses. Two are reserved (one names the street itself, one is the "shout to everybody" address), so **254 usable**.

Every bit you add to the street number cuts the house count in half:

| Slash | Subnet mask | Total addresses | Usable hosts |
|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /29 | 255.255.255.248 | 8 | 6 |
| /30 | 255.255.255.252 | 4 | 2 |

**Memorize the right column.** Network+ will ask you to size a subnet, and this table is the whole trick.

### The plan you're going to build

The skill being demonstrated is *right-sizing* — giving each network only as much space as it needs instead of lazily handing everything a /24.

| VLAN | Purpose | Devices needed | Network | Mask | Usable range | Gateway |
|---|---|---|---|---|---|---|
| 10 | Users | ~30 | 10.10.10.0/26 | 255.255.255.192 | 10.10.10.1 – .62 | 10.10.10.1 |
| 20 | Servers | ~5 | 10.10.20.0/28 | 255.255.255.240 | 10.10.20.1 – .14 | 10.10.20.1 |
| 30 | Management | ~3 | 10.10.30.0/29 | 255.255.255.248 | 10.10.30.1 – .6 | 10.10.30.1 |

**Worked example — why VLAN 10 is a /26:** You need 30 user devices, plus a gateway, plus headroom for growth. A /27 gives 30 usable, which leaves zero room and doesn't even fit the gateway comfortably. A /26 gives 62. That's the smallest size that fits with room to grow. Show this reasoning in your write-up — the reasoning is the part that's worth points.

**Write this into `03-virtual-lab/addressing.md` now, before you build anything.**

---

## Step 1.2 — Install VirtualBox

1. Go to **virtualbox.org** → Downloads → pick your operating system.
2. Install it with all default options.
3. On the same page, download the **VirtualBox Extension Pack**. Install it by double-clicking the downloaded file — VirtualBox will open and ask to install it. Accept.

## Step 1.3 — Download your operating systems

You need three ISO files. An **ISO** is a single file containing an entire installation disc.

| What | Where | Why |
|---|---|---|
| **pfSense CE** | pfsense.org → Download → select **AMD64**, **DVD Image (ISO) Installer** | This is your router and firewall. It's free, and it's real software used in real small businesses. |
| **Ubuntu Desktop** | ubuntu.com/download/desktop | Your client machines. You'll make two or three. |
| **Ubuntu Server** | ubuntu.com/download/server | Optional — a machine to live on the server VLAN. |

The pfSense download arrives compressed (`.gz`). Extract it with 7-Zip on Windows, or on Mac/Linux run `gunzip filename.iso.gz`.

---

## Step 1.4 — Create the virtual networks

**Plain English:** Before building the fake computers, you build the fake cables. In VirtualBox, an "Internal Network" is a private virtual cable that only VMs you attach to it can use. Nothing else on your real computer or real home network can see it. Each internal network is its own separate street.

You don't create these in a menu — you create them by *naming* them when you configure a VM. Just decide the names now:

- `vlan10-users`
- `vlan20-servers`
- `vlan30-mgmt`

Type these exactly the same way every time. A typo creates a fourth network that looks identical and nothing will connect. (Note this down — it's a realistic cause of failure and worth a troubleshooting case later.)

---

## Step 1.5 — Build the pfSense router

This VM is the heart of everything. It gets four network cards: one facing the internet, three facing your VLANs.

**Plain English on "router on a stick":** A router's whole job is to have a foot in multiple streets at once so it can pass traffic between them. This VM has four feet.

### Create it

1. VirtualBox → **New**
2. Name: `pfSense-Router` · Type: **BSD** · Version: **FreeBSD (64-bit)**
3. Memory: **2048 MB**
4. Create a virtual hard disk: **VDI**, dynamically allocated, **20 GB**
5. Click **Create**

### Configure its four network cards

Select the VM → **Settings** → **Network**. There are tabs for Adapter 1 through 4.

| Adapter | Attached to | Name | This is the... |
|---|---|---|---|
| 1 | **NAT** | — | WAN. The way out to the real internet. |
| 2 | **Internal Network** | `vlan10-users` | User network interface |
| 3 | **Internal Network** | `vlan20-servers` | Server network interface |
| 4 | **Internal Network** | `vlan30-mgmt` | Management network interface |

Check **Enable Network Adapter** on each of the four tabs. Leave adapter type as the default Intel PRO/1000.

### Install pfSense

1. **Settings** → **Storage** → click the empty CD icon → click the disc icon on the right → **Choose a disk file** → select your extracted pfSense ISO.
2. **Start** the VM.
3. Accept the license. Choose **Install**. Accept the default keymap.
4. Partitioning: choose **Auto (ZFS)** → **Install** → select **stripe** → press `SPACE` to select the disk (`ada0`) → `ENTER` → confirm **YES** to destroy the disk. (It's a virtual disk. Nothing real is being destroyed.)
5. When it finishes, choose **Reboot**. Before it boots back up, go to **Devices** → **Optical Drives** → **Remove disk from virtual drive** so it doesn't reinstall.

### Assign the interfaces

pfSense boots to a text menu and asks about VLANs. Answer **n** (you're using separate virtual cables instead of tagged VLANs — see the note at the end of this project).

It will then ask you to name each interface. pfSense calls them `em0`, `em1`, `em2`, `em3`, matching Adapters 1–4 in order.

- WAN interface name: `em0`
- LAN interface name: `em1`
- Optional 1: `em2`
- Optional 2: `em3`

Confirm with **y**.

### Set the IP addresses

From the pfSense console menu, choose option **2) Set interface(s) IP address**.

**For LAN (em1) — your VLAN 10:**
- Configure via DHCP? **n**
- IPv4 address: `10.10.10.1`
- Subnet bit count: `26`
- Upstream gateway: press **ENTER** for none
- Configure IPv6? **n**
- Enable DHCP server on LAN? **y**
- Start address: `10.10.10.10`
- End address: `10.10.10.60`
- Revert to HTTP webConfigurator? **n**

**Repeat option 2 for OPT1 (em2):** `10.10.20.1` / `28` / DHCP range `10.10.20.5` – `10.10.20.14`

**Repeat option 2 for OPT2 (em3):** `10.10.30.1` / `29` / DHCP **n** (management devices get static addresses on purpose — that's a deliberate design decision worth explaining in your write-up)

**Plain English on what just happened:** Each interface now holds the first usable address of its street, and acts as that street's only exit. You also stood up a DHCP clerk on two of the three streets.

---

## Step 1.6 — Build a client machine

1. VirtualBox → **New** → Name: `PC1-Users` · Type: **Linux** · Version: **Ubuntu (64-bit)**
2. Memory: **2048 MB** · Disk: **25 GB**
3. **Settings** → **Network** → Adapter 1 → **Internal Network** → `vlan10-users`
4. **Settings** → **Storage** → attach the Ubuntu Desktop ISO
5. Start it, install Ubuntu with defaults (choose "Minimal installation" to save time), reboot, remove the ISO.

### Verify it worked

Open a terminal in Ubuntu (`Ctrl+Alt+T`) and run:

```bash
ip a
```

You should see an address between `10.10.10.10` and `10.10.10.60`. If you do, your DHCP server works.

```bash
ip route
```

Should show `default via 10.10.10.1`. That's your gateway.

```bash
ping 10.10.10.1
```

Replies mean you can reach your router.

```bash
ping 8.8.8.8
```

Replies mean your router is passing traffic out to the internet.

**Screenshot all of this.** It's evidence.

### Build the others

Repeat for `PC2-Servers` on `vlan20-servers` and `PC3-Mgmt` on `vlan30-mgmt`. The management box has no DHCP, so set its address manually: Ubuntu Settings → Network → gear icon → IPv4 → Manual → Address `10.10.30.5`, Netmask `255.255.255.248`, Gateway `10.10.30.1`, DNS `10.10.30.1`.

---

## Step 1.7 — Reach the web interface and set firewall rules

From `PC1-Users`, open a browser and go to `https://10.10.10.1`. Accept the security warning. Log in with username `admin`, password `pfsense`. **Change the password immediately** when prompted — and mention in your write-up that you did, because default credentials are a Network+ security objective.

### The important part: inter-VLAN traffic control

**Plain English:** Right now VLAN 10 can reach everything, because pfSense's default LAN rule is "allow anything out." Meanwhile VLAN 20 and 30 can reach *nothing*, because optional interfaces start with no rules at all and anything not explicitly allowed is blocked. You're going to replace that with a deliberate policy.

Go to **Firewall → Rules**.

**Policy you're implementing:**

| From | To | Allowed? | Why |
|---|---|---|---|
| Users (10) | Internet | Yes | People need to work |
| Users (10) | Servers (20) | Yes, on specific ports only | Access files, not the whole box |
| Users (10) | Management (30) | **No** | Employees have no business on switch admin pages |
| Servers (20) | Internet | Yes | Updates |
| Servers (20) | Users (10) | **No** | A compromised server shouldn't be able to attack workstations |
| Management (30) | Everything | Yes | Admins need to get everywhere |

To build the "Users cannot reach Management" rule:

1. **Firewall → Rules → LAN** tab → **Add** (the up-arrow button, to place it at the top — rules are read top to bottom and the first match wins)
2. Action: **Block**
3. Interface: **LAN**
4. Address Family: **IPv4**
5. Protocol: **Any**
6. Source: **LAN net**
7. Destination: **Network** → `10.10.30.0` / `29`
8. Description: `Block users from management VLAN`
9. **Save** → **Apply Changes**

**Test it.** From `PC1-Users`: `ping 10.10.30.5` should now fail. From `PC3-Mgmt`: `ping 10.10.10.x` should still work. **Screenshot both.** A rule you tested is worth ten rules you configured.

Build out the rest of the table the same way. To allow only specific ports, set Protocol to **TCP** and specify the destination port.

---

## Step 1.8 — Internal DNS

**Plain English:** Right now you type `10.10.20.5` to reach your server. Real networks let you type `fileserver.lab.local`. That translation is DNS, and pfSense runs it for you.

1. **Services → DNS Resolver** — confirm **Enable** is checked (it is by default)
2. Scroll to **Host Overrides** → **Add**
3. Host: `fileserver` · Domain: `lab.local` · IP: `10.10.20.5` · Description: `File server`
4. **Save** → **Apply Changes**

Test from `PC1-Users`:

```bash
nslookup fileserver.lab.local
ping fileserver.lab.local
```

The name should resolve to `10.10.20.5`. Screenshot it.

---

## Step 1.9 — Take snapshots (do not skip)

**Plain English:** A snapshot is a saved photograph of a VM's exact state. If you wreck a machine, you restore the photograph and it's like it never happened. You are about to spend an entire project deliberately wrecking things.

For **every VM**: select it → **Snapshots** (top right) → **Take** → name it `clean-working-baseline` → OK.

---

## Step 1.10 — Document it

1. **Diagram:** Go to **app.diagrams.net** (free, no account). Draw three boxes for the VLANs, one for the router, one for the internet. Label every link with its network address and every interface with its IP. Export as PNG into `03-virtual-lab/diagrams/`.
2. **Addressing:** Finish `addressing.md` with the table and your sizing reasoning.
3. **Configs:** In pfSense, **Diagnostics → Backup & Restore → Download configuration as XML**. Save it to `03-virtual-lab/configs/`. **Open it in a text editor and delete the password hashes** before committing it anywhere public.

## Step 1.11 — Go past the finish line

Pick at least one and do it, because this is what separates your lab from everyone else's:

- **A $30 managed switch** (TP-Link TL-SG108E or similar) plus real 802.1Q VLAN tagging and a trunk port. This turns your "separate virtual cables" setup into genuine VLAN tagging, which is what the exam actually tests and what the job actually uses.
- **Monitoring:** install Zabbix or LibreNMS on the server VM and monitor the router.
- **VPN:** enable OpenVPN on pfSense and connect from your host machine.
- **IPv6:** dual-stack one VLAN.
- **Centralized logging:** point pfSense syslog at a server VM running rsyslog.

Write a paragraph about why you chose it and what surprised you.

---

# PART 2 — The Troubleshooting Case Log

**What you're building:** Six documented failures, worked start to finish, with real command output.

**Why it's the most valuable project:** Anyone can follow a tutorial. The job is figuring out what's wrong when nobody knows what's wrong. This is the only artifact that shows you can do that.

---

## Step 2.1 — Learn the methodology (it's on the exam)

CompTIA's seven steps, in plain language:

1. **Identify the problem** — What exactly is broken? Who's affected? When did it start? What changed?
2. **Establish a theory** — Best guess at the cause.
3. **Test the theory** — Prove or disprove it. If disproved, form a new theory or escalate.
4. **Establish a plan of action** — Decide what you'll change and what it might affect.
5. **Implement the solution**
6. **Verify full system functionality** — And take preventive measures.
7. **Document findings, actions, and outcomes**

Your write-ups will follow these headings exactly. That's deliberate: it shows a hiring manager you already work the way they need you to work.

**One critical habit:** change **one thing at a time**. If you change three things and it starts working, you don't know what fixed it, and you've learned nothing.

---

## Step 2.2 — Know your tools

| Tool | Plain English | Command |
|---|---|---|
| `ping` | Shout at a device and see if it shouts back | `ping 10.10.10.1` |
| `traceroute` | Show every stop along the route | `traceroute 8.8.8.8` (Win: `tracert`) |
| `ip a` | Show my own address | `ip a` (Win: `ipconfig /all`) |
| `ip route` | Show which way out I'm using | `ip route` (Win: `route print`) |
| `nslookup` / `dig` | Ask the phone book directly | `nslookup google.com` |
| `arp` | Show which physical device owns which IP on my street | `arp -a` |
| `ss` / `netstat` | Show what connections this machine has open | `ss -tuln` |
| **Wireshark** | Record every packet and read it | Install: `sudo apt install wireshark` |

### Wireshark in one paragraph

**Plain English:** Data crosses a network in small chunks called packets, each carrying addresses and a payload. Wireshark records every packet crossing an interface and lets you read them. It's a wiretap for your own network.

Open it, double-click your interface (usually `enp0s3`), and traffic scrolls past. Type a filter in the green bar and press Enter:

- `icmp` — only ping traffic
- `dns` — only phone book lookups
- `arp` — only "who owns this IP?" broadcasts
- `ip.addr == 10.10.20.5` — only traffic to or from that device
- `dhcp` — only address-assignment traffic (older versions: `bootp`)

**File → Export Packet Dissections → As Plain Text** to save evidence into your repo.

---

## Step 2.3 — The six faults

For each one: **take a fresh snapshot first**, break it, then approach it as though you don't know the cause. Actually run the diagnostic sequence and record the output even when you already suspect the answer, because the output *is* the portfolio.

---

### Case 01 — Wrong default gateway

**Break it:** On `PC1-Users`, set a static IP with a bad gateway. Ubuntu Settings → Network → gear → IPv4 → Manual: Address `10.10.10.50`, Netmask `255.255.255.192`, Gateway `10.10.10.99`, DNS `10.10.10.1`.

**Symptom:** Can ping other devices on VLAN 10. Cannot reach the internet or any other VLAN.

**The diagnostic path:**
```bash
ip a                    # address looks fine
ping 10.10.10.1         # router responds — local network is healthy
ping 8.8.8.8            # fails
ip route                # "default via 10.10.10.99" — there's your problem
arp -a                  # 10.10.10.99 shows as incomplete: nothing there
```

**Concept to explain in your write-up:** A device only knows how to reach its own street. Anything else gets handed to the gateway. Point at a gateway that doesn't exist and every off-network destination silently fails, while local traffic looks perfectly fine. That split symptom — local works, remote doesn't — is the fingerprint.

---

### Case 02 — Duplicate IP address

**Break it:** Set `PC1-Users` to static `10.10.10.20` (inside the DHCP range), and set another VM on the same VLAN to static `10.10.10.20` as well.

**Symptom:** Connectivity works intermittently. Sometimes fine, sometimes dead. Often worse for one machine than the other.

**Diagnostic path:**
```bash
ping 10.10.10.20        # inconsistent replies
arp -a                  # watch the MAC address for that IP change between checks
```
Run Wireshark with filter `arp` and watch two different MAC addresses claim the same IP. Also check the system log: `journalctl -xe | grep -i duplicate`.

**Concept:** IP addresses are how devices are *found*, but MAC addresses are how frames are actually *delivered* on the local street. When two machines claim one IP, switches and hosts keep flip-flopping on which MAC to deliver to. Intermittent is the signature — and intermittent problems are the hardest kind, which is why this case is worth including.

---

### Case 03 — Wrong subnet mask

**Break it:** On `PC1-Users`, set static `10.10.10.50` with mask `255.255.255.0` (a /24) instead of the correct `255.255.255.192` (/26). Gateway stays `10.10.10.1`.

**Symptom:** This is the sneaky one. Some things work. Some don't. Behavior depends on which address you're trying to reach.

**Diagnostic path:**
```bash
ip a                            # address is right, mask is wrong — easy to skim past
ping 10.10.10.1                 # works
ping 10.10.20.5                 # fails or behaves strangely
```

**Concept — and this is the best concept in the whole log:** The mask is what a device uses to decide "is this destination on my street, or do I send it to the gateway?" With a wrong /24 mask, the machine believes everything from `10.10.10.1` to `10.10.10.254` is local. So for anything in `.65`–`.254` it will shout on the local wire — ARP — instead of routing. Nobody answers, and the traffic dies. Meanwhile everything genuinely local still works.

If you can explain this out loud in an interview, you're ahead of most candidates. Wrong-mask problems are extremely common in the real world and notoriously misdiagnosed.

---

### Case 04 — Dead DNS server

**Break it:** On `PC1-Users`, keep everything correct but set DNS to `10.10.10.200` (nothing is there).

**Symptom:** "The internet is down." But it isn't.

**Diagnostic path:**
```bash
ping 8.8.8.8            # works — raw connectivity is fine
ping google.com         # "Name or service not known"
nslookup google.com     # timeout, connection refused
cat /etc/resolv.conf    # shows the wrong DNS server
nslookup google.com 8.8.8.8   # works when you specify a good server — proves it's DNS
```

**Concept:** Reachability and name resolution are two separate systems, and users can't tell them apart. "Ping the IP, then ping the name" is the fastest way to split them. If the IP works and the name doesn't, it's DNS. That single test is worth mentioning explicitly in your write-up.

---

### Case 05 — Firewall rule blocking legitimate traffic

**Break it:** In pfSense, **Firewall → Rules → LAN**, add a Block rule at the top: source **LAN net**, destination **Network** `10.10.20.0/28`. Apply.

**Symptom:** Users suddenly can't reach the file server. Nothing changed on any client.

**Diagnostic path:**
```bash
ping 10.10.20.5         # fails
ip a / ip route         # client config is perfect
ping 10.10.10.1         # gateway fine
```
Then in pfSense: **Status → System Logs → Firewall**. Find the blocked packets and the rule ID that dropped them.

**Concept:** When client config is provably correct and one specific destination is unreachable, stop looking at the client. The firewall log is the fastest path to the answer, and knowing to check it is the thing being demonstrated.

---

### Case 06 — Wrong VLAN assignment

**Break it:** Shut down `PC2-Servers`. In its VirtualBox network settings, change Adapter 1's Internal Network from `vlan20-servers` to `vlan10-users`. Boot it.

**Symptom:** The machine gets an unexpected address — it now pulls from the VLAN 10 DHCP pool — and nothing that's supposed to reach it can.

**Diagnostic path:**
```bash
ip a          # address is in 10.10.10.x, not 10.10.20.x — immediate red flag
```

**Concept:** This is the virtual equivalent of a cable in the wrong switch port, or a port assigned to the wrong VLAN. It's one of the most common real-world causes of "it worked yesterday" after an office move. The address a device receives tells you which broadcast domain it's actually sitting in, regardless of where you think you plugged it.

---

## Step 2.4 — Get one unplanned failure

This is the case that matters most, and you can't script it. Options:

- **Have someone else break it.** Give a friend the VM list and ten minutes. They change one thing and don't tell you what. Time yourself.
- **Wait for one.** Do the extension work from Step 1.11. Something will break for real, and you will not know why. That's the one to write up.
- **Attempt something above your level.** Configure OpenVPN or a site-to-site tunnel. You will fail several times before succeeding.

When you write it up, be specific about being wrong: what your first theory was, what evidence made it look right, what disproved it, what you had genuinely misunderstood. This is counterintuitive but it's the strongest thing you can put in the repo. It reads as competence and honesty at once, and it's unfakeable.

---

## Step 2.5 — The write-up template

Save as `01-troubleshooting-log/case-01-name.md`:

```markdown
# Case 01 — [Short symptom description]

**Date:** | **Time to resolve:** | **Severity:** [Single user / Subnet / Site-wide]

## 1. Identify the problem
Reported symptom, scope, what changed recently, questions asked.

## 2. Establish a theory
Initial theory and the reasoning behind it.

## 3. Test the theory
[Commands run and their real output in code blocks]
What each result ruled in or out.

## 4. Plan of action
What you decided to change and what else it might affect.

## 5. Implement
[The change]

## 6. Verify
[Proof it works — commands and output]

## 7. Documentation and lessons
Root cause in one sentence.
What I'd check first if I saw this symptom again.
What I misunderstood before this.
```

---

# PART 3 — The Network Audit

**What you're building:** A professional assessment of a real network, plus a costed redesign proposal.

**Why it's different from the other two:** It's the only project involving real hardware, real interference, real budget constraints, and a real non-technical stakeholder. That's what the job is.

---

## ⚠️ Read this before you scan anything

Scan **only** a network you personally own, or one where you have **written permission** from the owner. Port-scanning a network you don't own is a crime in most jurisdictions, including under the US Computer Fraud and Abuse Act. Your own home network is fine. A coffee shop's is not. A friend's is fine *if they say yes* — and get it in writing, because saying you got permission is itself a professional habit worth demonstrating.

If you audit someone else's network, put a line in the write-up: *"Assessment performed with written authorization from the network owner."* Hiring managers notice that.

---

## Step 3.1 — Inventory

Log into your router's admin page (usually `192.168.1.1` or `192.168.0.1` — check `ip route` or `ipconfig` for your gateway). Find the connected devices list.

Build a table: device name, type, MAC address, IP address, connection type (wired/wireless), and whether the IP is static or DHCP.

**Look for devices you can't identify.** Track every one down. Unidentified devices on a network is itself a finding.

---

## Step 3.2 — Topology diagram

In diagrams.net, draw what's physically there: modem → router → switches → access points → devices. Mark which links are wired and which are wireless. Note the speed of each link if you know it.

**Plain English:** A topology diagram answers "what is connected to what." It's usually the first thing anyone asks for and the thing that's never up to date. Making a good one is a real deliverable.

---

## Step 3.3 — Wireless survey

**Plain English on the concept:** Wi-Fi is radio. Radio operates on channels. If your neighbor's network and yours use the same channel, you're both shouting on the same frequency and both get slower. The 2.4 GHz band has only three channels that don't overlap: **1, 6, and 11**. Everything else partially overlaps and makes things worse for everyone.

**Tools:** WiFiman (Android/iOS), Network Analyzer (iOS), or NetSpot (desktop).

**Do this:**
1. Scan and record every network you can see, its channel, and its signal strength.
2. Note how many networks share your channel.
3. Walk the space. Record signal strength (in dBm) in each room. Anything weaker than **-70 dBm** is a dead zone.
4. Note whether you're on 2.4 GHz, 5 GHz, or both, and which standard (Wi-Fi 5 / 802.11ac, Wi-Fi 6 / 802.11ax).

**Reading dBm:** it's negative, and closer to zero is better. -40 is excellent, -60 is fine, -70 is marginal, -80 is unusable.

**Finding to look for:** you're on a congested channel while 1, 6, or 11 sits nearly empty. That's a free fix and a strong entry in your report.

---

## Step 3.4 — Firmware and patch status

For every network device — router, access points, switches, anything with an admin page:

- Current firmware version
- Latest available version from the manufacturer
- Date of the current version
- Whether the model is still supported at all

**Concept:** Unpatched network gear is one of the most common real-world attack vectors, and end-of-life hardware never gets fixed. A router that stopped receiving updates in 2019 is a finding regardless of whether it still works.

---

## Step 3.5 — Port and service scan

Install nmap (`sudo apt install nmap`, or nmap.org for Windows).

```bash
# Discover live hosts on your network
nmap -sn 192.168.1.0/24

# Scan one device for open ports and what's running on them
nmap -sV 192.168.1.1
```

**Plain English:** A port is a numbered door on a device, each one belonging to a specific service. Port 80 is web, 443 is secure web, 22 is remote shell, 23 is telnet. An open door isn't automatically bad — but a door you didn't know was open, or one running an insecure protocol, is.

**Findings to look for:** telnet (23) open anywhere — it sends passwords in plain text and should be SSH instead. Admin interfaces reachable from the wireless network. UPnP enabled. Any service you can't account for.

---

## Step 3.6 — Segmentation check

**Plain English:** Segmentation means keeping groups of devices apart so a problem in one group can't spread. A smart TV or doorbell camera sitting on the same flat network as a work laptop means anyone who compromises the cheap camera has a path to the laptop.

Check:
- Is there a guest network? Is it actually isolated, or just a second name on the same network?
- Are IoT devices separated from computers?
- Can a guest-network device reach your router's admin page? (Connect to guest Wi-Fi and try. If the admin page loads, that's a significant finding.)

---

## Step 3.7 — Write the findings

For each finding: **what it is → why it matters → how bad → what to do.**

Rate severity **High / Medium / Low** and defend the rating.

Example of the right voice:

> **Finding 3 — IoT devices share the primary network (Severity: High)**
> Six devices (two smart speakers, a thermostat, three cameras) are on the same subnet and broadcast domain as personal computers holding financial documents. Two of the cameras run firmware last updated in 2021 and no longer receive vendor security patches.
> **Impact:** A vulnerability in any one camera provides an attacker a foothold on the same network segment as sensitive data, with no boundary in between.
> **Recommendation:** Move all IoT devices to an isolated VLAN or a properly segmented guest SSID with client isolation enabled, and block that segment from initiating connections to the primary network.

---

## Step 3.8 — The redesign and the cost

Produce:
1. **Proposed topology diagram** — what it should look like
2. **Phased implementation plan** — what to do first, second, third, and why that order (highest risk and lowest cost first)
3. **Cost table** — real part numbers, real current prices, with a justification sentence per line
4. **A short "do nothing" section** — what the risk is if none of this happens

**Why the cost table matters more than it looks:** Anyone can say "buy better equipment." Saying "a $34 managed switch resolves findings 3 and 5, and here's why that specific model" is the difference between a student and someone who can be given a budget.

---

# Final Checklist

**Lab**
- [ ] Three VLANs with correct, right-sized subnets
- [ ] Inter-VLAN routing working
- [ ] DHCP serving two VLANs, static addressing on management by design
- [ ] Firewall policy implemented **and tested**, with screenshots of both allow and deny
- [ ] Internal DNS resolving
- [ ] Diagram, addressing doc with sizing reasoning, sanitized config export
- [ ] At least one thing built past the requirements

**Troubleshooting**
- [ ] Six cases, all seven methodology steps each
- [ ] Real command output, not descriptions of output
- [ ] At least two Wireshark captures
- [ ] **At least one unplanned failure with your wrong theories included**

**Audit**
- [ ] Authorization documented
- [ ] Device inventory and topology diagram
- [ ] Wireless survey with channel data and dBm readings by location
- [ ] Firmware status for every device
- [ ] Port scan results
- [ ] Segmentation assessment
- [ ] Findings with severity ratings and defended reasoning
- [ ] Redesign with phased plan and costed parts list

**Repo**
- [ ] README complete, no bracketed placeholders left
- [ ] No real passwords, password hashes, public IPs, or personal addresses anywhere
- [ ] Diagrams render as images, not links
- [ ] Every project folder has its own README
