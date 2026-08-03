---
name: invoice
description: Rename invoice and credit card statement PDF files based on their content.
allowed-tools: Read, Bash, Glob, AskUserQuestion, ToolSearch, mcp__claude_ai_Google_Drive__search_files, mcp__claude-in-chrome__tabs_context_mcp, mcp__claude-in-chrome__navigate, mcp__claude-in-chrome__computer, mcp__claude-in-chrome__find, mcp__claude-in-chrome__file_upload, mcp__claude-in-chrome__javascript_tool, mcp__claude-in-chrome__read_page, mcp__claude-in-chrome__read_console_messages
---

Rename invoice and credit card statement PDF files in the current directory based on their content. Then upload them to the matching Google Drive folder.

## Target files

!`ls -1 *.pdf 2>/dev/null || echo "NO_PDF_FILES_FOUND"`

## Instructions

1. If no PDF files are found, report that and stop.
2. For each `.pdf` file in the current directory:
   a. Read the PDF file using the Read tool to extract its content.
   b. Check if the document is an invoice or a statement:
      - **invoice**: A bill or receipt from one vendor for a specific product or service purchase. It usually contains keywords like `Invoice`, `請求書`, `領収書`, or `Receipt`. It contains one line item or grouped line items for one service.
      - **statement**: A monthly credit card statement from a card issuer. It lists multiple transactions. It usually contains keywords like `ご利用明細`, `ご請求明細`, `Statement`, or `明細書`. A card company (such as American Express, 三井住友カード, JCB, or 楽天カード) issues it.
   c. **If the document is an invoice**, get these fields:
      - **date**: The invoice date. Convert it to `YYYYMMDD` format.
      - **company**: The company or vendor name. Use lowercase English or Romaji. Replace spaces with hyphens.
      - **service**: The service or product name. Use short lowercase English. Replace spaces with hyphens.
      - **price**: The total amount charged. Use numbers only. Do not use commas or decimals.
      - **tax**: The consumption tax rate as an integer (for example, `10` for 10%).
      - If the currency is not Japanese Yen (JPY):
        - Tell the user the original currency and amount.
        - Use AskUserQuestion to ask the user for the JPY amount from their credit card statement. Or ask if you should use `xxxx` as a placeholder for later entry.
        - If the user gives a JPY amount, use it as the price.
        - If the user chooses to wait, use `xxxx` as the price. This makes the filename contain `xxxxyen`.
      - Make the new filename: `{date}_{company}_{service}_{price}yen_{tax}pct.pdf`
        - Example: `20260301_aws_cloud-hosting_15000yen_10pct.pdf`
   d. **If the document is a credit card statement**, get these fields:
      - **month**: The statement billing month in `YYYYMM` format (6 digits). Use the closing or issue month of the statement. Do not use the payment due month.
      - **issuer**: The short common name of the card issuer in lowercase (for example, `amex` for American Express, `mitsui` for 三井住友カード, `jcb` for JCB, or `rakuten` for 楽天カード).
      - Make the new filename: `{month}_{issuer}.pdf`
        - Example: `202602_amex.pdf`
   e. Show the rename plan to the user: `original_name` -> `new_name`
3. Show all rename plans first. Then use AskUserQuestion to ask the user for confirmation before renaming.
4. When the user confirms, rename files with `mv` using the Bash tool.
5. Upload each renamed file to Google Drive. See the "Google Drive upload" section below.
6. Report the results. Show each new filename and its target Drive folder.

## Google Drive upload

The Drive folder structure is `invoice/{YYYY}/{MM}`. `YYYY` and `MM` come from the date in the new filename. An invoice named `20260731_...` goes to `invoice/2026/07`. A statement named `202607_amex.pdf` goes to `invoice/2026/07`.

### 1. Find the folder ID

Use `mcp__claude_ai_Google_Drive__search_files` three times to search down the tree:

```
title = 'invoice' and mimeType = 'application/vnd.google-apps.folder'
parentId = '<invoice id>' and title = '<YYYY>'
parentId = '<YYYY id>' and title = '<MM>'
```

If the year or month folder does not exist, use AskUserQuestion to ask the user before creating anything.

### 2. Ask for confirmation

Uploading writes files to the user's Drive. Use AskUserQuestion to ask the user before the first upload. One confirmation covers all files in the same run.

### 3. Upload through the browser

Do not use `mcp__claude_ai_Google_Drive__create_file`. It has no local path input. You must convert the whole PDF to base64 encoding for the tool call. A small invoice PDF uses over 100k tokens that way.

Use the Chrome tools instead. Drive has no `input[type=file]` element on the page. Add a file input element to the page. Pass the file to it. Then send a simulated drop event to the Drive drop area.

The steps below are the shortest verified path on the Drive page as of 2026-08. They are not the only valid way. If a step fails, do not repeat it. Read "If the upload fails" at the end of this section.

