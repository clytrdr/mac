---
name: reviewhtml
description: Review HTML templates for correctness and proper use of daisyUI components and Tailwind CSS utilities, then implement approved fixes.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Glob, Grep, AskUserQuestion, mcp__context7__resolve-library-id, mcp__context7__query-docs
---

Perform a thorough review of one or more HTML templates. Check correctness and the proper use of daisyUI components and Tailwind CSS utilities. Then implement any approved fixes.

Directory arguments are expanded recursively.

## Arguments

One or more file paths or directory paths provided after the skill name:

```
/reviewhtml path/to/template.html path/to/templates
```

`$ARGUMENTS` contains the raw argument string.

## Instructions

1. Parse `$ARGUMENTS` into a list of paths.
   - If empty, use `AskUserQuestion` to ask the user which file(s) or directory(ies) to review. Do not guess.
2. Resolve each path to an absolute path relative to the current working directory.
   - For any path that does not exist, report the missing path and stop. Do not silently skip.
3. Expand each directory path into a recursive file list with `Glob` (pattern `**/*.html`).
   - Exclude generated and vendored content: `node_modules`, `dist`, `build`, `vendor`, `coverage`.
   - File arguments are used as-is.
4. Deduplicate the final file list.
   - If the list is empty, report that and stop.
   - If the list has more than 30 files, show the count and use `AskUserQuestion` to confirm before reviewing. Offer to narrow the scope.
5. Review **each** file:
   - `Read` the full file content and list the daisyUI component classes it uses (`btn`, `card`, `modal`, etc.).
   - Fetch the current daisyUI docs for each component via Context7. Fetch the docs for each component once, not once per file.
   - Check the template against the docs:
     - Class names that do not exist in the current daisyUI version.
     - Missing required HTML structure or nesting (e.g., `dropdown` needs a parent with `tabindex`).
     - Conflicting modifier classes (e.g., `btn-primary btn-secondary` on one element).
     - Missing `aria-*` attributes, labels, or roles.
     - Missing Tailwind responsive prefixes where needed.
     - Wrong framework template syntax (e.g., Angular directives and bindings).
   - Record findings as a bulleted list grouped by severity (blocker / major / minor / nit). Each finding must include a concrete suggestion (with a code snippet if helpful) and a location reference (file and line).
   - Do not fix anything during this pass — review only.
6. Present all findings to the user, grouped by file. If a file has no findings, say so explicitly.
7. For each actionable finding, use `AskUserQuestion` to ask whether to apply the fix. Batch multiple questions into a single `AskUserQuestion` call where possible.
8. Implement approved fixes locally with `Edit` or `Write`.
9. Report what was modified, listing each file and the findings that were addressed.

## Rules

- **Review first, fix later.** Never modify a file during the review pass (steps 5-6).
- Never apply a fix the user has not explicitly approved via `AskUserQuestion`.
- Preserve the original file's style and formatting unless a specific finding explicitly addresses style.
- If Context7 is not available, state this once and review without the docs. Do not stop the run.
- Report skipped files (excluded, unreadable) explicitly — do not silently drop them.
