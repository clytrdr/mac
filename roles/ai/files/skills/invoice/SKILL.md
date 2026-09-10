---
name: invoice
description: Rename invoice and credit card statement PDFs, then upload them to Google Drive when supported.
---

## Read and classify

List only `.pdf` files in the current directory. Do not search subdirectories. If none exist, report that and stop.

Read each PDF using an available PDF reader or local read-only text extractor. For image-only PDFs without OCR, ask the user for the missing information.

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

Validate filenames and check local collisions. Show every proposal as `original_name -> new_name`, then ask for confirmation and wait for explicit approval. Rename only approved files using exact absolute source and destination paths, without globs or unresolved variables.

Never change file contents or delete files. Keep every local file after upload.

## Google Drive upload

Use `invoice/{YYYY}/{MM}`, taking the year and month from the new filename. Both `20260731_...pdf` and `202607_amex.pdf` go to `invoice/2026/07`.

### Check capabilities

Inspect the current host's tools. Use a Drive connector or MCP server that supports folder search and local file upload, or an available browser automation integration. Browser integration is unnecessary for local reading and renaming.

Do not install, enable, or connect plugins, extensions, accounts, or services without explicit approval. If upload is unsupported, report the exact target folder and request manual upload. Do not report completion.

### Find the folder and upload

1. Find `invoice`, then its `YYYY` child, then its `MM` child. Restrict child searches to the parent folder ID. For missing folders, ask before creating them. Create only with approval and a supported integration; otherwise, ask the user to create them or choose an existing folder.
2. Search the target folder for the exact filename. If it exists, stop and ask before uploading that file. Never overwrite without explicit approval.
3. Show each local file and target folder. Ask once for approval before the first upload; one approval may cover all files shown.
4. Prefer upload by local file path. Never send a base64-encoded PDF as conversation text or a tool argument. For browser uploads, use the current page's normal upload control or supported interaction, without fixed CSS classes, coordinates, or host-specific tool names.
5. After each upload, search or refresh the folder to verify the exact filename and size. The upload action alone does not prove success. If verification fails, wait once and recheck; do not upload again because the result is inconclusive.
6. If verification still fails, stop automated attempts, keep the local file, report the target folder, and request manual completion.

Report each rename and its upload status: completed, skipped, or left for manual upload.
