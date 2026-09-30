# scripts/

One-off operational scripts. Not part of the app build.

## entitlement_audit.py

Read-only audit answering: **if we enforce the free-tier player limit in RLS,
how many paying customers would it affect?**

Premium currently lives only on the device, so the server cannot distinguish a
paying parent of four from a free user who predates the gate. This asks
RevenueCat directly.

Writes nothing — not to RevenueCat, not to Supabase, not to prod.

### Input

Expects `prod_players.csv` beside it: `user_id,player_count`, no header.
**Deliberately not committed** — it contains production user identifiers.
Regenerate it against the target database:

```sql
select user_id::text || ',' || count(*)
from public.players
group by user_id
order by count(*) desc;
```

### Run

```bash
export REVENUECAT_API_KEY='sk_...'      # SECRET key, customer read only
python3 scripts/entitlement_audit.py    # add --verbose to list affected uids
```

Delete the RevenueCat key afterwards; it is only needed for the audit.
