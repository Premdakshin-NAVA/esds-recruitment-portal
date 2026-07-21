// Local parser tests: node parse.test.mjs
import { parseAlert } from "./parse.js";

const cases = [
  {
    name: "HDFC UPI debit",
    text: "Rs.450.00 debited from A/c XX1234 on 12-Jul-26 to VPA swiggy@icici (UPI Ref No 519201234567). Not you? Call 18002586161 -HDFC Bank",
    expect: { amount: 450, direction: "debit", merchant: "swiggy", channel: "upi", ref_no: "519201234567", account_hint: "HDFC Bank ··1234" },
  },
  {
    name: "ICICI card spend",
    text: "INR 2,349.00 spent on ICICI Bank Card XX7003 on 12-Jul-26 at AMAZON. Avl Lmt: INR 1,05,000.",
    expect: { amount: 2349, direction: "debit", merchant: "AMAZON", channel: "card", account_hint: "··7003" },
  },
  {
    name: "SBI UPI credit",
    text: "Your a/c no. XX5678 is credited by Rs.55,000.00 on 01-07-26 from VPA employer@ybl (UPI Ref no 123456789012) - SBI Bank",
    expect: { amount: 55000, direction: "credit", merchant: "employer", channel: "upi", ref_no: "123456789012" },
  },
  {
    name: "VPA with display name",
    text: "Dear Customer, Rs.199.00 has been debited from a/c **4321 to VPA netflix@hdfcbank Netflix India on 05-07-26. UPI Ref 987654321012.",
    expect: { amount: 199, direction: "debit", merchant: "Netflix India", channel: "upi", ref_no: "987654321012" },
  },
  {
    name: "Numeric date with time",
    text: "Rs. 1200 debited from A/c XX9999 on 03/07/2026 at 18:45 to VPA bigbasket@upi. Ref No: 445566778899 -AXIS Bank",
    expect: { amount: 1200, direction: "debit", merchant: "bigbasket", channel: "upi" },
  },
  {
    name: "Unparseable (OTP message)",
    text: "Your OTP for login is 456123. Do not share it with anyone.",
    expect: null,
  },
  {
    name: "Promo message without direction",
    text: "Get 10% cashback up to Rs.100 on your next recharge!",
    expect: null,
  },
  {
    name: "HDFC InstaAlert email — credit card UPI, 'Paid to' + markdown asterisks",
    text: "HDFC BANK \nDear *Customer*,\n\nGreetings from *HDFC Bank!*\n\nWe're sharing this alert to help you quickly check a recent *UPI \ntransaction* made using your *RuPay Credit Card.*\n\n\n*Transaction Details:Rs.96.00* has been *debited* from your *RuPay Credit \nCard (ending 8754)*\nPaid to *paytm.s24i7q8@pty*\nDate: \n\n\n*20-07-26UPI Transaction Reference Number: 126569762285Important Note:*\nIf *you made this transaction,* no action is needed.\nIf *you did not make this transaction,* please act *immediately.* Your *safety \nand trust* are very important to us, and we are here to support you at \nevery step.",
    expect: { amount: 96, direction: "debit", merchant: "paytm.s24i7q8", channel: "upi", ref_no: "126569762285", account_hint: "··8754" },
  },
  {
    name: "HDFC InstaAlert email — bank account UPI, 'towards VPA X (Name)'",
    text: "Dear Customer,\n\nGreetings from HDFC Bank!\n\nRs.10000.00 is debited from your account ending 7492 towards VPA \npremabremii-2@okaxis (PREMA S) on 19-07-26.\n\nUPI transaction reference no.: 126559079050.\n\nIf you did not authorize this transaction, please report it immediately at: \na. When in India (Toll free): 1800 258 6161 \nb. When abroad: 9122 61606160 \nc. Or SMS 'BLOCK UPI' to 7308080808.\n\nWe're here to support you in every step of the way.\n\nWarm regards,\nHDFC Bank ",
    expect: { amount: 10000, direction: "debit", merchant: "PREMA S", channel: "upi", ref_no: "126559079050", account_hint: "··7492" },
  },
  {
    name: "HDFC InstaAlert email — card spend, 'towards MERCHANT' natural-language sentence before it",
    text: "HDFC BANK \nDear Customer,\n\nGreetings from HDFC Bank.\n\nWe would like to inform you that *Rs. 1400.00* has been debited from your \nHDFC Bank Credit Card ending *9746* towards *URBANCLAP TECHNOLOGIES* on *21 \nJul, 2026 at 08:05:01*. \nTo check your available balance, outstanding amount, or view recent \ntransactions, you may use Mycards or WhatsApp Banking.",
    expect: { amount: 1400, direction: "debit", merchant: "URBANCLAP TECHNOLOGIES", channel: "card", account_hint: "··9746" },
  },
  {
    name: "HDFC InstaAlert email — card refund/reversal, 'From Merchant:' label",
    text: "HDFC BANK \nDear Customer,\n\nGreetings from HDFC Bank!\n\nA *transaction reversal of Rs. 103.20* has been initiated to your HDFC Bank \nCredit Card ending *9746*\n*From Merchant:* ORACLE SINGAPORE\n*Date Time:* 20 Jul, 2026 at 14:55:25\n\nPlease allow up to *48 hours* for the reversal to reflect in your card statement.",
    expect: { amount: 103.2, direction: "credit", merchant: "ORACLE SINGAPORE", channel: "card", account_hint: "··9746" },
  },
];

let fail = 0;
for (const c of cases) {
  const got = parseAlert(c.text, new Date("2026-07-12T10:00:00+05:30"));
  if (c.expect === null) {
    if (got !== null) { console.log(`FAIL ${c.name}: expected null, got`, got); fail++; }
    else console.log(`ok   ${c.name}`);
    continue;
  }
  if (c.expect === "report") { console.log(`info ${c.name}:`, got); continue; }
  if (!got) { console.log(`FAIL ${c.name}: got null`); fail++; continue; }
  let bad = [];
  for (const [k, v] of Object.entries(c.expect)) {
    if (got[k] !== v) bad.push(`${k}: expected ${JSON.stringify(v)}, got ${JSON.stringify(got[k])}`);
  }
  if (bad.length) { console.log(`FAIL ${c.name}:\n  ` + bad.join("\n  ")); fail++; }
  else console.log(`ok   ${c.name}  (${got.occurred_at.toISOString()})`);
}
console.log(fail ? `\n${fail} failing` : "\nall passing");
process.exit(fail ? 1 : 0);
