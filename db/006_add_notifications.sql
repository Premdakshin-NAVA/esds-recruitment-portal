-- ============================================================================
-- Migration 006 — APPLIED (additive, non-breaking)
-- Applied to project txzrqrbixxrkaxdrsdnm.
--
-- Backs the in-app notification bell. Rows are addressed by profile id,
-- display name, or role ('admin' also reaches developers). RLS scopes both
-- reads and realtime delivery to the addressee; any authenticated user may
-- insert (the app emits on status changes, HM assignment, TEF saves,
-- comments, and new feedback).
--
-- Verified live: HM sees only their own rows and can mark them read;
-- developer receives 'admin'-role rows.
-- ============================================================================

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid,
  recipient_name text,
  recipient_role text,
  kind text default 'info',
  title text not null,
  body text,
  process_id uuid references public.processes(id) on delete set null,
  read boolean default false,
  created_at timestamptz default now()
);
create index if not exists idx_notifications_process_id on public.notifications(process_id);
alter table public.notifications enable row level security;

create policy "notif select" on public.notifications for select using (
  (recipient_id is not null and recipient_id = (select auth.uid()))
  or (recipient_name is not null and recipient_name = (select public.app_name()))
  or (recipient_role is not null and ((select public.app_role()) = recipient_role
      or (recipient_role = 'admin' and (select public.app_role()) = 'developer')))
);
create policy "notif insert" on public.notifications for insert
  with check ((select auth.role()) = 'authenticated');
create policy "notif update" on public.notifications for update using (
  (recipient_id is not null and recipient_id = (select auth.uid()))
  or (recipient_name is not null and recipient_name = (select public.app_name()))
  or (recipient_role is not null and ((select public.app_role()) = recipient_role
      or (recipient_role = 'admin' and (select public.app_role()) = 'developer')))
) with check (true);
create policy "notif delete" on public.notifications for delete using (
  (recipient_id is not null and recipient_id = (select auth.uid()))
  or (recipient_name is not null and recipient_name = (select public.app_name()))
  or (recipient_role is not null and ((select public.app_role()) = recipient_role
      or (recipient_role = 'admin' and (select public.app_role()) = 'developer')))
);

-- Realtime delivery (RLS-filtered)
do $$ begin
  alter publication supabase_realtime add table public.notifications;
exception when duplicate_object then null; when undefined_object then null; end $$;
