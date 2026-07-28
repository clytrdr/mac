# TypeScript and JavaScript review reference

Applies to `.ts`, `.tsx`, `.js`, and `.jsx`.

Run the IDE inspections on every file in the list. See the "IDE inspections" section of `SKILL.md`. PyCharm reports TypeScript compiler errors and ESLint problems for a project that is open in the IDE.

If the project has an `eslint.config.js` or a `tsconfig.json`, read it first. It tells you which rules and compiler options are already enforced. Do not report a problem the configured tooling already blocks.

Beyond that, apply current, widely recommended TypeScript practices. Do not invent project-specific rules.

## Angular

Applies when `angular.json` exists at the project root.

Review against current Angular recommendations: subscription cleanup, signals, change detection, standalone components. Check naming against neighboring files with `Grep` before you report a naming finding. If you need a current Angular API, use Context7 — once per symbol.

As verification, run `ng build` and merge the template type errors into the findings. AOT compilation checks template bindings against component types, which the IDE inspections do not fully cover. When the PyCharm MCP tools are unavailable, use `ng lint` as the fallback. If `node_modules` is missing, skip these commands and say so once — do not run `npm install`.
