# Naming convention — draft for `td-registry/NAMING.md`

**Status:** Drafted in td-flow on 2026-05-18. Awaiting copy into `td-registry/NAMING.md`.
Once landed there, this scratch file gets deleted in a follow-up td-flow commit (fold-and-delete).

**How to land it:**

1. Open Claude Code in `~/projects/td-registry/`.
2. Copy the content under the `---` divider below into `~/projects/td-registry/NAMING.md`.
3. `git add NAMING.md && git commit -m "docs: add NAMING.md — portfolio naming convention"` + push.
4. Next session in td-flow: delete `.td/work/naming-convention.md` with a `chore: fold naming-convention scratch` commit.

The td-flow `CLAUDE.md § Cross-repo` already points to `$TD_REGISTRY/NAMING.md`, so it's expected to exist.

---

# Naming

How projects in this portfolio are named — repo slugs, friendly names, local directories, package names, deploy URLs. **One identity per project, used everywhere.** The deploy URL (domain/subdomain) is the only thing that lives separately — that's metadata in `SERVICES.md`.

The convention applies firmly to *new* repos. Existing repos get retrofitted opportunistically — pay the rename cost when you're touching the project anyway. GitHub auto-redirects keep old slugs working through the grace period.

## The single-identity rule

The same string is used for:

- GH repo slug (`mergodon/<name>`)
- Friendly name (the alias in `SERVICES.md` — same as the slug under this convention)
- Local clone directory (`~/projects/<name>/`)
- Package name (`package.json` `name`, `composer.json` `name`, etc.)
- Internal name in extension manifests, Cloudflare resource names, environment variable prefixes

The deploy URL (domain/subdomain) lives separately in `SERVICES.md`. Everything else points at the same string.

## Shape

Pick the smallest that fits:

```
<product>                  # standalone, no siblings yet
<family>-<role>            # within a multi-project family
<product>-<role>           # typed but no family yet
```

Don't stack `<family>-<product>-<role>` unless you genuinely need it. Usually one prefix or one suffix is enough.

## Rules

1. **kebab-case, lowercase, ASCII.** No `snake_case`, `dot.notation`, or `noseparator`. Why: standard for GitHub, URL-safe, predictable in shell autocomplete.
2. **Domain is not the identity.** No `.com` / `-com` / `_com` in the slug. The deploy URL is metadata in `SERVICES.md`. Why: domains can change; identity should not. Also avoids ambiguity for projects that span multiple domains.
3. **Tech stack is not the identity.** No `-wp`, `-php`, `-react`, `-py`. Why: tech rotates; identity persists across rewrites.
4. **Family prefix only when siblings exist.** Don't pre-create a family "just in case." When the second project in a world appears, rename the first to include the prefix. Cheap with GH redirects.
5. **Role suffix only when the role matters.** A standalone product doesn't need one. Add it when the project type is a salient identity (`tonalium-web` vs `tonalium-api`).

## Role suffix vocabulary

One word, one role. Pick from this set:

| Suffix | What it is | Typical deploy URL |
|---|---|---|
| `-web` | Marketing site, dashboard, full web app | `<product>.com` or `<product>.mergodon.com` |
| `-api` | HTTP service | `api.<product>.com` or `<product>-api.mergodon.com` |
| `-app` | Interactive product (when type is implied by context — SPA, desktop, etc.) | varies |
| `-ext` | Browser extension (Chrome / Firefox store) | Chrome Web Store |
| `-script` | Userscript (Tampermonkey / Violentmonkey) | hosted as raw `.user.js` |
| `-mobile` | Mobile app (iOS + Android, one repo if cross-platform) | App Store / Play Store |
| `-cli` | Command-line tool | npm / cargo / brew |
| `-worker` | Cloudflare Worker / serverless function | `workers.dev` until custom domain |
| `-pipeline` | Backend data flow / ETL service | internal |
| `-collector` | Edge ingestion (e.g., desktop client capturing data) | end-user machines |
| `-analytics` | Analytics / reporting tooling | internal |
| `-infra` | Deployment configs, IaC, scripts | not deployed; consumed by other repos |

Extend this list deliberately, not opportunistically. If a new role keeps coming up, add it. One-offs go in `-app` or a descriptive product name.

## Domain ↔ slug mapping

The slug root matches the domain root. Knowing the slug tells you where to look, and vice versa:

```
tonalium-web     → https://tonalium.com  (or tonalium.mergodon.com)
tonalium-api     → https://api.tonalium.com
tonalium-ext     → Chrome Web Store: "Tonalium"
tonalium-mobile  → App Store / Play Store: "Tonalium"
```

