/**
 * Finance Tracker — Gmail → webhook forwarder (Google Apps Script).
 *
 * SETUP (one-time, ~3 minutes, works from a phone browser):
 *  1. Open https://script.google.com → New project.
 *  2. Paste this whole file, replacing the default code. Save (name it
 *     "Finance Tracker forwarder").
 *  3. Run the `setup` function once (▶ button) and approve the Gmail
 *     permission prompts.
 *  4. Done. It now checks Gmail every 5 minutes for unread bank alerts,
 *     posts them to the tracker, and labels them "fintracker-sent".
 *
 * To add/remove banks, edit SENDER_QUERY below and save — no other change.
 */

const WEBHOOK = "https://moatomqvfwwpvnhwnfiy.supabase.co/functions/v1/ingest";
const TOKEN = "ft_0332e62cef88401ef726c5391e6f21f7747c0ad280b27c60";

// Gmail search for bank/payment alert senders. Extend as needed.
const SENDER_QUERY = [
  "from:(alerts@hdfcbank.net)",
  "from:(credit_cards@icicibank.com)",
  "from:(alerts@icicibank.com)",
  "from:(alerts@sbi.co.in)",
  "from:(alerts@axisbank.com)",
  "from:(alerts@kotak.com)",
  "from:(noreply@phonepe.com)",
  "from:(no-reply@paytm.com)",
].join(" OR ");

const LABEL = "fintracker-sent";

function setup() {
  // idempotent: clear old triggers, create the 5-minute poll
  ScriptApp.getProjectTriggers().forEach((t) => ScriptApp.deleteTrigger(t));
  ScriptApp.newTrigger("forwardAlerts").timeBased().everyMinutes(5).create();
  GmailApp.createLabel(LABEL);
  forwardAlerts(); // first run now
}

function forwardAlerts() {
  const label = GmailApp.getLabelByName(LABEL) || GmailApp.createLabel(LABEL);
  const threads = GmailApp.search(`(${SENDER_QUERY}) -label:${LABEL} newer_than:2d`, 0, 20);
  for (const thread of threads) {
    for (const msg of thread.getMessages()) {
      const payload = {
        source: "email",
        sender: msg.getFrom(),
        subject: msg.getSubject(),
        body: msg.getPlainBody().slice(0, 4000),
        received_at: msg.getDate().toISOString(),
      };
      try {
        UrlFetchApp.fetch(`${WEBHOOK}?token=${TOKEN}`, {
          method: "post",
          contentType: "application/json",
          payload: JSON.stringify(payload),
          muteHttpExceptions: true,
        });
      } catch (e) {
        console.error("forward failed", e); // stays unlabeled → retried next run
        return;
      }
    }
    thread.addLabel(label);
  }
}
