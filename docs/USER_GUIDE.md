# Talent Nexus — User Guide

**ESDS Talent Acquisition Portal · A guide for everyone on the team**

Talent Nexus is a website where our hiring team keeps track of job candidates — from the first phone call to the final hiring decision. Instead of spreadsheets, email chains, and WhatsApp messages, everything about a candidate lives in one place that the whole team can see.

- **Portal address:** https://premdakshin-nava.github.io/esds-recruitment-portal/
- **Questions or problems?** Contact Prem Dakshin (Sachu) — premdakshin@gmail.com — or use the **Feedback** button inside the portal (bottom-right corner).

---

## 1. Words you will see (read this first)

You don't need any HR background. These are all the terms the portal uses:

| Word | What it means |
|---|---|
| **Candidate** | A person applying for a job with us. |
| **Process** | One candidate being considered for one job. If the same person applies for two different jobs, that's two processes. |
| **TA (Talent Acquisition)** | The recruiter — the person who finds candidates, talks to them first, and moves them through the steps. |
| **HM (Hiring Manager)** | The person the candidate would work under. HMs take interviews and judge whether the candidate is right for the job. |
| **Round** | One interview. A candidate usually goes through 2–4 rounds: **L1** (first technical interview), **L2/L3** (further technical interviews), and an **HR round** (final discussion about fit, salary, joining). |
| **Stage** | Where the candidate currently is in their journey — for example "L1 scheduled" or "Profile shared with HM". |
| **Status** | The overall health of a process: **Active** (moving along), **Scheduled** (an interview is booked), **On hold** (paused), **Cancelled** (candidate dropped out), or **Closed** (finished — selected or rejected). The portal sets this automatically based on the stage you pick. |
| **TEF (Talent Evaluation Form)** | The scorecard for a candidate. Interviewers rate the candidate and write their comments here. One TEF per process. |
| **CTC** | The candidate's yearly salary package (Cost To Company). "Current CTC" is what they earn now; "Expected CTC" is what they're asking for. |
| **Notice period** | How long the candidate must wait before leaving their current job (for example, 30 days). |
| **WFO** | Work From Office — whether the candidate agrees to work from our office. |
| **Source** | Where we found the candidate (Naukri, LinkedIn, referral, etc.). |

---

## 2. Logging in

1. Open the portal address in any browser (works on phone too).
2. Enter your **email** and **password** and press **Sign in**.
3. You stay signed in on that device until you sign out (bottom-left corner, or Settings page).

You cannot create your own account. Access is given by the admin — if you can't log in, contact Sachu.

---

## 3. Roles — who can do what

What you see and what you can change depends on your role:

| What you can do | Admin | TA | HM |
|---|---|---|---|
| See all candidates and processes | ✅ | ✅ | ✅ |
| Add new candidates / start processes | ✅ | ✅ | ❌ |
| Edit candidate details | ✅ | ✅ | ❌ |
| Update stage / schedule interviews | ✅ | ✅ | ❌ |
| See salary details | ✅ | ✅ | Only if the TA has switched it on |
| Fill TEF ratings | All columns | View only | Only your own column |
| Write comments | ✅ | ✅ | ✅ |
| Manage the team list | ✅ | HMs only | ❌ |
| Give portal access / change roles | ✅ | ❌ | ❌ |
| Read team feedback | ✅ | ❌ | ❌ |

These rules are enforced by the system itself, not just hidden buttons — an HM genuinely cannot change a process even by technical means.

*(There is also a **Developer** role — Sachu — which has full access for building and fixing the portal.)*

---

## 4. A candidate's journey (the flow)

This is the story of how one candidate moves through the portal, start to finish:

1. **The TA finds a candidate** and has a first phone call (a "screening call") to check basics: experience, salary expectations, notice period, interest.
2. **The TA creates a process** in the portal — clicks **New process**, fills in the job details and everything learned in the screening call. The candidate now appears on the dashboard with the stage "Screening call completed".
3. **The TA shares the profile with the HM**, and updates the stage to "Profile shared with HM". The HM reviews and says yes or no to interviewing this person.
4. **An interview gets scheduled.** The TA picks a "scheduled" stage (like "L1 scheduled"), chooses which HM will interview, enters the date, time, and mode (Teams link for online, venue for in-person). When saved, the portal **automatically emails** the candidate and the HM with the details. The HM also gets a notification inside the portal.
5. **The interview happens.** Afterwards, the HM opens the candidate, clicks **TEF**, and fills their column: ratings from 1–5 on ten qualities, comments, one reason to hire, one reason not to hire.
6. **The TA updates the outcome** — for example "L1 completed — Selected". If selected, the next round gets scheduled the same way. If rejected, the process closes automatically.
7. **The HR round** is the final interview. The HM who takes it also fills **Section D** of the TEF (strengths, weaknesses, overall view).
8. **The decision.** The TA/Admin fills **Section E** of the TEF — proposed designation, department, and the final **Hire / Don't hire** recommendation. The stage is set to its final value and the process closes as **Selected** or **Rejected**.

At every step, the portal keeps a **timeline** (who did what, when) and a **comments** thread on the process — so anyone can open a candidate and understand the full history in seconds.

---

## 5. The screens

**Dashboard** — the home page. Four number cards at the top (active processes, scheduled interviews, on hold, average days in pipeline) and the full candidate list below. Use the search box or the filter chips (All / Active / On hold / Scheduled / Closed) to find anyone. Click any row to open the details. The sidebar's "Scheduled" link jumps straight to the scheduled-only view.

