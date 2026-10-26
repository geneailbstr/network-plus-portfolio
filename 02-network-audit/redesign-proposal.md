# Redesign Proposal

Written for the network owner, not for a network engineer. Each recommendation states what it fixes, what it costs, and what happens if it isn't done.

---

## Executive summary

`[Three to five sentences, no jargon. What is wrong, what it would take to fix, what the priority is. This is the only section some readers will finish — write it last, from the findings.]`

---

## Current state

> `diagrams/current-topology.png`

**Summary:** `[2–3 sentences on how the network is structured today and its primary weaknesses]`

---

## Proposed state

> `diagrams/proposed-topology.png`

**Summary of changes:**

| Change | Addresses finding(s) |
|---|---|
| | |
| | |
| | |

### Proposed segmentation

| Segment | Purpose | Devices | Reaches internet | Reaches primary LAN | Reaches management |
|---|---|---|---|---|---|
| Primary | Workstations, phones | | ✅ | — | ❌ |
| IoT | Cameras, speakers, thermostat | | ✅ | ❌ | ❌ |
| Guest | Visitor devices | | ✅ | ❌ | ❌ |
| Management | Network device admin | | ✅ | ❌ | — |

---

## Phased implementation

Ordered by risk reduced per dollar and per hour. Phase 1 is everything that costs nothing.

### Phase 1 — No cost, immediate `[est. X hours]`

| # | Action | Addresses | Downtime |
|---|---|---|---|
| 1 | | Finding | |
| 2 | | Finding | |
| 3 | | Finding | |

### Phase 2 — Low cost `[est. $X, X hours]`

| # | Action | Addresses | Downtime |
|---|---|---|---|
| 1 | | Finding | |
| 2 | | Finding | |

### Phase 3 — Hardware replacement `[est. $X, X hours]`

| # | Action | Addresses | Downtime |
|---|---|---|---|
| 1 | | Finding | |

---

## Costs

| Item | Model | Qty | Unit | Total | Justification |
|---|---|---|---|---|---|
| | | | $ | $ | |
| | | | $ | $ | |
| | | | $ | $ | |
| | | | | **$** | |

**Pricing as of:** `[date]` · **Source:** `[retailer]`

> Name actual models and actual current prices. "Buy a better router" is a student answer; "the TP-Link TL-SG108E at $34 resolves findings 2 and 4 because it supports 802.1Q VLANs, which the existing all-in-one router does not" is the answer of someone who can be handed a budget.

---

## If nothing is done

| Finding | Risk if unaddressed | Likelihood |
|---|---|---|
| | | |
| | | |

`[One honest paragraph. Not scare tactics — a straight statement of exposure. Credibility here is what makes the rest of the document persuasive.]`

---

## Out of scope

`[Things considered and deliberately not recommended, with reasoning. Showing what you chose not to do demonstrates judgment as clearly as what you did.]`

| Considered | Why not recommended |
|---|---|
| | |
