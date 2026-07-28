# Python review reference

Applies to `.py`, `.pyi`, and the code cells of `.ipynb`.

Run the IDE inspections on every Python file in the list. See the "IDE inspections" section of `SKILL.md`. Beyond them, apply current, widely recommended Python practices. Do not invent project-specific rules.

## Test files

For a pytest test file, the conventions in the `pythontests` skill win over general practice. Read that skill's `SKILL.md` before you report a finding on a test file. Report a deviation from those conventions as a finding. Do not report a pattern the skill asks for, such as a fixture with no docstring.

## Notebooks

- Report a cell that depends on a variable defined in a later cell. The notebook does not run top to bottom in that state.
- Report a hard-coded absolute path or a credential in a cell.
