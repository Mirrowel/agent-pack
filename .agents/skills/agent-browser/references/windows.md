# Windows, the rest

Everything here was measured on agent-browser 0.44.0 with PowerShell 7.

## Launch options that need a value

Plain-word options ride on the detached launch: `'--restore'` and `'--color-scheme','dark'` both gave exit code 0. A value with quotes or spaces goes in its `AGENT_BROWSER_*` variable, set in the same call as the launch, because each shell call may be a new shell. The variable for `--color-scheme` is `AGENT_BROWSER_COLOR_SCHEME`:

```powershell
$env:AGENT_BROWSER_COLOR_SCHEME = 'dark'
$p = Start-Process agent-browser.cmd -ArgumentList '--session','flow','open' -WindowStyle Hidden -PassThru
$p.WaitForExit(20000)
$p.ExitCode
```

The docs list 67 such variables, one per launch option. `AGENT_BROWSER_STATE`, `AGENT_BROWSER_PROFILE`, `AGENT_BROWSER_CDP`, `AGENT_BROWSER_RESTORE` and `AGENT_BROWSER_HEADED` are examples.

## A launch that returns what it printed

The detached launch in the main file prints `True` and the exit code, nothing else. When the launch's own lines matter, wrap it in `cmd.exe`, which passes real file handles and no pipe:

```powershell
$o = "$env:TEMP\ab-out.txt"
$p = Start-Process cmd.exe -ArgumentList '/c', "agent-browser --session flow open http://localhost:3000/ > `"$o`" 2>&1" -WindowStyle Hidden -PassThru
$null = $p.WaitForExit(20000)
$p.ExitCode
Get-Content $o
```

Good target: exit code 0 and the launch's lines in the file. Bad target: exit code 1 and `✗ Navigation failed: ...` in the file. Quote an argument that holds `&`, `%` or a space for `cmd.exe` (`"http://x/?a=1&b=2"`). `%NAME%`, where `NAME` is an environment variable, is expanded even inside quotes. In a detached launch a bare `&` cut a URL (`?x=1&y=2` opened as `?x=1`, exit code 1), and a bare space cut it with exit code 0 (`?q=a b` opened as `?q=a`).

## Base64

`eval -b` works through either name, with `$b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($js))`. It stops at the command-line length: `cmd.exe` allows 8,191 characters, a process 32,767. That is about 6,000 characters of script through `agent-browser.cmd` and 24,000 through the plain name. Through `agent-browser.cmd` the failure prints `The command line is too long.`. Through the plain name the process fails to start with `StandardOutputEncoding is only supported when standard output is redirected.`, a message that names the wrong cause.

Above that, stdin: a 108,940-character script went through.

## Why a launch hangs

A daemon keeps a copy of the shell call's output pipe until its session closes. The call's three standard handles are pipes, and all three are inheritable.

- `Start-Process agent-browser.cmd` with no redirection starts the process through the shell, which passes no pipe. Safe with the session left open.
- `Start-Process` with `-RedirectStandardOutput` or `-RedirectStandardError` starts the child with handle inheritance on, so the daemon receives a copy of the call's pipe. It hung with the session left open.
- A direct launch with `> file 2> file` hung the same way: the inheritable pipe is handed over even when the standard handles are files.
- Captured output (`$x = ...`, `| Out-String`) and discarded output (`*> $null`, `| Out-Null`) hung as well, under load in the case of the discarded form.
- Clearing the inherit flag on the three handles around the launch also prevented it.

In PowerShell, a launch that stays open is safe in two forms: the main file's detached launch without redirection, and the `cmd.exe` wrapper above. In bash the redirect form works: a launch with its output captured inside a Git Bash script returned.

## Git Bash

- Git Bash rewrites arguments that begin with `/` into Windows paths (`pushstate /route`, `--path /`). Put `MSYS_NO_PATHCONV=1` in front of the call, or pass a full URL.
- From PowerShell, run a bash script by path: `& 'C:\Program Files\Git\bin\bash.exe' script.sh`. A bare `bash` may be WSL's.
