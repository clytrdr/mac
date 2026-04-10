---
name: code-review
description: Review a specified file and suggest improvements in Japanese.
user-invocable: true
arguments:
  - name: file
    description: The file path to review.
    required: true
---

Review the specified file and suggest improvements in Japanese.

## Target file

!`cat -n $ARGUMENTS_FILE`

## Instructions

1. Enter plan mode using the EnterPlanMode tool.
2. Review the file content above from the following perspectives:
   - Correctness and potential bugs
   - Readability and maintainability
   - Performance
   - Security
   - Best practices and idiomatic usage for the language/framework
3. Present improvement suggestions in Japanese with the following format for each finding:
   - **箇所:** The relevant line number(s) and code snippet
   - **問題点:** What the issue is
   - **改善案:** How to improve it, with a code example if applicable
4. If the file has no significant issues, state that in Japanese.

Do not modify any files. This is a review-only skill.
