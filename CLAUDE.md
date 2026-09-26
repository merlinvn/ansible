# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- Syntax check: `ansible-playbook playbooks/setup.yml --syntax-check`
- Lint: `ansible-lint .`
- Run playbook (remote): `ansible-playbook -i hosts playbooks/setup.yml -K --tags all`
- Run playbook (docker): `./run-playbook [--tags base,zsh,git,...]`
- Docker: `./docker-build` → `./docker-run` → `./docker-reset`
- SSH docker: `ssh -p 2222 ubuntu@localhost` (password: `ubuntu`)

## Architecture

- Main playbook `playbooks/setup.yml` orchestrates task includes from `tasks/` directory
- Task files: `install_basic_packages.yml`, `zsh.yml`, `git.yml`, `fzf.yml`, `rust.yml`, `mise.yml`, `node.yml`, `dotfiles.yml`, `unattended-upgrades.yml`, `docker.yml`
- Tag-based execution: `--tags base,install,zsh,git,fzf,rust,mise,node,dotfiles,unattended-upgrades`
- All tasks use `become: true` for sudo
- `playbooks/setup.yml` targets all hosts in the selected inventory; use `--limit` to select one host
