-- Financial Tracker — generic keyword hints (Phase 3)
--
-- Merchant rules (from db/001) map a specific brand name ("swiggy") to a
-- category and auto-categorize at ingestion. Keywords here are weaker,
-- generic signals ("cafe", "hospital", "rent") used only to *pre-suggest* a
-- category in the review queue / add-transaction form for merchants that
-- don't match any merchant rule yet — they never auto-categorize on their
-- own, so a coincidental word match can't silently miscategorize a payment.

create table public.category_keywords (
  id uuid primary key default gen_random_uuid(),
  keyword text not null check (keyword = lower(keyword)) unique,
  category_id uuid not null references public.categories(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.category_keywords enable row level security;
create policy "owner full access" on public.category_keywords
  for all to authenticated using (true) with check (true);

insert into public.category_keywords (keyword, category_id)
select v.keyword, c.id
from (values
  ('restaurant',  'Food & Dining'),
  ('cafe',        'Food & Dining'),
  ('coffee',      'Food & Dining'),
  ('bakery',      'Food & Dining'),
  ('dhaba',       'Food & Dining'),
  ('eatery',      'Food & Dining'),
  ('kitchen',     'Food & Dining'),
  ('biryani',     'Food & Dining'),
  ('supermarket', 'Groceries'),
  ('grocery',     'Groceries'),
  ('groceries',   'Groceries'),
  ('kirana',      'Groceries'),
  ('hypermarket', 'Groceries'),
  ('apparel',     'Clothing'),
  ('fashion',     'Clothing'),
  ('garments',    'Clothing'),
  ('mall',        'Shopping'),
  ('cab',         'Transport'),
  ('taxi',        'Transport'),
  ('metro',       'Transport'),
  ('parking',     'Transport'),
  ('tollway',     'Transport'),
  ('fastag',      'Transport'),
  ('diesel',      'Fuel'),
  ('fuel',        'Fuel'),
  ('gas station', 'Fuel'),
  ('broadband',   'Utilities & Bills'),
  ('recharge',    'Utilities & Bills'),
  ('postpaid',    'Utilities & Bills'),
  ('prepaid',     'Utilities & Bills'),
  ('dth',         'Utilities & Bills'),
  ('rent',        'Rent & Housing'),
  ('landlord',    'Rent & Housing'),
  ('maintenance', 'Rent & Housing'),
  ('society',     'Rent & Housing'),
  ('hospital',    'Health'),
  ('clinic',      'Health'),
  ('pharmacy',    'Health'),
  ('diagnostic',  'Health'),
  ('dental',      'Health'),
  ('medical',     'Health'),
  ('cinema',      'Entertainment'),
  ('multiplex',   'Entertainment'),
  ('theatre',     'Entertainment'),
  ('gaming',      'Entertainment'),
  ('airlines',    'Travel'),
  ('railway',     'Travel'),
  ('hotel',       'Travel'),
  ('resort',      'Travel'),
  ('hostel',      'Travel'),
  ('school',      'Education'),
  ('college',     'Education'),
  ('university',  'Education'),
  ('tuition',     'Education'),
  ('salon',       'Personal Care'),
  ('spa',         'Personal Care'),
  ('parlour',     'Personal Care'),
  ('gym',         'Personal Care'),
  ('fitness',     'Personal Care'),
  ('donation',    'Gifts & Donations'),
  ('charity',     'Gifts & Donations'),
  ('temple',      'Gifts & Donations'),
  ('penalty',     'Fees & Charges'),
  ('late fee',    'Fees & Charges'),
  ('refund',      'Income'),
  ('cashback',    'Income'),
  ('interest',    'Income'),
  ('dividend',    'Income'),
  ('reimbursement','Income')
) as v(keyword, cat)
join public.categories c on c.name = v.cat;
