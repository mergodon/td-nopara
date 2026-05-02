# Testing

The two sections below are locked. Add values, don't add or rename sections. CLAUDE.md routes "this is how local testing works" → § Local testing, and "this is how live testing works" → § Live testing.

The pre-commit hook runs `Test command` from § Local testing. Phase 3 (TEST) runs the Pre-ship checklist. Phase 5 (VALIDATE) runs the Post-ship validation; if every value here is "none", phase 5 is auto-skipped.

## Local testing

- Test command:    {{test_command}}
- Dev server:      {{dev_command}}
- Local URL:       {{local_url}}
- Pre-ship checklist:
  - [ ] {{test_command}} passes
  - [ ] dev server starts without errors
  - [ ] {{manual_local_check_or_none}}

## Live testing

- Live URL:        {{live_url_or_none}}
- Deploy:          {{deploy_command_or_auto}}
- Smoke command:   {{smoke_command_or_none}}
- Logs:            {{logs_command_or_url_or_none}}
- Post-ship validation:
  - [ ] {{post_ship_check_1_or_none}}
  - [ ] {{post_ship_check_2_or_none}}

## Notes

<!-- Project-specific gotchas: flaky tests, env-only checks, things to remember. Keep short. -->

(none)
