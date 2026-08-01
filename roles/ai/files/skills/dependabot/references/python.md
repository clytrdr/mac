# Post-merge refresh: pip

Dependabot edits `requirements*.txt` in the PR. After `git pull`, the pinned versions are already correct. The job here is to sync the local environment and check that nothing broke.

Run these in order. Ask the user before each step.

## 1. Install

```
uv pip install -r requirements.txt -r requirements-dev.txt
```

Leave out `-r requirements-dev.txt` if that file does not exist.

The project may be installed as a package. That is the case when there is a `pyproject.toml` with a build system, and the README says so. Then also run:

```
uv pip install -e .
```

Do not run `uv sync`. A `uv.lock` file can exist even when the project does not use that workflow. Follow the README.

## 2. Rebuild the container (optional, slow)

If `docker-compose.yml` or `compose.yml` exists, ask as a separate question whether to run:

```
docker compose build
```

This is slow. The user may skip it. It matters when the image installs the same requirements files and something else runs against the container.

## 3. Verify

Run the project's test command. Check which one the project uses before you pick one:

```
pytest
```

or, if `tox.ini` exists:

```
tox
```

Report failures with the output.

## 4. Ansible repositories

The repository root may have `localhost.yml` or `ansible.cfg`. Then the Python requirements are the tools themselves, not an application. Step 1 is the whole refresh. There is no test suite to run.

Running the playbook again changes the local machine. Do not run it. Show the user the command and let them decide:

```
ansible-playbook localhost.yml --check --diff --vault-password-file .vault_pass
```

## 5. Files that may change

Usually none. Dependabot already committed the `requirements*.txt` changes in the PR. `uv pip install` only writes to the virtual environment.

If `git status` is clean after these steps, say so and skip the commit question.
