# Container review reference

Applies to `Dockerfile`, `Dockerfile.*`, `*.dockerfile`, Compose files (`compose*.yaml`, `compose*.yml`, `docker-compose*.yaml`, `docker-compose*.yml`), CI build files such as `cloudbuild.yaml`, and the build context ignore files `.dockerignore` and `.gcloudignore`.

## Dockerfile, compose, and CI build files

Apply current, widely recommended best practices. Do not invent project-specific rules. Focus on what matters most:

- Reproducible builds: pinned image versions.
- Image size and layer caching.
- Running as a non-root user.
- No secrets in the file, the image, or its history. A leaked secret is a blocker.
- Signal handling and container lifecycle (exec form, health checks).

## Ignore files

These files decide what goes into the build context or upload. Git does not apply them. A git-ignored file is still part of the build context, unless these files exclude it. Read the file, then check it against the real directory tree.

The two files use different pattern syntax:

- `.gcloudignore` uses `.gitignore` pattern syntax. A pattern without a slash, such as `*.pem`, matches at every depth.
- `.dockerignore` uses Go `filepath.Match` rules. Each pattern is relative to the root of the build context. `*.pem` matches only in the root. `**/*.pem` matches at every depth.

Checks:

- A credential file the patterns do not exclude (a service account key, `.env`, `*.pem`) is a blocker.
- Cross-check every `COPY` source in the Dockerfile against the patterns. An excluded source breaks the build, or worse, the build succeeds with the file missing.
- No ignore file means the whole directory is uploaded. Report the large directories that the build uploads (`.git`, `node_modules`, `.venv`, `dist`, `__pycache__`).
- If `.dockerignore` and `.gcloudignore` both exist and exclude different files, report the difference and ask which one is correct.

`.gcloudignore` only:

- When the file is absent, `gcloud` uses a generated one. The generated file excludes `.git` and `.gitignore`. When a `.gitignore` exists, it also excludes the git-ignored files. Nobody reviewed this upload set. Report that.
- A hand-written `.gcloudignore` does not exclude `.git` unless it lists `.git`. Check that the file lists it.
- The line `#!include:.gitignore` inserts the `.gitignore` patterns. A change to `.gitignore` then changes the upload set.
