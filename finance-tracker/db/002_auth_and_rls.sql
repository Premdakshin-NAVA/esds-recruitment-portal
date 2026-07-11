-- Financial Tracker — single-owner auth + RLS (Phase 1)

-- Only the owner's email may ever register. Sign-ups stay enabled in Supabase,
-- but this trigger rejects any other address at the database level.
create or replace function public.enforce_owner_email()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if lower(new.email) <> 'premdakshin@gmail.com' then
    raise exception 'Sign-ups are disabled on this portal';
  end if;
  return new;
end $$;

drop trigger if exists only_owner_signup on auth.users;
create trigger only_owner_signup
before insert on auth.users
for each row execute function public.enforce_owner_email();

-- RLS: single-user project — any authenticated session is the owner.
alter table public.categories enable row level security;
alter table public.merchant_rules enable row level security;
alter table public.raw_messages enable row level security;
alter table public.transactions enable row level security;

create policy "owner full access" on public.categories
  for all to authenticated using (true) with check (true);
create policy "owner full access" on public.merchant_rules
  for all to authenticated using (true) with check (true);
create policy "owner full access" on public.raw_messages
  for all to authenticated using (true) with check (true);
create policy "owner full access" on public.transactions
  for all to authenticated using (true) with check (true);
