# Global AI Agent Guidelines

## Language Preference
- **Communication Language:** Japanese
- The AI assistant must strictly communicate with the user in Japanese.
- **Documentation & Code:** English
- All documentation, commit messages, and code comments must be written in English.
- The user uses PyCharm as their IDE.

## Git Workflow
- Run `git add` and `git commit` as **separate commands** (not chained with `&&`).
- Pass the commit message directly with `-m`, not via `$(cat <<EOF)`.
