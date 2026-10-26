# Setup — Accounts, Costs, and Daily Operation

Everything needed to build both labs on an Apple Silicon Mac, and how to start them up once installed.

---

# Part 1 — What you sign up for

| # | Account | Where | Cost | Needed for |
|---|---|---|---|---|
| 1 | **Cisco Networking Academy** | netacad.com | **Free** | The only way to download Packet Tracer |
| 2 | GitHub | already have it | Free | Hosting the portfolio |
| 3 | diagrams.net | app.diagrams.net | **Free, no account** | Topology diagrams |

That's the whole list. One new signup.

### The Cisco account, in detail

The Packet Tracer download isn't on a public page — it's behind a free account. Google sign-in works if you'd rather not make another password.

Once signed in, there are two routes to the file:
- **Resource Hub → Lab Downloads**, or
- enrol in the free course **"Getting Started with Cisco Packet Tracer."** You don't have to finish it.

Either gets you the same installer. Packet Tracer is free outright — there's no paid tier.

> Do this first. Account creation plus a ~1 GB download is the slowest step of the evening, and everything else can happen while it runs.

---

# Part 2 — What you download

| Software | From | Size | Cost |
|---|---|---|---|
| **Cisco Packet Tracer** (macOS .dmg) | netacad.com, behind the account above | ~1 GB | Free |
| **UTM** | mac.getutm.app | ~200 MB | **Free** |
| **Ubuntu Server 24.04 LTS, ARM64** | ubuntu.com/download/server/arm | ~2.5 GB | Free |

**On UTM and cost:** the direct download from mac.getutm.app is completely free and fully functional. UTM is also on the Mac App Store for about $10 — identical software, sold as a way to support the project. Download it from the website; don't pay unless you want to.

**On the Ubuntu image:** it must be **ARM64**, not AMD64. An x86 image would have to be emulated on your M1 and would run too slowly to be usable. The ARM64 image virtualizes natively and is fast.

### Disk space

| Item | Space |
|---|---|
| Packet Tracer installed | ~1.5 GB |
| UTM | ~300 MB |
| Ubuntu ISO (deletable after install) | ~2.5 GB |
| Ubuntu VM disk | 20 GB |
| **Total** | **~24 GB** |

Check you have it before starting. On an 8 GB Mac the drive is often the tighter constraint than the RAM.

---

# Part 3 — Total cost

**$0.**

Every tool in this portfolio is free: Packet Tracer, UTM, Ubuntu, nmap, tcpdump, dnsmasq, diagrams.net, and whichever Wi-Fi analyzer app you use for the audit.

**The one optional purchase**, much later: a managed switch for real 802.1Q tagging on physical hardware — a TP-Link TL-SG108E runs about $35 new, or $40–60 used for a Cisco 2960 on eBay. Not needed for anything in this repo. It's an upgrade for when you want hardware on your résumé rather than simulation.

---

# Part 4 — Installation

## 4.1 Packet Tracer

1. Sign in at netacad.com → Resource Hub → Lab Downloads
2. Download the **macOS 64-bit** `.dmg`
3. Open it, drag Packet Tracer into Applications
4. First launch: macOS will likely block it. Go to **System Settings → Privacy & Security**, find the blocked-app notice, click **Open Anyway**
5. If prompted to install **Rosetta**, accept — Packet Tracer is an Intel app and runs through Rosetta 2 translation on Apple Silicon
6. Sign in inside the app with the same Cisco account. It won't run without it.

## 4.2 UTM + Ubuntu

1. Install UTM from the `.dmg`
2. **Create a New Virtual Machine → Virtualize → Linux**
3. Browse to the Ubuntu Server ARM64 ISO
4. Settings: **Memory 3072 MB · CPU 2 cores · Storage 20 GB**
5. Start it and install Ubuntu with defaults
6. When offered, **check "Install OpenSSH server"** — this lets you SSH in from your Mac's Terminal, which makes copying command output into your write-ups vastly easier than retyping from a screenshot
7. After install completes: shut down → VM settings → remove the ISO from the drive → boot

### Inside the VM, once

```bash
sudo apt update
sudo apt install -y iproute2 iputils-ping tcpdump dnsmasq nftables bridge-utils net-tools dnsutils git
git clone https://github.com/geneailbstr/network-plus-portfolio
cd network-plus-portfolio/03-virtual-lab
chmod +x build-lab.sh
```

