# CI and Linux

## Install

```bash
npm i -g agent-browser
agent-browser install --with-deps
```

`install` downloads Chrome for Testing. `--with-deps` adds its system libraries on Linux through the package manager, as root (`sudo` when not root).

Where Chrome already exists, skip `install`. At launch the CLI uses its own Chrome first, then a system Chrome, then the Puppeteer and Playwright caches. `AGENT_BROWSER_EXECUTABLE_PATH` names one. ARM64 Linux has no Chrome for Testing build: use the distribution's `chromium` with that variable.

## A workflow step

- A whole check in one step or one shell call, ending in `close`. A step that starts the browser and keeps it open may hold the step's output open.
- Assert with `--json` and the exit code. Any command exits 1 on failure, and so does `batch` when an item failed.
- Screenshots: `screenshot <path>`, uploaded as artifacts. Video for evidence: `capture.md`.
- Short-lived sessions. No `--restore` in CI, nothing persisted.
- `--headed` on a server without a display starts Xvfb by itself when `DISPLAY` is unset and Xvfb is installed (`apt-get install -y xvfb`, `AGENT_BROWSER_NO_XVFB=1` to opt out). Needed for screenshots of WebGPU canvases. Never wrap the CLI in `xvfb-run`: the display goes away when the CLI exits while the browser keeps running.

## Proxy

- `--proxy <url>`, or `HTTP_PROXY` and `HTTPS_PROXY`. SOCKS: `ALL_PROXY`. Bypass: `--proxy-bypass "localhost,*.internal.com"` or `NO_PROXY`.
- Credentials in the URL: `http://user:pass@proxy.example.com:8080`, percent-encoded once (`p@ss` is `p%40ss`, a literal `%` is `%25`).
- An SSL-inspecting proxy: trust its CA with `--ca-cert <path>`. For the browser this works on locally launched Linux Chromium only (`install --with-deps` provides the needed `certutil`; otherwise `libnss3-tools` on Debian and Ubuntu, `nss-tools` on RPM systems). `--use-system-ca` switches the CLI's own requests (`read`, `install`, `upgrade`, `doctor`) to the OS trust store. `--ignore-https-errors` disables verification: testing only.
- Browser trust options do not reach a remote browser (`--cdp`, `--auto-connect`, a provider) and do not work with `--profile`, on macOS, or on Windows.

## WebGPU in a container

`apt-get install -y libvulkan1 mesa-vulkan-drivers`, plus `--webgpu` at launch. SwiftShader does the rendering, so no GPU is needed. `webgpu.md` has the rest.
