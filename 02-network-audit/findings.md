# Findings

Each finding states what was observed, why it matters, a severity rating with reasoning, and a recommendation. Severity reflects likelihood combined with impact — not how technically interesting the finding is.

| Severity | Meaning |
|---|---|
| **High** | Exploitable now, or exposes sensitive data; fix promptly |
| **Medium** | Meaningful risk requiring a chained condition, or significant operational impact |
| **Low** | Hygiene, best practice, or quality-of-life |

---

## Summary

| # | Finding | Severity | Effort to remediate |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

---

## Finding 1 — [title]

**Severity:** `High / Medium / Low`
**Category:** `Segmentation / Patching / Wireless / Access control / Configuration`

**Observed:**

**Evidence:**
```

```

**Why it matters:**

**Severity reasoning:**

**Recommendation:**

**Effort:** `[time and cost]`

---

## Finding 2 — [title]

**Severity:**
**Category:**

**Observed:**

**Evidence:**
```

```

**Why it matters:**

**Severity reasoning:**

**Recommendation:**

**Effort:**

---

## Finding 3 — [title]

**Severity:**
**Category:**

**Observed:**

**Evidence:**
```

```

**Why it matters:**

**Severity reasoning:**

**Recommendation:**

**Effort:**

---

## Finding 4 — [title]

**Severity:**
**Category:**

**Observed:**

**Evidence:**
```

```

**Why it matters:**

**Severity reasoning:**

**Recommendation:**

**Effort:**

---

## Finding 5 — [title]

**Severity:**
**Category:**

**Observed:**

**Evidence:**
```

```

**Why it matters:**

**Severity reasoning:**

**Recommendation:**

**Effort:**

---

## Example of the voice to aim for

> **Finding — IoT devices share the primary network (Severity: High)**
>
> **Observed:** Six devices — two smart speakers, a thermostat, three cameras — hold addresses in the same /24 and the same broadcast domain as personal computers. Two cameras report firmware last updated in 2021; the vendor's support page lists the model as end-of-life.
>
> **Why it matters:** There is no boundary between a class of device that receives no security patches and the machines holding financial and personal documents. A vulnerability in any one camera yields a foothold on the same segment as that data, with nothing further to bypass.
>
> **Severity reasoning:** Rated High rather than Medium because the vulnerable devices are internet-reachable by design, are unpatchable, and the distance from compromise to sensitive data is zero hops.
>
> **Recommendation:** Move all IoT devices onto an isolated VLAN or a guest SSID with client isolation enabled, and block that segment from initiating connections toward the primary network. Replace the two end-of-life cameras.
>
> **Effort:** ~2 hours configuration; $34 managed switch if the current router cannot do VLANs; camera replacement $80–140.

*(Delete this example block before publishing.)*
