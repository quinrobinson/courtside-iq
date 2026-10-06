#!/usr/bin/env python3
"""
Builds the three Supabase auth emails (confirm sign-up, change email, reset password) from one
layout, so they can never drift apart. Output: supabase/templates/*.html.

Email HTML rules followed: table layout, inline styles, no web fonts relied on
(Hanken Grotesk is requested, with system fallbacks), a hosted PNG for the mark
(SVG does not render in Gmail), light-only colour scheme (dark-mode rewriting
in mail apps breaks ink-on-lime designs), and a plain-text fallback link.

MARK_SRC is the public URL of the mark PNG. Pass --preview to inline it as a
data: URI for local review instead. PROJECT_REF picks the project (test or
prod) for the recovery link.

THE RECOVERY LINK IS NOT {{ .ConfirmationURL }}. The live template (Quin,
2026-10-05) builds the verify URL by hand from TokenHash and RedirectTo, and the
app's password-recovery flow was built against it, so it is kept exactly.
"""
import base64, html, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OUT = os.path.join(ROOT, "supabase", "templates")
MARK_PNG = os.path.join(OUT, "assets", "mark-144.png")

INK, PAPER, CARD, TEXT, MUTED, LINE, LIME = "#0F0F0F", "#F2F3EE", "#FFFFFF", "#15170F", "#565B4E", "#E1E3DA", "#9DFF00"
FONT = "'Hanken Grotesk', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"

EMAILS = {
    "confirmation": dict(
        subject="Confirm your email for Courtside IQ",
        preheader="One tap and you're ready to add your player.",
        heading="Confirm your email",
        body="Thanks for joining Courtside IQ. Tap the button below to confirm this is your email, then head back to the app to add your player.",
        button="Confirm email",
        note="If you didn't create a Courtside IQ account, you can ignore this email.",
    ),
    "email_change": dict(
        subject="Confirm your new email for Courtside IQ",
        preheader="One tap to finish updating your email.",
        heading="Confirm your new email",
        body="You asked to change the email on your Courtside IQ account from {{ .Email }} to {{ .NewEmail }}. Tap the button below to confirm the change.",
        button="Confirm new email",
        note="Didn't ask for this? Ignore this email and your account keeps its current address.",
    ),
    "recovery": dict(
        subject="Reset your Courtside IQ password",
        preheader="Choose a new password in under a minute.",
        heading="Reset your password",
        body="We got a request to reset the password for {{ .Email }}. Tap the button below to choose a new one. The link works once and expires in one hour.",
        button="Choose a new password",
        note="Didn't ask to reset it? You can ignore this email, and your password stays the same.",
    ),
}

def render(e, mark_src, link):
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light">
<meta name="supported-color-schemes" content="light">
<title>{html.escape(e['subject'])}</title>
</head>
<body style="margin:0;padding:0;background:{PAPER};-webkit-text-size-adjust:100%;">
<div style="display:none;max-height:0;overflow:hidden;opacity:0;color:{PAPER};">{html.escape(e['preheader'])}</div>
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="{PAPER}" style="background:{PAPER};">
  <tr><td align="center" style="padding:32px 16px;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width:520px;">
      <tr><td bgcolor="{INK}" style="background:{INK};border-radius:18px 18px 0 0;padding:28px 32px;">
        <table role="presentation" cellpadding="0" cellspacing="0" border="0"><tr>
          <td style="vertical-align:middle;"><img src="{mark_src}" width="40" height="40" alt="" style="display:block;border:0;width:40px;height:40px;"></td>
          <td style="vertical-align:middle;padding-left:12px;font-family:{FONT};font-size:18px;font-weight:700;color:#FFFFFF;letter-spacing:-0.01em;">Courtside IQ</td>
        </tr></table>
      </td></tr>
      <tr><td bgcolor="{CARD}" style="background:{CARD};border-radius:0 0 18px 18px;padding:36px 32px 32px;font-family:{FONT};">
        <h1 style="margin:0 0 12px;font-size:26px;line-height:1.2;font-weight:800;color:{TEXT};letter-spacing:-0.02em;">{e['heading']}</h1>
        <p style="margin:0 0 28px;font-size:16px;line-height:1.55;color:{MUTED};">{e['body']}</p>
        <table role="presentation" cellpadding="0" cellspacing="0" border="0"><tr>
          <td bgcolor="{LIME}" style="background:{LIME};border-radius:999px;">
            <a href="{link}" style="display:inline-block;padding:15px 28px;font-family:{FONT};font-size:15px;font-weight:600;line-height:18px;color:{INK};text-decoration:none;border-radius:999px;">{e['button']}</a>
          </td>
        </tr></table>
        <p style="margin:28px 0 0;font-size:14px;line-height:1.5;color:{MUTED};">{e['note']}</p>
        <div style="margin:28px 0 0;padding-top:20px;border-top:1px solid {LINE};">
          <p style="margin:0 0 6px;font-size:13px;line-height:1.5;color:{MUTED};">Button not working? Copy this link into your browser:</p>
          <p style="margin:0;font-size:13px;line-height:1.5;word-break:break-all;"><a href="{link}" style="color:{TEXT};text-decoration:underline;">{link}</a></p>
        </div>
      </td></tr>
      <tr><td align="center" style="padding:20px 24px 0;font-family:{FONT};font-size:12px;line-height:1.5;color:{MUTED};">
        Courtside IQ helps parents see how their player grows, game by game.
      </td></tr>
    </table>
  </td></tr>
</table>
</body>
</html>
"""

def main():
    preview = "--preview" in sys.argv
    mark = os.environ.get("MARK_SRC", "")
    ref = os.environ.get("PROJECT_REF", "ejwgxsszmfabujdqxxdz")
    links = {
        "confirmation": "{{ .ConfirmationURL }}",
        "email_change": "{{ .ConfirmationURL }}",
        "recovery": f"https://{ref}.supabase.co/auth/v1/verify?token={{{{ .TokenHash }}}}&type=recovery&redirect_to={{{{ .RedirectTo }}}}",
    }
    if preview:
        mark = "data:image/png;base64," + base64.b64encode(open(MARK_PNG, "rb").read()).decode()
    if not mark:
        sys.exit("Set MARK_SRC to the public mark URL, or pass --preview.")
    out = {}
    for name, e in EMAILS.items():
        out[name] = (e["subject"], render(e, mark, links[name]))
        if not preview:
            open(os.path.join(OUT, f"{name}.html"), "w").write(out[name][1])
    return out

if __name__ == "__main__":
    r = main()
    for k, (s, h) in r.items():
        print(k, s, len(h), "em-dash" if "—" in h else "ok")
