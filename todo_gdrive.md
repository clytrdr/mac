# Google Drive MCP Server Integration Tasks

## Overview
This document lists the steps to integrate the Google Drive Model Context Protocol (MCP) server into the Ansible setup.
This integration enables AI coding agents (Antigravity and Claude Code) to search and upload files to Google Drive.

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
- [ ] Open `vars/secrets.yml`.
- [ ] Add the following encrypted variables using Ansible Vault:
  ```yaml
  gdrive_client_id: "<YOUR_CLIENT_ID>"
  gdrive_client_secret: "<YOUR_CLIENT_SECRET>"
  ```

### 3. MCP Server Definition
- [ ] Edit `roles/ai/vars/main.yml`.
- [ ] Add the Google Drive MCP server definition under `ai_mcp_servers`:
  ```yaml
  - name: gdrive
    command: npx
    args: ["-y", "@modelcontextprotocol/server-gdrive"]
    env:
      GDRIVE_CLIENT_ID: "{{ gdrive_client_id }}"
      GDRIVE_CLIENT_SECRET: "{{ gdrive_client_secret }}"
  ```

### 4. Agent Permissions Update
- [ ] Edit `roles/ai/templates/antigravity_settings.j2`.
  - Add `"mcp(gdrive/*)"` to `permissions.allow`.
- [ ] Edit `roles/ai/templates/claude_settings.j2`.
  - Add `"mcp__gdrive__*"` to `permissions.allow`.

### 5. Deployment and Verification
- [ ] Run the Ansible playbook to apply the configuration:
  ```bash
  ansible-playbook localhost.yml --tags antigravity
  ```
- [ ] Start or restart the Antigravity CLI (`agy`).
- [ ] Verify that the `gdrive` MCP server is loaded.
- [ ] Complete the one-time OAuth browser authentication prompt.
- [ ] Test the `/invoice` skill with a sample PDF to verify automated upload to `invoice/{YYYY}/{MM}`.
