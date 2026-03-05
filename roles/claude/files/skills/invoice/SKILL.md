---
name: invoice
description: Rename invoice PDF files based on their content (date, company, service, price, tax).
allowed-tools: Read, Bash, Glob, AskUserQuestion
---

Rename invoice PDF files in the current directory based on their content.

## Target files

!`ls -1 *.pdf 2>/dev/null || echo "NO_PDF_FILES_FOUND"`

## Instructions

1. If no PDF files are found, report that and stop.
2. For each `.pdf` file in the current directory:
   a. Read the PDF file using the Read tool to extract its content.
   b. Analyze the invoice content and extract the following fields:
      - **Date**: The invoice date (convert to `YYYYMMDD` format)
      - **Company**: The company or vendor name (use English or romaji, replace spaces with hyphens)
      - **Service**: The service or product name (use concise English, replace spaces with hyphens)
      - **Price**: The total amount charged (numeric only, no commas or decimals)
      - **Tax**: The consumption tax rate as an integer (e.g., `10` for 10%)
   c. If the currency is NOT Japanese Yen (JPY):
      - Inform the user of the original currency and amount.
      - Use AskUserQuestion to ask the user for the JPY amount from their credit card statement, or whether to use `xxxx` as a placeholder for later entry.
      - If the user provides a JPY amount, use it as the price.
      - If the user chooses to defer, use `xxxx` as the price (resulting in `xxxxYEN` in the filename).
   d. Construct the new filename: `{DATE}_{COMPANY}_{SERVICE}_{PRICE}YEN_{TAX}PCT.pdf`
      - Example: `20260301_AWS_Cloud-Hosting_15000YEN_10PCT.pdf`
   e. Show the user the rename plan: `original_name` -> `new_name`
3. After showing all rename plans, use AskUserQuestion to ask the user for confirmation before renaming.
4. Upon confirmation, rename files using `mv` via the Bash tool.
5. Report the results.

## Rules

- Do NOT delete or modify the content of any file.
- Only rename `.pdf` files in the current directory (not subdirectories).
- If any field cannot be determined from the invoice, ask the user using AskUserQuestion.
- Use lowercase for company and service names. Use hyphens instead of spaces.
