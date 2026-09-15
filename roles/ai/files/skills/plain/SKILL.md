---
name: plain
description: Rewrite English or translate Japanese text in files into plain English while preserving meaning, code, and structure.
---

Edit the requested files in place. Rewrite English and translate Japanese into plain English. Leave other languages unchanged. Preserve every fact, detail, and example. Do not add information.

Use short sentences with one idea each and common verbs such as use, make, get, run, and check. Keep technical terms. Avoid nested clauses, idioms, metaphors, and fancy wording. Write like an O'Reilly technical book.

## Editable Text

| File type | Editable text |
| --- | --- |
| Markdown | Body prose, including headings, lists, and table text |
| HTML | Visible text and comments |
| Code | Comments and docstrings |
| Config, data, templates, dotfiles | Comments only; all keys and values are code |
| Jupyter notebooks | Markdown cell prose; code cell comments and docstrings |

## Constraints

- Preserve quotations from books exactly as written, including inline quotations and blockquotes. Do not rewrite or translate them.
- Preserve code, program strings, formatting, and template expressions, including expressions inside comments.
- Preserve Markdown code blocks, inline code, URLs, image paths, table layout, and frontmatter.
- Preserve HTML tags, attributes, and `script`, `style`, `pre`, and `code` contents.
- Preserve comment markers and indentation. Formats without comments, such as JSON, have no editable text.
- In notebooks, edit only cell `source` text. Preserve code, cell types, outputs, execution counts, and metadata.

## Workflow

1. Use the requested paths. Ask if none are provided. Stop and report missing paths. Ask about unknown file types.
2. Read each full file and edit only the text allowed above. If meaning is unclear, leave the passage unchanged and flag it.
3. Check the diff for changes to meaning, code, or structure. Report changes and skipped or unchanged files. Do not commit.
