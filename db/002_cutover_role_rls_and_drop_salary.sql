-- ============================================================================
-- Migration 002 — CUTOVER (BREAKING — do NOT apply until the new index.html
-- is live on `main`). Apply this in the same maintenance window as the merge.
--
-- 1) Re-backfill candidate_comp for any candidates created by the OLD frontend
--    between migration 001 and cutover.
-- 2) Drop the salary columns from candidates (true server-side salary gating —
--    hidden salary can no longer reach an HM's browser).
-- 3) Replace the permissive "any authenticated user" policies with role-based
--    rules matching the app's PERMS. Also fixes the auth_rls_initplan and
--    multiple_permissive_policies advisories (wrap auth.* in (select ...),
--    one policy per command).
-- 4) Prevent non-admins from escalating their own role.
-- ============================================================================

begin;

-- 1) Re-backfill (captures anything the old frontend created in the interim)
insert into public.candidate_comp (candidate_id,curctc,ctc_fixed,ctc_variable,expctc_min,expctc_max,expctc_neg)
select id,curctc,ctc_fixed,ctc_variable,expctc_min,expctc_max,expctc_neg from public.candidates
on conflict (candidate_id) do nothing;

-- 2) Drop migrated salary columns from candidates
alter table public.candidates
  drop column if exists curctc,
  drop column if exists ctc_fixed,
  drop column if exists ctc_variable,
  drop column if exists expctc_min,
  drop column if exists expctc_max,
  drop column if exists expctc_neg;

-- 3) Role-based RLS ----------------------------------------------------------

-- CANDIDATES  (read: all authenticated; write: staff)
drop policy if exists "read all" on public.candidates;
drop policy if exists "write" on public.candidates;
create policy "candidates_select" on public.candidates for select using ((select auth.role())='authenticated');
create policy "candidates_insert" on public.candidates for insert with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "candidates_update" on public.candidates for update using ((select public.app_role()) in ('admin','ta','developer')) with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "candidates_delete" on public.candidates for delete using ((select public.app_role()) in ('admin','ta','developer'));

-- PROCESSES
drop policy if exists "read all" on public.processes;
drop policy if exists "write" on public.processes;
create policy "processes_select" on public.processes for select using ((select auth.role())='authenticated');
create policy "processes_insert" on public.processes for insert with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "processes_update" on public.processes for update using ((select public.app_role()) in ('admin','ta','developer')) with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "processes_delete" on public.processes for delete using ((select public.app_role()) in ('admin','ta','developer'));

-- PROCESS_ROUNDS
drop policy if exists "read all" on public.process_rounds;
drop policy if exists "write" on public.process_rounds;
create policy "process_rounds_select" on public.process_rounds for select using ((select auth.role())='authenticated');
create policy "process_rounds_insert" on public.process_rounds for insert with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "process_rounds_update" on public.process_rounds for update using ((select public.app_role()) in ('admin','ta','developer')) with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "process_rounds_delete" on public.process_rounds for delete using ((select public.app_role()) in ('admin','ta','developer'));

-- TIMELINE_EVENTS
drop policy if exists "read all" on public.timeline_events;
drop policy if exists "write" on public.timeline_events;
create policy "timeline_select" on public.timeline_events for select using ((select auth.role())='authenticated');
create policy "timeline_insert" on public.timeline_events for insert with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "timeline_update" on public.timeline_events for update using ((select public.app_role()) in ('admin','ta','developer')) with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "timeline_delete" on public.timeline_events for delete using ((select public.app_role()) in ('admin','ta','developer'));

-- ROUND_INTERVIEWERS (unused; staff-write only)
drop policy if exists "read all" on public.round_interviewers;
drop policy if exists "write" on public.round_interviewers;
create policy "round_int_select" on public.round_interviewers for select using ((select auth.role())='authenticated');
create policy "round_int_insert" on public.round_interviewers for insert with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "round_int_update" on public.round_interviewers for update using ((select public.app_role()) in ('admin','ta','developer')) with check ((select public.app_role()) in ('admin','ta','developer'));
create policy "round_int_delete" on public.round_interviewers for delete using ((select public.app_role()) in ('admin','ta','developer'));

