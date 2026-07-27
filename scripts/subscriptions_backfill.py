#!/usr/bin/env python3
"""
4.20a — Backfill prod `subscriptions` from RevenueCat.

Reads scripts/prod_users.csv (one auth.users id per line, checksum-verified
against prod) and asks RevenueCat for each user's premium_users entitlement.
For every user RevenueCat has EVER granted the entitlement, emits one INSERT
into scripts/subscriptions_backfill.sql.

WRITES NOTHING REMOTE. Output is a SQL file to be reviewed and applied
separately. The inserts are ON CONFLICT DO NOTHING so a row the live webhook
has already written (fresher by definition) is never clobbered.

Usage (in YOUR terminal, so the key never lands in a transcript):
    read -s REVENUECAT_API_KEY && export REVENUECAT_API_KEY
    python3 scripts/subscriptions_backfill.py

Output: aggregate counts on stdout, SQL in scripts/subscriptions_backfill.sql.
"""

import json
import os
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone

API_KEY = os.environ.get("REVENUECAT_API_KEY", "")
ENTITLEMENT = "premium_users"
HERE = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(HERE, "prod_users.csv")
SQL_PATH = os.path.join(HERE, "subscriptions_backfill.sql")
REQUEST_DELAY_S = 0.12


def fail(msg):
    print(f"\nERROR: {msg}\n", file=sys.stderr)
    sys.exit(1)


if not API_KEY:
    fail(
        "REVENUECAT_API_KEY is not set in this shell.\n"
        "  read -s REVENUECAT_API_KEY && export REVENUECAT_API_KEY   then re-run."
    )
if not API_KEY.startswith("sk_"):
    print(
        f"WARNING: key does not start with 'sk_' (starts '{API_KEY[:4]}').\n"
        "         Public SDK keys (appl_/goog_) will not work here.\n",
        file=sys.stderr,
    )


def parse_iso(s):
    if not s:
        return None
    try:
        return datetime.fromisoformat(s.replace("Z", "+00:00"))
    except ValueError:
        return None


def fetch_subscriber(uid):
    req = urllib.request.Request(
        f"https://api.revenuecat.com/v1/subscribers/{uid}",
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode()), None
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None, "unknown_user"
        if e.code in (401, 403):
            fail(f"RevenueCat rejected the key (HTTP {e.code}). Use a SECRET key (sk_...).")
        if e.code == 429:
            time.sleep(2.0)
            return fetch_subscriber(uid)
        return None, f"http_{e.code}"
    except Exception as e:
        return None, type(e).__name__


def q(val):
    """SQL literal: NULL, quoted string, or bool."""
    if val is None:
        return "null"
    if isinstance(val, bool):
        return "true" if val else "false"
    return "'" + str(val).replace("'", "''") + "'"


def row_for(uid, subscriber, now):
    """One backfill row, or None when the entitlement never existed."""
    ents = subscriber.get("entitlements", {}) or {}
    ent = ents.get(ENTITLEMENT)
    if not ent:
        return None

    product_id = ent.get("product_identifier")
    subs = subscriber.get("subscriptions", {}) or {}
    sub = subs.get(product_id, {}) if product_id else {}

    expires = parse_iso(ent.get("expires_date"))
    billing_issue_at = sub.get("billing_issues_detected_at")
    unsubscribed_at = sub.get("unsubscribe_detected_at")

    # Mirrors the webhook's lifecycle semantics (see revenuecat-webhook):
    # expired beats everything; grace period beats cancelled; else active.
    if expires is not None and expires <= now:
        status = "expired"
    elif billing_issue_at:
        status = "billing_issue"
    elif unsubscribed_at:
        status = "cancelled"
    else:
        status = "active"

    will_renew = True if status == "active" else False if status == "cancelled" else None

    return {
        "user_id": uid,
        "rc_app_user_id": subscriber.get("original_app_user_id") or uid,
        "status": status,
        "product_id": product_id,
        "store": sub.get("store"),
        "current_period_end": ent.get("expires_date"),
        "will_renew": will_renew,
    }


def main():
    if not os.path.exists(CSV_PATH):
        fail(f"input file missing: {CSV_PATH}")
    ids = [l.strip() for l in open(CSV_PATH) if l.strip()]
    print(f"checking {len(ids)} prod users against RevenueCat...")

    now = datetime.now(timezone.utc)
    now_iso = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    rows, counts = [], {"unknown_user": 0, "not_entitled": 0, "error": 0}

    for i, uid in enumerate(ids, 1):
        body, err = fetch_subscriber(uid)
        if err == "unknown_user":
            counts["unknown_user"] += 1
        elif err is not None:
            counts["error"] += 1
            print(f"  {err} for {uid[:8]}...", file=sys.stderr)
        else:
            row = row_for(uid, body.get("subscriber", {}) or {}, now)
            if row is None:
                counts["not_entitled"] += 1
            else:
                rows.append(row)
        if i % 50 == 0:
            print(f"  ...{i}/{len(ids)}")
        time.sleep(REQUEST_DELAY_S)

    by_status = {}
    for r in rows:
        by_status[r["status"]] = by_status.get(r["status"], 0) + 1

    with open(SQL_PATH, "w") as f:
        f.write(
            "-- 4.20a backfill, generated "
            + now_iso
            + f" from {len(ids)} prod users.\n"
            "-- ON CONFLICT DO NOTHING: a row the live webhook already wrote is\n"
            "-- fresher than this snapshot and must win.\n"
            "begin;\n"
        )
        for r in rows:
            f.write(
                "insert into public.subscriptions\n"
                "  (user_id, rc_app_user_id, entitlement, status, product_id, store,\n"
                "   current_period_end, will_renew, last_event_type, last_event_at)\n"
                "values\n"
                f"  ({q(r['user_id'])}::uuid, {q(r['rc_app_user_id'])}, 'premium_users', "
                f"{q(r['status'])}, {q(r['product_id'])}, {q(r['store'])},\n"
                f"   {q(r['current_period_end'])}{'::timestamptz' if r['current_period_end'] else ''}, "
                f"{q(r['will_renew'])}, 'BACKFILL', {q(now_iso)}::timestamptz)\n"
                "on conflict (user_id) do nothing;\n"
            )
        f.write("commit;\n")

    print("\n==== SUMMARY ====")
    print(f"users checked      : {len(ids)}")
    print(f"unknown to RC      : {counts['unknown_user']}")
    print(f"no entitlement     : {counts['not_entitled']}")
    print(f"errors             : {counts['error']}")
    print(f"rows written       : {len(rows)}  {by_status}")
    print(f"\nSQL: {SQL_PATH}")
    if counts["error"]:
        print("\nWARNING: errors above mean some users were NOT checked. Re-run before applying.")


if __name__ == "__main__":
    main()
