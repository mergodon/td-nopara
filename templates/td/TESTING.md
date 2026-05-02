# How to test this project

This file is the single source for the pre-ship checklist. `/td-ship` runs it. The pre-commit hook runs the **Test command** below.

## Test command

```
{{test_command}}
```

## Dev server

```
{{dev_command}}
```

Local URL: {{local_url}}

## Pre-ship checklist

<!-- /td-ship walks this list before commit. Failure = no commit, no push. -->

- [ ] `{{test_command}}` passes
- [ ] Dev server starts without errors
- [ ] Manual check: {{manual_check_or_none}}

## How to verify in browser

{{browser_steps_or_none}}

## How to verify via curl / API

{{curl_steps_or_none}}

## Notes

<!-- Project-specific gotchas: flaky tests, env-only checks, things to remember. Keep short. -->

(none)
