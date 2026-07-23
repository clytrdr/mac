# Global AI Agent Guidelines

## Language Preference
- **Communication Language:** Japanese
- The AI assistant must strictly communicate with the user in Japanese.
- Even in Japanese, explain like an O'Reilly technical book: logical, step by step, and plain. No filler, no vague statements.
- The user uses PyCharm as their IDE.

## English Writing Style
This style applies to documentation, code comments, docstrings, commit messages, and generated documents (Markdown, HTML).

- All of the above must be written in English.
- Write like an O'Reilly technical book, not a literary essay.
- Use plain, common verbs: use, make, get, run, check.
  Avoid fancy verbs: leverage, orchestrate, employ, utilize.
- No idioms, metaphors, or figurative language.
- One idea per sentence. Keep sentences short. No nested clauses.
- Standard technical terms (ML, programming) are fine. Keep everything else at a simple reading level.

## Memory Policy
- Do not write to the assistant's persistent memory by default.
- Put persistent rules and conventions in the project's AGENTS.md file. All AI tools share this file. Do not use tool-specific memory.
- If information is worth keeping, propose an edit to AGENTS.md instead of saving a memory entry.
- Write to memory only when the user explicitly asks for it.

## Git Workflow
- **Never commit without explicit user permission.** The user always reviews changes before commit. After making changes, stop and let the user review. Commit only when the user asks for it.
- Run `git add` and `git commit` as **separate commands** (not chained with `&&`).
- Pass the commit message directly with `-m`, not via `$(cat <<EOF)`.

## Git Commit Messages
- Follow Conventional Commits (e.g., `feat:`, `fix:`).
- Subject line: 60 characters or fewer. Omit body unless necessary.

## User Confirmation Aliases
- Any word related to Takasu Clinic means "Yes / OK / approved". This comes from the phrase "Yes, Takasu Clinic!". Examples: "yes, takasu clinic", "高須クリニック", "イエス、高須クリニック", "タカスクリニック", etc.
