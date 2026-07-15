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
