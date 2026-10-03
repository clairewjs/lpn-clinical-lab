# Claire’s LPN Clinical Case Lab

A GitHub Pages-ready website for case-based practical nursing learning in British Columbia. The source contains 48 original fictional case drafts, 12 per level, mapped to the supplied PN1006, PN2006, PN3006 and PN4006 session schedules.

## What works immediately

Open `index.html` in a browser, or publish on GitHub Pages. No install or build is required.

- Search and filter by level, topic, skill and progress.
- Each case has a patient chart, objectives, three research prompts, three practice quiz questions, two sequential simulation decisions with remediation branches, SBAR and documentation, three debrief questions, and a draft lab preparation checklist.
- 48 × 3 = 144 quiz questions and 48 × 2 = 96 decision points. Decision paths and written rationales are recorded.
- Browser-local preview saves work in that browser. It is clearly labelled and does not authenticate anyone or share student records.
- Instructor preview can review that same local work, save feedback and draft lab assessments, and export a CSV summary.
- Print the lab preparation screen. Students can export their work as JSON.
- Mobile layouts, keyboard-accessible controls, labelled forms, and bottom-of-stage navigation.

## Publish as a NEW GitHub project

Recommended repository name: `lpn-clinical-lab`.

1. In GitHub, create a new repository under your account. Do not replace the existing REx-PN repository.
2. Extract this ZIP. Upload the **contents** of `lpn-clinical-lab`, so `index.html` is at the repository root, not inside another nested folder.
3. The `.github/workflows/pages.yml` file is a hidden folder in some file explorers. Include it if using GitHub Actions.
4. Open repository **Settings → Pages → Build and deployment** and choose **GitHub Actions**.
5. Open **Actions → Publish Clinical Case Lab → Run workflow** if the initial upload happened before Pages was configured.
6. After the deployment succeeds, use the URL shown in **Settings → Pages**. For the recommended name under `clairewjs`, the expected URL is `https://clairewjs.github.io/lpn-clinical-lab/`. This is an expected address, not a verified deployment.

Alternative if uploading hidden folders is inconvenient: in Settings → Pages choose **Deploy from a branch**, select `main` and `/ (root)`, and save. The static site needs no build. The SQL and documentation in this package contain no secrets, but the included Actions workflow publishes only the website assets.

Optional Git commands from an extracted project (after creating the empty repository):

```sh
git init -b main
git add .
git commit -m "Build LPN clinical case learning website"
git remote add origin https://github.com/clairewjs/lpn-clinical-lab.git
git push -u origin main
```

## Connect real student accounts and private submissions

The UI and SQL integration are included. A live Supabase project is not provisioned or connected in this deliverable. Preview mode does not pretend to be secure authentication.

Use one NEW Supabase project per classroom/teaching team. Every instructor in that project can read the classroom's student work. This version is not a multi-school tenancy system.

1. Create a Supabase project suitable for your school's requirements. Run `supabase/schema.sql` once in its SQL Editor. It creates the tables, invite-only profile trigger, and row-level access rules.
2. Keep email confirmations enabled in Authentication. Configure the Site URL and allowed redirect URL to the exact published website URL, including its repository path. Configure approved email delivery for confirmation and recovery before inviting a class.
3. In SQL Editor, create your own initial invitation, replacing the example email:

```sql
insert into public.invitations(email, display_name)
values ('your-email@example.com', 'Claire Song');
```

4. Put the project URL and **public publishable key or legacy anon key** in `config.js`. Commit this public configuration. NEVER use a secret/service-role key. Authentication and database permissions, not secrecy of this public key, protect records.
5. On the website, choose **Student sign-in → Create account** using your invited email. Confirm it by email.
6. In the SQL Editor, promote only your verified account:

```sql
update public.profiles
set role = 'instructor'
where id = (select id from auth.users where email = 'your-email@example.com');
```

