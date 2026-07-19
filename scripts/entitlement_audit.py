#!/usr/bin/env python3
"""
Read-only entitlement audit — Phase 4.4b input.

Answers one question: if we enforce a 1-player free limit in RLS, how many
REAL, PAYING customers would be affected?

Right now premium lives only on the device, so the server cannot tell a paying
parent of four kids from a free user who predates the gate. This asks
RevenueCat directly.

WRITES NOTHING. Not to RevenueCat, not to Supabase, not to prod. It reads a
local CSV of (user_id, player_count) pulled from prod and asks RevenueCat about
each user's entitlement.

Usage:
    export REVENUECAT_API_KEY='sk_...'
    python3 entitlement_audit.py

Output is aggregate counts only. No emails, no names. User ids appear solely in
the optional --verbose per-bucket listing.
"""

import csv
import json
import os
import sys
import time
import urllib.error
import urllib.request
from collections import Counter

API_KEY = os.environ.get("REVENUECAT_API_KEY", "")
ENTITLEMENT = "premium_users"
CSV_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "prod_players.csv")
FREE_PLAYER_LIMIT = 1          # what the UI enforces today
REQUEST_DELAY_S = 0.12         # be polite to RevenueCat's rate limiter
VERBOSE = "--verbose" in sys.argv


def fail(msg):
    print(f"\nERROR: {msg}\n", file=sys.stderr)
    sys.exit(1)


if not API_KEY:
    fail(
        "REVENUECAT_API_KEY is not set in this shell.\n"
        "  export REVENUECAT_API_KEY='sk_...'   then re-run in the SAME terminal."
    )
if not API_KEY.startswith("sk_"):
    print(
        f"WARNING: key does not start with 'sk_' (starts '{API_KEY[:4]}').\n"
        "         Public SDK keys (appl_/goog_) will not work here.\n",
        file=sys.stderr,
    )


def entitlement_state(uid):
    """
    Return one of: 'entitled', 'not_entitled', 'unknown_user', 'error'.

    RevenueCat 404s for a user it has never seen — that is a normal answer
    (the user never opened a paywall), not a failure.
    """
    req = urllib.request.Request(
        f"https://api.revenuecat.com/v1/subscribers/{uid}",
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return "unknown_user"
        if e.code in (401, 403):
            fail(
                f"RevenueCat rejected the key (HTTP {e.code}).\n"
                "  Check it is a SECRET key (sk_...) with customer read access."
            )
        if e.code == 429:
            time.sleep(2.0)
            return entitlement_state(uid)  # one retry after backoff
        print(f"  http {e.code} for {uid[:8]}...", file=sys.stderr)
        return "error"
    except Exception as e:
        print(f"  {type(e).__name__} for {uid[:8]}...", file=sys.stderr)
        return "error"

    subscriber = body.get("subscriber", {})
    ents = subscriber.get("entitlements", {}) or {}
    ent = ents.get(ENTITLEMENT)
    if not ent:
        return "not_entitled"

    # expires_date is null for lifetime/promotional grants.
    expires = ent.get("expires_date")
    if expires is None:
        return "entitled"

    # RevenueCat returns ISO8601 in UTC, e.g. 2026-08-01T12:00:00Z
    from datetime import datetime, timezone
    try:
        exp = datetime.fromisoformat(expires.replace("Z", "+00:00"))
    except ValueError:
        return "entitled"  # unparseable but present: assume entitled, do not under-count
    return "entitled" if exp > datetime.now(timezone.utc) else "not_entitled"


def main():
    if not os.path.exists(CSV_PATH):
        fail(f"input file missing: {CSV_PATH}")

    rows = []
    with open(CSV_PATH) as f:
        for uid, count in csv.reader(f):
            rows.append((uid.strip(), int(count)))

    total = len(rows)
    print(f"Auditing {total} prod users against RevenueCat (read-only)...\n")

    states = {}
    for i, (uid, players) in enumerate(rows, 1):
        states[uid] = entitlement_state(uid)
        if i % 25 == 0 or i == total:
            print(f"  {i}/{total}")
        time.sleep(REQUEST_DELAY_S)

    over = [(u, c) for u, c in rows if c > FREE_PLAYER_LIMIT]
    tally = Counter(states.values())
    over_tally = Counter(states[u] for u, _ in over)

    print("\n" + "=" * 58)
    print("ENTITLEMENT AUDIT")
    print("=" * 58)
    print(f"\nAll users with players: {total}")
    for k in ("entitled", "not_entitled", "unknown_user", "error"):
        print(f"  {k:<14} {tally.get(k, 0):>4}")

    print(f"\nOver the {FREE_PLAYER_LIMIT}-player free limit: {len(over)}")
    for k in ("entitled", "not_entitled", "unknown_user", "error"):
        print(f"  {k:<14} {over_tally.get(k, 0):>4}")

    at_risk = over_tally.get("not_entitled", 0) + over_tally.get("unknown_user", 0)
    print("\n" + "-" * 58)
    print(f"BLAST RADIUS of a {FREE_PLAYER_LIMIT}-player RLS limit:")
    print(f"  {over_tally.get('entitled', 0):>4} paying users over the limit (must NOT be broken)")
    print(f"  {at_risk:>4} non-paying users over the limit (would be capped)")
    if tally.get("error", 0):
        print(f"  {tally['error']:>4} lookups errored - treat totals as approximate")
    print("-" * 58)

    if VERBOSE:
        print("\nNon-paying users over the limit (uid, players):")
        for u, c in over:
            if states[u] in ("not_entitled", "unknown_user"):
                print(f"  {u}  {c}")

    print("\nNo data was written anywhere. Delete the RevenueCat key when done.\n")


if __name__ == "__main__":
    main()
