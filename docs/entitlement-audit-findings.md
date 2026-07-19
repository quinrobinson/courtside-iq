# Entitlement Audit — findings

Run 2026-07-18 against production via `scripts/entitlement_audit.py` (read-only,
nothing written). Input: 165 prod users with at least one player, checked
against RevenueCat's `premium_users` entitlement.

Purpose: decide whether the free-tier player limit can safely be enforced in
RLS (roadmap **4.4b**). Until now premium existed only on the device, so the
server could not tell a paying parent of four from a free user who predates the
gate.

---

## Results

| | Count |
|---|---:|
| Users with at least one player | 165 |
| Entitled (paying) | **7** |
| Not entitled | 155 |
| Lookup errored (transient network) | 3 |

**Over the current 1-player free limit: 36**

| | Count |
|---|---:|
| Entitled | **1** |
| Not entitled | 35 |

---

## Decision: enforcement is safe

**Blast radius on paying customers is zero.** The limit is gated on
`is_premium()`, so the single entitled user over the limit passes it and is
unaffected. The 35 non-entitled users keep every player they already have and
simply cannot add more — the INSERT-only design never hides existing data.

Treat 7 as a floor: 3 lookups failed on transient network errors. It does not
change the conclusion.

---

## Two findings that outlive the go/no-go

### 1. Conversion is ~4% (7 of 165)

The 1-player gate is effectively the entire paywall, and 35 users sit past it.
Relative to 7 paying customers that is not a rounding error. Not a technical
conclusion — flagged because it reframes what 4.4b is actually worth.

### 2. UNRESOLVED: how did 35 free users get past a gate that hides the button?

The Add Player control is hidden when a free user already has one player, so
these users should not exist. Two very different explanations:

- **They paid, added players, then lapsed.** Legitimate. They earned that data;
  capping additions is fine, anything harsher punishes a former customer.
- **The gate has a hole, or postdates their signup.**

This audit only asked "entitled right now". RevenueCat's subscriber records
include purchase history and can distinguish the two. **Answer this before
building 4.4b** — it decides whether this is a leak to close or history to
grandfather.

---

## Scope this sets for 4.4b

- `players` INSERT policy: permit when `is_premium(auth.uid())` **or** the user
  has zero players.
- **No SELECT restriction, ever.** A user must never lose sight of data they
  created.
- **Nothing about games.** There is no 3-game limit anywhere in the code; the
  games "limit" is an upsell banner. Adding one would be a new product
  decision, not an implementation of an existing one — the roadmap's
  "1 player / 3 games" phrasing is wrong on the games half.

**Blocker:** `subscriptions` is empty and only learns about users who transact
from now on. Enforcement requires the backfill first, and the rows that matter
live in prod.
