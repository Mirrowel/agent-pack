# Capture and performance

## Screenshots and files

- `screenshot <path>` takes the viewport. `--full` the whole page. `--annotate` draws numbered labels and prints a legend (`[37] @e37 button "Save"`). `--if-changed` saves only when the image changed; `--threshold 0.01` treats up to 1% changed pixels as unchanged. `--json` adds `changed` and `pixelChangeRatio`.
- `pdf <path>` saves the page as a PDF. `download '@e1' <path>` clicks and saves the download.
- Headless screenshots hide scrollbars. `--hide-scrollbars false` at launch keeps them.

## Video

```bash
agent-browser --session $S record start ./demo.webm --fps 30 --cursor --contact-sheet
agent-browser --session $S record stop
```

- Needs `ffmpeg` with the libvpx and libx264 encoders. `.webm` or `.mp4`.
- `--fps` takes 1 to 60, 30 by default.
- `--cursor` draws a pointer and a click ripple.
- `--contact-sheet` saves a PNG of the frames that changed. `--contact-sheet-threshold <0 to 1>` sets the sensitivity (default 0.05), at most 100 frames.
- `record start <path> <url>` navigates first. `record restart <path>` stops the current file and starts a new one.
- The video runs from `start` to `stop`: a set length needs a fixed wait between them (`wait 2000` is right here). `record stop --json`, as its own command and not in a `batch`, reports `frames` written and `capturedFrames`, the distinct frames Chrome delivered.

## Traces and profiles

- `trace start`, then `trace stop trace.json`: a Chrome DevTools trace.
- `profiler start [--categories "devtools.timeline,v8.execute"]`, then `profiler stop profile.json`: a trace of the CPU work in Chrome Trace Event format. Stop soon after the area of interest. Events pile up in memory, capped at five million.
- Open either in the DevTools Performance panel or at ui.perfetto.dev. Chromium browsers only.
- `inspect` opens DevTools for the session. `highlight '@e1'` outlines an element.

## Web Vitals

`vitals [url] [--json]` prints `ttfb`, `fcp`, `lcp`, `cls`, `inp` and a hydration summary. INP is `-` until an interaction happened.

## Responsive and dark

- `set viewport 390 844 [scale]`: kept for the session, no reset. Start a new session to go back.
- `set device "iPhone 14"`: viewport, user agent and touch after the next navigation.
- `set media dark|light [reduced-motion]`. A dark scheme for the whole session: `--color-scheme dark` at launch, or its variable `AGENT_BROWSER_COLOR_SCHEME` (`references/windows.md`).
- Read the size back with `eval 'innerWidth + "x" + innerHeight'`.

## Changed or not

- `diff snapshot` compares the accessibility tree with the last `snapshot` of that tab, taken with that snapshot's options, and each diff becomes the next baseline. A style-only change counts as no change. `--baseline <file>` compares against a saved snapshot instead. Options: `-s <selector>`, `-i`, `-c`, `-d <n>`, `-u`. Errors: `no_baseline` with no earlier snapshot, `baseline_mismatch` when an option differs from the baseline's, `file_not_found`.
- `diff screenshot --baseline before.png` prints the share of pixels that differ (`✗ 97.33% pixels differ`, `766459 different / 787488 total pixels`) and exits 0 whether or not they differ. A page toggled back to its first state came out at 0.04%. `-t <0-1>` sets the color distance threshold (default 0.1), `-o <file>` the diff image, `-s <selector>` and `--full` the scope.
- `diff url <a> <b>` loads both pages and prints a diff of their accessibility trees; the tab ends on the second. `--screenshot` compares screenshots too, `--wait-until <strategy>` sets the navigation wait.

## Live stream

`stream enable [--port <n>]`, `stream status --json`, `stream disable`: a WebSocket stream of the viewport that also takes remote input, for a remote preview. `agent-browser skills get core --ref streaming` has the protocol.
