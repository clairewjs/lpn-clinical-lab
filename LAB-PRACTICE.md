# Lab Practice

Sign in and select **Lab Practice**. Adult head-to-toe is the first skill.

## Self-practice

Choose **Self-practice**, start the timer, and tick actions as performed. Conditional actions may be marked Not applicable when their trigger is absent; add a reason in section notes. Finish to review missed actions and source CF flags. A repeat creates a separate record.

## Peer evaluation

1. The learner chooses **Practice with a peer** and shares the pairing code privately.
2. The evaluator signs in to their own classroom account and enters the code under **Join as a peer evaluator**.
3. The evaluator starts the timer, observes actions, ticks completed steps, and adds notes.
4. The evaluator finishes the run. Learner, paired evaluator, and instructor can review it; unrelated students cannot.

Only the paired evaluator can rate a peer run. The learner can refresh the peer connection or reopen a saved run to see updated results. Finished results cannot be edited. Instructor accounts see class practice records under Lab Practice.

## Checklist and timing limits

Content is stored in authenticated Supabase clinical_content, not in this repository. The comprehensive PN2006 assessment sections A–J and universal procedures supply the initial adaptation; the separate focused-assessment checklist is excluded. One-action checklist items inherit CF flags from their original source row. Source criteria are available beneath actions. CF review does not automatically assign official failure or competency.

The full source adaptation includes preparation, subjective history, assessment, conditional escalation, and documentation. The 15-minute timer is a rehearsal target, not evidence that all source requirements fit within 15 minutes. No requirements are dropped automatically. Use mannequins or approved simulation for intimate/rectal components, not classmates. Instructor-demonstrated landmark diagrams remain necessary.

## Verification

- Database transactions tested canonical content, own-record access, peer pairing and evaluation, unrelated-student denial, finished-record locking, instructor access, and anonymous denial; temporary test data rolled back.
- DOM-based workflow tests covered all ten sections, checkboxes, Not applicable notes, timer controls, missed/CF scoring, repeat runs, and role-dependent controls.
- All 48 existing cases across seven stages rendered after the update.
- Browser visual verification was unavailable in the execution environment.
