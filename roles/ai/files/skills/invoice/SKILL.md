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

The upload needs two capabilities:

- A Drive connector or MCP server that can search folders. Example: the claude.ai Google Drive connector (`search_files`).
- A browser automation integration that can run JavaScript on a page and set a local file on a file input. Example: Claude in Chrome (`javascript_tool`, `find`, `file_upload`).

Do not upload with a Drive connector that takes only base64 content, such as `create_file`. Never send a base64-encoded PDF as conversation text or a tool argument. A small PDF uses over 100k tokens that way.

Do not install, enable, or connect plugins, extensions, accounts, or services without explicit approval. If upload is unsupported, report the exact target folder and request manual upload. Do not report completion.

### Find the folder

1. Find `invoice`, then its `YYYY` child, then its `MM` child. Restrict child searches to the parent folder ID. For missing folders, ask before creating them. Create only with approval and a supported integration; otherwise, ask the user to create them or choose an existing folder.
2. Search the target folder for the exact filename. If it exists, stop and ask before uploading that file. Never overwrite without explicit approval.
3. Show each local file and target folder. Ask once for approval before the first upload; one approval may cover all files shown.

### Upload through the browser

Drive has no `input[type=file]` element on the page. Its "File upload" menu opens a native file picker that browser tools cannot use. So add a file input to the page, set the file on it, and send simulated drag events to the Drive drop area.

These steps were verified on 2026-10-07. If a step fails, do not repeat it. Read "If the upload fails".

1. Open a new tab and go to `https://drive.google.com/drive/folders/<MM folder id>`.
2. Add a file input with JavaScript:
   ```js
   const i = document.createElement('input');
   i.type = 'file';
   i.id = '__claude_up';
   i.style.cssText = 'position:fixed;top:0;left:0;z-index:99999;width:200px;height:30px;';
   document.body.appendChild(i);
   ```
3. Find the element with the query `file input element`. Set the absolute path of the renamed PDF on it.
4. Send `dragenter` and `dragover`. Do not send `drop` yet. Drive shows a drop overlay only after it gets these events. The overlay is the element that handles the drop. Drive has no `main` element, so send the events to `[role=main]` and `document.body`:
   ```js
   const f = document.getElementById('__claude_up').files[0];
   window.__cdt = new DataTransfer();
   window.__cdt.items.add(f);
   const targets = [document.querySelector('[role=main]'), document.body].filter(Boolean);
   targets.forEach(target =>
     ['dragenter', 'dragover'].forEach(t =>
       target.dispatchEvent(new DragEvent(t, {bubbles: true, cancelable: true, dataTransfer: window.__cdt}))
     )
   );
   await new Promise(r => setTimeout(r, 1000));
   const overlay = document.querySelector('.LOo9ab');
   JSON.stringify({name: f.name, size: f.size, overlay: overlay ? overlay.getBoundingClientRect().height : 'NO_OVERLAY'});
   ```
   `.LOo9ab` is the overlay class as of 2026-10. Check that `name` and `size` match the local file. If the result is `NO_OVERLAY`, run the same code once more. If the overlay still does not appear, read "If the upload fails".
5. In a separate JavaScript call, send `drop` to the overlay with the same `DataTransfer` object:
   ```js
   const overlay = document.querySelector('.LOo9ab');
   ['dragenter', 'dragover', 'drop'].forEach(t =>
     overlay.dispatchEvent(new DragEvent(t, {bubbles: true, cancelable: true, dataTransfer: window.__cdt}))
   );
   ```
   Do not use the element from `document.elementFromPoint()`. The overlay is not always on top at that point.
6. Wait about 5 seconds. Take a screenshot and check that the file is in the folder list. A simulated drop fails silently when Drive ignores it.

   Do not send the drop again only because the file is missing from the first screenshot. The upload may still be running. Wait and take one more screenshot. A second drop makes Drive open the "Upload options" dialog for a duplicate file. If that dialog appears, click `Cancel`.
7. Remove the added elements:
   ```js
   document.getElementById('__claude_up')?.remove();
   delete window.__cdt;
   document.body.dispatchEvent(new DragEvent('dragleave', {bubbles: true, cancelable: true, dataTransfer: new DataTransfer()}));
   ```

For multiple files, repeat steps 2 to 7 for each file in the same tab. Close the tab after all uploads.

### Verify

Search the target folder with the Drive connector. Check that each filename appears exactly once and that its `fileSize` matches the local file size. The upload action alone does not prove success. If verification fails, wait once and recheck. Do not upload again because the result is inconclusive.

### If the upload fails

Drive and the browser tools can change at any time. If a step fails, do not retry the same steps:

1. Run the cleanup in step 7.
2. Inspect the page state. If Drive now has a real `input[type=file]`, set the file on it directly. If the overlay class changed, run the drag events in step 4 again, then list the elements that cover the file list area to find the new overlay:
   ```js
   JSON.stringify([...document.querySelectorAll('[role=main] div')]
     .filter(e => e.getBoundingClientRect().width > 800 && e.getBoundingClientRect().height > 400)
     .map(e => e.className));
   ```
3. Try this process once.
4. If it still fails, stop automated attempts. Keep the local file and the tab on the target folder. Report the target folder and ask the user to drag the file into the browser manually.

Report each rename and its upload status: completed, skipped, or left for manual upload.
