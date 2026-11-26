# Shell

Windows, PowerShell 7. Each rule was reproduced on this machine.

- `$env:X = ""` deletes the variable, so a dotenv loader refills it from `.env`. To unset: `Remove-Item Env:X`. To pass "none": the program's own flag for it, never an empty string.
- Python reads and writes pipes in the ANSI code page (cp1251 here). Set `PYTHONUTF8=1` for any piped Python.
- Text for another program goes through a file: `git commit -F`, `gh --body-file`, `gh api -F body=@file`. Inside double quotes, a backtick is an escape character and `$` expands.
- After a native program in a script, check `$LASTEXITCODE` or chain with `&&`. A failure does not stop the script, and its stderr can be JSON that looks like output.
- Call `pwsh`, never `powershell`. That is Windows PowerShell 5.1: it reads BOM-less UTF-8 files as the ANSI code page, writes a BOM with `-Encoding UTF8`, and writes UTF-16 by default.
