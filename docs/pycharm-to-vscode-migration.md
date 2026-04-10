# Migration Plan: PyCharm → VS Code (Parallel Trial)

## Motivation

AI agent-based coding (Claude Code, GitHub Copilot, etc.) is becoming the primary development workflow. PyCharm's rich
built-in features are increasingly redundant when AI agents handle refactoring, code completion, and debugging. VS Code
offers a lighter footprint with better AI tooling integration.

This plan assumes a **parallel usage period** — both PyCharm and VS Code will be installed and available until the
PyCharm annual license expires. The goal is to evaluate VS Code in real workflows before fully committing.

## Current State

### Installed via Ansible (`homebrew` role)

- `pycharm` (Homebrew Cask) — keep until license expiry

### PyCharm External Tools configured manually

| Tool                   | Command                          |
|------------------------|----------------------------------|
| Docker Compose Up      | `docker compose up -d`           |
| Docker Compose Restart | `docker compose restart`         |
| Docker Compose Down    | `docker compose down`            |
| Docker Compose PS      | `docker compose ps`              |
| Docker Compose Build   | `docker compose build`           |
| Pre Commit             | `pre-commit run --all-files`     |
| Push All               | `git push --all`                 |
| gcloud build           | `gcloud builds submit`           |

### Claude Code MCP integration

- JetBrains MCP server (`localhost:64342`) is configured in the `claude` role

## Migration Steps

### Phase 1: Add VS Code alongside PyCharm

1. **Add `visual-studio-code` to the `homebrew` role** (keep `pycharm` as-is)

2. **Create a new `vscode` Ansible role** with the following tasks:
   - Install VS Code extensions via `code --install-extension`
   - Deploy user-level `settings.json`

3. **Add the `vscode` role to `localhost.yml`**

### Phase 2: VS Code Extensions

#### Essential

| Extension                         | Purpose                        |
|-----------------------------------|--------------------------------|
| `ms-python.python`                | Python language support        |
| `ms-python.vscode-pylance`        | Python IntelliSense            |
| `ms-toolsai.jupyter`              | Jupyter notebook support       |
| `ms-azuretools.vscode-docker`     | Docker / Compose integration   |
| `hashicorp.terraform`             | Terraform support              |
| `eamodio.gitlens`                 | Git history / blame            |

#### Recommended

| Extension                            | Purpose                             |
|--------------------------------------|-------------------------------------|
| `ms-vscode-remote.remote-containers` | Dev Containers                      |
| `googlecloudtools.cloudcode`         | gcloud integration                  |
| `actboy168.tasks`                    | Task buttons in status bar          |

> **Note:** VS Code native keybindings will be learned from scratch — no IntelliJ keybinding
> emulation.

### Phase 3: Replicate External Tools with `tasks.json`

Deploy a project-level `.vscode/tasks.json` via Ansible template to replicate PyCharm External Tools:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Docker Compose Up",
      "type": "shell",
      "command": "docker compose up -d",
      "presentation": { "reveal": "always", "panel": "shared" }
    },
    {
      "label": "Docker Compose Restart",
      "type": "shell",
      "command": "docker compose restart"
    },
    {
      "label": "Docker Compose Down",
      "type": "shell",
      "command": "docker compose down"
    },
    {
      "label": "Docker Compose PS",
      "type": "shell",
      "command": "docker compose ps"
    },
    {
      "label": "Docker Compose Build",
      "type": "shell",
      "command": "docker compose build"
    },
    {
      "label": "Pre Commit",
      "type": "shell",
      "command": "pre-commit run --all-files"
    },
    {
      "label": "Push All",
      "type": "shell",
      "command": "git push --all"
    },
    {
      "label": "gcloud build",
      "type": "shell",
      "command": "gcloud builds submit"
    }
  ]
}
```

### Phase 4: Claude Code — Dual MCP Configuration

During the parallel period, keep **both** MCP servers in the `claude` role:

- **JetBrains MCP server** — existing config (`localhost:64342`)
- **VS Code integration** — Claude Code has a native VS Code extension, which may not require a
  separate MCP server

> **Decision point:** After evaluating both setups, remove the one that is no longer needed.

### Phase 5: Evaluation and Final Migration

Once the PyCharm license expires, evaluate and decide:

- [ ] Is VS Code + AI agents sufficient for daily work?
- [ ] Are there PyCharm-only features that are still needed?
- [ ] Is the `tasks.json` setup a good enough replacement for External Tools?

If the answer is yes:
1. Remove `pycharm` from the `homebrew` role
2. Remove JetBrains MCP server from the `claude` role

## Checklist

- [ ] Add `visual-studio-code` to `homebrew` role
- [ ] Create `vscode` Ansible role (extensions, settings)
- [ ] Deploy `tasks.json` template via Ansible
- [ ] Configure Claude Code to work with both IDEs
- [ ] Trial period: use VS Code for selected projects
- [ ] Evaluate after PyCharm license expiry
- [ ] Final cleanup: remove PyCharm references from Ansible if migrating
