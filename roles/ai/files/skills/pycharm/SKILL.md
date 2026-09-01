---
name: pycharm
description: Open all uncommitted files in PyCharm via JetBrains MCP.
---

Open all uncommitted files in PyCharm via the JetBrains MCP server.

Run this workflow only when the user explicitly asks to open the files.

## Instructions

1. Run `git status --porcelain` from the project root.
2. Parse each line of the output.
3. Extract the file path from each line after the two-character status code and space.
4. Skip lines with status `D` (deleted) or `!!` (ignored).
5. For renamed files (`R` status), use the destination path after `-> `.
6. If no files are listed, report that there are no uncommitted files and stop.
7. Use the configured JetBrains or PyCharm integration to open each project-relative path.
   Tool names may have a different namespace in each AI host. Make independent calls in parallel
   when the host supports it.
8. If no JetBrains integration is available, report that no files were opened and list the paths.
9. Report the list of opened files when complete.

Do not modify any files.
