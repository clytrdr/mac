---
name: invoice
description: Rename invoice and credit card statement PDFs, then upload them to Google Drive when supported.
---

Rename invoice and credit card statement PDF files in the current directory based on their
content. Then upload them to the matching Google Drive folder when the current AI host has a
supported Drive upload capability.

## Instructions

1. List `.pdf` files in the current directory. Do not search subdirectories. If none are found,
   report that and stop.
2. Read each PDF with an available PDF-reading capability. If the host cannot extract the PDF
   text, use a local read-only extraction tool when available. If the document is image-only and
   no OCR capability is available, ask the user for the missing information.
3. Classify each document:
   - **invoice**: A bill or receipt from one vendor for a specific product or service purchase.
     It usually contains `Invoice`, `請求書`, `領収書`, or `Receipt` and has one line item or
     grouped line items for one service.
   - **statement**: A monthly credit card statement from a card issuer. It lists multiple
     transactions and usually contains `ご利用明細`, `ご請求明細`, `Statement`, or `明細書`.
4. For an invoice, get these fields:
   - **date**: The invoice date in `YYYYMMDD` format.
   - **company**: The company or vendor name in lowercase English or Romaji. Replace spaces with
     hyphens.
   - **service**: A short product or service name in lowercase English. Replace spaces with
     hyphens.
   - **price**: The total amount charged, using digits only with no commas or decimals.
   - **tax**: The consumption tax rate as an integer, such as `10` for 10%.
   - For a non-JPY invoice, tell the user the original currency and amount. Ask for the JPY amount
     from the credit card statement or offer `xxxx` as a placeholder. Use the user's choice.
   - Make the filename `{date}_{company}_{service}_{price}yen_{tax}pct.pdf`.
     Example: `20260301_aws_cloud-hosting_15000yen_10pct.pdf`.
5. For a credit card statement, get these fields:
   - **month**: The closing or issue month in `YYYYMM` format. Do not use the payment due month.
   - **issuer**: The short common issuer name in lowercase, such as `amex`, `mitsui`, `jcb`, or
     `rakuten`.
   - Make the filename `{month}_{issuer}.pdf`. Example: `202602_amex.pdf`.
6. If a required field or document type is unclear, ask the user. Do not guess.
7. Show every proposed rename as `original_name -> new_name`. Check for local filename
   collisions. Then ask for confirmation and wait for explicit approval.
8. Rename only the approved files. Use exact absolute source and destination paths. Do not use
   globs or unresolved variables in a move command.
9. Follow the Google Drive upload workflow below.
10. Report each rename and whether its upload was completed, skipped, or left for manual upload.

## Google Drive upload

The target folder is `invoice/{YYYY}/{MM}`. Get `YYYY` and `MM` from the new filename. An invoice
named `20260731_...` and a statement named `202607_amex.pdf` both go to `invoice/2026/07`.

### Capability check

Before using Drive, inspect the capabilities available in the current AI host. Tool names and
namespaces differ between Claude, Codex, and Gemini.

- Use a Google Drive connector or MCP server when it can search folders and upload a local file.
- A browser-based upload requires a browser automation integration, such as a compatible Chrome
  extension. This integration is not required for local PDF reading or renaming.
- Do not install, enable, or connect a plugin, extension, account, or external service without the
  user's explicit approval.
- If no supported upload capability is available, report the exact target folder and ask the user
  to upload the renamed file manually. Do not mark the upload as completed.

### Find and verify the folder

1. Search for the `invoice` folder, then its `YYYY` child, then its `MM` child. Restrict every
   child search to the parent folder ID so that similarly named folders do not match.
2. If a folder is missing, ask before creating it. Create it only when the available Drive
   integration supports folder creation and the user approves. Otherwise, ask the user to create
   it or choose an existing folder.
3. Search the target folder for the exact filename. If it already exists, stop and ask the user
   before uploading that file.

### Upload and verify

1. Show the local file and target Drive folder. Ask once for confirmation before the first upload.
   One confirmation may cover all files shown in the same plan.
2. Prefer a Drive upload capability that accepts a local file path. Do not put a base64-encoded
   PDF into the conversation or a tool argument that would consume the full document as text.
3. If using browser automation, use the current page's normal file-upload control or supported
   upload interaction. Do not rely on a fixed CSS class, screen coordinate, or host-specific tool
   name.
4. After each upload, search or refresh the folder and verify the exact filename and file size.
   Do not report success from the upload action alone.
5. If verification fails, wait once and check again. Do not upload the same file again because the
   first check was inconclusive. A repeated upload can create a duplicate.
6. If the upload still cannot be verified, stop automated attempts. Keep the local file, report
   the target folder, and ask the user to complete the upload manually.

## Rules

- Do not delete or change the content of any file.
- Only rename `.pdf` files in the current directory. Do not rename files in subdirectories.
- The entire filename without `.pdf` must match `^[a-z0-9_-]+$`. Use only lowercase ASCII
  letters, digits, hyphens, and underscores.
- Use `_` to separate fields and `-` to separate words within one field.
- Check the filename pattern before renaming. Fix an invalid proposal before showing it.
- Keep every local file after uploading. Do not move or delete it.
- Do not create Drive folders, overwrite Drive files, or upload files without explicit approval.
