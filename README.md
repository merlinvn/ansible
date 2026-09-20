# Ansible Setup

Provision Ubuntu developer machines with tools, shell setup, dotfiles, and auto-security upgrades.

The repository also prepares portable Debian/Ubuntu lab hosts. The host layer is
separate from the developer-machine playbook and is composed from roles for
common packages, networking, nftables, Incus, Firecracker, containerd, and
monitoring.

The component-based entry point for powerful compute hosts is
`playbooks/compute-node.yml`. It is intended for machines such as the Radxa X4
that can provide KVM, containerd, Incus, or Firecracker. Add a host and declare
what it should run; implementation roles and Firecracker's nftables dependency
are selected automatically. It also installs the local controller's SSH public
key for the Ansible connection user:

```yaml
new-box:
  ansible_host: 10.10.50.80
  install:
    - containerd
    - firecracker
    - node_exporter
```

Run it with `ansible-playbook -i inventory/local.yml playbooks/compute-node.yml
--limit localhost` (or point `-i` at your own inventory). Forwarding, lab
bridges, and firewall rules remain opt-in.

For lightweight nodes such as an Orange Pi Zero 3W, put hosts in the
`light_nodes` group and run:

```sh
ansible-playbook -i inventory/light-nodes.yml playbooks/light-node.yml
```

The lightweight playbook installs the base developer packages, locale, NTP time
synchronization, the local controller's `~/.ssh/id_ed25519.pub` as an
authorized key for `neo`, Git, Zsh, Mise, tmux, and unattended security
upgrades. Dotfile configuration is applied only through Stow for
the `tmux`, `shell`, `mise`, `git`, and `starship` packages from
`https://github.com/merlinvn/dotfiles`. Language runtimes are intentionally
left to Mise. The SSH key behavior is shared by playbooks that use the common
user setup task; override it with `-e ssh_public_key_file=...` when needed.

## Quick Start

### Remote machine
```sh
ansible-playbook -i hosts setup.yml -K --tags all
```

### Portable lab host

```sh
./run-playbook portable-lab local
```

The legacy portable-lab playbook is still available. Runtime features are opt-in:

```sh
ansible-playbook -i inventory/local.yml playbooks/portable-lab.yml -K \
  -e lab_bridge_configure=true -e nftables_enabled=true \
  -e incus_enabled=true -e firecracker_enabled=true \
  -e containerd_enabled=true -e monitoring_enabled=true
```

For a fresh machine, set `BOOTSTRAP_REPO_URL` to clone the repository before
running it:

```sh
BOOTSTRAP_REPO_URL=https://github.com/you/homelab.git ./bootstrap portable-lab local
```

### Docker dev environment
```sh
./run-playbook --tags all
```

## Development

```sh
# Install required Ansible collections
ansible-galaxy collection install -r requirements.yml

# Syntax check
ansible-playbook setup.yml --syntax-check

# Lint
ansible-lint .

# Run specific tags
./run-playbook --tags base,zsh,git

# Run the Firecracker-focused playbook
./run-playbook --playbook playbooks/firecracker.yml --tags all local

# Docker workflow
./docker-build   # build image
./docker-run     # start container
./docker-reset   # restart
```

## SSH to Docker

```sh
ssh -p 2222 ubuntu@localhost  # password: ubuntu
```
