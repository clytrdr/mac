# Container review reference

Applies to `Dockerfile`, `*.dockerfile`, `docker-compose.yml`, CI build files such as `cloudbuild.yaml`, and the build context ignore files `.dockerignore` and `.gcloudignore`.

## Dockerfile, compose, and CI build files

Apply current, widely recommended best practices. Do not invent project-specific rules. Focus on what matters most:

- Reproducible builds: pinned image versions.
- Image size and layer caching.
- Running as a non-root user.
- No secrets in the file, the image, or its history. A leaked secret is a blocker.
- Signal handling and container lifecycle (exec form, health checks).

## Ignore files

These files decide what goes into the build context or upload. They use `.gitignore` pattern syntax, but they are not `.gitignore`. Read the file, then check it against the real directory tree with `Glob`.

- A credential file the patterns do not exclude (a service account key, `.env`, `*.pem`) is a blocker.
- Cross-check every `COPY` source in the Dockerfile against the patterns. An excluded source breaks the build, or worse, the build succeeds with the file missing.
- No ignore file means the whole directory is uploaded. Report the largest offenders you can see (`.git`, `node_modules`, `.venv`, `dist`, `__pycache__`).
- If `.dockerignore` and `.gcloudignore` both exist with different content, report the drift and ask which one is correct.
- `.gcloudignore` only: when the file is absent, `gcloud` generates one from `.gitignore`, unreviewed — report that. `#!include:.gitignore` ties the upload set to `.gitignore` changes. `.git` is not excluded by default.