Find the VM's IP so you can SSH to it from the Mac:

```bash
ip a
```

Look for the address on `enp0s1` or similar. Then from your Mac's Terminal:

```bash
ssh yourusername@<that-ip>
```

---

# Part 5 — Running the Packet Tracer lab

**Every session:**

1. Open Packet Tracer (sign-in is remembered)
2. **File → Open** → `03-virtual-lab/packet-tracer/lab.pkt`

**To configure a device:** click it → **CLI** tab → press Enter.

**To test from a PC:** click it → **Desktop** tab → **Command Prompt**. This is where `ping`, `ipconfig` and `tracert` live.

**The verification commands worth knowing by heart:**

| Command | Run on | Shows |
|---|---|---|
| `show vlan brief` | Switch | VLANs and which ports are in each |
| `show interfaces trunk` | Switch | Which ports are trunking, and which VLANs they carry |
| `show ip interface brief` | Router | Every interface and whether it's up/up |
| `show ip route` | Router | The routing table |
| `show ip dhcp binding` | Router | Which addresses have been leased to whom |
| `show access-lists` | Router | ACL rules and their hit counters |
| `show running-config` | Either | The whole config — this is what you paste into the repo |

**Always save:** after any config change, run `write memory` on the device, then **File → Save** in the app. Two separate saves — forgetting the first means your work vanishes on reload.

---

# Part 6 — Running the namespace lab

**Every session:**

1. Open UTM, press play on the Ubuntu VM
2. From your Mac's Terminal: `ssh yourusername@<vm-ip>`
3. `cd network-plus-portfolio/03-virtual-lab`

**Build it:**

```bash
sudo ./build-lab.sh up
```

Takes about a second. It destroys anything from a previous run first, so it's always safe to run again — this is why you don't need snapshots for the troubleshooting work.

**Three commands total:**

| Command | Does |
|---|---|
| `sudo ./build-lab.sh up` | Build (destroys and rebuilds) |
| `sudo ./build-lab.sh status` | Show all namespaces, bridges, addresses and routes |
| `sudo ./build-lab.sh down` | Remove everything |

**Working inside a host.** Every command run "on" a lab host is prefixed with `ip netns exec <name>`:

```bash
sudo ip netns exec pc1 ip a
sudo ip netns exec pc1 ip route
sudo ip netns exec pc1 ping -c3 10.10.20.5
```

Three hosts exist: **`pc1`** (users, 10.10.10.50), **`srv1`** (servers, 10.10.20.5), **`mgmt1`** (management, 10.10.30.5).

**To get a full shell inside a host** instead of prefixing every command:

```bash
sudo ip netns exec pc1 bash
# you are now "on" pc1 — run ip a, ping, etc. with no prefix
exit
```

**The four checks that prove the policy works:**

```bash
sudo ip netns exec pc1 ping -c3 10.10.20.5      # SUCCEEDS — users may reach servers
sudo ip netns exec pc1 ping -c3 10.10.30.5      # BLOCKED  — users may not reach mgmt
sudo ip netns exec srv1 ping -c3 10.10.10.50    # BLOCKED  — servers may not initiate to users
sudo ip netns exec mgmt1 ping -c3 10.10.10.50   # SUCCEEDS — mgmt reaches everything
```

Run these every time you rebuild. A firewall policy nobody tested is an assumption.

**To capture packets:**

```bash
sudo tcpdump -i br10 -n arp          # ARP on the users segment
sudo tcpdump -i br10 -n icmp         # ping traffic
sudo tcpdump -i br10 -n port 53      # DNS
```

Open a second SSH window to run traffic while tcpdump watches in the first.

**When you're done:** `sudo ./build-lab.sh down`, then shut the VM down in UTM so it isn't holding 3 GB.

---

# Part 7 — Suggested first session

| Order | Task | Why first |
|---|---|---|
| 1 | Create the Cisco account, start the Packet Tracer download | Slowest step; runs in the background |
| 2 | Download UTM and the Ubuntu ARM64 ISO | Also slow; parallel with the above |
| 3 | Install Packet Tracer, build the switch config | First real progress |
| 4 | Install Ubuntu in UTM | Longest install |
| 5 | Clone the repo in the VM, run `build-lab.sh up` | Immediate working network |
| 6 | Run the four policy checks and save the output | Your first real artifact |

Step 6 is the first thing in this project that goes into the portfolio as evidence rather than setup.
