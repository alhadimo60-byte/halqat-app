CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  username TEXT NOT NULL UNIQUE COLLATE NOCASE,
  password_salt TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'user')),
  phone TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

CREATE TABLE IF NOT EXISTS sessions (
  token_hash TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  expires_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS sessions_expiry_idx ON sessions (expires_at);

CREATE TABLE IF NOT EXISTS login_attempts (
  ip_address TEXT PRIMARY KEY,
  window_started_at INTEGER NOT NULL,
  attempts INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS app_data (
  data_key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  revision INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS app_meta (
  meta_key TEXT PRIMARY KEY,
  meta_value TEXT NOT NULL
);
