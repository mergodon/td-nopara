# Live environment

Non-secret details Claude needs to access the live thing. Secrets stay in `.env` (gitignored).

## Repo

- GitHub: {{github_url}}
- Default branch: main
- Push policy: direct to `origin/main` (no PRs)

## Live

- URL: {{live_url}}
- Deploy: {{deploy_command_or_auto}}
- Logs: {{logs_command_or_url}}

## Dashboards

- {{dashboard_name}}: {{dashboard_url}}

## Database

- Provider: {{db_provider_or_none}}
- Console: {{db_console_or_none}}
- Connection string in: `.env` → `{{db_env_var_or_none}}`

## Secrets

<!-- Names only. Real values in .env (gitignored). Keep this in sync with .env.example. -->

- {{env_var_1}}
- {{env_var_2}}

## SSH / remote access

{{ssh_or_none}}
