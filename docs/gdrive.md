# Google Drive MCP Server Integration Tasks

## Overview
This document lists the steps to integrate the Google Drive Model Context Protocol (MCP) server into the Ansible setup.
This integration enables AI coding agents to search and upload files to Google Drive.

## Status

On hold. Resolve these open questions before the setup below:

- `@modelcontextprotocol/server-gdrive` is deprecated on npm
  ("Package no longer supported"). Find a maintained Drive MCP server.
- The server must support upload of a local file by path. The `/invoice`
  skill needs this, and it does not allow base64-encoded PDFs in tool
  arguments. The deprecated server is likely read-only.
- Claude Code already has the claude.ai Google Drive connector. Check whether
  it can upload a local PDF for `/invoice`. If it can, decide whether
  Antigravity and Codex CLI still need a Drive MCP server.

## Tasks

### 1. Google Cloud Console Setup
- [ ] Open the Google Cloud Console.
- [ ] Create a new Google Cloud project or select an existing project.
- [ ] Enable the **Google Drive API**.
- [ ] Configure the **OAuth consent screen** (User Type: External or Internal).
- [ ] Add the required OAuth scopes: `https://www.googleapis.com/auth/drive.file`.
- [ ] Create OAuth 2.0 Client Credentials with the Application Type set to **Desktop app**.
- [ ] Save the **Client ID** and **Client Secret**.

### 2. Ansible Secrets Configuration
- [ ] Add the credentials that the chosen server needs to `../vars/secrets.yml`
  with Ansible Vault. Some servers read a key file instead of environment
  variables. Check the server documentation.

### 3. MCP Server Definition
- [ ] Add one entry for the chosen server under `ai_mcp_servers` in
  `../roles/ai/vars/main.yml`.
- The role registers the server in Claude Code, Codex CLI, and Antigravity CLI.
  It also adds the server to the Claude Code and Antigravity allow lists.
  No other file needs a change.

### 4. Deployment and Verification
- [ ] Run the Ansible playbook to apply the configuration:
  ```bash
  ansible-playbook localhost.yml --tags ai --vault-password-file .vault_pass
  ```
- [ ] Check that `claude mcp list`, `codex mcp list`, and `agy mcp list` show the server.
- [ ] Complete the one-time OAuth browser authentication prompt.
- [ ] Test the `/invoice` skill with a sample PDF to verify automated upload to `invoice/{YYYY}/{MM}`.
