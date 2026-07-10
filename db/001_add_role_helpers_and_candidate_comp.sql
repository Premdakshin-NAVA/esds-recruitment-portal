-- ============================================================================
-- Migration 001 — APPLIED (additive, non-breaking)
-- Applied to project txzrqrbixxrkaxdrsdnm as migration
-- "add_role_helpers_and_candidate_comp".
--
-- Adds role helper functions and a separate, RLS-gated compensation table.
-- The old frontend is unaware of candidate_comp, so this is safe to run while
-- the old index.html is still live.
-- ============================================================================

-- Helper: current user's app role. SECURITY DEFINER bypasses profiles RLS
-- (no recursion when used inside other tables' policies).
create or replace function public.app_role()
returns text language sql stable security definer set search_path = ''
as $$ select role from public.profiles where id = auth.uid() $$;

create or replace function public.app_name()
returns text language sql stable security definer set search_path = ''
as $$ select full_name from public.profiles where id = auth.uid() $$;

-- Compensation split into its own table.
create table if not exists public.candidate_comp (
  candidate_id uuid primary key references public.candidates(id) on delete cascade,
  curctc numeric,
  ctc_fixed numeric,
  ctc_variable numeric,
  expctc_min numeric,
  expctc_max numeric,
  expctc_neg boolean default false,
  updated_at timestamptz default now()
);

-- Backfill from the existing candidate salary columns.
insert into public.candidate_comp (candidate_id,curctc,ctc_fixed,ctc_variable,expctc_min,expctc_max,expctc_neg)
select id,curctc,ctc_fixed,ctc_variable,expctc_min,expctc_max,expctc_neg from public.candidates
on conflict (candidate_id) do nothing;

alter table public.candidate_comp enable row level security;

-- Read: admin/ta/developer always; HM only when a process for that candidate
-- has salary shared (processes.sal_visible = true).
create policy "comp select" on public.candidate_comp for select using (
  (select public.app_role()) in ('admin','ta','developer')
  or exists (select 1 from public.processes p
             where p.candidate_id = candidate_comp.candidate_id and p.sal_visible)
);
create policy "comp insert" on public.candidate_comp for insert
  with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "comp update" on public.candidate_comp for update
  using ((select public.app_role()) in ('admin','ta','developer'))
  with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "comp delete" on public.candidate_comp for delete
  using ((select public.app_role()) in ('admin','ta','developer'));
