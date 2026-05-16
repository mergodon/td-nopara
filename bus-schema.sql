-- td-bus — cross-project messaging schema.
--
-- Lives on a Turso/libsql cloud DB. Each developer provisions their own DB
-- (turso db create td-bus-<you>), runs this schema once, then any project on
-- their machine registered via /td-bus-init can send/receive messages.
--
-- Idempotent: every CREATE uses IF NOT EXISTS. Re-running this against an
-- existing bus is safe and acts as a forward-only migration when columns get
-- added (use ALTER TABLE ... ADD COLUMN IF NOT EXISTS for future changes).

-- ──────────────────────────────────────────────────────────────────────────
-- apps — who's on the bus.
--
-- Registration is mandatory: every from_app / to_app on a message must exist
-- here (enforced by FK). Onboarding happens once per project via /td-bus-init.
--
-- `name` is the canonical handle (lowercase kebab, matches project folder
-- basename by convention). `description` is the one-liner shown in inbox
-- listings; `long_description` is the optional "about" page surfaced by
-- `td-bus apps show <name>`.
-- ──────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS apps (
  name             TEXT PRIMARY KEY,
  description      TEXT NOT NULL,
  long_description TEXT,
  repo_path        TEXT,
  contact          TEXT,
  registered_at    TEXT NOT NULL DEFAULT (datetime('now')),
  last_seen_at     TEXT
);

-- ──────────────────────────────────────────────────────────────────────────
-- messages — the unified content table.
--
-- One row per CR / note / bug / etc. The `type` column distinguishes intent;
-- the bus doesn't enforce per-type lifecycle (the CLI hints, the convention
-- documents). Status enum is shared across types: open | accepted | shipped
-- | rejected | withdrawn | done.
--
-- `id` is human-readable: '<from_app>-<TYPE>-<n>' where n is per-(from_app,
-- type) auto-incremented at INSERT by the CLI (not by the DB — keeps the
-- counter logic in one place).
-- ──────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS messages (
  id          TEXT PRIMARY KEY,
  from_app    TEXT NOT NULL REFERENCES apps(name),
  to_app      TEXT NOT NULL REFERENCES apps(name),
  type        TEXT NOT NULL CHECK (type IN ('cr', 'note', 'bug')),
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'open'
              CHECK (status IN ('open', 'accepted', 'shipped', 'rejected', 'withdrawn', 'done')),
  shipped_in  TEXT,
  created_at  TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ──────────────────────────────────────────────────────────────────────────
-- replies — append-only discussion thread on each message.
--
-- Either party adds entries via `td-bus reply <id>`. Reads chronologically.
-- Deleted with the parent message via ON DELETE CASCADE.
-- ──────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS replies (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  message_id  TEXT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  from_app    TEXT NOT NULL,
  body        TEXT NOT NULL,
  created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Hot paths:
--   inbox  → WHERE to_app = ? AND status != 'done'
--   outbox → WHERE from_app = ? AND status != 'done'
--   thread → WHERE message_id = ? ORDER BY created_at
CREATE INDEX IF NOT EXISTS idx_messages_to_status   ON messages(to_app, status);
CREATE INDEX IF NOT EXISTS idx_messages_from_status ON messages(from_app, status);
CREATE INDEX IF NOT EXISTS idx_replies_msg          ON replies(message_id, created_at);
