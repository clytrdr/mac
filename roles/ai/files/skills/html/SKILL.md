---
name: html
description: Review HTML templates for correctness and proper use of daisyUI components and Tailwind CSS utilities.
allowed-tools: Read, Glob, Grep, mcp__context7__resolve-library-id, mcp__context7__query-docs
---

# HTML / daisyUI Code Review

Review the HTML template at the path given in `$ARGUMENTS`. Do not modify any files. Report findings only.

## Workflow

1. Read the target file and list the daisyUI component classes it uses (`btn`, `card`, `modal`, etc.).
2. Fetch the current daisyUI docs for each component via Context7. If Context7 is not available, state this once and review without the docs.
3. Check the template against the docs:
   - Class names that do not exist in the current daisyUI version.
   - Missing required HTML structure or nesting (e.g., `dropdown` needs a parent with `tabindex`).
   - Conflicting modifier classes (e.g., `btn-primary btn-secondary` on one element).
   - Missing `aria-*` attributes, labels, or roles.
   - Missing Tailwind responsive prefixes where needed.
   - Wrong framework template syntax (e.g., Angular directives and bindings).

## Output

For each issue, report 場所 (file and line), 問題, and 推奨 (with a code snippet if helpful). If there are no issues, confirm that the template follows daisyUI best practices.
