# Post-merge refresh: pip

Dependabot edits `requirements*.txt` in the PR. After `git pull`, the pinned versions are already correct. Refresh the local environment and check that everything still works.

Run these steps in order. Do not ask the user before each step. These steps change only the local virtual environment.

## 1. Install

```
uv pip install -r requirements.txt -r requirements-dev.txt
```

Do not include `-r requirements-dev.txt` if that file does not exist.

`uv pip install -r` keeps an editable install of the project. Do not run `uv pip install -e .` again.
Run `uv pip install -e .` only if the project is not installed in the virtual environment yet.

Do not run `uv sync` or `uv pip sync`. A `uv.lock` file can exist even when the project does not use that workflow. Follow the README.

## 2. Container

Do not run `docker compose build`. It is slow.
If `docker-compose.yml` or `compose.yml` exists, tell the user in the final report that the image still has the old dependencies.

## 3. Check

Read AGENTS.md first. A project can require a specific test command for AI agents.
If AGENTS.md does not specify a command, run:

```
pytest
```

Report failures with the output.

## 4. Ansible repositories

If the repository root has `localhost.yml` or `ansible.cfg`, the Python requirements are the tools themselves, not an application. Step 1 completes the refresh. The repository has no test suite.

Running the playbook again changes the local machine. Do not run the playbook. Show this command in the final report. Let the user decide whether to run it:

```
ansible-playbook localhost.yml --check --diff --vault-password-file .vault_pass
```

## 5. Files that may change

Usually none. Dependabot already committed the `requirements*.txt` changes in the PR. `uv pip install` writes only to the virtual environment.
