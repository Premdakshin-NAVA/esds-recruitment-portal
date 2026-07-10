# Database migrations

Supabase project: `txzrqrbixxrkaxdrsdnm`

These files document the security hardening of the portal's database. The app
uses the Supabase anon key from the browser, so **all access control must live
in Row Level Security** — the frontend `PERMS` object is only a UI convenience.

## 001 — `add_role_helpers_and_candidate_comp.sql` — ✅ APPLIED
Additive and non-breaking. Adds:
- `app_role()` / `app_name()` — SECURITY DEFINER helpers that read the caller's
  `profiles` row for use inside other tables' policies.
- `candidate_comp` — a separate, RLS-gated table holding the 6 salary columns.
  Readable by admin/TA/developer always, and by an HM only when a process for
  that candidate has `sal_visible = true`. Backfilled from `candidates`.

The live (old) frontend does not reference `candidate_comp`, so applying 001
had no effect on the running app.

## 003 — `add_role_provisioning.sql` — ✅ APPLIED
Additive and non-breaking. Adds `role_provisioning(email, role, full_name)` so
an admin/developer can pre-authorize a role by email (the "Add admins" panel on
the Team page). `initApp()` consults it on first login. A signing-in user can
read only their own row; admins/developers manage all rows.

## 004 — `add_feedback.sql` — ✅ APPLIED
Additive and non-breaking. `feedback` table for the in-app Feedback button:
any authenticated user can insert; admin/developer can read (shown in Settings)
and delete.

## 002 — `cutover_role_rls_and_drop_salary.sql` — ✅ APPLIED (cutover complete)
Applied after merging the new `index.html` to `main`. Changed the data model
and access rules the frontend depends on:
1. Re-backfills `candidate_comp` for any candidates the old frontend created
   since 001.
2. **Drops** the salary columns from `candidates` (so hidden salary can never
   reach an HM's browser — the CSS blur is replaced by real enforcement).
3. Replaces the "any authenticated user can read/write everything" policies
   with role-based ones matching `PERMS`, and clears the `auth_rls_initplan`
   and `multiple_permissive_policies` advisories.
4. Adds a trigger preventing non-admins from changing their own role.

### Cutover checklist
1. Merge the feature branch to `main`; wait for GitHub Pages to redeploy.
2. Apply `002` (via Supabase migration).
3. Smoke-test: TA creates/edits a process, HM comments + saves TEF ratings,
   HM salary visibility respects the per-process toggle.

Rollback for 002 is non-trivial (dropped columns); the data is preserved in
`candidate_comp`, so a rollback would re-add the columns and copy values back.
