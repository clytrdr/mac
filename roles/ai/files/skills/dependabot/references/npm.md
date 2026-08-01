# Post-merge refresh: npm

Run these in order. Ask the user before each step.

## 1. Install

```
npm ci
```

This syncs `node_modules` with the merged lockfile. It also prints a vulnerability count. Do not stop here.

## 2. Audit

```
npm audit
```

Report the counts by severity. If there are no findings, go to step 5.

## 3. Fix what is safe

```
npm audit fix
```

This never makes breaking changes. Run `npm audit` again after it and report the new counts.

Do not run `npm audit fix --force` on your own. It can downgrade a package and still call it a fix. If the user asks for it, first compare the version it wants to install with the installed version. Say clearly when it is a downgrade.

## 4. Check for in-range updates

`npm audit fix` is careful. It can leave a package on an old version even when the range in `package.json` already allows a fixed version. Always check:

```
npm outdated
```

A package may have a `Current` value that differs from its `Wanted` value. That means the range allows a newer version, but it is not installed. Offer to run:

```
npm update
```

Then run `npm audit` again. This often clears findings that `npm audit fix` could not clear. The reason is that the vulnerable package is a transitive dependency of a build tool, and that build tool was patched in a minor release.

## 5. Check what is left

For each advisory that remains, decide whether it can be fixed at all:

1. Note the vulnerable range printed by `npm audit`.
2. Find the latest published version: `npm view <package> dist-tags --json`.
3. Check whether the latest version is still inside the vulnerable range. If it is, no local action can fix it. It is blocked upstream.

Report blocked findings as blocked. Do not keep running commands against them. Do not suggest `--force` as a way around them.

To see why a version is pinned, run `npm ls <package>`. It shows which parent package holds it. There may be several copies at different versions.

## 6. Verify

Dependency updates can break the build. Run the scripts that the project defines in `package.json`:

```
npm run build
npm test
```

Skip a command if the script does not exist. Report failures with the output. Do not call an update done until these commands pass.

## 7. Files that may change

- `package-lock.json` — changed by `npm audit fix` and `npm update`
- `package.json` — only if a fix had to widen a range

The diff for `package-lock.json` can be very large. npm rewrites the whole file. That is normal.
