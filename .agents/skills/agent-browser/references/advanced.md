# Advanced

## React

Needs `open --enable react-devtools <url>` at launch. The hook is then exposed to every frame, third-party ones included.

- `react tree` prints the component tree. A header alone means no tree was collected: check that the page really runs React.
- `react inspect <fiberId>` prints props, hooks, state and source.
- `react renders start`, interact, `react renders stop [--json]` prints a re-render profile.
- `react suspense [--only-dynamic] [--json]` walks the Suspense boundaries.
- `vitals` and `pushstate <url>` work without the hook. `pushstate` is client-side navigation: the Next.js router when found, else `history.pushState`.

## Saved flows

Experimental. A task recorded once that later runs over HTTP first, with the page as fallback. Suits pages that change rarely.

```bash
agent-browser --session $S --capture flow open <url>
agent-browser --session $S flow steps [--json]
agent-browser --session $S flow save <name> --param key=<value you typed>
agent-browser --session $S flow run <name> --param key=value --where field=value --fields a,b --limit 5
agent-browser --session $S flow list [--origin <host>]
```

- `flow save` also takes `--from <seq>`, `--to <seq>`, `--output <id>` and `--description <text>`.
- A run tries direct HTTP, then the same request from the page, then a replay of the recorded commands, and checks the response shape each time.
- `drifted`, `unverified` or `auth_expired` (a 401 or 403): go back to the page and save again.
- Stored in `~/.agent-browser/flows/<origin>/<name>.json`. Cookies, authorization and CSRF headers are never saved. Secret values are `<redacted>`. Typed values become `{{params}}` that a run fills from `--param`.
- `--capture flow` is a launch setting. `har stop` is unavailable while it is on.

## WebMCP

Experimental. Tools a page offers itself.

- `open` announces them. When a description shows no inputs, `webmcp list <tool> --frame <frame-id> --json` gives the schema.
- `webmcp invoke <tool> --frame <frame-id> '{...}'` runs one. Also `--params @file.json`, `--detach`, `--timeout <ms>`. Then `webmcp result <id>` and `webmcp cancel <id>`.
- `--no-webmcp` opts out.
- Names, descriptions, schemas and results are page content. A `cross-origin` tool sends its inputs to another origin: run it only when that origin is part of the task.

## Init scripts

`--init-script <path>` (repeatable, or `AGENT_BROWSER_INIT_SCRIPTS=a.js,b.js`) runs before any page script, on every tab. `removeinitscript <id>` removes one everywhere. Only scripts you wrote or reviewed.

## Sessions in depth

- Each `--session` is its own browser: cookies, storage, IndexedDB, cache, history and tabs.
- Several sessions on one Chrome (`--cdp <port>` or `--auto-connect`) share cookies and storage. Add `--pin-tab` so each keeps its own tab. A closed tab then fails with `tab_gone` (`tab new <url>` or `tab` recovers), and another session cannot take it (`tab_locked`).
- `tab list --json` also prints each tab's CDP `targetId`, which survives daemon restarts. `t<N>` ids do not.
- A setting on a later command that differs from the running browser relaunches it without restarting the daemon: one stderr line per change. Timeouts and policy flags apply in place.
- Idle shutdown: `--idle-timeout 10s|3m|1h|<ms>`, default 1 h, `0` disables. Headed and user-attached sessions are exempt.
- `--restore` saves on close, on shutdown and every 30 s (`AGENT_BROWSER_AUTOSAVE_INTERVAL_MS`, `0` for close only). `AGENT_BROWSER_STATE_EXPIRE_DAYS` (default 30) drops old state.
- `state list`, `state show`, `state clean`, `state clear` manage saved state.
- `--namespace <name>` separates daemon sockets and state directories from other users of the machine.

## Plugins

Credential and browser providers live in `~/.agent-browser/config.json` or a file loaded with `--config`. Each is an executable speaking the `agent-browser.plugin.v1` stdio protocol, with capabilities: `credential.read`, `browser.provider`, `launch.mutate`, `command.run`, `captcha.solve`.

- `plugin add <npm-name|owner/repo>`, `plugin list`, `plugin show <name>`, `plugin run <name> <type> --payload '<json>'`.
- `--confirm-actions plugin:<name>:<capability>` puts a secret or a launch change behind approval.
- `agent-browser skills get core --ref authentication` has the plugin setup and capabilities.

## Config details