**Candidate detail panel** — opens when you click a row. Shows everything about the candidate: their info, salary (if you're allowed to see it), the process timeline, and comments. Buttons at the bottom: **TEF**, **Update status**, **Edit details** (depending on your role).

**TEF** — the evaluation form. Five sections: A (candidate info, filled automatically), B (rating table — one column per interviewer), C (interviewer comments), D (HR assessment), E (final recommendation — TA/Admin only). You can expand it to a full page with the ⤢ button. Press **Save** when done.

**Team** — the list of TAs and HMs. Admins can add/remove both; TAs can add/remove HMs. Admins also see **Portal access & roles** here — this is where new people are given logins/roles.

**Reports** — charts and numbers: pipeline by stage, outcomes, load per TA, candidate sources. Use the date filters to look at any period.

**Settings** — your account info, sign out, and (for admins) the list of feedback submitted by the team.

**🔔 Bell (top-right)** — your notifications: interviews assigned to you, status changes on your processes, TEF submissions, new comments. A red badge shows how many are unread. Click a notification to jump to that candidate.

**Feedback button (bottom-right)** — found a bug? Have an idea? Click it, type, send. It goes straight to the admins.

---

## 6. How to do common tasks

### Add a new candidate (TA / Admin)
1. Dashboard → **New process** (top-right).
2. Fill the job details (role, department, number of rounds, which TA owns it).
3. Fill the candidate details from your screening call. Only **name** and **job role** are compulsory — fill the rest as you learn it.
4. **Create process**. The candidate appears on the dashboard.

### Schedule an interview (TA / Admin)
1. Click the candidate → **Update status** (or the ⇄ button on their row).
2. Pick the stage, e.g. **L1 scheduled**.
3. Choose the **HM** who will interview.
4. Enter **date, time, mode** (Teams link if online, venue if in-person) and the HM's email.
5. **Save & send emails** — the candidate and HM are emailed automatically, and the HM gets a portal notification.

### Record an interview result (TA / Admin)
1. Candidate → **Update status**.
2. Pick the outcome stage, e.g. **L1 completed — Selected** or **L1 completed — Rejected**.
3. Choose who conducted it, add a comment if useful → Save. The overall status updates itself.

### Fill in your evaluation (HM)
1. Click the candidate you interviewed → **TEF**.
2. Find **your column** in the rating table (marked "Editable") and score all ten items from 5 (excellent) to 1 (not acceptable).
3. In Section C, write your comments plus one reason to hire and one concern.
4. If you took the **HR round**, also fill Section D.
5. **Save**. The TA gets notified automatically.

### Show or hide salary from the HM (TA / Admin)
1. Open the candidate's detail panel.
2. Use the **"Show salary to hiring manager"** switch, then press **Save salary visibility**. When off, HMs cannot see the salary at all — anywhere.

### Add a comment (everyone)
Open the candidate → scroll to **Add comment** → type → **Save comment**. The process owner (TA) is notified.

### Give someone portal access (Admin)
1. **Team** page → **Portal access & roles** card.
2. Type their name and email, choose the role, press **Add**.
3. If they already have a login, their role changes immediately. If not, the role is remembered and applied automatically the first time they sign in. (Their login account itself is created by Sachu.)

### Send feedback / report a bug (everyone)
Click **Feedback** (bottom-right) → pick Bug / Idea / General → type → **Send**. Admins see it under Settings.

---

## 7. Things the portal does by itself

So nobody is surprised:

- **Status is automatic.** You only ever pick the *stage*; the portal derives the status (picking a "…Rejected" stage closes the process, a "…scheduled" stage marks it Scheduled, and so on).
- **Emails go out when an interview is scheduled** — one to the candidate, one to the HM, sent from the portal at the moment you save.
- **Notifications appear instantly** — no refresh needed if the portal is open.
- **"Days" counts itself** — the days number on the dashboard is how long the process has been open since it was created.
- **The timeline writes itself** — every stage change is recorded with who did it and when.

---

## 8. Frequently asked questions

**I forgot my password.**
Contact Sachu — passwords are reset by the admin.

**I can't see a candidate's salary. Is that a bug?**
No. If you're an HM, the TA controls whether salary is visible to you, per candidate. Ask the TA to switch it on if you need it.

**Why can't I edit anything?**
Your role decides what you can change (see section 3). HMs can view everything, comment, and fill their own TEF ratings — but only TAs/Admins can edit candidate data or move stages.

**I filled the TEF but my colleague's column is greyed out.**
Correct — every interviewer fills only their own column. Only Admins can edit all columns.

**Does clicking "Update status" always send emails?**
No. Emails are sent only when you pick a *scheduled* stage (because that's when the candidate and HM need the invite). Other stage changes don't email anyone — they just update the portal and notify the right people inside it.

**The same person is applying for two jobs. What do I do?**
Create two processes (one per job). Each has its own stages, interviews, and TEF.

**A candidate stopped answering calls.**
Set the stage to **Drop off** (or **No show** for a missed interview) with a comment. The process is marked Cancelled but stays in the records.

**Can I use it on my phone?**
Yes — it's a website, so it works in any mobile browser. The layout is built for desktop, so complex screens like the TEF are more comfortable on a computer.

**Is the data safe?**
Yes. Everyone must log in; every rule in section 3 is enforced by the database itself; salary data is stored separately with its own protection; and every change is recorded in the timeline.

**Something looks broken. What do I do?**
Click **Feedback → Bug** and describe what happened (what you clicked, what you expected, what you saw). That's the fastest way to get it fixed.

---

*Talent Nexus is built and maintained by Prem Dakshin (Sachu), Senior Specialist HRBP, ESDS Software Solution. This guide lives in the project repository (`docs/USER_GUIDE.md`) — the portal team keeps it updated as features change.*
