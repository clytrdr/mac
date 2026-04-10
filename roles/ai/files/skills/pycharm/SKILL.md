---
name: pycharm
description: Open all uncommitted files in PyCharm via JetBrains MCP.
disable-model-invocation: true
allowed-tools: mcp__jetbrains__open_file_in_editor
---

Open all uncommitted files in PyCharm via the JetBrains MCP server.

## Uncommitted files

!`git status --porcelain`

## Instructions

1. Parse each line of the git status output above.
2. Extract the file path from each line (after the two-character status code and space).
3. Skip lines with status `D` (deleted) or `!!` (ignored).
4. For renamed files (`R` status), use the destination path (after `-> `).
5. If no files are listed, report that there are no uncommitted files and stop.
6. Call `mcp__jetbrains__open_file_in_editor` for each file path (relative to project root).
   Make all calls in parallel.
7. Report the list of opened files when complete.

Do not modify any files.