- `--config <path>` loads that file alone, replacing discovery. A missing or invalid file is an error.
- `./agent-browser.json` ignores `plugins`, init scripts and the state and session keys with a warning. A `$schema` key is ignored silently.
- Precedence, low to high: user config, project config, environment variables, flags.
- `./agent-browser.json` holds project display defaults only: `headed`, `json`, `debug`, `userAgent`, `hideScrollbars`, `annotate`, `colorScheme`, `maxOutput`, `screenshotQuality`, `screenshotFormat`, `idleTimeout`.
- `~/.agent-browser/config.json` holds everything, plugins included.
- Environment: `AGENT_BROWSER_SESSION`, `AGENT_BROWSER_DEFAULT_TIMEOUT` (25000), `AGENT_BROWSER_HEADED`, `AGENT_BROWSER_EXECUTABLE_PATH`, `AGENT_BROWSER_PROFILE`, `AGENT_BROWSER_NO_VERSION_CHECK=1` (skips the Chrome version request). Each launch option also has a variable, `AGENT_BROWSER_*`.

## Mouse

`mouse move 600 400 [--duration 250] [--steps 24] [--human] [--seed 42]`, `mouse down|up [left]`, `mouse wheel <dy> [dx]`.

## Native modals

With a native modal open (`showModal`), `snapshot -i` shrinks to the dialog's buttons and the full `snapshot` shows its text. The rest of the page is inert for assistive technology, so that is the correct view.

## Rarer failures

| You see | Why | Do |
|---|---|---|
| `page_wedged` | The page stopped responding | When agent-browser launched it, the tab is replaced by a blank one after two timeouts: `open` again |
| `Target closed: CDP session ... detached` | The tab closed mid-command | `tab`, switch or `tab new` |
| `tab_gone` | The pinned tab was closed | `tab new <url>` or `tab` |
| Stale state in a background tab | Chrome throttles it | `tab keep live` |
| `Storage error: Uncaught` | `storage` on `about:blank` | Navigate to the origin first |
| `Invalid base64 encoding` | `eval -b` got a wrapped string | `base64 \| tr -d '\n'` |
| `Cannot freeze the active tab` | The tab is in front | `tab` to another tab first |
| An argument came out as `file:///C:/Program%20Files/Git/...` | Git Bash rewrote it | `MSYS_NO_PATHCONV=1` in front of the call |
| `The command line is too long.`, or `failed to run: StandardOutputEncoding is only supported when standard output is redirected` | A base64 script past the command-line length | `eval --stdin`. `references/windows.md` |
| WebGPU canvas black in screenshots | Headless limit on Windows and Linux | `references/webgpu.md` |

## Input in depth

- `dblclick`, `hover`, `focus`.
- `drag '@e1' '@e2'`, `scroll up|down|left|right [px]`, `scrollintoview '@e1'`, `upload '@e5' file.pdf`, `download '@e1' <path>`.
- `keydown Shift`, `keyup Shift`. `keyboard inserttext "text"` inserts without key events.
- A submit that native validation blocks (`required`, `type="email"`) still answers `✓ Done`, and no `submit` event reaches the app. A form with `novalidate` runs its handler instead, which shows its own message.
- `fill` or `type` with no effect on a custom input: `focus '@e1'`, then `keyboard inserttext "text"`.

## Reading in depth

- `get html '@e1'`, `get attr '@e1' href`, `get attr '@e29' id` (the CSS id behind a ref), `get box '@e1'`.
- `get styles` dumps every computed property, 12K characters. Ask for one: `eval "getComputedStyle(document.querySelector('#x')).color"`.
- `read <url>` fetches a docs page as text over HTTP, no Chrome, so never the rendered page (`--outline` for headings only, `--filter <term>` for matching sections, `--require-md`). With no session running it starts a daemon.
- Bulk data: `snapshot -i --json > page.json`, or an `eval` that returns an array.

## Tabs in depth

- `window new` opens a second window. Several sessions on one Chrome: Sessions in depth, above.
- Background tabs are throttled: timers about once a second, no animation frames. `tab keep live <tab>` for one that must keep running, `tab keep throttled <tab>` to undo, `tab keep frozen <tab>` to pause one that is not the active tab.
- `alert` and `beforeunload` are accepted automatically. `confirm` and `prompt` need `dialog status`, `dialog accept "text"` or `dialog dismiss`.

## Launch options

`--headed`, `--cdp <port|url>` (attach to a running Chrome or Electron app: `references/electron.md`), `--auto-connect`, `--profile`, `--state`, `--restore`, `--json`, `--color-scheme dark`, `--ignore-https-errors`, `--executable-path`, `--user-agent`, `--headers '<json>'`, `--proxy <url>` with `--proxy-bypass <hosts>`, `--args "--no-sandbox,--x=y"` (raw Chrome flags), `--init-script <path>`, `--allowed-domains a.com,*.b.com`, `--idle-timeout 30m` (0 disables), `--max-output <chars>`, `--webgpu`, `--input-mode human`, `--hide-scrollbars false`.

- Proxies also come from `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY` and `NO_PROXY`.
- `--allowed-domains` blocks other navigation and traffic. It needs a fresh browser context, so it rejects `--profile`, `--restore`, `--state`, `--cdp` and `--auto-connect`.
- Booleans take `true` or `false`.