1. Load the Chrome tools with one `ToolSearch` call:
   `select:mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__computer,mcp__claude-in-chrome__find,mcp__claude-in-chrome__file_upload,mcp__claude-in-chrome__javascript_tool,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__read_console_messages`
2. Go to `https://drive.google.com/drive/folders/<folder id>`.
3. Add a file input element with `javascript_tool`:
   ```js
   const i = document.createElement('input');
   i.type = 'file';
   i.id = '__claude_up';
   i.style.cssText = 'position:fixed;top:0;left:0;z-index:99999;width:200px;height:30px;';
   document.body.appendChild(i);
   ```
4. Call `find` with query `file input element` to get its reference.
5. Call `file_upload` with the absolute path of the renamed PDF and that reference.
6. Send `dragenter` and `dragover` first. Do not send `drop` yet. Drive shows a drop overlay only after it gets these events. The overlay is the element that handles the drop.

   Drive has no `main` element. The main content area is `div[role=main]`. Send the events to that element and to `document.body`. Do not use fixed screen coordinates:
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
   overlay ? overlay.getBoundingClientRect().height : 'NO_OVERLAY';
   ```
   `.LOo9ab` is the overlay element as of 2026-08. It shows the text "Drop files to upload them to \<folder\>". If the result is `NO_OVERLAY`, run this same code once more. One extra try is usually enough. If it still does not appear, read "If the upload fails".

7. Send `drop` to the overlay element in a separate `javascript_tool` call. Use the same `DataTransfer` object:
   ```js
   const overlay = document.querySelector('.LOo9ab');
   ['dragenter', 'dragover', 'drop'].forEach(t =>
     overlay.dispatchEvent(new DragEvent(t, {bubbles: true, cancelable: true, dataTransfer: window.__cdt}))
   );
   ```
   Do not target the element from `document.elementFromPoint()`. The overlay does not always sit on top at that point.

8. Wait about 5 seconds. Then check the upload. You must complete this step. Take a screenshot. Verify that the file appears in the folder list with the correct name and size. A simulated drop event fails silently. It shows no error when Drive ignores it. Do not report an upload as finished without this check.

   Do not send the drop again just because the file is missing from the first screenshot. The upload may still be running. Wait and take one more screenshot. A second drop makes Drive open the "Upload options" dialog for a duplicate file. If that dialog appears, click `Cancel`. Then check the folder with `mcp__claude_ai_Google_Drive__search_files` to confirm there is only one copy.

   If the file is not in the list after the second screenshot, stop and read "If the upload fails".
9. Remove added elements:
   ```js
   document.getElementById('__claude_up')?.remove();
   delete window.__cdt;
   document.body.dispatchEvent(new DragEvent('dragleave', {bubbles: true, cancelable: true, dataTransfer: new DataTransfer()}));
   ```

For multiple files, repeat steps 3 to 9 for each file. Use the same tab.

After all uploads, confirm the result with one `mcp__claude_ai_Google_Drive__search_files` call. Compare the `fileSize` field against the local file size. This catches a partial upload and a duplicate copy.

### If the upload fails

Google Drive and the Chrome tools can change at any time. If a step fails, or if step 8 does not find the file, do not retry the same steps. Follow these steps instead:

1. Run the cleanup in step 9. This removes any added element from the page.
2. Read the current page with `read_page` and `read_console_messages` to inspect the page state. If Drive has a real `input[type=file]`, use it directly with `file_upload`. If the drop overlay class changed, find the new element and use it instead. To find it, list the elements that cover the file list area:
   ```js
   JSON.stringify([...document.querySelectorAll('[role=main] div')]
     .filter(e => e.getBoundingClientRect().width > 800 && e.getBoundingClientRect().height > 400)
     .map(e => e.className));
   ```
3. Try this process once.
4. If it still fails, stop. Keep the tab open on the target folder. Tell the user the file name and the target folder. Ask the user to drag the file into the browser manually. Mark the upload as not completed.

## Rules

- Do not delete or change the content of any file.
- Only rename `.pdf` files in the current directory. Do not rename files in subdirectories.
- If you cannot find a field in the document, ask the user with AskUserQuestion.
- If you cannot determine if the document is an `invoice` or a `statement`, ask the user with AskUserQuestion.
- **Filename character set**: The entire filename (without the `.pdf` extension) must match `^[a-z0-9_-]+$`. Use only lowercase ASCII letters, digits, hyphens, and underscores. Do not use uppercase letters, spaces, other symbols, or non-ASCII characters.
- **Separator convention**:
  - `_` (underscore) separates fields:
    - invoice: `date_company_service_priceyen_taxpct`
    - statement: `month_issuer`
  - `-` (hyphen) separates words within one field: `cloud-hosting`, `web-services`
- Check that the new filename matches the regular expression before renaming. If it does not match, fix the filename before proceeding.
- Keep the local file after uploading. Do not move or delete it.
- If a file with the same name exists in the Drive folder, stop and ask the user before uploading.
