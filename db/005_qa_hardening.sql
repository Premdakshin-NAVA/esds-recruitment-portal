-- ============================================================================
-- Migration 005 — APPLIED (QA hardening)
-- Applied to project txzrqrbixxrkaxdrsdnm.
--
-- QA finding #1 (high): the profiles INSERT policy only checks id=auth.uid(),
-- so a brand-new auth user could have created their first profile with
-- role='admin' via the REST API, bypassing role_provisioning.
-- Fix: BEFORE INSERT trigger — for authenticated non-admin callers, the email
-- is pinned to the JWT email and the role is forced to the pre-authorized
-- role_provisioning value for that email (default 'hm'). Looking up by JWT
-- email (not the submitted email) prevents claiming someone else's invite.
--
-- QA finding #6 (mitigation): tef_ratings ownership is matched by hm_name, so
-- a self-rename would orphan an HM's ratings. prevent_role_change() now also
-- blocks full_name changes by non-admins. (Proper fix later: key by hm_id.)
--
-- Verified live: HM inserting profile with role='admin' + spoofed email got
-- role='hm' + JWT email; HM self-rename rejected.
-- ============================================================================

create or replace function public.enforce_profile_defaults()
returns trigger language plpgsql security definer set search_path = '' as $$
declare jwt_email text; prov_role text;
begin
  if (select auth.role()) = 'authenticated'
     and coalesce((select public.app_role()),'') not in ('admin','developer') then
    jwt_email := (select auth.jwt()->>'email');
    if jwt_email is not null then new.email := jwt_email; end if;
    select role into prov_role from public.role_provisioning where lower(email)=lower(coalesce(jwt_email,new.email));
    new.role := coalesce(prov_role,'hm');
  end if;
  return new;
end $$;
drop trigger if exists trg_enforce_profile_defaults on public.profiles;
create trigger trg_enforce_profile_defaults before insert on public.profiles
  for each row execute function public.enforce_profile_defaults();

create or replace function public.prevent_role_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.role()) = 'authenticated'
     and coalesce((select public.app_role()),'') not in ('admin','developer') then
    if new.role is distinct from old.role then
      raise exception 'Only admins can change roles';
    end if;
    if new.full_name is distinct from old.full_name then
      raise exception 'Only admins can change display names';
    end if;
  end if;
  return new;
end $$;
