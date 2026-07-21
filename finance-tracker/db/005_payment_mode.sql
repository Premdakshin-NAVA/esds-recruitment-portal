-- Financial Tracker — payment mode detail (Phase 3)
--
-- `channel` (upi/card/netbanking/cash/wallet/other) is a coarse rail. This
-- adds a finer, human-readable instrument label derived straight from the
-- alert text — e.g. "RuPay Card", "Credit Card", "Google Pay", "PhonePe",
-- "Online Transaction" — so spend can be broken down by how it was paid,
-- not just categorized by what it was for.

alter table public.transactions add column payment_mode text;