No translation step needed.

## Multi-platform products — example

When one product spans multiple surfaces, one family covers everything:

```
rgb-web              # dashboard at rgbtracker.com
rgb-api              # service at api.rgbtracker.com
rgb-ext              # Chrome Web Store extension
rgb-script           # Tampermonkey userscript
rgb-collector-macos  # desktop client (macOS)
rgb-collector-windows
rgb-pipeline         # backend ETL
rgb-analytics        # reporting
```

One identity. Every surface obvious from the slug.

## Renaming an existing repo

The retrofit steps:

1. `gh repo rename --repo mergodon/<old> <new>` (run from anywhere with auth).
2. `git remote set-url origin git@github.com:mergodon/<new>.git` (in the local clone).
3. `mv ~/projects/<old> ~/projects/<new>` (rename the local clone directory to match).
4. Update `SERVICES.md` in this repo — slug column.
5. Sweep the renamed repo's own docs (`README.md`, `.td/PROJECT.md`, `package.json` `name`, deployment configs) for old-slug references.
6. Sweep sibling repos' `.td/PROJECT.md § Cross-repo` for old-slug references.

GitHub auto-redirects external references through the grace period (~90 days for issues/PRs URLs, indefinite for clone URLs unless the slug is reused).

## Adoption status

These existing repos don't yet match the convention. Rename opportunistically when touching the project — not all at once.

**Clear targets (slug → recommended):**

| Current | Recommended | Notes |
|---|---|---|
| `mergodon/anzsco-tasmanvisa-com` | `mergodon/anzscofinder-web` | Sibling `anzscofinder-pipeline` already in family |
| `mergodon/webapp-tonalium-com` | `mergodon/tonalium-web` | |
| `mergodon/mergodoncom` | `mergodon/mergodon-web` | |
| `mergodon/app_pkrdudes_com` | `mergodon/pkrdudes-app` | snake → kebab + drop `-com` |
| `mergodon/cypruspokerbrisbane_web_cypruspokerbrisbane_com` | `mergodon/cypruspoker-web` | |
| `mergodon/web_otborond_com` | `mergodon/otborond-web` | |
| `mergodon/web_famcop_mergodon_com` | (decide: merge into `familycop` family?) | Identity overlap with `familycop` |
| `mergodon/karat.io` | `mergodon/karat` or `mergodon/karat-web` | |
| `mergodon/tasmanvisa-com-wp` | `mergodon/tasmanvisa-web` | Drop tech + domain suffixes |
| `mergodon/rgb_hand_auditor` | `mergodon/rgb-hand-auditor` | snake → kebab |
| `mergodon/rgb-ggbuddy` | `mergodon/rgb-script` | It's a Tampermonkey userscript |
| `mergodon/tdphp-rgbtracker-mainweb` | `mergodon/rgb-web` | Already friendly-named `rgb-webapp` — slug catches up |
| `mergodon/rgbtracker-pipeline` | `mergodon/rgb-pipeline` | Consolidate `rgbtracker-*` family into `rgb-*` |
| `mergodon/rgbtracker-collector-macos` | `mergodon/rgb-collector-macos` | Same consolidation |
| `mergodon/rgbtracker-collector-windows` | `mergodon/rgb-collector-windows` | Same |
| `mergodon/tdgeneric-mergodon-mainweb` | `mergodon/mergodon-web` | Template info → `.td/PROJECT.md`, not slug |
| `mergodon/tdgeneric-cypruspoker-mainweb` | `mergodon/cypruspoker-web` | |
| `mergodon/tdgeneric-shorevisa-mainweb` | `mergodon/shorevisa-web` | |
| `mergodon/tdgeneric-bernadettdoka-mainweb` | `mergodon/bernadettdoka-web` | |
| `mergodon/tdgeneric-rgbtracker-mainweb` | `mergodon/rgb-web` (if same as `tdphp-rgbtracker-mainweb`) | Possible duplicate — resolve identity |

**Need a friendly-name decision:**

- `mergodon/fwv2` — what does `fw` stand for?
- `mergodon/tdgeneric-mergodon-appslikeyouweb` → `appslikeyou-web`?
- `mergodon/tdgeneric-mergodon-clientsweb` → `mergodon-clients-web`?
- `mergodon/tdgeneric-mergodon-dudemailsweb` → `dudemails-web`?
- `mergodon/tdgeneric-matevisky-otborondweb` → `otborond-web` (duplicate of `web_otborond_com`?)

As renames land, cross them off this list (or remove the row entirely). The convention itself stays stable; only the adoption table evolves.
