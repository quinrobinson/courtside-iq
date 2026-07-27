#!/usr/bin/env python3
"""
4.20a — Backfill prod `subscriptions` from RevenueCat (API v2).

Reads scripts/prod_users.csv (one auth.users id per line, checksum-verified
against prod) and asks RevenueCat's v2 API for each customer's subscriptions.
For every user who ever held one, emits one INSERT into
scripts/subscriptions_backfill.sql.

API v2 because the secret key is deliberately SCOPED (customer read only) -
v2 keys cannot call the old v1 endpoints, which is the right trade: this key
cannot grant entitlements even if it leaks.

WRITES NOTHING REMOTE. Output is a SQL file to be reviewed and applied
separately. Inserts are ON CONFLICT DO NOTHING so a row the live webhook has
already written (fresher by definition) is never clobbered. Alongside the SQL
it writes subscriptions_backfill_raw.json - the untouched API responses for
the users that produced rows - so the review can check the mapping against
the source.

Usage (in YOUR terminal, so the key never lands in a transcript):
    export REVENUECAT_PROJECT_ID='proj...'
    read -s "REVENUECAT_API_KEY?Paste key, then Enter: " && export REVENUECAT_API_KEY
    python3 scripts/subscriptions_backfill.py
"""

import json
import os
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone

API_KEY = os.environ.get("REVENUECAT_API_KEY", "")
PROJECT_ID = os.environ.get("REVENUECAT_PROJECT_ID", "")
HERE = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(HERE, "prod_users.csv")
SQL_PATH = os.path.join(HERE, "subscriptions_backfill.sql")
RAW_PATH = os.path.join(HERE, "subscriptions_backfill_raw.json")
REQUEST_DELAY_S = 0.12


def fail(msg):
    print(f"\nERROR: {msg}\n", file=sys.stderr)
    sys.exit(1)


if not API_KEY:
    fail("REVENUECAT_API_KEY is not set in this shell.")
if not PROJECT_ID:
    fail(
        "REVENUECAT_PROJECT_ID is not set.\n"
        "  It is the segment after /projects/ in the dashboard URL.\n"
        "  export REVENUECAT_PROJECT_ID='proj...'   then re-run."
    )


