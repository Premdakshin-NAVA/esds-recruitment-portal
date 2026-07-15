// Generic parser for Indian bank/UPI payment alert messages (SMS + email).
// Plain JS (no TS syntax) so the same file runs in Deno (edge function) and
// Node (local tests). Returns null when no amount+direction can be found —
// the caller keeps the raw message in the review inbox instead.

const MONTHS = { jan: 0, feb: 1, mar: 2, apr: 3, may: 4, jun: 5, jul: 6, aug: 7, sep: 8, oct: 9, nov: 10, dec: 11 };

function parseAmount(text) {
  const m = text.match(/(?:rs\.?|inr|₹)\s*:?\s*([\d,]+(?:\.\d{1,2})?)/i);
  if (!m) return null;
  const v = parseFloat(m[1].replace(/,/g, ""));
  return isFinite(v) && v > 0 ? v : null;
}

function parseDirection(text) {
  if (/(credited|received|deposited|refund(ed)?|cashback)/i.test(text)) return "credit";
  if (/(debited|debit(ed)? from|spent|paid|payment of|sent|purchase|withdrawn|txn|transaction)/i.test(text)) return "debit";
  return null;
}

function parseMerchant(text) {
  // VPA (UPI handle) — prefer the trailing display name when present
  let m = text.match(/(?:to|from|at)\s+VPA\s+([a-z0-9.\-_]+)@[a-z0-9]+(?:\s+([A-Z][A-Za-z0-9 &.\-']{2,40}?))?(?=\s+on\s|\s*\(|[.,;]|$)/i);
  if (m) return (m[2] || m[1]).trim();
  m = text.match(/\bat\s+([A-Z0-9][A-Za-z0-9 &.\-*']{2,40}?)(?=\s+on\s|\s+Avl|\s+Ref|[.,;]|$)/i);
  if (m) return m[1].trim();
  m = text.match(/\b(?:to|towards)\s+([A-Z][A-Za-z0-9 &.\-']{2,40}?)(?=\s+on\s|\s+Ref|[.,;]|$)/i);
  if (m && !/^(?:your|the|a\/c|account)/i.test(m[1])) return m[1].trim();
  m = text.match(/Info:?\s*([^.\n]{3,40})/i);
  if (m) return m[1].trim();
  return null;
}

function parseAccount(text) {
  const card = text.match(/card\s*(?:no\.?|ending|ending in)?\s*[Xx*.]*(\d{4})/i);
  const acct = text.match(/a\/c(?:\s*no\.?)?\s*[Xx*.]*(\d{4})/i) || text.match(/account\s*(?:no\.?)?\s*[Xx*.]*(\d{4})/i);
  const bank = text.match(/[-–—]\s*([A-Z][A-Za-z ]{2,25}Bank)\s*\.?\s*$/m);
  const num = card ? card[1] : acct ? acct[1] : null;
  const hint = num ? `${bank ? bank[1] + " " : ""}··${num}` : bank ? bank[1] : null;
  return { hint, isCard: !!card };
}

function parseChannel(text, isCard) {
  if (/\b(upi|vpa)\b/i.test(text)) return "upi";
  if (isCard || /\b(credit card|debit card)\b/i.test(text)) return "card";
  if (/\b(neft|imps|rtgs|netbanking|net banking)\b/i.test(text)) return "netbanking";
  if (/\bwallet\b/i.test(text)) return "wallet";
  return "other";
}

function parseRef(text) {
  const m = text.match(/(?:upi\s*)?ref(?:erence)?(?:\s*no)?\.?\s*:?\s*(\d{6,18})/i)
    || text.match(/txn\s*(?:id|no)\.?\s*:?\s*([A-Za-z0-9]{6,22})/i);
  return m ? m[1] : null;
}

function parseWhen(text, fallback) {
  // "on 12-Jul-26", "on 12/07/2026", "on 12-07-26 at 18:32"
  const m = text.match(/\bon\s+(\d{1,2})[-\/ ]([A-Za-z]{3,9}|\d{1,2})[-\/ ](\d{2,4})(?:[,\s]+(?:at\s+)?(\d{1,2}):(\d{2}))?/i);
  if (!m) return fallback;
  const day = parseInt(m[1], 10);
  const mon = /^\d+$/.test(m[2]) ? parseInt(m[2], 10) - 1 : MONTHS[m[2].slice(0, 3).toLowerCase()];
  let year = parseInt(m[3], 10);
  if (year < 100) year += 2000;
  if (mon == null || mon < 0 || mon > 11 || day < 1 || day > 31) return fallback;
  const hh = m[4] ? parseInt(m[4], 10) : 12, mm = m[5] ? parseInt(m[5], 10) : 0;
  // Bank timestamps are IST (+05:30)
  const d = new Date(Date.UTC(year, mon, day, hh - 5, mm - 30));
  return isNaN(d) ? fallback : d;
}

export function parseAlert(text, receivedAt) {
  const amount = parseAmount(text);
  const direction = parseDirection(text);
  if (!amount || !direction) return null;
  const { hint, isCard } = parseAccount(text);
  const ref = parseRef(text);
  // Require a transactional anchor so promos/offers don't become transactions.
  if (!hint && !ref && !/\b(a\/c|account|card|vpa|upi|neft|imps|withdrawn)\b/i.test(text)) return null;
  let merchant = parseMerchant(text);
  if (merchant && /^(?:rs|inr|₹)/i.test(merchant)) merchant = null;
  return {
    amount,
    direction,
    merchant,
    account_hint: hint,
    channel: parseChannel(text, isCard),
    ref_no: ref,
    occurred_at: parseWhen(text, receivedAt || new Date()),
  };
}
