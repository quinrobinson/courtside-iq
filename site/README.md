# courtsideiq.app

The marketing site, designed in code (approved 2026-10). Plain static files, hosted on Cloudflare Pages.

- `index.html` home page (from `docs/site-revamp/round-3`, plus the 3.8 free-plan copy and a real QR)
- `policy.html`, `terms.html` legal pages (served at /policy and /terms). **The app links to `/policy` and `/terms`; never move them.**
- `support.html`, `get.html` (sends phones to the right app store; the QR code points here), `404.html`
- `_redirects`, `_headers` are Cloudflare Pages config

Deploy a preview: `wrangler pages deploy site --project-name courtsideiq-site --branch preview`
Deploy production: `wrangler pages deploy site --project-name courtsideiq-site --branch main`
