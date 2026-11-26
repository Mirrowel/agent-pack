# Electron apps

Any Electron app (VS Code, Slack, Discord, Figma, Notion, Spotify) speaks CDP. Launch it with `--remote-debugging-port=<n>`, connect, then run the usual loop.

## Launch

The flag has to be present at launch: quit a running app first.

```bash
# macOS
open -a "Slack" --args --remote-debugging-port=9222
# Linux
code --remote-debugging-port=9223
```

```powershell
# Windows
& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" --remote-debugging-port=9223
```

The port hands full control of the app to every local process. Trusted machines only.

## Connect

```bash
agent-browser --session app connect 9222
agent-browser --session app snapshot -i
```

- `connect` stays attached until `close`. Later commands need no flag. Or `--cdp 9222` on each command. Or `--auto-connect` for the first Chromium-based app found.
- An app still starting has no port yet. `connect` and `--cdp` wait two seconds for it, then fail.
- One session per app: `--session slack`, `--session vscode`.

## Windows and webviews

- `tab` lists every target: windows and `<webview>` elements, each with its URL. Switch with `tab t2`. Refs belong to the active target, so snapshot after a switch.
- Elements missing from the snapshot usually sit in another target. `tab`, switch, snapshot.

## Quirks

- The color scheme over CDP can default to light: `--color-scheme dark` or `AGENT_BROWSER_COLOR_SCHEME=dark`.
- An input that ignores `fill`: `focus '@e1'`, then `keyboard type "text"`. A custom input: `keyboard inserttext "text"`.
- `Connection refused`: the app was not launched with the flag, the port is taken, or the app needs a few more seconds.
