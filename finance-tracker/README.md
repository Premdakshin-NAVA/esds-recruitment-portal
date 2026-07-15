# Finance Tracker

Personal expense tracker (see `BRE.md` for full requirements). Lives in its own
dedicated Supabase project, separate from the recruitment portal.

**Live portal:** https://moatomqvfwwpvnhwnfiy.supabase.co/functions/v1/portal
(Supabase project `finance-tracker`, ref `moatomqvfwwpvnhwnfiy`, ap-south-1)

## Layout

| Path | What it is |
|---|---|
| `BRE.md` | Business requirements + phase plan |
| `db/*.sql` | Database migrations, applied in order via Supabase MCP |
| `index.html` | The whole portal (single-page, no build step). `__SUPABASE_URL__` / `__SUPABASE_ANON_KEY__` are substituted at deploy time |
| `functions/portal/index.ts` | Edge function that serves the portal over HTTPS |
| `build-portal.sh` | Generates `functions/portal/html.ts` (base64 of the substituted `index.html`) |

## Deploying the portal

```sh
SUPABASE_URL=https://<ref>.supabase.co \
SUPABASE_ANON_KEY=sb_publishable_... \
./build-portal.sh
# then deploy functions/portal (index.ts + html.ts) with verify_jwt=false
```

The portal is served at `https://<ref>.supabase.co/functions/v1/portal`.
Auth is enforced inside the app (Supabase Auth + RLS); a DB trigger restricts
sign-ups to the owner's email.

## Phase status

- [x] Phase 0 — BRE
- [x] Phase 1 — Core portal (schema, auth, manual entry, review queue, dashboard)
- [x] Phase 2 (backend) — Ingest webhook live + parser (unit-tested, e2e-tested),
      dedup, auto-categorize; Gmail Apps Script + SMS forwarder guides in `ingestion/`.
      **Owner setup pending:** run the Apps Script + install the SMS forwarder (see `ingestion/SETUP.md`)
- [x] Portal v3 — mobile layout, unparsed-alerts inbox, CSV export
- [ ] Phase 3 — Intelligence (learning-loop backfill, suggestions, summaries)
- [ ] Phase 4 — Polish (budgets, recurring detection)
