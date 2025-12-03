# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

- Syntax check: `ansible-playbook setup.yml --syntax-check`
- Lint: `ansible-lint .`
- Run remotely: `ansible-playbook -i hosts setup.yml -K --tags all`
- Run locally: `ansible-playbook setup.yml -K --tags all`
- Test environment: `./docker-build &amp;&amp; ./docker-run`; SSH `ubuntu@localhost -p 2222`; Reset: `./docker-reset`

## Architecture

- Flat structure with main playbook `setup.yml` orchestrating includes from `tasks/` directory: `install_basic_packages.yml` (curl, git, zsh, vim, etc.), `zsh.yml` (oh-my-zsh, plugins, starship), `git.yml`, `fzf.yml`, `rust.yml`, `mise.yml` (includes node), `node.yml`, `dotfiles.yml`, `unattended-upgrades.yml` (auto-security updates + reboot).
- Inventory: `hosts` defines `[new_machine]` group (e.g., SSH hosts like pi5-neo.local).
- Tag-based execution (e.g., `--tags base,install,zsh,git,fzf,rust,mise,node,dotfiles,unattended-upgrades`).
- Purpose: Provisions Ubuntu developer machines/servers with tools, shell setup, dotfiles, and auto-upgrades using `become: true` for sudo.