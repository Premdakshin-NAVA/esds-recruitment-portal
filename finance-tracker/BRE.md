# Personal Financial Tracker — Business Requirements (BRE)

**Version:** 1.0 (approved)
**Date:** 2026-07-11
**Owner:** Premdakshin
**Branch:** `claude/financial-tracker-app-hne0zs`

---

## 1. Goal

A private, single-user web portal that automatically records every payment the
owner makes, categorizes it, and surfaces spending insights. Payment alerts
(SMS and email from banks / cards / UPI) are captured automatically; the owner
only reviews the transactions the system couldn't confidently categorize, and
the system learns from every correction.

## 2. Confirmed decisions

| Decision | Choice |
|---|---|
| Phones | Multiple phones (Android + others) — SMS forwarding where possible, email capture everywhere |
| Alert sources | Mix of SMS **and** email → both pipelines built, with de-duplication |
| Database | **New** dedicated Supabase project (separate from the recruitment portal; free tier) |
| Categorization | Rules + learned merchant→category mappings only for v1. AI (Claude) suggestion deferred to Phase 3 as an optional add-on |
| Frontend pattern | Single-page HTML + Supabase JS (same pattern as the recruitment portal, no build step) |
| Hosting | Static hosting from this repo (GitHub Pages or equivalent) |

## 3. Functional requirements

### FR-1 Ingestion
- A single HTTPS webhook (Supabase Edge Function, secret-token protected)
  accepts raw alert messages from any source.
- Sources:
  - **Email:** Google Apps Script on the owner's Gmail polls for bank alert
    emails (label/filter based) and POSTs them to the webhook.
  - **SMS (Android):** a forwarder app (MacroDroid / Tasker / SMS Forwarder)
    POSTs matching bank SMS to the webhook.
  - **Manual:** the portal itself for cash spends or missed alerts.
- Every inbound message is stored verbatim (raw text, sender, source,
  received-at) even when parsing fails, so nothing is ever lost.

### FR-2 Parsing
- Parsers extract: amount, currency, direction (debit/credit), date/time,
  merchant/payee, account or card identifier (last 4 digits), channel
  (UPI / card / netbanking / other), reference number when present.
- Parsers are per-bank/per-format and driven by real sample messages supplied
  by the owner (numbers redacted). Unparseable messages land in the review
  queue with the raw text visible.

### FR-3 Auto-categorization
- A merchant→category mapping table is consulted first (exact, then pattern
  match). Seed rules cover obvious merchants (e.g. Swiggy/Zomato → Food,
  BigBasket → Groceries).
- Transactions with no confident match are recorded with status
  **Needs review** and highlighted in the portal.

### FR-4 Learning loop
- When the owner assigns a category to a needs-review transaction, the
  merchant→category mapping is saved and auto-applied to all future
  transactions from that merchant.
- On save, the owner is offered a one-click "apply to N similar past
  transactions" action.
- The review UI pre-suggests the most likely category where any signal exists.

### FR-5 De-duplication
- The same payment arriving via both SMS and email must produce one
  transaction. Matching is on (amount, direction, account, timestamp window,
  and reference number when available). The duplicate raw message is linked to
  the surviving transaction, not discarded.

### FR-6 Portal
- **Auth:** Supabase email/password login; all tables RLS-protected;
  single-user.
- **Dashboard:** current-month spend by category, month-over-month trend,
  largest expenses, review-queue count.
- **Transactions view:** filter by date range / category / account / status;
  inline recategorize; edit; split; delete; manual add.
- **Categories view:** manage categories and merchant mappings.
- **Review queue:** dedicated view of uncategorized/unparsed items.

### FR-7 Data management
- CSV export of transactions (Phase 4).
- Raw messages retained indefinitely unless owner deletes.

## 4. Non-functional requirements

- **Privacy:** data lives only in the owner's Supabase project; webhook
  requires a secret token; no third-party inbound-email service holds data.
- **Cost:** target ₹0/month — Supabase free tier, Apps Script free, static
  hosting free, free-tier Android forwarder app.
- **Resilience:** ingestion never drops a message; parse failures are queued,
  not lost. Webhook is idempotent (safe retries from forwarders).
- **Simplicity:** no build tooling; one HTML file + SQL migrations + edge
  functions, all in this repo under `finance-tracker/`.

## 5. Non-goals (v1)

Budgets/alerts, family/multi-user sharing, investment tracking, receipt
scanning/OCR, direct bank-API or account-aggregator integration, native
mobile app.

## 6. Tool stack

| Piece | Tool |
|---|---|
| Repo / CI | GitHub — this repo, `finance-tracker/` folder, designated branch |
| DB, Auth, RLS | New Supabase project (Postgres) |
| Ingestion endpoint | Supabase Edge Function |
| Email capture | Google Apps Script (Gmail) |
| SMS capture | Android SMS-forwarder app → webhook |
| Frontend | Single-page HTML + Supabase JS CDN |
| Hosting | GitHub Pages (or Vercel/Netlify) |

## 7. Phase plan

| Phase | Scope | Exit criteria |
|---|---|---|
| **0 — BRE** | This document | Owner sign-off ✔ |
| **1 — Core portal** | New Supabase project; schema + RLS; auth; manual entry; categories & mappings; review queue; dashboard | Owner can log in, hand-enter and categorize transactions, see dashboard |
| **2 — Ingestion** | Webhook edge function; per-bank parsers (built from owner's sample messages); Gmail Apps Script; Android SMS forwarding; dedup | A real payment alert appears in the portal within minutes, auto-categorized or queued |
| **3 — Intelligence** | Learning-loop auto-apply + bulk backfill; category suggestions; optional Claude-based categorization; monthly summary | Review queue shrinks over time without manual rule-writing |
| **4 — Polish** | Budgets, recurring-payment detection, CSV export | Owner-defined |

## 8. Owner inputs needed per phase

- **Phase 1:** preferred starting category list (or accept a sensible default).
- **Phase 2:** 2–3 sample alert messages per bank/card/UPI app (redact account
  numbers), and which Gmail address receives bank emails.
- **Phase 3:** Anthropic API key only if AI categorization is switched on.
