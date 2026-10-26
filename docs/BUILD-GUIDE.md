# Network+ Portfolio — Complete Build Guide

Everything here assumes you know nothing. Concepts are explained in plain language first, then the actual commands and clicks.

**Target machine:** Apple Silicon Mac, 8 GB RAM. Every tool chosen below runs on that hardware. If you're reading this on a different machine, the concepts still hold but the installation steps won't.

---

## Why two labs instead of one

The usual advice is "build a lab in VirtualBox with pfSense." That doesn't work here, for two independent reasons:

1. **pfSense has no ARM build.** Netgate has stated there are no plans for ARM Community Edition images; ARM support exists only in pfSense Plus. On Apple Silicon it can only run under x86 emulation, which is slow and unreliable.
2. **8 GB isn't enough anyway.** macOS alone uses 3–4 GB. A router VM plus three client VMs needs 8 GB on top of that.

So the lab is split in two, and each half does something the other can't:

| | **Packet Tracer** | **Namespace lab** |
|---|---|---|
| What it is | Cisco's network simulator | Real Linux networking inside one small VM |
| RAM | ~1 GB | ~3 GB |
| Gives you | VLANs, trunking, IOS syntax, visual topology | Real `ip`/`ping`/`arp`/`tcpdump` output |
| Maps to | Network+ exam objectives, CCNA later | The troubleshooting log |
| Differentiating? | No — everyone has one | **Yes** — almost nobody does this |

Build both. Packet Tracer is your study tool and gives you the diagram recruiters can look at. The namespace lab is where the troubleshooting log gets its real command output, and because it's a script, it's reproducible — anyone can clone your repo and rebuild your exact network in thirty seconds. That's the part that doesn't look like everyone else's portfolio.

**The design work already applies to both.** [`addressing.md`](../03-virtual-lab/addressing.md) and [`firewall-policy.md`](../03-virtual-lab/firewall-policy.md) are platform-independent. The subnets, the sizing reasoning, and the policy are the same whichever tool implements them.

**Build order:**

| Order | What | Time |
|---|---|---|
| 1st | Packet Tracer lab | 4–8 hours |
| 2nd | Namespace lab | 3–6 hours |
| 3rd | Troubleshooting log | 10–20 hours |
| 4th | Network audit | 4–8 hours |

---

# PART 0 — Vocabulary

Read this once. Everything later assumes it.

| Term | Plain English |
|---|---|
| **IP address** | The street address of a device. `10.10.10.50` |
| **Subnet mask** | Tells a device which addresses are "on my street" vs. somewhere else. `255.255.255.192` |
| **Default gateway** | The one road out of your street. Traffic for anywhere else gets handed here. |
| **Switch** | Connects devices *on the same street*. Doesn't know how to leave it. |
| **Router** | Connects *different streets*. Knows how to get from one to another. |
| **VLAN** | An invisible wall inside one physical switch, splitting it into separate streets that can't hear each other. |
| **Broadcast domain** | Everyone who hears you when you shout. One VLAN = one broadcast domain. |
| **Trunk** | A single cable carrying traffic for *multiple* VLANs between two devices, with each frame tagged so the far end knows which VLAN it belongs to. The tagging standard is **802.1Q**. |
| **Router on a stick** | One physical router interface split into logical subinterfaces, one per VLAN, so a single cable can route between all of them. |
| **DHCP** | A clerk that hands out IP addresses automatically. |
| **DNS** | The phone book. Turns `fileserver.lab.local` into an IP address. |
| **ACL** | Access Control List — a rule list on a router saying which traffic is allowed through. |

### The one piece of math you need

An IP address is 32 bits. The slash number says how many of those bits identify the *street*; the rest identify the *house*.

| Prefix | Mask | Addresses | Usable hosts |
|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /29 | 255.255.255.248 | 8 | 6 |
| /30 | 255.255.255.252 | 4 | 2 |

**Memorize the right-hand column.** Two addresses per subnet are unusable: all-zeros names the network itself, all-ones is the broadcast.

### The scheme you're building

Both labs implement this. Full reasoning in [`addressing.md`](../03-virtual-lab/addressing.md).

