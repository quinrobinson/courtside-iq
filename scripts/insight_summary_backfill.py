#!/usr/bin/env python3
"""
Insight summary backfill (Release 2.1, Quin 2026-09-30).

Game rows now show a one-line `summary` of the per-game insight instead of the
insight cut short. Prompt v3 writes it for new games; this writes it for the
games that already have an insight. It ONLY ADDS `summary`: the insight text
itself is never regenerated (CLAUDE.md: insights are cached per game).

Input:  scripts/insight_summary_input_<env>.json, exported by Claude with
        [{"id": ..., "first_name": ..., "text": ...}, ...]
Output: scripts/insight_summary_backfill_<env>.sql, one UPDATE per game.

WRITES NOTHING REMOTE. The SQL is reviewed and applied separately, and each
UPDATE only fills a summary that is still missing, so a game that got a v3
insight in the meantime keeps the model's own line.

Rules match supabase/functions/_shared/insight_summary.ts and
lib/courtside_iq/game_row_meaning.dart: at most 52 characters (asked for 50),
no player name, no leading pronoun, sentence case, no closing period. A line
that breaks them is left out, and the app derives one from the text.

Usage (in YOUR terminal, so the key never lands in a transcript):
    read -s "ANTHROPIC_API_KEY?Paste key, then Enter: " && export ANTHROPIC_API_KEY
    python3 scripts/insight_summary_backfill.py test
"""

import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

MODEL = "claude-haiku-4-5-20251001"  # the per-game insight model
MAX_CHARS = 52
TARGET_CHARS = 50
HERE = os.path.dirname(os.path.abspath(__file__))
PRONOUNS = ("he ", "she ", "they ", "you ", "his ", "her ", "their ", "your ")

SYSTEM = f"""You write one-line headlines for a list of a young basketball player's games, for their parent.

Given the full insight about ONE game, write a headline that says what stood out in that game, so it reads differently from the player's other games.

Rules:
- At most {TARGET_CHARS} characters. This is strict.
- Do NOT use the player's name. Do not start with a pronoun (He, She, They, You).
- Sentence case, no closing period, no em dashes.
- Warm and encouraging, taken only from what the insight says. Invent nothing.
- Examples: "Scoring efficiency was really impressive this game", "Showed good activity on the court with 7 points", "Made efficient use of her chances with 18 points".

Reply with the headline only."""


def fail(msg):
    print(f"\nERROR: {msg}\n", file=sys.stderr)
    sys.exit(1)


def clean(raw, first_name):
    s = re.sub(r"\s*—\s*", ", ", raw.strip().strip('"').strip())
    if first_name:
        s = re.sub(rf"^{re.escape(first_name.strip())}(?:['’]s)?\s+", "", s, flags=re.I)
    s = re.sub(r"[.!\s]+$", "", s).strip()
    if not s or s.lower().startswith(PRONOUNS):
        return None
    s = s[0].upper() + s[1:]
    return s if len(s) <= MAX_CHARS else None


def ask(key, first_name, text):
    body = json.dumps({
        "model": MODEL,
        "max_tokens": 60,
        "system": SYSTEM,
        "messages": [{
            "role": "user",
            "content": f"Player's first name (do not use it): {first_name}\n\nInsight:\n{text}",
        }],
    }).encode()
    req = urllib.request.Request(
        "https://api.anthropic.com/v1/messages",
        data=body,
        headers={
            "x-api-key": key,
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
        },
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)["content"][0]["text"]


def sql_str(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("test", "prod"):
        fail("Usage: python3 scripts/insight_summary_backfill.py test|prod")
    env = sys.argv[1]
    key = os.environ.get("ANTHROPIC_API_KEY", "")
    if not key:
        fail("ANTHROPIC_API_KEY is not set in this shell.")
    src = os.path.join(HERE, f"insight_summary_input_{env}.json")
    out = os.path.join(HERE, f"insight_summary_backfill_{env}.sql")
    if not os.path.exists(src):
        fail(f"{src} is missing. Ask Claude to export it.")
    rows = json.load(open(src))

    lines = [
        f"-- Insight summary backfill ({env}), {len(rows)} games in.",
        "-- Adds `summary` only where it is still missing. Review before applying.",
        "begin;",
    ]
    written = skipped = 0
    for i, row in enumerate(rows, 1):
        try:
            raw = ask(key, row["first_name"] or "", row["text"])
        except urllib.error.HTTPError as e:
            fail(f"Anthropic API {e.code} on row {i}: {e.read()[:200]!r}")
        summary = clean(raw, row["first_name"] or "")
        if summary is None:
            skipped += 1
            lines.append(f"-- skipped {row['id']}: {raw.strip()[:80]!r}")
        else:
            written += 1
            lines.append(
                "update player_game_stats set game_insights = game_insights || "
                f"jsonb_build_object('summary', {sql_str(summary)}) "
                f"where id = {sql_str(str(row['id']))} "
                "and game_insights->>'summary' is null;"
                f"  -- {summary}"
            )
        print(f"{i}/{len(rows)}  {summary or '(skipped)'}")
        time.sleep(0.15)
    lines.append("commit;")
    open(out, "w").write("\n".join(lines) + "\n")
    print(f"\n{written} summaries, {skipped} skipped (the app derives those).")
    print(f"Wrote {out}. Nothing was changed in the database.")


if __name__ == "__main__":
    main()
