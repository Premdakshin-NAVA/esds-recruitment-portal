-- ============================================================================
-- Migration 003 — APPLIED (additive, non-breaking)
-- Applied to project txzrqrbixxrkaxdrsdnm as migration "add_role_provisioning".
--
-- Backs the "Add admins" UI. An admin/developer pre-authorizes a role for an
-- email; when that person first signs in, initApp() reads their own row and
-- creates their profile with the pre-authorized role.
-- ============================================================================

create table if not exists public.role_provisioning (
  email text primary key,
  role text not null,
  full_name text,
  created_at timestamptz default now()
);
alter table public.role_provisioning enable row level security;

-- Admin/developer manage all; a signing-in user may read only their own row
-- (by email from the JWT) so first-login provisioning works before a profile exists.
create policy "prov select" on public.role_provisioning for select using (
  (select public.app_role()) in ('admin','developer')
  or email = (select auth.jwt()->>'email')
);
create policy "prov insert" on public.role_provisioning for insert
  with check ((select public.app_role()) in ('admin','developer'));
create policy "prov update" on public.role_provisioning for update
  using ((select public.app_role()) in ('admin','developer'))
  with check ((select public.app_role()) in ('admin','developer'));
create policy "prov delete" on public.role_provisioning for delete
  using ((select public.app_role()) in ('admin','developer'));
