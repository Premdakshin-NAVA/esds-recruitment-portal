// Ingestion webhook: receives raw payment alerts (SMS forwarder / Gmail Apps
// Script), stores them verbatim, parses, dedupes, categorizes, and creates
// transactions. Auth is a shared secret token (verify_jwt is off because the
// senders are dumb forwarders that can't mint JWTs).
//
// POST /functions/v1/ingest?token=...   (or header x-webhook-token: ...)
// { "source": "sms"|"email", "sender": "...", "subject": "...",
//   "body": "...", "received_at": "ISO-8601 (optional)" }
import { createClient } from "npm:@supabase/supabase-js@2";
import { parseAlert } from "./parse.js";

const TOKEN = "ft_0332e62cef88401ef726c5391e6f21f7747c0ad280b27c60";

const db = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const json = (status: number, data: unknown) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method !== "POST") return json(405, { error: "POST only" });
  const token = req.headers.get("x-webhook-token") ??
    new URL(req.url).searchParams.get("token");
  if (token !== TOKEN) return json(401, { error: "unauthorized" });

  let p: Record<string, unknown>;
  try {
    p = await req.json();
  } catch {
    return json(400, { error: "invalid json" });
  }
  const body = String(p.body ?? "").trim();
  if (!body) return json(400, { error: "body required" });
  const source = p.source === "sms" || p.source === "email" ? p.source : "other";
  const receivedAt = p.received_at ? new Date(String(p.received_at)) : new Date();

  // 1. Always store the raw message first — nothing is ever lost.
  const { data: raw, error: rawErr } = await db.from("raw_messages").insert({
    source,
    sender: p.sender ? String(p.sender) : null,
    subject: p.subject ? String(p.subject) : null,
    body,
    received_at: (isNaN(+receivedAt) ? new Date() : receivedAt).toISOString(),
  }).select("id").single();
  if (rawErr) return json(500, { error: rawErr.message });

  // 2. Parse.
  const parsed = parseAlert(body, isNaN(+receivedAt) ? new Date() : receivedAt);
  if (!parsed) {
    await db.from("raw_messages").update({
      parse_status: "failed",
      parse_error: "no transactional amount/direction found",
    }).eq("id", raw.id);
    return json(200, { stored: true, parsed: false, raw_id: raw.id });
  }

  // 3. De-duplicate (same payment alerted via both SMS and email, or retries).
  let dup = null;
  if (parsed.ref_no) {
    const { data } = await db.from("transactions").select("id")
      .eq("ref_no", parsed.ref_no).eq("amount", parsed.amount).limit(1);
    dup = data?.[0] ?? null;
  }
  if (!dup) {
    const t = +parsed.occurred_at;
    const { data } = await db.from("transactions").select("id,account_hint")
      .eq("amount", parsed.amount).eq("direction", parsed.direction)
      .gte("occurred_at", new Date(t - 5 * 60000).toISOString())
      .lte("occurred_at", new Date(t + 5 * 60000).toISOString());
    dup = (data ?? []).find((d) =>
      !d.account_hint || !parsed.account_hint ||
      d.account_hint.slice(-4) === parsed.account_hint.slice(-4)
    ) ?? null;
  }
  if (dup) {
    await db.from("raw_messages").update({ parse_status: "duplicate" }).eq("id", raw.id);
    return json(200, { stored: true, parsed: true, duplicate: true, tx_id: dup.id });
  }

  // 4. Categorize via merchant rules.
  let categoryId: string | null = null;
  if (parsed.merchant) {
    const m = parsed.merchant.toLowerCase();
    const { data: rules } = await db.from("merchant_rules").select("*");
    // short patterns ('ola','jio') must match as a whole word, not as a substring
    const matches = (r: { match_type: string; pattern: string }) => {
      if (r.match_type === "exact") return r.pattern === m;
      if (!m.includes(r.pattern)) return false;
      if (r.pattern.length > 4) return true;
      const escRe = r.pattern.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      return new RegExp(`(^|[^a-z0-9])${escRe}([^a-z0-9]|$)`).test(m);
    };
    const hit = (rules ?? []).filter(matches)
      .sort((a, b) =>
        (Number(b.match_type === "exact") - Number(a.match_type === "exact")) ||
        (b.pattern.length - a.pattern.length)
      )[0];
    if (hit) {
      categoryId = hit.category_id;
      await db.from("merchant_rules").update({ hit_count: (hit.hit_count ?? 0) + 1 }).eq("id", hit.id);
    }
  }

  // 5. Create the transaction.
  const { data: tx, error: txErr } = await db.from("transactions").insert({
    amount: parsed.amount,
    currency: "INR",
    direction: parsed.direction,
    occurred_at: parsed.occurred_at.toISOString(),
    merchant: parsed.merchant,
    account_hint: parsed.account_hint,
    channel: parsed.channel,
    payment_mode: parsed.payment_mode,
    ref_no: parsed.ref_no,
    category_id: categoryId,
    status: categoryId ? "categorized" : "needs_review",
    source,
    raw_message_id: raw.id,
  }).select("id").single();
  if (txErr) {
    await db.from("raw_messages").update({
      parse_status: "failed",
      parse_error: "insert failed: " + txErr.message,
    }).eq("id", raw.id);
    return json(500, { error: txErr.message, raw_id: raw.id });
  }

  await db.from("raw_messages").update({ parse_status: "parsed" }).eq("id", raw.id);
  return json(200, {
    stored: true,
    parsed: true,
    duplicate: false,
    tx_id: tx.id,
    categorized: !!categoryId,
  });
});
