# Ingestion setup — get alerts flowing into the tracker

The webhook endpoint (already deployed and live):

```
POST https://moatomqvfwwpvnhwnfiy.supabase.co/functions/v1/ingest?token=ft_0332e62cef88401ef726c5391e6f21f7747c0ad280b27c60
Content-Type: application/json

{ "source": "sms" | "email", "sender": "...", "subject": "...",
  "body": "<the alert text>", "received_at": "ISO timestamp (optional)" }
```

Every message is stored verbatim. If it parses, a transaction is created and
auto-categorized by your merchant rules; duplicates (same payment via SMS and
email) are detected and linked, not double-counted. If it can't be parsed it
shows up under **Review → Unparsed alerts** in the portal.

## A. Email (Gmail) — ~3 minutes

Follow the steps at the top of `gmail-forwarder.gs` (paste into
script.google.com, run `setup` once, approve permissions). Works from a phone
browser. Add/remove bank sender addresses in `SENDER_QUERY`.

## B. SMS (Android) — ~5 minutes

Any SMS-to-webhook app works. With **MacroDroid** (free tier is enough):

1. Install MacroDroid from the Play Store → Add Macro.
2. **Trigger:** SMS Received → any content. (Optional: filter to senders
   containing `HDFC`, `ICICI`, `SBI`, etc. — or leave open; the webhook
   ignores non-payment texts automatically.)
3. **Action:** HTTP Request →
   - Method: `POST`
   - URL: `https://moatomqvfwwpvnhwnfiy.supabase.co/functions/v1/ingest?token=ft_0332e62cef88401ef726c5391e6f21f7747c0ad280b27c60`
   - Content type: `application/json`
   - Body:
     ```json
     {"source":"sms","sender":"{sms_number}","body":"{sms_message}"}
     ```
4. Save and enable the macro. Send yourself a test (or wait for a real
   payment) and check the portal.

Alternatives: Tasker, "SMS Forwarder — auto forward" (configure the same URL
and JSON body).

## C. iPhone

SMS interception is not possible on iOS. Rely on the Gmail path (enable email
alerts in your bank apps) — most banks/UPI apps can email every transaction.

## Testing the webhook by hand

```sh
curl -X POST "https://moatomqvfwwpvnhwnfiy.supabase.co/functions/v1/ingest?token=ft_0332e62cef88401ef726c5391e6f21f7747c0ad280b27c60" \
  -H "content-type: application/json" \
  -d '{"source":"sms","sender":"HDFCBK","body":"Rs.450.00 debited from A/c XX1234 on 12-Jul-26 to VPA swiggy@icici (UPI Ref No 519201234567). -HDFC Bank"}'
```

Expected: `{"stored":true,"parsed":true,"duplicate":false,...,"categorized":true}`
and a Food & Dining transaction appears in the portal.

## Security notes

- The token is the only guard on the webhook — treat it like a password.
  If it ever leaks, say the word and it gets rotated (one redeploy).
- The webhook only *inserts* data; it cannot read or modify your transactions.
