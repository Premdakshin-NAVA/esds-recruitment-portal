-- ============================================================================
-- Migration 004 — APPLIED (additive, non-breaking)
-- Applied to project txzrqrbixxrkaxdrsdnm.
--
-- Backs the in-app "Feedback" button. Any authenticated user can submit;
-- only admin/developer can read (surfaced in Settings) or delete.
-- ============================================================================

create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  by_id uuid,
  by_name text,
  kind text default 'general',
  message text not null,
  page text,
  created_at timestamptz default now()
);
alter table public.feedback enable row level security;

create policy "feedback insert" on public.feedback for insert
  with check ((select auth.role())='authenticated');
create policy "feedback select" on public.feedback for select
  using ((select public.app_role()) in ('admin','developer'));
create policy "feedback delete" on public.feedback for delete
  using ((select public.app_role()) in ('admin','developer'));
