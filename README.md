# Ansible Setup

Provision Ubuntu developer machines with tools, shell setup, dotfiles, and auto-security upgrades.

## Quick Start

### Remote machine
```sh
ansible-playbook -i hosts setup.yml -K --tags all
```

### Docker dev environment
```sh
./run-playbook --tags all
```

## Development

```sh
# Syntax check
ansible-playbook setup.yml --syntax-check

# Lint
ansible-lint .

# Run specific tags
./run-playbook --tags base,zsh,git

# Docker workflow
./docker-build   # build image
./docker-run     # start container
./docker-reset   # restart
```

## SSH to Docker

```sh
ssh -p 2222 ubuntu@localhost  # password: ubuntu
```