def get(path):
    """GET a v2 path. Returns (json, None) or (None, 'reason')."""
    req = urllib.request.Request(
        f"https://api.revenuecat.com/v2/projects/{PROJECT_ID}{path}",
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
            # Distinguish "customer unknown" from "project id wrong" - the
            # error body names the missing resource.
            try:
                detail = e.read().decode()
            except Exception:
                detail = ""
            if "project" in detail.lower():
                return None, "project_not_found"
            return None, "not_found"
        if e.code in (401, 403):
            fail(
                f"RevenueCat rejected the request (HTTP {e.code}).\n"
                "  Check the key is a v2 secret key with customer read access\n"
                "  AND that REVENUECAT_PROJECT_ID matches the key's project."
            )
        if e.code == 429:
            time.sleep(2.0)
            return get(path)
        return None, f"http_{e.code}"
    except Exception as e:
        return None, type(e).__name__


def resolve_project_id(sample_uid):
    """Dashboard URLs show the id bare; the API sometimes wants proj-prefixed.
    Probe with a real customer and keep whichever form the API accepts."""
    global PROJECT_ID
    candidates = [PROJECT_ID]
    if not PROJECT_ID.startswith("proj"):
        candidates.append("proj" + PROJECT_ID)
    for cand in candidates:
        PROJECT_ID = cand
        _, err = get(f"/customers/{sample_uid}")
        if err != "project_not_found":
            print(f"project id resolved: {PROJECT_ID}")
            return
    fail(
        "Neither form of the project id was accepted:\n"
        f"  tried {candidates}\n"
        "  Copy the id from the dashboard URL segment after /projects/."
    )


def ts(val):
    """Epoch-millis int or ISO string -> aware datetime, else None."""
    if val is None:
        return None
    if isinstance(val, (int, float)):
        return datetime.fromtimestamp(val / 1000.0, tz=timezone.utc)
    try:
        return datetime.fromisoformat(str(val).replace("Z", "+00:00"))
    except ValueError:
        return None


def q(val):
    if val is None:
        return "null"
    if isinstance(val, bool):
        return "true" if val else "false"
    return "'" + str(val).replace("'", "''") + "'"


_product_cache = {}


def store_product_id(rc_product_id):
    """Resolve RC's prod_... id to the store identifier the webhook writes."""
    if not rc_product_id:
        return None
    if rc_product_id in _product_cache:
        return _product_cache[rc_product_id]
    body, err = get(f"/products/{rc_product_id}")
    ident = (body or {}).get("store_identifier") or rc_product_id
    _product_cache[rc_product_id] = ident
    time.sleep(REQUEST_DELAY_S)
    return ident


def row_for(uid, subs, now):
    """Map the customer's subscription list to one backfill row, or None."""
    if not subs:
        return None

    def period_end(s):
        return ts(s.get("current_period_ends_at")) or datetime.min.replace(tzinfo=timezone.utc)

    best = max(subs, key=period_end)
    rc_status = (best.get("status") or "").lower()
    auto_renew = (best.get("auto_renewal_status") or "").lower()
    end = ts(best.get("current_period_ends_at"))

    if rc_status in ("expired", "incomplete") or (end is not None and end <= now and rc_status not in ("in_grace_period", "in_billing_retry")):
        status = "expired"
    elif rc_status in ("in_grace_period", "in_billing_retry"):
        status = "billing_issue"
    elif "will_not_renew" in auto_renew or "will_pause" in auto_renew:
        status = "cancelled"
    elif rc_status in ("active", "trialing"):
        status = "active"
    else:
        # Unknown state: keep the row visible for review rather than guessing
        # entitled. Expired is the safe floor; the review can promote it.
        print(f"  NEEDS REVIEW {uid[:8]}...: status={rc_status!r} renew={auto_renew!r}", file=sys.stderr)
        status = "expired"

    will_renew = True if status == "active" else False if status == "cancelled" else None
    return {
        "user_id": uid,
        "rc_app_user_id": uid,
        "status": status,
        "product_id": store_product_id(best.get("product_id")),
        "store": best.get("store"),
        "current_period_end": end.strftime("%Y-%m-%dT%H:%M:%SZ") if end else None,
        "will_renew": will_renew,
    }


def main():
    if not os.path.exists(CSV_PATH):
        fail(f"input file missing: {CSV_PATH}")
    ids = [l.strip() for l in open(CSV_PATH) if l.strip()]
    resolve_project_id(ids[0])
    print(f"checking {len(ids)} prod users against RevenueCat v2 (project {PROJECT_ID})...")

    now = datetime.now(timezone.utc)
    now_iso = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    rows, raw, counts = [], {}, {"not_found": 0, "no_subscriptions": 0, "error": 0}

    for i, uid in enumerate(ids, 1):
        body, err = get(f"/customers/{uid}/subscriptions")
        if err == "not_found":
            counts["not_found"] += 1
        elif err is not None:
            counts["error"] += 1
            print(f"  {err} for {uid[:8]}...", file=sys.stderr)
        else:
            subs = (body or {}).get("items") or []
            if not subs:
                counts["no_subscriptions"] += 1
            else:
                raw[uid] = subs
                row = row_for(uid, subs, now)
                if row:
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
            + f" from {len(ids)} prod users via RevenueCat API v2.\n"
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

    with open(RAW_PATH, "w") as f:
        json.dump(raw, f, indent=2, default=str)

    print("\n==== SUMMARY ====")
    print(f"users checked      : {len(ids)}")
    print(f"unknown to RC      : {counts['not_found']}")
    print(f"no subscriptions   : {counts['no_subscriptions']}")
    print(f"errors             : {counts['error']}")
    print(f"rows written       : {len(rows)}  {by_status}")
    print(f"\nSQL: {SQL_PATH}")
    print(f"raw: {RAW_PATH}")
    if counts["error"]:
        print("\nWARNING: errors above mean some users were NOT checked. Re-run before applying.")


if __name__ == "__main__":
    main()
