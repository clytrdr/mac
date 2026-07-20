---
name: plain
description: Rewrite the English text in a file into plain English without changing its meaning or any code.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Glob, NotebookEdit, AskUserQuestion
---

Rewrite the English text in one or more files into plain, simple English. Keep the meaning. Do not lose any content. For code files, change only comments and docstrings, never the code.

This skill covers four kinds of target text:

- **Markdown** (`.md`, `.markdown`): the body text.
- **HTML** (`.html`, `.htm`): the visible text and HTML comments.
- **Code** (any source file): the comments and docstrings only.
- **Jupyter Notebook** (`.ipynb`): the body text of Markdown cells, and the comments and docstrings in code cells.

## Arguments

One or more file paths provided after the skill name:

```
/plain path/to/doc.md path/to/page.html path/to/module.py path/to/analysis.ipynb
```

`$ARGUMENTS` contains the raw argument string.

## English Writing Style

Rewrite the text to follow these rules. They come from the user's global guidelines.

- Write like an O'Reilly technical book, not a literary essay.
- Use plain, common verbs: use, make, get, run, check.
  Avoid fancy verbs: leverage, orchestrate, employ, utilize.
- No idioms, metaphors, or figurative language.
- One idea per sentence. Keep sentences short. No nested clauses.
- Standard technical terms (ML, programming) are fine. Keep everything else at a simple reading level.

## Instructions

1. Parse `$ARGUMENTS` into a list of paths.
   - If empty, use `AskUserQuestion` to ask which file(s) to rewrite. Do not guess.
2. Resolve each path to an absolute path relative to the current working directory.
   - For any path that does not exist, report the missing path and stop. Do not silently skip.
3. For each file, decide the target text by file type:
   - **Markdown**: rewrite the body text.
   - **HTML**: rewrite the visible text and HTML comments.
   - **Code**: rewrite the comments and docstrings only.
   - **Jupyter Notebook** (`.ipynb`): parse the file as a notebook. Rewrite the body text of Markdown cells. In code cells, rewrite the comments and docstrings only.
   - For any other or unknown file type, use `AskUserQuestion` to ask whether to treat it as Markdown, HTML, or code. Do not guess.
4. `Read` the full file. For a notebook, `Read` returns the cells with their outputs.
5. Rewrite the target text in place, following the English Writing Style rules above.
   - Use `Edit` for Markdown, HTML, and code files.
   - For a Jupyter notebook, edit it one cell at a time and change the cell source only. In Claude Code, use `NotebookEdit`. If the agent has no notebook-aware edit tool, keep the `.ipynb` JSON structure intact and change only the text inside the cell `source` fields.
   - Preserve the meaning. Do not drop or add facts, steps, numbers, warnings, or examples.
   - Keep the original language. Rewrite English text only. Leave non-English text as is.
6. Report the result per file: which parts were rewritten, and note any file left unchanged.

## Rules

- **Never change code.** In code files, edit only the text inside comments and docstrings. Do not touch identifiers, logic, strings used by the program, imports, or formatting of the code.
- **Never break structure.** In Markdown, do not change code blocks, inline code, link URLs, image paths, tables layout, or frontmatter keys. In HTML, do not change tags, attributes, URLs, `<script>`, `<style>`, or `<pre>`/`<code>` blocks. In Jupyter notebooks, edit cell source only. Do not change cell types, execution counts, cell outputs, or notebook metadata. In a code cell, keep the code itself unchanged and rewrite only the comments and docstrings.
- **No content loss.** The rewrite must keep every fact and detail from the original. Simplify the wording, not the information.
- **Meaning first.** If a sentence cannot be simplified without changing its meaning, keep it as is and report it.
- **Do not commit.** Leave the changes in the working tree for the user to review.
- Report skipped or unchanged files explicitly. Do not silently drop them.