-- COMMENTS (any authenticated user may comment; edits/deletes staff-only)
drop policy if exists "read all" on public.comments;
drop policy if exists "write" on public.comments;
create policy "comments_select" on public.comments for select using ((select auth.role())='authenticated');
create policy "comments_insert" on public.comments for insert with check ((select auth.role())='authenticated');
create policy "comments_update" on public.comments for update using ((select public.app_role()) in ('admin','developer')) with check ((select public.app_role()) in ('admin','developer'));
create policy "comments_delete" on public.comments for delete using ((select public.app_role()) in ('admin','developer'));

-- TEAM_MEMBERS (admin/dev: all; TA: HM rows only)
drop policy if exists "read all" on public.team_members;
drop policy if exists "write" on public.team_members;
create policy "team_select" on public.team_members for select using ((select auth.role())='authenticated');
create policy "team_insert" on public.team_members for insert with check (
  (select public.app_role()) in ('admin','developer')
  or ((select public.app_role())='ta' and type='HM'));
create policy "team_update" on public.team_members for update using ((select public.app_role()) in ('admin','developer')) with check ((select public.app_role()) in ('admin','developer'));
create policy "team_delete" on public.team_members for delete using (
  (select public.app_role()) in ('admin','developer')
  or ((select public.app_role())='ta' and type='HM'));

-- TEF_RATINGS (admin/dev: all; HM: only their own rows, matched by hm_name)
drop policy if exists "read all" on public.tef_ratings;
drop policy if exists "write" on public.tef_ratings;
create policy "tef_ratings_select" on public.tef_ratings for select using ((select auth.role())='authenticated');
create policy "tef_ratings_insert" on public.tef_ratings for insert with check (
  (select public.app_role()) in ('admin','developer') or hm_name = (select public.app_name()));
create policy "tef_ratings_update" on public.tef_ratings for update using (
  (select public.app_role()) in ('admin','developer') or hm_name = (select public.app_name())) with check (
  (select public.app_role()) in ('admin','developer') or hm_name = (select public.app_name()));
create policy "tef_ratings_delete" on public.tef_ratings for delete using ((select public.app_role()) in ('admin','developer'));

-- TEF_HR (admin/ta/dev: all; plus the HR-round HM for that process)
drop policy if exists "read all" on public.tef_hr;
drop policy if exists "write" on public.tef_hr;
create policy "tef_hr_select" on public.tef_hr for select using ((select auth.role())='authenticated');
create policy "tef_hr_insert" on public.tef_hr for insert with check (
  (select public.app_role()) in ('admin','ta','developer')
  or exists (select 1 from public.process_rounds pr
             where pr.process_id = tef_hr.process_id and pr.round_name='HR'
               and pr.hm_name = (select public.app_name())));
create policy "tef_hr_update" on public.tef_hr for update using (
  (select public.app_role()) in ('admin','ta','developer')
  or exists (select 1 from public.process_rounds pr
             where pr.process_id = tef_hr.process_id and pr.round_name='HR'
               and pr.hm_name = (select public.app_name())))
  with check (
  (select public.app_role()) in ('admin','ta','developer')
  or exists (select 1 from public.process_rounds pr
             where pr.process_id = tef_hr.process_id and pr.round_name='HR'
               and pr.hm_name = (select public.app_name())));
create policy "tef_hr_delete" on public.tef_hr for delete using ((select public.app_role()) in ('admin','ta','developer'));

-- PROFILES (dedupe SELECT policies + wrap auth in select)
drop policy if exists "own profile read" on public.profiles;
drop policy if exists "read all" on public.profiles;
drop policy if exists "own profile insert" on public.profiles;
drop policy if exists "own profile update" on public.profiles;
create policy "profiles_select" on public.profiles for select using ((select auth.role())='authenticated');
create policy "profiles_insert" on public.profiles for insert with check ((select auth.uid()) = id);
-- Own profile, OR an admin/developer editing anyone (needed by the role-management UI).
-- The prevent_role_change() trigger still blocks non-admins from changing any role.
create policy "profiles_update" on public.profiles for update
  using ((select auth.uid()) = id or (select public.app_role()) in ('admin','developer'))
  with check ((select auth.uid()) = id or (select public.app_role()) in ('admin','developer'));

-- 4) Block self role escalation: only admins/developers may change a role.
create or replace function public.prevent_role_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.role is distinct from old.role
     and (select public.app_role()) not in ('admin','developer') then
    raise exception 'Only admins can change roles';
  end if;
  return new;
end $$;

drop trigger if exists trg_prevent_role_change on public.profiles;
create trigger trg_prevent_role_change before update on public.profiles
  for each row execute function public.prevent_role_change();

commit;
