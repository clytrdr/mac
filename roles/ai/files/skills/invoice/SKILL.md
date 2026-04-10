---
name: invoice
description: Rename invoice and credit card statement PDF files based on their content.
allowed-tools: Read, Bash, Glob, AskUserQuestion
---

Rename invoice and credit card statement PDF files in the current directory based on their content.

## Target files

!`ls -1 *.pdf 2>/dev/null || echo "NO_PDF_FILES_FOUND"`

## Instructions

1. If no PDF files are found, report that and stop.
2. For each `.pdf` file in the current directory:
   a. Read the PDF file using the Read tool to extract its content.
   b. Classify the document as one of:
      - **invoice**: A bill or receipt from a single vendor for a specific product or service purchase. Typically contains keywords like `Invoice`, `請求書`, `領収書`, `Receipt`, and a single line item or grouped line items for one service.
      - **statement**: A monthly credit card statement from a card issuer listing multiple transactions. Typically contains keywords like `ご利用明細`, `ご請求明細`, `Statement`, `明細書`, and is issued by a card company (e.g., American Express, 三井住友カード, JCB, 楽天カード).
   c. **If the document is an invoice**, extract the following fields:
      - **date**: The invoice date (convert to `YYYYMMDD` format)
      - **company**: The company or vendor name (lowercase English or romaji, replace spaces with hyphens)
      - **service**: The service or product name (concise lowercase English, replace spaces with hyphens)
      - **price**: The total amount charged (numeric only, no commas or decimals)
      - **tax**: The consumption tax rate as an integer (e.g., `10` for 10%)
      - If the currency is NOT Japanese Yen (JPY):
        - Inform the user of the original currency and amount.
        - Use AskUserQuestion to ask the user for the JPY amount from their credit card statement, or whether to use `xxxx` as a placeholder for later entry.
        - If the user provides a JPY amount, use it as the price.
        - If the user chooses to defer, use `xxxx` as the price (resulting in `xxxxyen` in the filename).
      - Construct the new filename: `{date}_{company}_{service}_{price}yen_{tax}pct.pdf`
        - Example: `20260301_aws_cloud-hosting_15000yen_10pct.pdf`
   d. **If the document is a credit card statement**, extract the following fields:
      - **month**: The statement billing month in `YYYYMM` format (6 digits). Use the closing/issue month of the statement, not the payment due month.
      - **issuer**: The card issuer's short common name in lowercase (e.g., `amex` for American Express, `mitsui` for 三井住友カード, `jcb` for JCB, `rakuten` for 楽天カード).
      - Construct the new filename: `{month}_{issuer}.pdf`
        - Example: `202602_amex.pdf`
   e. Show the user the rename plan: `original_name` -> `new_name`
3. After showing all rename plans, use AskUserQuestion to ask the user for confirmation before renaming.
4. Upon confirmation, rename files using `mv` via the Bash tool.
5. Report the results.

## Rules

- Do NOT delete or modify the content of any file.
- Only rename `.pdf` files in the current directory (not subdirectories).
- If any field cannot be determined from the document, ask the user using AskUserQuestion.
- If the document type cannot be confidently classified as either `invoice` or `statement`, ask the user using AskUserQuestion.
- **Filename character set**: The entire filename (excluding the `.pdf` extension) MUST match `^[a-z0-9_-]+$`. Only lowercase ASCII letters, digits, hyphens, and underscores are allowed. No uppercase, no spaces, no other symbols, no non-ASCII characters.
- **Separator convention**:
  - `_` (underscore) separates fields:
    - invoice: `date_company_service_priceyen_taxpct`
    - statement: `month_issuer`
  - `-` (hyphen) separates words within a single field: `cloud-hosting`, `web-services`
- Before renaming, validate that the new filename matches the regex above. If it does not, fix it before proceeding.
