-- Financial Tracker — core schema (Phase 1)

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  icon text,
  color text,
  sort int not null default 100,
  is_archived boolean not null default false,
  created_at timestamptz not null default now()
);

-- Patterns are stored lowercased (app enforces) so the plain unique index
-- doubles as the upsert conflict target.
create table public.merchant_rules (
  id uuid primary key default gen_random_uuid(),
  pattern text not null check (pattern = lower(pattern)),
  match_type text not null default 'contains' check (match_type in ('exact','contains')),
  category_id uuid not null references public.categories(id) on delete cascade,
  hit_count int not null default 0,
  created_at timestamptz not null default now()
);
alter table public.merchant_rules add constraint merchant_rules_pattern_key unique (pattern, match_type);

-- Every inbound alert is stored verbatim, even when parsing fails (FR-1).
create table public.raw_messages (
  id uuid primary key default gen_random_uuid(),
  source text not null check (source in ('sms','email','manual','other')),
  sender text,
  subject text,
  body text not null,
  received_at timestamptz not null default now(),
  parse_status text not null default 'pending' check (parse_status in ('pending','parsed','failed','duplicate','ignored')),
  parse_error text,
  created_at timestamptz not null default now()
);

create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  amount numeric(14,2) not null check (amount >= 0),
  currency text not null default 'INR',
  direction text not null default 'debit' check (direction in ('debit','credit')),
  occurred_at timestamptz not null default now(),
  merchant text,
  account_hint text,
  channel text check (channel in ('upi','card','netbanking','cash','wallet','other')),
  ref_no text,
  category_id uuid references public.categories(id) on delete set null,
  status text not null default 'needs_review' check (status in ('categorized','needs_review')),
  source text not null default 'manual' check (source in ('manual','sms','email')),
  notes text,
  raw_message_id uuid references public.raw_messages(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index transactions_occurred_idx on public.transactions (occurred_at desc);
create index transactions_category_idx on public.transactions (category_id);
create index transactions_status_idx on public.transactions (status);

create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

create trigger transactions_touch before update on public.transactions
for each row execute function public.touch_updated_at();
