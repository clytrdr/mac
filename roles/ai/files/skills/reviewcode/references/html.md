# HTML review reference

Applies to `.html` and `.htm`, including framework component templates.

Apply widely recommended HTML practices: accessibility, valid structure, and labeled form controls. The sections below apply only when the project uses that framework. Check for the framework once per run, not once per file.

## Tailwind CSS and daisyUI

The project uses them when `Grep` finds `tailwindcss` or `daisyui` in `package.json`, or a `tailwind.config.*` file at the project root.

List the daisyUI component classes the templates use (`btn`, `card`, `modal`, and so on) and fetch the current docs for each component with Context7 — once per component, not once per file. Verify against the docs: a class that does not exist in the current version, and a component missing its required HTML structure or nesting. If Context7 is not available, say so once and review without the docs.

## Angular templates

Applies when `angular.json` exists at the project root.

Check the template against its component: bindings, `@if` / `@for` blocks (every `@for` needs a `track` expression), and form control names that must exist in the component's form group. If you need a current Angular API, use Context7 — once per symbol.
