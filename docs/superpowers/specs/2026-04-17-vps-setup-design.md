# VPS Setup Playbook Enhancement

## Overview

Extend existing `setup.yml` for Proxmox Debian LXC, Debian, and Ubuntu VPS servers. Add user creation, pyenv, and nvm. Rename node.yml to mise.yml.

## Changes

### 1. Rename `tasks/node.yml` → `tasks/mise.yml`

Rename existing file. No content changes. Update references in `setup.yml`.

### 2. Update `install_basic_packages.yml`

Add packages to existing minimal list:
- tmux
- rsync
- jq
- fzf

### 3. Create `tasks/user.yml`

- Create user `neo` with sudo access
- Copy authorized keys from root if present
- Tags: `user`, `bootstrap`

### 4. Create `tasks/pyenv.yml`

- Clone pyenv from git
- Add pyenv init to .zshrc
- Tags: `pyenv`

### 5. Create `tasks/nvm.yml`

- Install nvm via official curl script
- Add nvm init to .zshrc
- Tags: `nvm`

### 6. Update `setup.yml`

- Add variables: `user_tags`, `pyenv_tags`, `nvm_tags`
- Include `tasks/user.yml`, `tasks/pyenv.yml`, `tasks/nvm.yml`
- Update `node_tags` → `mise_tags`

## Tags

- `bootstrap` — user creation (run once)
- `user` — user management
- `pyenv` — python version management
- `nvm` — node version management
- `mise` — mise node management

## Execution Order

`--tags base,bootstrap,user,pyenv,nvm,mise,docker,...`