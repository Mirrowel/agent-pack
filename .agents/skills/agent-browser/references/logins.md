# Logins, state, storage

The daily path is in the main file: the vault, `--restore`, 2FA, and the rule that state files and cookies are secrets. Everything here needs a session. `auth list`, `auth show` and `auth delete` too: without `--session` they run in the shared default session and start its daemon.

## Profiles

- A profile directory keeps everything (cookies, IndexedDB, service workers, cache): `--profile ~/.myapp-profile`. A Chrome profile by name: `--profile Default` (`agent-browser profiles` lists them).

## HTTP auth

- HTTP basic auth: `set credentials <user> <pass>`, for current and future tabs. Bearer token: `--headers '{"Authorization":"Bearer ..."}'` at launch, scoped to the URL's origin, or `set headers '<json>'` later.

## Cookies

- `cookies` lists the cookies of the current page's host, so `--domain` or `--url` has to match it. Errors never echo cookie values.
- `cookies set <name> <value> [--url <url>] [--domain <host>] [--path /] [--http-only] [--secure] [--same-site Strict]`, `cookies clear`. From DevTools "Copy as cURL": `cookies set --curl <file> [--domain <host>]`. The file may also be a JSON array of `{name, value}`, or cookie pairs without the `Cookie:` prefix (`a=1; b=2`). With the prefix, a cookie named `Cookie:` is created.

## Storage

- `storage local|session`, `storage local <key>`, `storage local set <key> <value>`, `storage local clear`.
- Stage a test before the first load: `batch "open" "cookies set session abc --domain localhost" "navigate <url>"`. Storage refuses on `about:blank`: navigate first, `storage local set`, then `reload`.

## Restore checks and portable state

- Check a restore: `--restore-check-url "**/dashboard"`, `--restore-check-text "Dashboard"` or `--restore-check-fn "<js>"`. A failed restore or check skips the auto-save; `--restore-save always|never|auto` changes that. `session info --json` shows the restore status and skipped origins.
- Portable state file: `state save ./auth.json`, `state load ./auth.json`, or `--state ./auth.json` at launch.
- `AGENT_BROWSER_ENCRYPTION_KEY` (64 hex characters) encrypts saved state. CI sessions stay short-lived, with nothing persisted.

## Login options

- `auth login --no-navigate` acts on the page already open, for a login reached through a click or a consent step (the origin must match). `--username-selector`, `--password-selector` and `--submit-selector` override the field lookup once.
- Copy a login out of the user's real Chrome: that Chrome has to run with `--remote-debugging-port=9222`, which hands full control of it to every local process, so trusted machines only. Then `agent-browser --auto-connect state save ./auth.json`.