7. Sign in again. The instructor workspace can add allowed student email addresses. Share the website link yourself. The app does not email invitations when you add them. Students create and confirm their own accounts and choose their own passwords.
8. Assign cases after student profiles exist. Student work saves to the database. Instructor feedback remains private until you check **Release this feedback**.
9. Verify isolation using two fictional student accounts before real student use: A must not read B's submissions, cannot change their profile role, cannot create reviews, cannot read unreleased feedback, and cannot list invitations. Instructor can read both students' work.

The SQL file uses server-managed timestamps and instructor review audit IDs. Users cannot assign themselves an instructor role through registration metadata. Student answers are user-authored and quiz totals are not trusted exam grades.

### Account behaviour

- Login tokens are stored in session storage for the browser tab and refreshed as needed.
- Preview work uses local storage and is intentionally separate from signed-in work.
- Password-reset links return to the Account screen, where the user can set a new password.
- No roster, password, real patient record or backend secret is included.
- Invitations are an allowlist. Removing an invitation prevents future registration but does not deactivate an existing account. Manage existing accounts in the Supabase authentication dashboard.
- This initial app keeps drafts and permits resubmission. For immutable graded exam submissions, server-side content delivery, scoring, locks and an assessment-specific policy are needed.

## Content review and learning limits

All cases are faculty-review drafts. They provide reasoning practice, not complete clinical protocols, prescribing records or official competencies. The patient charts explicitly identify missing observations, allergy information and orders. Students must identify what to obtain rather than assume missing information is normal.

The public case data includes feedback and answer keys, making this a formative learning site rather than a secure examination platform. Instructor-assessed written reasoning and observed lab performance are kept separate from practice scores.

Each case has seven draft lab criteria. They are not official pass/fail criteria. The actual Skills Book and INPA rubrics are still needed. The software does not infer a lab pass from a quiz score or student self-check.

The supplied PN4006 course concepts identify IV insertion, IV medication administration, blood-product initiation and nasogastric-tube insertion as theory/knowledge only. Its session schedule also lists IV insertion; the explicit theory-only restriction is retained until clarified. Maternal/pediatric practical eligibility must also be checked against current approved program requirements.

Case S numbers refer to the teaching session whose relevant content should be covered before use, not to an authorization to practise independently. All cases retain student supervision requirements.

Original source packets are not redistributed. Existing school testing scenarios are not copied. Draft cases must be checked for current clinical guidance and local protocols before release; the website does not claim BCCNM approval.

## Sources and editing

See `CONTENT-MAP.csv` for the case-to-session map. Source links are also available in every case.

- Supplied Sprott Shaw College PN1006, PN2006, PN3006 and PN4006 course packets: topic and session mapping only.
- BCCNM practice standards: https://www.bccnm.ca/LPN/PracticeStandards/Pages/Default.aspx
- BCCNM student supervision: https://www.bccnm.ca/LPN/learning/regulatorysupervision/Pages/Default.aspx
- BCCNM Medication standard: https://www.bccnm.ca/LPN/PracticeStandards/Pages/Medication.aspx
- Province of British Columbia (2025), Practical Nursing Program provincial curriculum: https://opentextbc.ca/pncurriculum/
- Doyle, G. R., & McCutcheon, J. A. (2015). Clinical procedures for safer patient care. BCcampus. https://opentextbc.ca/clinicalskills/ (CC BY 4.0). This older text is linked as background reading, not reproduced or treated as current local policy.
- GitHub Pages: https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages
- Supabase password authentication: https://supabase.com/docs/guides/auth/passwords
- Supabase row-level security: https://supabase.com/docs/guides/database/postgres/row-level-security

Reference discovery checked 3 October 2026 UTC. BCCNM sources establish regulatory principles; they do not independently validate every clinical detail in the fictional cases.

Edit case content in `assets/cases.js`; styles in `assets/style.css`; workflows in `assets/app.js`. Use `config.js` only for public connection settings. The SQL is intentionally not copied into the GitHub Actions published assets.
