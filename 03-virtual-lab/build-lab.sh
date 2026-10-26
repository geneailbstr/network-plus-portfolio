#!/usr/bin/env bash
#
# build-lab.sh — construct the three-segment lab topology
#
# Builds the network documented in addressing.md using Linux network
# namespaces. Each namespace is an isolated network stack: its own
# interfaces, routing table, ARP cache and firewall state. Functionally
# it behaves like a separate host, but costs a few hundred KB instead of
# a gigabyte of VM.
#
#   bridge        = virtual switch (one per segment / broadcast domain)
#   veth pair     = virtual patch cable (one end in a namespace, one on a bridge)
#   root netns    = the router — it holds every bridge's gateway address
#                   and forwards between them
#
# The whole topology is destroyed and rebuilt on every run, so a lab
# wrecked while practising is thirty seconds from clean.
#
# Usage:   sudo ./build-lab.sh [up|down|status]
#
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────
# Topology definition — see addressing.md for the sizing reasoning
#
#   name : bridge : gateway/prefix : host-addr/prefix
# ─────────────────────────────────────────────────────────────────────
SEGMENTS=(
  "users:br10:10.10.10.1/26:pc1:10.10.10.50/26"
  "servers:br20:10.10.20.1/28:srv1:10.10.20.5/28"
  "mgmt:br30:10.10.30.1/29:mgmt1:10.10.30.5/29"
)

NAMESPACES=(pc1 srv1 mgmt1)
BRIDGES=(br10 br20 br30)

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script manipulates network interfaces and must run as root." >&2
    echo "Try: sudo $0 ${1:-up}" >&2
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────────────
# Teardown
# ─────────────────────────────────────────────────────────────────────
teardown() {
  echo "Tearing down existing topology..."
  for ns in "${NAMESPACES[@]}"; do
    ip netns del "$ns" 2>/dev/null || true
  done
  for br in "${BRIDGES[@]}"; do
    ip link del "$br" 2>/dev/null || true
  done
  # veth host-side interfaces are removed automatically with their peer,
  # but clean up any orphans from an interrupted run
  for v in v-pc1 v-srv1 v-mgmt1; do
    ip link del "$v" 2>/dev/null || true
  done
  echo "  done"
}

# ─────────────────────────────────────────────────────────────────────
# Build
# ─────────────────────────────────────────────────────────────────────
create_bridge() {
  local bridge=$1 gateway=$2
  ip link add "$bridge" type bridge
  ip addr add "$gateway" dev "$bridge"
  ip link set "$bridge" up
  echo "  bridge $bridge  gateway $gateway"
}

create_host() {
  local ns=$1 bridge=$2 addr=$3 gw=$4
  local veth="v-${ns}"

  ip netns add "$ns"

  # One virtual cable: host-side stays in the root namespace and plugs
  # into the bridge; the far end becomes eth0 inside the namespace.
  ip link add "$veth" type veth peer name eth0 netns "$ns"
  ip link set "$veth" master "$bridge"
  ip link set "$veth" up

  ip netns exec "$ns" ip link set lo up
  ip netns exec "$ns" ip addr add "$addr" dev eth0
  ip netns exec "$ns" ip link set eth0 up
  ip netns exec "$ns" ip route add default via "$gw"

  echo "  host   $ns  $addr  via $gw  -> $bridge"
}

apply_firewall_policy() {
  echo "Applying inter-segment policy..."

  nft flush ruleset

  nft add table inet lab
  nft add chain inet lab forward \
      '{ type filter hook forward priority 0; policy accept; }'

  # Users (10.10.10.0/26) must not reach Management (10.10.30.0/29)
  nft add rule inet lab forward \
      ip saddr 10.10.10.0/26 ip daddr 10.10.30.0/29 drop

  # Servers must not initiate toward Users or Management.
  # Established/related return traffic is permitted first, so connections
  # the server legitimately answers continue to work — this is the
  # stateful behaviour described in firewall-policy.md.
  nft insert rule inet lab forward \
      ct state established,related accept
  nft add rule inet lab forward \
      ip saddr 10.10.20.0/28 ip daddr 10.10.10.0/26 drop
  nft add rule inet lab forward \
      ip saddr 10.10.20.0/28 ip daddr 10.10.30.0/29 drop

  echo "  policy applied — verify with: nft list ruleset"
}

bring_up() {
  teardown
  echo "Building topology..."

  for entry in "${SEGMENTS[@]}"; do
    IFS=':' read -r _name bridge gateway host hostaddr <<< "$entry"
    create_bridge "$bridge" "$gateway"
    create_host "$host" "$bridge" "$hostaddr" "${gateway%/*}"
  done

  echo "Enabling IPv4 forwarding (this is what makes the root namespace a router)..."
  sysctl -qw net.ipv4.ip_forward=1

  apply_firewall_policy

  echo
  echo "Topology is up. Try:"
  echo "  sudo ip netns exec pc1 ip a"
  echo "  sudo ip netns exec pc1 ping -c3 10.10.20.5     # permitted"
  echo "  sudo ip netns exec pc1 ping -c3 10.10.30.5     # must be blocked"
  echo "  sudo ip netns exec srv1 ping -c3 10.10.10.50   # must be blocked"
}

show_status() {
  echo "=== Namespaces ==="
  ip netns list || echo "(none)"
  echo
  echo "=== Bridges ==="
  ip -brief addr show type bridge || echo "(none)"
  echo
  for ns in "${NAMESPACES[@]}"; do
    if ip netns list | grep -q "^${ns}"; then
      echo "=== $ns ==="
      ip netns exec "$ns" ip -brief addr show
      ip netns exec "$ns" ip route show
      echo
    fi
  done
}

case "${1:-up}" in
  up)     require_root up;   bring_up    ;;
  down)   require_root down; teardown    ;;
  status) show_status                    ;;
  *)      echo "Usage: sudo $0 [up|down|status]" >&2; exit 1 ;;
esac
