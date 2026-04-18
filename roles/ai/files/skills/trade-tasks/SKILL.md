---
name: trade-tasks
description: Read the user's trading system TODO list and ideas backlog from the Trade spreadsheet on Google Drive. Use when the user asks about Tradeスプシ, trading system tasks, what to work on next for the trading system, or references the trade task list / ideas backlog.
allowed-tools: mcp__claude_ai_Google_Drive__read_file_content, mcp__claude_ai_Google_Drive__search_files
---

Read the user's trading system task board from the Google Sheets file titled `Trade`.

## Source of truth

- **File ID**: `10JdF1Ik7sxPT4tUSalm2lLsKkTBgmBY_dEjNQRRuXXg`
- **Title**: `Trade`

The sheet has two sections:

1. **Task table** — columns: `Kind`, `routine`, `draft`, `Task`, `Memo`, `On`.
   - `Kind`: category (`Gen`, `Infra`, `Strategy`, `Back`, `Front`, ...).
   - `routine`: `TRUE` if recurring work.
   - `draft`: `TRUE` if still in ideation.
   - `On`: `TRUE` if currently active. **Rows with `On=TRUE` are what the user is working on now.**
2. **Ideas** — free-form backlog of strategy/implementation ideas for the trading system.

## Instructions

1. Call `mcp__claude_ai_Google_Drive__read_file_content` with the file ID above.
2. If the read fails (e.g., file not found or ID changed), fall back to `mcp__claude_ai_Google_Drive__search_files` with `title = 'Trade' and mimeType = 'application/vnd.google-apps.spreadsheet'` and retry.
3. Present the relevant section(s) to the user based on their intent:
   - If asking "what should I work on" → show rows where `On=TRUE`.
   - If asking about ideas/backlog → show the `Ideas` section.
   - If asking generally → show both, with `On=TRUE` rows highlighted.
4. Do not invent rows. Only report what is actually in the sheet.

## Rules

- Read-only. Do not attempt to modify the spreadsheet (no write tools are permitted).
- Do not cache sheet contents across conversations — always re-read; the user edits this sheet frequently.
