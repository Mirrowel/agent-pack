# WebGPU pages

Without setup a WebGPU canvas (three.js `WebGPURenderer`, Babylon.js, raw WebGPU) screenshots black in headless Chrome, with no error anywhere.

- Launch with `--webgpu` (or `AGENT_BROWSER_WEBGPU=1`).
- Windows and Linux: headless screenshots of a WebGPU canvas stay black even then, while rendering itself works. `--headed` gives real pixels. On a server, `--headed` starts Xvfb by itself.
- Linux container: `apt-get install -y libvulkan1 mesa-vulkan-drivers`. SwiftShader does the rendering, so no GPU is needed. Heavy scenes render at single-digit fps.
- `navigator.gpu` exists only in secure contexts: `https://`, `http://localhost`, `file://`.
- A screenshot too early is black as well: the first frame lands asynchronously. Wait for the app's own signal (`wait --fn "window.__appReady === true"`), or for two animation frames: `eval "new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)))"`.
- three.js falls back to WebGL2 with no word when it gets no adapter. Check: `eval "document.querySelector('canvas').getContext('webgpu') ? 'webgpu' : 'webgl-fallback'"`.
- A pixel check without a screenshot: render to an offscreen texture and read it back with `copyTextureToBuffer`. `drawImage(webgpuCanvas, ...)` reads transparent black on Windows.
- `agent-browser doctor --webgpu` tests the render and the screenshot stages separately.
