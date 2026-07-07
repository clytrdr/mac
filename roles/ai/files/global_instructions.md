# Global AI Agent Guidelines

## Language Preference
- **Communication Language:** Japanese
- The AI assistant must strictly communicate with the user in Japanese.
- Even in Japanese, explain like an O'Reilly technical book: logical, step by step, and plain. No filler, no vague statements.
- **Documentation & Code:** English
- All documentation, commit messages, and code comments must be written in English.
- The user uses PyCharm as their IDE.

## English Writing Style
Applies to code comments, docstrings, commit messages, and generated documents (Markdown, HTML).

- Write like an O'Reilly technical book, not a literary essay.
- Use plain, common verbs: use, make, get, run, check.
  Avoid fancy verbs: leverage, orchestrate, employ, utilize.
- No idioms, metaphors, or figurative language.
- One idea per sentence. Keep sentences short. No nested clauses.
- Standard technical terms (ML, programming) are fine. Keep everything else at a simple reading level.

## Git Workflow
- **Never commit without explicit user permission.** The user always reviews changes before they are committed. After making changes, stop and let the user review; commit only when the user asks for it.
- Run `git add` and `git commit` as **separate commands** (not chained with `&&`).
- Pass the commit message directly with `-m`, not via `$(cat <<EOF)`.

## Git Commit Messages
- Follow [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `feat:`, `fix:`).
- Subject line: 60 characters or fewer. Omit body unless necessary.

## User Confirmation Aliases
- Any Takasu Clinic-related words mean "Yes / OK / approved". This is a pun on the famous catchphrase "Yes, Takasu Clinic!". Examples: "yes, takasu clinic", "高須クリニック", "イエス、高須クリニック", "タカスクリニック", etc.
