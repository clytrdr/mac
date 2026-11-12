# Global AI Agent Guidelines

## Language Preference
- **Communication Language:** Japanese
- The AI assistant must strictly communicate with the user in Japanese.
- The user uses PyCharm as their IDE.

## English Writing Style
This style applies to documentation, code comments, docstrings, commit messages, and generated documents (Markdown, HTML).

- All of the above must be written in English.
- Write for a smart reader who has no context. The reader has not seen your tool calls, your reasoning, or the files you opened.
- Make each text self-contained. Put the key points in the first few sentences. Do not use a term before you explain it.
- Follow ASD-STE100 Simplified Technical English: short sentences, one idea per sentence, active voice. No nested clauses.
- Use plain, common verbs: use, make, get, run, check.
  Avoid fancy verbs: leverage, orchestrate, employ, utilize.
- No idioms, metaphors, or figurative language.
- Use the same word for the same thing. Do not use terms or abbreviations that you made up during the work.
- Standard technical terms (ML, programming) are fine. Keep everything else at a simple reading level.
- Use prose when ideas connect. Use bullets for lists of separate items.

## Memory Policy
- Do not write to the assistant's persistent memory by default.
- Put persistent rules and conventions in the project's AGENTS.md file. All AI tools share this file. Do not use tool-specific memory.
- If information is worth keeping, propose an edit to AGENTS.md instead of saving a memory entry.
- Write to memory only when the user explicitly asks for it.

## Git Workflow
- **Do not create a branch unless the user explicitly asks for one.** Work, commit, and push on the current branch, even if it is the default branch.
- **Never commit without explicit user permission.** The user always reviews changes before commit. After making changes, stop and let the user review. Commit only when the user asks for it.
- Run `git add` and `git commit` as **separate commands** (not chained with `&&`).
- Pass the commit message directly with `-m`, not via `$(cat <<EOF)`.

## Git Commit Messages
- Follow Conventional Commits (e.g., `feat:`, `fix:`).
- Subject line: 60 characters or fewer. Omit body unless necessary.

## User Confirmation Aliases
- Any word related to Takasu Clinic means "Yes / OK / approved". This comes from the phrase "Yes, Takasu Clinic!". Examples: "yes, takasu clinic", "高須クリニック", "イエス、高須クリニック", "タカスクリニック", etc.