| VLAN | Purpose | Network | Mask | Usable | Gateway |
|---|---|---|---|---|---|
| 10 | Users | 10.10.10.0/26 | 255.255.255.192 | .1 – .62 | 10.10.10.1 |
| 20 | Servers | 10.10.20.0/28 | 255.255.255.240 | .1 – .14 | 10.10.20.1 |
| 30 | Management | 10.10.30.0/29 | 255.255.255.248 | .1 – .6 | 10.10.30.1 |

---

# PART 1A — The Packet Tracer Lab

**What you're building:** three VLANs on a switch, trunked to a router that routes between them, with DHCP and an ACL enforcing the segmentation policy.

**Why this half exists:** it uses real Cisco IOS syntax, it maps directly onto Network+ exam objectives, and it produces a clean topology picture. It's also the foundation for CCNA if you go that way later.

---

## Step 1A.1 — Get Packet Tracer

Packet Tracer is free but requires a Cisco Networking Academy account.

1. Go to **skillsforall.com** (Cisco's free learning platform) and create an account.
2. Enrol in the free course **"Getting Started with Cisco Packet Tracer."** Enrolment is what unlocks the download — you don't have to finish the course.
3. Download the **macOS** version and install it.
4. Launch it and sign in with the same account. It won't run unsigned.

**On Apple Silicon:** Packet Tracer is an Intel application and runs through Rosetta 2 translation rather than natively. If macOS prompts to install Rosetta, accept. Performance is fine — the app is light.

---

## Step 1A.2 — Lay out the topology

Drag these onto the canvas from the device panel at the bottom left:

| Device | Type | Where to find it |
|---|---|---|
| Router | **2911** | Routers |
| Switch | **2960** | Switches |
| PC-Users | PC | End Devices |
| PC-Server | PC | End Devices |
| PC-Mgmt | PC | End Devices |

Wire them with the **Copper Straight-Through** cable (the plain solid line under Connections):

| From | Port | To | Port |
|---|---|---|---|
| Router 2911 | GigabitEthernet0/0 | Switch 2960 | GigabitEthernet0/1 |
| PC-Users | FastEthernet0 | Switch | FastEthernet0/1 |
| PC-Server | FastEthernet0 | Switch | FastEthernet0/2 |
| PC-Mgmt | FastEthernet0 | Switch | FastEthernet0/3 |

Link lights will be red at first. That's expected — nothing is configured yet.

---

## Step 1A.3 — Configure the switch

Click the switch → **CLI** tab → press Enter.

**Create the VLANs.** Right now the switch has one broadcast domain. You're splitting it into three.

```
enable
configure terminal
hostname SW1

vlan 10
 name USERS
 exit
vlan 20
 name SERVERS
 exit
vlan 30
 name MGMT
 exit
```

**Assign the access ports.** An *access port* belongs to exactly one VLAN and sends untagged frames — the end device has no idea VLANs exist.

```
interface fastEthernet 0/1
 switchport mode access
 switchport access vlan 10
 exit
interface fastEthernet 0/2
 switchport mode access
 switchport access vlan 20
 exit
interface fastEthernet 0/3
 switchport mode access
 switchport access vlan 30
 exit
```

**Configure the trunk.** This is the one cable to the router carrying all three VLANs, with each frame tagged so the router can tell them apart.

```
interface gigabitEthernet 0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30
 exit
end
write memory
```

> **Why no `switchport trunk encapsulation dot1q` here?** On a 2960, 802.1Q is the only encapsulation supported, so the command doesn't exist. On a layer-3 switch like a 3560 you *would* need it, because those also support the older Cisco ISL. Worth knowing — it's a classic exam gotcha and a classic real-world confusion.

**Verify:**

```
show vlan brief
show interfaces trunk
```

`show vlan brief` should list your three VLANs with the right ports in each. `show interfaces trunk` should show Gi0/1 trunking VLANs 10, 20 and 30. **Screenshot both.**

---

## Step 1A.4 — Configure the router (router on a stick)

Click the router → **CLI** tab.

**Plain English:** the router has one physical cable to the switch but needs an address on all three VLANs. You split the physical interface into three logical *subinterfaces*, each tagged for one VLAN. One cable, three gateways.

```
enable
configure terminal
hostname R1

interface gigabitEthernet 0/0
 no shutdown
 exit

interface gigabitEthernet 0/0.10
 encapsulation dot1Q 10
 ip address 10.10.10.1 255.255.255.192
 exit

interface gigabitEthernet 0/0.20
 encapsulation dot1Q 20
 ip address 10.10.20.1 255.255.255.240
 exit

interface gigabitEthernet 0/0.30
 encapsulation dot1Q 30
 ip address 10.10.30.1 255.255.255.248
 exit
```

The physical interface must be brought up with `no shutdown` *before* the subinterfaces work. Forgetting that is the single most common reason a router-on-a-stick build silently fails.

**Verify:**

```
show ip interface brief
show ip route
```

All three subinterfaces should read **up/up**, and the routing table should show three directly connected networks with `C`. **Screenshot both.**

---

## Step 1A.5 — DHCP

**Plain English:** `ip dhcp excluded-address` reserves addresses the clerk isn't allowed to hand out — the gateway and the statically assigned server.

```
configure terminal

ip dhcp excluded-address 10.10.10.1 10.10.10.9
ip dhcp excluded-address 10.10.20.1 10.10.20.4

ip dhcp pool VLAN10
 network 10.10.10.0 255.255.255.192
 default-router 10.10.10.1
 dns-server 10.10.20.5
 exit

ip dhcp pool VLAN20
 network 10.10.20.0 255.255.255.240
 default-router 10.10.20.1
 dns-server 10.10.20.5
 exit
end
write memory
```

VLAN 30 gets no pool — management devices are static by design, so an unexpected device on that segment fails loudly instead of quietly joining. That's a deliberate decision; say so in your write-up.

**Test it.** Click PC-Users → **Desktop** → **IP Configuration** → select **DHCP**. It should pull an address in 10.10.10.10–.62 with gateway 10.10.10.1.

Set PC-Mgmt manually: address `10.10.30.5`, mask `255.255.255.248`, gateway `10.10.30.1`.

**Verify from the router:**

```
show ip dhcp binding
```

**Screenshot it.**

---

## Step 1A.6 — Enforce the policy with an ACL

**Plain English:** inter-VLAN routing now works, which means everyone can reach everyone. That's not what [`firewall-policy.md`](../03-virtual-lab/firewall-policy.md) says should happen. An ACL is a rule list applied to an interface that permits or denies traffic.

```
configure terminal

ip access-list extended USERS_IN
 deny ip 10.10.10.0 0.0.0.63 10.10.30.0 0.0.0.7
 permit ip any any
 exit

interface gigabitEthernet 0/0.10
 ip access-group USERS_IN in
 exit
end
write memory
```

### Wildcard masks — the bit that trips everyone up

Cisco ACLs use a **wildcard mask**, which is the inverse of a subnet mask. A `0` bit means "must match"; a `1` bit means "don't care."

| Network | Subnet mask | Wildcard mask |
|---|---|---|
| 10.10.10.0/26 | 255.255.255.192 | **0.0.0.63** |
| 10.10.20.0/28 | 255.255.255.240 | **0.0.0.15** |
| 10.10.30.0/29 | 255.255.255.248 | **0.0.0.7** |

Quick conversion: subtract each subnet-mask octet from 255. `255 − 192 = 63`. That's the whole trick.

### The rule everyone forgets

**Every ACL ends with an invisible `deny any any`.** If you write only the deny line and omit `permit ip any any`, you have blocked all traffic from that VLAN, not just the management traffic. Leave it off and your users lose internet, the file server, everything.

**Test both directions:**

- PC-Users → Command Prompt → `ping 10.10.30.5` → must **fail**
- PC-Users → `ping 10.10.20.5` → must **succeed**
- PC-Mgmt → `ping 10.10.10.x` → must **succeed**

```
show access-lists
```

The deny line will show a match counter climbing as blocked pings hit it. **Screenshot that** — a rule with hit counts is proof it's actually doing something, not just configured.

---

## Step 1A.7 — Save the artifacts

1. **File → Save As** → `03-virtual-lab/packet-tracer/lab.pkt`
2. Screenshot the topology canvas → `03-virtual-lab/diagrams/topology.png`
3. Export each device's config: on the CLI run `show running-config`, copy the output into `03-virtual-lab/configs/r1-running-config.txt` and `sw1-running-config.txt`

---

# PART 1B — The Namespace Lab

**What you're building:** the same three-segment network, as real Linux networking inside a single small VM — and as a script that rebuilds it from nothing in thirty seconds.

**Why this half exists:** Packet Tracer is a simulator. It can't give you genuine `ip a` output, a real ARP table, or a real packet capture. Your troubleshooting log needs all three. It's also the piece that makes your portfolio reproducible, which almost nobody at this level does.

---

## Step 1B.1 — Install UTM and Ubuntu

**UTM** is a free, Apple Silicon–native virtualization app.

1. Download from **mac.getutm.app** (the direct download is free; the Mac App Store build is the same app, paid as a convenience).
2. Download **Ubuntu Server 24.04 LTS for ARM64** from `ubuntu.com/download/server/arm` — it must be the **ARM64** image, not AMD64. An x86 image would have to be emulated and would be unusably slow.
3. In UTM: **Create a New Virtual Machine → Virtualize → Linux**, select the Ubuntu ARM64 ISO.
4. Memory: **3072 MB**. Storage: **20 GB**. CPU cores: 2.
5. Install Ubuntu with defaults. Choose **"Install OpenSSH server"** when offered — it makes copying command output out of the VM far easier than retyping from a screenshot.

> Server, not Desktop. You don't need a GUI, and Desktop would eat another gigabyte for nothing.

After install, shut down, remove the ISO from the VM's drive settings, and boot.

---

## Step 1B.2 — Install the tools

```bash
sudo apt update
sudo apt install -y iproute2 iputils-ping tcpdump dnsmasq nftables bridge-utils net-tools dnsutils
```

| Package | What it gives you |
|---|---|
| `iproute2` | `ip` — addresses, routes, namespaces |
| `iputils-ping` | `ping` |
| `tcpdump` | packet capture (Wireshark's command-line sibling) |
| `dnsmasq` | lightweight DHCP + DNS server |
| `nftables` | the firewall |
| `dnsutils` | `dig`, `nslookup` |

---

## Step 1B.3 — Understand what you're about to build

**Plain English, and this is the key idea:** a *network namespace* is a completely separate network stack inside one running kernel — its own interfaces, its own routing table, its own ARP cache, its own firewall state. From the inside it behaves exactly like a separate computer. It costs a few hundred kilobytes instead of a gigabyte.

The mapping to real hardware:

| Real thing | Linux equivalent |
|---|---|
| A computer | a **network namespace** |
| A patch cable | a **veth pair** — two virtual interfaces joined end to end |
| A switch | a **bridge** |
| A router | the **root namespace** with IP forwarding on, holding every segment's gateway address |
| A firewall | **nftables** rules on the forward chain |

So: three bridges (three switches, one per segment), each with its gateway address; three namespaces (three PCs), each cabled to its bridge by a veth pair; and the root namespace forwarding between them.

---

## Step 1B.4 — Run the build script

The script lives in the repo at [`03-virtual-lab/build-lab.sh`](../03-virtual-lab/build-lab.sh). Copy it into the VM (or `git clone` your repo there once it's pushed).

```bash
chmod +x build-lab.sh
sudo ./build-lab.sh up
```

It tears down anything from a previous run, then builds the topology from scratch. Three subcommands:

| Command | Does |
|---|---|
| `sudo ./build-lab.sh up` | Build (destroys and rebuilds) |
| `sudo ./build-lab.sh down` | Remove everything |
| `sudo ./build-lab.sh status` | Show namespaces, bridges, addresses, routes |

**Read the script before you run it.** It's commented line by line, and understanding it is most of the value. If you can't explain what `ip link add v-pc1 type veth peer name eth0 netns pc1` does, you're not ready to put this in a portfolio — and once you can explain it, you'll be ahead of most people interviewing for the same job.

---

## Step 1B.5 — Verify

Commands run inside a namespace are prefixed with `ip netns exec <name>`:

```bash
sudo ip netns exec pc1 ip a
sudo ip netns exec pc1 ip route
sudo ip netns exec pc1 ping -c3 10.10.10.1      # own gateway
sudo ip netns exec pc1 ping -c3 10.10.20.5      # permitted cross-segment
sudo ip netns exec pc1 ping -c3 10.10.30.5      # must be BLOCKED
sudo ip netns exec srv1 ping -c3 10.10.10.50    # must be BLOCKED
sudo ip netns exec mgmt1 ping -c3 10.10.10.50   # must SUCCEED
```

Those last three are the ones that matter. A firewall policy nobody tested is an assumption.

```bash
sudo nft list ruleset
```

**Capture all of this.** Real output from these commands is exactly what the troubleshooting log needs.

---

## Step 1B.6 — Capture packets

```bash
# Watch ARP on the users segment
sudo tcpdump -i br10 -n arp

# In another terminal, from inside pc1:
sudo ip netns exec pc1 ping -c3 10.10.10.60
```

You'll see pc1 broadcast "who has 10.10.10.60?" and get no answer. That's the raw material for Case 02 and Case 03.

Save captures in a form you can commit:

```bash
# Human-readable text (commit this)
sudo tcpdump -i br10 -n arp -c 50 > case-03-arp.txt

# Full capture to open in Wireshark later (do NOT commit — .gitignore blocks it)
sudo tcpdump -i br10 -w capture.pcap
```

To read a `.pcap` in Wireshark's GUI, copy it to your Mac with `scp` and open it there. The `.gitignore` in this repo blocks `.pcap` files from being committed, because raw captures can contain credentials.

---

## Step 1B.7 — DHCP and DNS

The build script sets static addresses so the topology comes up deterministically. Adding DHCP is your first extension, and a good one.

```bash
sudo dnsmasq \
  --interface=br10 \
  --bind-interfaces \
  --dhcp-range=10.10.10.10,10.10.10.60,255.255.255.192,12h \
  --dhcp-option=3,10.10.10.1 \
  --dhcp-option=6,10.10.20.5 \
  --address=/fileserver.lab.local/10.10.20.5 \
  --no-daemon
```

| Flag | Means |
|---|---|
| `--dhcp-range` | pool start, end, mask, lease time |
| `--dhcp-option=3` | default gateway |
| `--dhcp-option=6` | DNS server |
| `--address=/name/ip` | a static DNS record |
| `--no-daemon` | run in the foreground so you can watch the DHCP exchange live |

Then remove pc1's static address and let it request one:

```bash
sudo ip netns exec pc1 ip addr flush dev eth0
sudo ip netns exec pc1 dhclient eth0
sudo ip netns exec pc1 ip a
```

Watching a DHCP lease happen in the dnsmasq log — DISCOVER, OFFER, REQUEST, ACK — is worth more than reading about it ten times.

---

## Step 1B.8 — Go past the finish line

Pick at least one. This is the part that separates your lab from a tutorial follow-along:

- **Rewrite the build script in Python** with a topology defined in YAML. You're a Python developer — make the lab config-driven and the repo becomes a tool, not a writeup.
- **Add real 802.1Q VLAN tagging** with `ip link add link eth0 name eth0.10 type vlan id 10` instead of separate bridges. Closer to how actual switches work.
- **Add a fourth IoT segment** with a stricter policy, mirroring what you'll recommend in the audit.
- **Centralized logging** — point nftables at the system log and watch the drops accumulate.
- **IPv6 dual-stack** on one segment.

Write a paragraph on what you picked, why, and what surprised you.

---

# PART 2 — The Troubleshooting Case Log

**Why it's the most valuable project:** anyone can follow a tutorial. The job is figuring out what's wrong when nobody knows what's wrong. This is the only artifact that shows you can do that.

---

## Step 2.1 — The methodology

CompTIA's seven steps, in plain language:

1. **Identify the problem** — What's broken? Who's affected? What changed?
2. **Establish a theory** — Best guess at the cause.
3. **Test the theory** — Prove or disprove it. If disproved, form a new one.
4. **Establish a plan of action** — What you'll change, and what else it might affect.
5. **Implement**
6. **Verify full system functionality** — and take preventive measures.
7. **Document findings, actions, and outcomes**

Every case file in [`01-troubleshooting-log/`](../01-troubleshooting-log/) uses these as headings. That's deliberate — it shows a hiring manager you already work the way they need you to.

**One habit that matters more than any tool:** change **one thing at a time**. Change three and it starts working, and you've learned nothing.

---

## Step 2.2 — Tools

| Tool | Plain English | Command |
|---|---|---|
| `ping` | Shout and see if it answers | `ping 10.10.10.1` |
| `traceroute` | Every stop along the route | `traceroute 8.8.8.8` |
| `ip a` | My own address | `ip a` |
| `ip route` | Which way out I'm using | `ip route` |
| `arp` | Who owns which IP on my segment | `ip neigh` or `arp -a` |
| `nslookup` / `dig` | Ask the phone book directly | `dig google.com` |
| `ss` | What connections this host has open | `ss -tuln` |
| `tcpdump` | Record and read every packet | `tcpdump -i br10 -n` |

### tcpdump filters worth memorizing

```bash
sudo tcpdump -i br10 -n arp              # ARP only
sudo tcpdump -i br10 -n icmp             # ping only
sudo tcpdump -i br10 -n port 53          # DNS only
sudo tcpdump -i br10 -n host 10.10.20.5  # one host
sudo tcpdump -i br10 -n port 67 or port 68   # DHCP
```

`-n` stops it resolving names, which otherwise makes output slow and confusing — especially when DNS is the thing that's broken.

---

## Step 2.3 — The six faults

**Take a snapshot before each one.** In the namespace lab that's free: `sudo ./build-lab.sh up` rebuilds clean in thirty seconds. In UTM, snapshot the VM. In Packet Tracer, save a copy of the `.pkt`.

Each case can be worked in either environment. Use the namespace lab when you want real output for the write-up, Packet Tracer when you want the Cisco-side view.

---

### Case 01 — Wrong default gateway

**Namespace lab:**
```bash
sudo ip netns exec pc1 ip route del default
sudo ip netns exec pc1 ip route add default via 10.10.10.99
```

**Packet Tracer:** PC-Users → Desktop → IP Configuration → set gateway to `10.10.10.99`

**Symptom:** local hosts reachable, everything off-segment dead.

**Diagnostic path:** `ip a` → `ping 10.10.10.1` (works) → `ping 10.10.20.5` (fails) → `ip route` (shows the bad gateway) → `ip neigh` (gateway shows `INCOMPLETE` — nothing is there)

**Concept:** a host only knows how to reach its own segment; everything else goes to the gateway. Point at a gateway nothing answers to and every off-segment destination fails silently while local traffic stays healthy. That split is the fingerprint.

---

### Case 02 — Duplicate IP address

**Namespace lab:**
```bash
sudo ip netns exec srv1 ip addr add 10.10.10.50/26 dev eth0
# now both pc1 and srv1 claim .50
```
(For a cleaner version, add a fourth namespace on br10 with the same address as pc1.)

**Packet Tracer:** set two PCs on the same VLAN to the same static address.

**Symptom:** intermittent. Sometimes fine, sometimes dead.

**Diagnostic path:** repeated `ping` showing inconsistent replies → `ip neigh` run twice showing the MAC changing → `tcpdump -i br10 -n arp` showing two MACs claiming one IP

**Concept:** IPs are how hosts are addressed; MACs are how frames are actually delivered. Two hosts on one IP means every other device's ARP cache keeps flip-flopping, and delivery becomes a coin toss. Intermittent is the signature — and intermittent faults get closed as "user error" when nobody checks the ARP table.

---

### Case 03 — Wrong subnet mask

**Namespace lab:**
```bash
sudo ip netns exec pc1 ip addr flush dev eth0
sudo ip netns exec pc1 ip addr add 10.10.10.50/24 dev eth0   # should be /26
sudo ip netns exec pc1 ip route add default via 10.10.10.1
```

**Packet Tracer:** set PC-Users mask to `255.255.255.0` instead of `255.255.255.192`.

**Symptom:** the sneaky one. Some destinations work, some don't, and which is which looks arbitrary.

**Diagnostic path:** `ip a` (mask is wrong but easy to skim past) → `ping 10.10.10.1` works → `ping 10.10.20.5` fails → `ip route` shows an over-wide directly-connected network → `tcpdump -i br10 -n arp` shows the host ARPing for an address it should have routed to

**Concept — the best one in the log:** the mask is what a host uses to decide "is this local, or does it go to the gateway?" With a wrong /24, the host believes `.1` through `.254` are all on its segment, so for anything in `.65`–`.254` it broadcasts ARP on the local wire instead of routing. Nothing answers. Traffic dies with no error pointing at the mask, while everything genuinely local keeps working. This gets misdiagnosed as a server problem, a cable problem, or an application problem long before anyone re-reads the mask.

**Spend the most time on this write-up.** If you can explain it out loud in an interview, you're ahead of most candidates.

---

### Case 04 — Dead DNS server

**Namespace lab:**
```bash
sudo ip netns exec pc1 mkdir -p /etc/netns/pc1
echo "nameserver 10.10.10.200" | sudo tee /etc/netns/pc1/resolv.conf
```
(Namespaces can have their own `/etc/netns/<name>/resolv.conf` — a genuinely useful thing to know.)

**Packet Tracer:** set PC-Users' DNS server to `10.10.10.200`.

**Symptom:** "the internet is down." It isn't.

**Diagnostic path:** `ping 8.8.8.8` works → `ping google.com` fails to resolve → `dig google.com` times out → `cat /etc/resolv.conf` shows the wrong server → `dig @8.8.8.8 google.com` works, proving it's the resolver

**Concept:** reachability and name resolution are independent systems, and from a user's chair both failures look identical. Ping an IP, then ping a name — ten seconds to split them, and it redirects the whole investigation away from cables and the ISP.

---

### Case 05 — Firewall rule blocking legitimate traffic

**Namespace lab:**
```bash
sudo nft insert rule inet lab forward ip saddr 10.10.10.0/26 ip daddr 10.10.20.0/28 drop
```

**Packet Tracer:** add a `deny ip 10.10.10.0 0.0.0.63 10.10.20.0 0.0.0.15` line above the permit in `USERS_IN`.

**Symptom:** users can't reach the file server. Nothing changed on any client.

**Diagnostic path:** client config is provably fine (`ip a`, `ip route`, gateway ping all good) → one specific destination unreachable, control destination fine → `sudo nft list ruleset` / `show access-lists` reveals the rule

**Concept:** rules are evaluated top to bottom, first match wins, so a rule inserted above an allow silently overrides it. When the client is healthy and exactly one destination is dead, stop testing the endpoint and read the rule list. Knowing to make that jump is the whole skill.

---

### Case 06 — Wrong VLAN / segment assignment

**Namespace lab:**
```bash
sudo ip link set v-srv1 nomaster
sudo ip link set v-srv1 master br10     # srv1 is now cabled to the wrong switch
```

**Packet Tracer:** change Fa0/2 from `switchport access vlan 20` to `vlan 10`.

**Symptom:** the host comes up with an address from the wrong pool, or can't reach its own gateway.

**Diagnostic path:** `ip a` — the address alone is the diagnosis

**Concept:** a host's address tells you which broadcast domain it's actually in, regardless of where you think you plugged it. In production this is a patch panel error or a mis-assigned access port, and the fix is at the switch, not the server. It's one of the most common real causes of "it worked yesterday" after an office move.

---

## Step 2.4 — Get one unplanned failure

This is Case 07, it's the most valuable page in the repo, and you can't script it.

- **Have someone else break it.** Hand them the lab and ten minutes. One change, no hints.
- **Do the extension work** from Step 1B.8. Something will break for real.
- **Attempt something above your level.** You'll fail several times before succeeding.

Write it up with the wrong theories left in: what you thought first, what made it look right, what disproved it, what you'd actually misunderstood. That's unfakeable, and it's the case an interviewer will ask about.

---

# PART 3 — The Network Audit

**What you're building:** a professional assessment of a real network plus a costed redesign.

**Why it's different:** it's the only project with real hardware, real interference, a real budget, and a real non-technical stakeholder. That's the job.

---

## ⚠️ Before you scan anything

Scan **only** a network you own, or one where you have **written permission**. Unauthorized port scanning is a criminal offense in most jurisdictions, including under the US Computer Fraud and Abuse Act. Your own home network is fine. A coffee shop's is not. A friend's is fine *if they say yes in writing*.

Record it in [`02-network-audit/authorization.md`](../02-network-audit/authorization.md) before you start. Documenting authorization is itself a professional habit worth demonstrating.

---

## Step 3.1 — Inventory

Log into your router (usually `192.168.1.1`; check `ip route` for your gateway). Find the connected devices list.

Cross-check with a host sweep, which catches statically addressed devices the router's list may miss:

```bash
nmap -sn 192.168.1.0/24
```

Fill in [`inventory.md`](../02-network-audit/inventory.md). **Track down every unidentified device.** An unaccounted-for device is a finding, not a gap.

---

## Step 3.2 — Topology diagram

In **app.diagrams.net** (free, no account): modem → router → switches → APs → devices. Mark wired vs. wireless and note link speeds. Export to `02-network-audit/diagrams/`.

---

## Step 3.3 — Wireless survey

**Plain English:** Wi-Fi is radio. Same channel as your neighbour means you're both shouting on the same frequency. In 2.4 GHz only **1, 6, and 11** don't overlap; everything else partially overlaps and makes things worse for everyone.

**Tool:** WiFiman or Network Analyzer on your phone.

1. Record every visible network, its channel, and its signal strength.
2. Count how many share your channel.
3. Walk the space; record dBm per room.
4. Note band and standard (Wi-Fi 5 / 802.11ac, Wi-Fi 6 / 802.11ax).

**Reading dBm** — negative, closer to zero is better: -40 excellent · -60 fine · -70 marginal · -80 unusable.

**The easy win to look for:** you're on a congested channel while 1, 6, or 11 sits nearly empty. Free fix, strong finding.

Fill in [`wireless-survey.md`](../02-network-audit/wireless-survey.md).

---

## Step 3.4 — Firmware and patch status

For every device with an admin page: current version, latest available, release date, and whether the model is still supported. Unpatched network gear is among the most common real-world attack vectors, and end-of-life hardware never gets fixed. A router that stopped receiving updates in 2019 is a finding whether or not it still works.

---

## Step 3.5 — Port and service scan

```bash
nmap -sn 192.168.1.0/24      # what's alive
nmap -sV 192.168.1.1         # open ports and what's running on them
```

**Plain English:** a port is a numbered door, each belonging to a service. 80 is web, 443 secure web, 22 SSH, 23 telnet. An open door isn't automatically bad — one you didn't know about, or one running an insecure protocol, is.

**Look for:** telnet (23) anywhere — it sends passwords in plain text and should be SSH. Admin interfaces reachable from wireless. UPnP enabled. Anything you can't account for.

---

## Step 3.6 — Segmentation check

**Plain English:** segmentation keeps groups of devices apart so a problem in one can't spread. A doorbell camera on the same network as a work laptop means compromising the cheap camera gives a path to the laptop.

- Is there a guest network? Is it actually isolated, or just a second name on the same network?
- Are IoT devices separated from computers?
- **Connect to the guest network and try to load the router's admin page.** If it loads, that's a significant finding.

---

## Step 3.7 — Write it up

[`findings.md`](../02-network-audit/findings.md) has the structure and a worked example of the right voice. For each: what it is → why it matters → how bad, with reasoning → what to do.

[`redesign-proposal.md`](../02-network-audit/redesign-proposal.md) has the phased plan and cost table.

**The cost table matters more than it looks.** "Buy better equipment" is a student answer. "A $34 TP-Link TL-SG108E resolves findings 2 and 4 because it supports 802.1Q VLANs, which the current all-in-one router does not" is the answer of someone who can be handed a budget.

---

# Final Checklist

**Packet Tracer lab**
- [ ] Three VLANs, correct access port assignments
- [ ] Trunk carrying all three, verified with `show interfaces trunk`
- [ ] Router-on-a-stick subinterfaces, all up/up
- [ ] DHCP pools serving VLANs 10 and 20; VLAN 30 static by design
- [ ] ACL with `permit ip any any` present, hit counters screenshotted
- [ ] `.pkt` file, topology screenshot, both running-configs committed

**Namespace lab**
- [ ] Script runs clean from nothing
- [ ] All four policy tests verified — two allows, two denies
- [ ] At least two tcpdump captures exported as text
- [ ] DHCP via dnsmasq demonstrated
- [ ] One extension built past the requirements

**Troubleshooting**
- [ ] Seven cases, all seven methodology steps each
- [ ] Real command output, not descriptions of output
- [ ] **At least one unplanned failure with the wrong theories left in**

**Audit**
- [ ] Authorization documented before scanning
- [ ] Inventory, topology, wireless survey, firmware status, port scan, segmentation test
- [ ] Findings with defended severity ratings
- [ ] Redesign with phased plan and real part numbers

**Repo**
- [ ] No bracketed placeholders left in any README
- [ ] No passwords, hashes, public IPs, or personal addresses
- [ ] Setup-brief HTML comments deleted from published case files
- [ ] Diagrams render as images
