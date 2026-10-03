# Verification record

Completed during preparation of this project.

## Passed

- JavaScript syntax and structured-content checks: 48 unique cases, 12 per level, 144 quiz items, 96 simulation decisions, and valid reference keys.
- Chromium browser testing of four complete case journeys, one per level.
- Required-response checks, quiz incorrect/correct attempts, simulation teaching pauses and progression, SBAR, care notes, debrief and lab preparation submission.
- Browser-local save and reload, instructor review, released feedback and theory-only outcome options.
- User-written HTML is displayed as text in instructor review, not executed.
- Case search, level filtering, empty results, and explicit unconfigured account message.
- Desktop and 390-pixel mobile screenshots inspected; no horizontal overflow in tested library and case screens.
- Database schema executed against local PGlite with mocked Supabase auth identities. Verified invitation-only account trigger, isolation of student records, instructor access, rejection of self-promotion and forged reviews, hidden unreleased feedback, and denial of anonymous table access.

## Not yet verified

- Live GitHub Pages publication: a separate target repository is needed.
- Live Supabase authentication, email confirmation/recovery delivery, session refresh, and cloud submission integration: a project must be configured first.
- Production database policies must be rechecked using two fictional student accounts and an instructor in the actual configured project.
- Case clinical content and official lab scoring: faculty review and the approved Skills Book are still required.

Run the dependency-free content check with `node tests/check-content.cjs`.
