# HTML review reference

Applies to `.html` and `.htm`, including framework component templates.

Apply widely recommended HTML practices: accessibility, valid structure, and labeled form controls. Each section below applies only when the project uses the framework in its heading. Check for the framework once per run, not once per file.

## Tailwind CSS and daisyUI

The project uses them when `package.json` contains `tailwindcss` or `daisyui`, or when a `tailwind.config.*` file exists at the project root.

List the daisyUI component classes the templates use (`btn`, `card`, `modal`, and so on). Read the daisyUI version from `package.json`. Fetch the docs of that major version for each component with Context7 — once per component, not once per file. Report a class that does not exist in that version, and a component that does not have its required HTML structure or nesting. If Context7 is not available, say so once and review without the docs.

## Angular templates

Applies when `angular.json` exists at the project root.

Check the template against its component: bindings, `@if` / `@for` blocks (every `@for` needs a `track` expression), and form control names that must exist in the component's form group. To check the current API of an Angular symbol, look it up with Context7. Look up each symbol once.

Also run the build check in the "Angular" section of `references/typescript.md`. Run it even when the list has no TypeScript file.
