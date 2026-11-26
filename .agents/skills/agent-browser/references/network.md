# Network

## Routes

A route applies to the loads after it. To affect the first load, stage it on a blank launch:

```bash
agent-browser --session $S batch "open" "network route *api/search* --abort" "cookies set --curl cookies.curl --domain localhost" "navigate http://localhost:3000/"
```

Global flags (`--init-script`, `--enable`) go on the outer `agent-browser` call, never inside an item.

| Need | Command |
|---|---|
| block | `network route "<glob>" --abort` |
| only some resource types | `... --abort --resource-type script` or `--resource-type image,font` |
| mock a response | `network route "<glob>" --body '{"ok":true}'` |
| mock a cross-origin API for the page | `... --body '<json>' --allow-origin https://app.example.com` |
| remove one or all | `network unroute [url]` |
| server-rendered HTML only | `network route "*" --abort --resource-type script` |

`open` with no URL launches without navigating, so routes, cookies and init scripts are in place for the first real navigation.

A blocked request is aborted before any response, so it still shows in `network requests`, without a status (`[8924.7] GET http://127.0.0.1:8765/missing.png (Image)` next to the earlier `404` line). `network requests --clear` empties the list.

## Requests

- `network requests [--clear] [--filter api]` lists the tracked requests.
- `network request <requestId>` prints one request and its response in full, body included.

## HAR

`network har start [--content all|none]`, later `network har stop out.har`. Text response bodies are embedded by default; `--content all` adds binary ones as base64; `--content none` keeps sizes and headers only.

- A HAR holds every request, auth headers included. Redact before sharing.
- When `har stop` fails, the capture stays available: fix the path and stop again. `no_har_recording` means no capture is active, for example after a daemon restart.
- `har stop` is unavailable while `--capture flow` is on: `flow save` then.
