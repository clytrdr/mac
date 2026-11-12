# TypeScript and JavaScript review reference

Applies to `.ts`, `.tsx`, `.mts`, `.cts`, `.js`, `.jsx`, `.mjs`, and `.cjs`.

PyCharm reports TypeScript compiler errors and ESLint problems for a project that is open in the IDE. The IDE inspections return them. See the "IDE inspections" section of `SKILL.md`.

If the project has an `eslint.config.js` or a `tsconfig.json`, read it first. It tells you which rules and compiler options are already enforced. Report the problems that this tooling finds. Do not suggest a rule or a compiler option that the configuration already enforces.

In addition, apply current, widely recommended TypeScript practices. Do not invent project-specific rules.

## Angular

Applies when `angular.json` exists at the project root.

Review against current Angular recommendations: subscription cleanup, signals, change detection, standalone components. Before you report a naming finding, search the neighboring files and compare the names. To check the current API of an Angular symbol, look it up with Context7. Look up each symbol once.

### Build check

AOT compilation checks template bindings against component types, which the IDE inspections do not fully cover.

- During the review pass (step 5 of `SKILL.md`), run `ng build` once per run. Merge the template type errors into the findings.
- After the fixes (step 9), run `ng build` again if a fix changed a template or a component. Report a new error.
- `ng build` writes the build output directory (`dist/` by default). Say so once in the report.
- When the PyCharm MCP tools are unavailable, use `ng lint` as the fallback.
- If `node_modules` is missing, skip these commands and say so once — do not run `npm install`.
