# Python review reference

Applies to `.py`, `.pyi`, and the code cells of `.ipynb`.

In addition to the IDE inspections, apply current, widely recommended Python practices. Do not invent project-specific rules.

## Test files

For a pytest test file, the conventions in the `pythontests` skill take priority over general practice. That skill is next to this skill: `../pythontests/SKILL.md` from the `reviewcode` directory. Read it before you report a finding on a test file. Report a deviation from those conventions as a finding. Do not report a pattern the skill asks for, such as a test with no docstring.

## Notebooks

- Report a cell that depends on a variable defined in a later cell. The notebook does not run top to bottom in that state.
- Report a hard-coded absolute path or a credential in a cell.
