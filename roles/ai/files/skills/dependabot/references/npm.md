# Post-merge refresh: npm

Run these steps in order. Do not ask the user before each step. These steps change only `node_modules` and the lockfile.

## 1. Install and audit

```
npm ci
npm audit
```

Record the counts by severity. If `npm audit` reports no findings, go to step 5.

## 2. Apply safe fixes

```
npm audit fix
npm audit
```

Record the new counts. If `npm audit` reports no findings, go to step 5.

Do not run `npm audit fix --force`. If the user asks for `--force`, compare the target version with the installed version first. Tell the user clearly if the change is a downgrade.

## 3. Check for in-range updates

Check `.github/dependabot.yml` for `ignore` rules under the `npm` ecosystem. Do not update packages that match those rules.

```
npm outdated
```

Find packages where `Current` differs from `Wanted` and no `ignore` rule matches them.
If any such packages exist, update only those packages:

```
npm update <package1> <package2> ...
npm audit
```

If `.github/dependabot.yml` has no `ignore` rules for `npm`, you can run plain `npm update`.

## 4. Check remaining findings

For each remaining finding, run `npm view <package> dist-tags --json` and compare the latest version with the vulnerable range from `npm audit`.
If the latest version is still vulnerable, report the finding as blocked upstream. Do not run more commands for it. Do not suggest `--force`.

## 5. Check

Run these scripts if `package.json` defines them:

```
npm run lint
npm run build
npm test
```

Report failures with the output.
