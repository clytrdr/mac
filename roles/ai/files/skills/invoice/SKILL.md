---
name: invoice
description: Rename invoice and credit card statement PDFs, then upload them to Google Drive when supported.
---

## Read and classify

List only `.pdf` files in the current directory. Do not search subdirectories. If none exist, report that and stop.

Read each PDF with an available PDF reader or local read-only text extractor. For image-only PDFs without OCR, ask the user for the missing information.

- **Invoice:** A vendor bill or receipt for a purchase, with one or grouped line items. Common labels: `Invoice`, `請求書`, `領収書`, `Receipt`.
- **Statement:** A monthly credit card statement from an issuer, listing multiple transactions. Common labels: `ご利用明細`, `ご請求明細`, `Statement`, `明細書`.

Ask the user about unclear document types or required fields. Do not guess.

## Filenames

Use lowercase ASCII letters, digits, hyphens, and underscores. Separate fields with `_` and words with `-`. The filename without `.pdf` must match `^[a-z0-9_-]+$`.

### Invoice: `{date}_{company}_{service}_{price}yen_{tax}pct.pdf`

| Field | Value |
|---|---|
| `date` | Invoice date as `YYYYMMDD` |
| `company` | Vendor name in lowercase English or Romaji |
| `service` | Short product or service name in lowercase English |
| `price` | Total charged in JPY, digits only, without commas or decimals |
| `tax` | Consumption tax rate as an integer, such as `10` for 10% |

For non-JPY invoices, show the original currency and amount. Ask for the JPY amount from the card statement or offer `xxxx` as a placeholder. Use the user's choice.

Example: `20260301_aws_cloud-hosting_15000yen_10pct.pdf`.

### Statement: `{month}_{issuer}.pdf`

- `month`: Closing or issue month as `YYYYMM`, not the payment due month.
- `issuer`: Short common name in lowercase, such as `amex`, `mitsui`, `jcb`, or `rakuten`.

Example: `202602_amex.pdf`.

## Rename

Validate filenames and check local collisions. Show every proposal as `original_name -> new_name`. Ask for confirmation and wait for explicit approval. Rename only approved files with exact absolute source and destination paths, without globs or unresolved variables.

Never change file contents or delete files. Keep every local file after upload.

## Google Drive upload

Use `invoice/{YYYY}/{MM}` as the target folder. Take the year and month from the new filename. Both `20260731_...pdf` and `202607_amex.pdf` go to `invoice/2026/07`.

### Check capabilities

The upload needs two MCP servers:

- **Drive connector:** Searches folders and checks uploads. Example: the claude.ai Google Drive connector (`search_files`).
- **chrome-devtools MCP:** Controls the user's running Chrome signed in to Google. The upload uses `new_page`, `take_snapshot`, `click`, `upload_file`, `wait_for`, and `close_page`.

Before the upload, call `list_pages` once. If it lists the open tabs, the connection works. If it fails, do not try other browser tools. Read "If chrome-devtools does not work".

Do not upload with a Drive connector that takes only base64 content, such as `create_file`. Never send a base64-encoded PDF as conversation text or a tool argument. A small PDF uses over 100k tokens that way.

Do not install, enable, or connect plugins, extensions, accounts, or services without explicit approval.

### Find the folder

1. Find `invoice`, then its `YYYY` child, then its `MM` child. Limit child searches to the parent folder ID. If a folder is missing, ask before you create it. With approval, create a folder in the Drive web page with the `New` button and `New folder`. Otherwise, ask the user to create the folder or choose an existing folder.
2. Search the target folder for the exact filename. If it exists, stop and ask before uploading that file. Never overwrite a file without explicit approval.
3. Show each local file and its target folder. Ask once for approval before the first upload. One approval can cover all files shown.

### Upload with chrome-devtools

The `upload_file` tool can take an element that opens a file picker. It catches the picker and sets the file. Because of this, the Drive menu item `File upload` works directly. Verified on 2026-11-23.

1. Open a new page with `new_page` at `https://drive.google.com/drive/folders/<MM folder id>`.
2. Take a snapshot. Click the `New` button. The English name is `New` and the Japanese name is `新規`.
3. Take a snapshot. Find the menu item `File upload` (`ファイルのアップロード`). Call `upload_file` with its uid and the absolute path of the renamed PDF.
4. Call `wait_for` with the filename and a 15-second timeout. Check that the upload dialog says the upload is complete.
5. Do not upload the same file again only because `wait_for` timed out. The upload may still be running. Go to "Verify".

For multiple files, repeat steps 2 to 4 for each file on the same page. You can also pass several paths in one `upload_file` call. Close the page with `close_page` after all uploads.

`upload_file` accepts only files inside the Claude Code working directories. The PDFs are in the current directory, so this is usually not a problem. Do not copy files to other locations to bypass this limit.

### Verify

Search the target folder with the Drive connector. Check that each filename appears exactly once and that its `fileSize` matches the local file size. The upload action alone does not prove success. If verification fails, wait once and check again. Do not upload again when the result is unclear.

### If chrome-devtools does not work

Do not switch to another browser tool or try workarounds. Stop the upload. Keep the local files. Tell the user the target folder for each file. Then ask the user to check the setup below, based on the error.

| Error | Check |
|---|---|
| `Could not connect to Chrome`, or `DevToolsActivePort` with `EPERM` / `Operation not permitted` | macOS blocks the terminal app from reading Chrome data. In System Settings > Privacy & Security > Files & Folders, open the terminal app (for example, Ghostty or PyCharm) and turn on `Google Chrome`. If that item is not there, give the app Full Disk Access. Restart the terminal app after the change. |
| `Could not connect to Chrome`, and the user can read `DevToolsActivePort` | Remote debugging is off, or Chrome is not running. Start Chrome and turn on remote debugging at `chrome://inspect/#remote-debugging`. |
| chrome-devtools tools are not available | The MCP server is not configured or not running. Check it with `/mcp` in Claude Code. |
| `is not within any of the configured workspace roots` | The PDF is outside the Claude Code working directories. Start Claude Code in the directory that has the PDFs. |
| The Drive page shows a sign-in page | Chrome is not signed in to Google. Ask the user to sign in. |
| `New` or `File upload` is missing from the snapshot | The Drive page changed. Ask the user to upload the file manually. |

The user can test the first item in a terminal:

```bash
head -1 "$HOME/Library/Application Support/Google/Chrome/DevToolsActivePort"
```

A port number such as `9222` means the terminal app can read the file.

Report each rename and its upload status: completed, skipped, or left for manual upload.
