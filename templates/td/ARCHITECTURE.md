# Architecture

Project-specific rationale. NOT a system diagram — the code is the structure, and any reader can map it in 5 minutes. This doc captures **why the system is shaped the way it is**: the decisions that aren't obvious from reading code, the surprises that mislead new readers, the parts that are load-bearing under load.

The bar: would this content be useful to a future maintainer (or future-you after 2 months of context-switch) trying to decide whether a proposed change is safe? If yes, keep it. If it's derivable from code or `git log`, cut it.

Each section is optional. Delete the ones that don't apply for this project — empty sections are noise, not structure.

## System shape

One paragraph: what runs where. The 10-second mental model someone needs before reading any code.

Example: "Next.js app on Vercel → Supabase (Postgres + auth + storage). Cron via Vercel Cron Jobs. Background image-processing offloaded to a Cloudflare Worker because Vercel function timeouts couldn't accommodate large PDFs."

## Key components

Top-level modules / services / domains, one line each. Skip if the project is small enough that listing them duplicates the directory tree.

- **<module>** — <one-line purpose>
- **<module>** — <one-line purpose>

## Important decisions

The load-bearing whys. Trade-offs you'd defend in a review. The choices a contributor needs to understand before proposing alternatives — because changing them quietly will break invariants that aren't obvious from the code.

Format: short heading, one or two sentences. Don't write essays here — link to a commit or an issue if the full story matters.

### <Decision in plain language>

<Why. What the trade-off was. What got rejected and why.>

### <Decision in plain language>

<Why. What the trade-off was. What got rejected and why.>

## What's load-bearing

Things that would silently break the system if changed casually. The "if you touch X, also update Y" relationships that the code doesn't make obvious.

- **<file or component>** — <what depends on it; what care to take>
- **<file or component>** — <what depends on it; what care to take>

## Surprises

Counterintuitive choices, things that new readers misread, places where the code looks one way but actually does another. The "this looks redundant but it isn't because..." reservoirs.

### <Surprise heading>

<Why it looks one way, what it actually does, why the obvious-looking alternative was wrong.>

## When to update this doc

- After a significant architectural shift (new service, removed dependency, rewritten module).
- At `/td-close` — the doc hygiene pass prompts review against current state.
- After `/td-incident` if a fire surfaced something architecturally load-bearing that wasn't documented (added to **What's load-bearing** or **Surprises**).
- When a "new idea" risks breaking an existing decision — add it to **Important decisions** before the idea ships, so future you remembers why it was decided that way.
- NOT every commit. NOT every refactor. NOT speculation about how the system might evolve.

Architecture rationale dies first when context-switches stretch — that's exactly when this file earns its keep.
