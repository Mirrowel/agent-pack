#!/usr/bin/env bash
# Boot-time installer for the agent-browser extension. The agent's pack
# installer runs this in the background right after the pack is fetched and
# relays two kinds of lines into the action log: "EXT-SUMMARY:" (the result
# line) and workflow commands such as "::warning::". Everything else stays in
# the extension log for debugging.
set -uo pipefail

warn()    { echo "::warning::agent-browser: $*"; }
summary() { echo "EXT-SUMMARY: $*"; }
start=$(date +%s)

# Chrome's first launch reads its install tree from disk: about 450 MB, which
# takes 2.7 to 5.1 seconds for the binary alone on a slow runner and turns the
# launch check below into an 8 to 9 second wait. The read happens in the
# background now, beside the network-bound npm install, so the files are in
# the page cache by the time the check runs. Failure is irrelevant: a launch
# that still has to read the disk just pays what it paid before.
warm_browser() {
  local p resolved
  for p in google-chrome google-chrome-stable chromium chromium-browser chrome; do
    resolved="$(command -v "$p" 2>/dev/null)" || continue
    resolved="$(readlink -f "$resolved" 2>/dev/null || printf '%s' "$resolved")"
    case "$resolved" in
      /opt/*) find "$(dirname "$resolved")" -type f -exec cat {} + >/dev/null 2>&1 & ;;
      *) cat "$resolved" >/dev/null 2>&1 & ;;
    esac
    return 0
  done
}
warm_browser

# --- CLI -------------------------------------------------------------------
npm_log="$(mktemp)"
if ! npm install -g agent-browser --ignore-scripts=false --loglevel=warn >"$npm_log" 2>&1; then
  warn "npm install failed"
  sed -n '1,40p' "$npm_log"
  summary "npm install failed"
  exit 1
fi
t_npm=$(date +%s)

# Blocked install scripts and engine problems must never pass silently. Plain
# npm warnings (deprecations and the like) are counted, not annotated.
blocked="$(grep -nEi 'ignored|skipped|EBADENGINE|npm error' "$npm_log" | head -n 20 || true)"
if [ -n "$blocked" ]; then
  warn "npm reported blocked or failed steps during install:"
  printf '%s\n' "$blocked" | sed 's/^/  /'
fi
warn_count="$(grep -ci 'npm warn' "$npm_log" || true)"
first_warn="$(grep -i 'npm warn' "$npm_log" | head -n 1 || true)"

if ! command -v agent-browser >/dev/null 2>&1; then
  warn "agent-browser is not on PATH after install"
  summary "not on PATH after install"
  exit 1
fi
version="$(agent-browser --version 2>/dev/null | head -n 1 | tr -d '\r')"

# --- browser ---------------------------------------------------------------
chrome=""
for c in google-chrome google-chrome-stable chromium chromium-browser chrome; do
  if p="$(command -v "$c" 2>/dev/null)"; then chrome="system $c ($p)"; break; fi
done
if [ -z "$chrome" ] && [ -n "${AGENT_BROWSER_EXECUTABLE_PATH:-}" ] && [ -x "${AGENT_BROWSER_EXECUTABLE_PATH}" ]; then
  chrome="env (${AGENT_BROWSER_EXECUTABLE_PATH})"
fi

smoke() {
  timeout 90 agent-browser --session ext-bootcheck batch "open about:blank" "get url" "close" >"$ab_log" 2>&1
}
ab_log="$(mktemp)"

if [ -z "$chrome" ]; then
  summary "no system Chrome found, downloading one with agent-browser install"
  if ! agent-browser install >>"$ab_log" 2>&1; then
    warn "agent-browser install failed"
    sed -n '1,40p' "$ab_log"
    summary "browser download failed"
    exit 1
  fi
  chrome="downloaded by agent-browser install"
fi

if ! smoke; then
  # A launch that fails usually means missing system libraries.
  warn "first launch check failed, retrying once after agent-browser install --with-deps"
  if ! agent-browser install --with-deps >>"$ab_log" 2>&1; then
    warn "agent-browser install --with-deps failed"
  fi
  if ! smoke; then
    warn "browser does not launch; the agent-browser skill will not work in this run"
    tail -n 25 "$ab_log" | sed 's/^/  /'
    summary "agent-browser ${version:-?} | chrome: ${chrome} | launch: FAILED"
    exit 1
  fi
  chrome="${chrome}, system deps installed"
fi

# Where the time went: a slow npm registry and a slow first launch need
# different fixes, and the summary is the only part that reaches the log.
timings="npm install $(( t_npm - start ))s, browser check $(( $(date +%s) - t_npm ))s"

if [ "${warn_count:-0}" != "0" ]; then
  summary "agent-browser ${version:-?} | chrome: ${chrome} | launch: ok | ${timings} | npm warnings: ${warn_count} (first: ${first_warn})"
else
  summary "agent-browser ${version:-?} | chrome: ${chrome} | launch: ok | ${timings}"
fi
summary "done in $(( $(date +%s) - start ))s"
exit 0
