# AGENTS.md

# Homelab Ansible Repository

## 1. Purpose

This repository manages my personal homelab infrastructure using **Ansible as the primary host configuration tool**.

The repository should make it easy to take a fresh Linux machine and configure it into the desired state with minimal manual work.

Supported machines may include:

- physical mini PCs;
- SBCs;
- portable lab machines;
- Proxmox VMs;
- VPS instances;
- Incus VMs;
- generic Linux VMs;
- Kubernetes nodes;
- storage servers;
- development machines.

The repository must not require the user to classify a machine as a specific infrastructure type before it can be configured.

The important question is:

> What should this box run or provide?

Not:

> What type of box is this?

---

# 2. Core Design Philosophy

The repository should follow these principles.

## 2.1 Describe desired state, not machine taxonomy

Inventory should describe the components, services, configuration, and capabilities desired on a machine.

Avoid making the user remember artificial categories such as:

```text
server
container_host
virtualization_host
monitoring_host
vps
baremetal
proxmox_vm
```

unless such a grouping is genuinely useful internally.

Prefer configuration such as:

```yaml
install:
  - docker
  - tailscale
  - node_exporter
```

over:

```yaml
use_cases:
  - server
  - container_host
  - monitoring
```

The user-facing configuration should answer:

```text
What should be installed?
What should be configured?
What services should run?
What storage/networking behavior is needed?
```

---

## 2.2 Internal roles may still exist

Internally, the repository should remain organized into reusable Ansible roles.

For example:

```text
roles/
├── common/
├── ssh/
├── docker/
├── containerd/
├── tailscale/
├── monitoring/
├── networking/
├── nftables/
├── storage/
├── incus/
├── firecracker/
├── k3s/
└── development/
```

The user should not need detailed knowledge of these internal roles just to configure a new box.

---

## 2.3 Capabilities are checked when needed

Do not infer behavior primarily from whether a machine is:

```text
VPS
VM
bare metal
Proxmox guest
SBC
```

Instead, when a feature requires a concrete capability, check that capability.

Examples:

Firecracker requires:

```text
/dev/kvm
```

SMART monitoring requires accessible block devices.

Wake-on-LAN requires NIC support.

GPU configuration requires a supported GPU.

Architecture-specific binaries require a compatible CPU architecture.

The rule is:

```text
requested feature
       ↓
check required capability
       ↓
configure or fail clearly
```

Do not write logic like:

```text
if VPS → disable feature
if VM → maybe enable feature
if bare metal → enable feature
```

unless there is a real platform-specific requirement.

---

# 3. Main Goals

The repository should provide:

- reproducible configuration;
- idempotent playbooks;
- understandable automation;
- easy machine rebuilds;
- minimal manual configuration;
- support for heterogeneous hardware;
- safe defaults;
- clear failure modes;
- simple extension for new software and services.

Correctness, clarity, and maintainability are more important than clever abstractions.

This is a personal homelab repository, not an enterprise fleet management system.

---

# 4. Repository Structure

Prefer a structure similar to:

```text
ansible/
├── ansible.cfg
├── AGENTS.md
├── requirements.yml
│
├── inventories/
│   └── homelab/
│       ├── hosts.yml
│       ├── group_vars/
│       └── host_vars/
│
├── playbooks/
│   ├── site.yml
│   └── bootstrap.yml
│
└── roles/
    ├── common/
    ├── ssh/
    ├── networking/
    ├── nftables/
    ├── storage/
    ├── docker/
    ├── containerd/
    ├── tailscale/
    ├── monitoring/
    ├── incus/
    ├── firecracker/
    ├── k3s/
    └── development/
```

Do not reorganize an existing reasonable structure purely for aesthetics.

Make incremental improvements instead of large rewrites.

---

# 5. Host Configuration Model

A machine should primarily be described using desired components and configuration.

Example:

```yaml
radxa-x4:
  ansible_host: 10.10.50.20

  install:
    - development_tools
    - incus
    - firecracker
    - containerd
    - node_exporter

  storage:
    lab_mount: /srv/lab

  networking:
    forwarding: true

  firecracker:
    network: 172.16.0.0/24
```

Another machine may look like:

```yaml
vps01:
  ansible_host: example-host

  install:
    - docker
    - tailscale
    - node_exporter
```

A Proxmox VM may look like:

```yaml
k3s-node-01:
  ansible_host: 10.10.50.70

  install:
    - k3s_agent
    - tailscale
    - node_exporter
```

A bare-metal box may look like:

```yaml
dell3060:
  ansible_host: 10.10.50.30

  install:
    - docker
    - node_exporter

  power:
    wol: true
```

The same configuration model should work regardless of where the machine runs.

---

# 6. Optional Presets

Presets may exist as convenience shortcuts, but they must be optional.

Example:

```yaml
vps01:
  preset: basic_server

  install:
    - docker
    - tailscale
```

A preset may expand to defaults such as:

```text
common tools
SSH configuration
monitoring agent
basic firewall configuration
```

However, a user must not be required to remember preset names.

It must always be possible to explicitly configure the desired components.

Avoid building a large hierarchy of presets.

---

# 7. Inventory Groups

Inventory groups are allowed when they simplify actual operations.

Good reasons for groups include:

```text
all production-like boxes
all k3s nodes
all monitoring targets
machines at a physical location
machines sharing a network
```

Do not require every machine to belong to several artificial capability groups just so roles can run.

Avoid making inventory groups the primary public configuration API.

Groups should simplify administration, not create another taxonomy the user must memorize.

---

# 8. Bootstrap Responsibilities

A bootstrap script may exist, but it should stay minimal.

Its responsibilities may include:

- install Python if required;
- install Git;
- install Ansible;
- clone or update this repository;
- run the initial playbook.

Example flow:

```text
Fresh Debian/Ubuntu
        │
        ▼
bootstrap.sh
        │
        ▼
Ansible available
        │
        ▼
site.yml
```

Do not place major host configuration logic inside `bootstrap.sh`.

---

# 9. Ansible Owns Persistent Host State

Ansible should manage persistent host state such as:

- packages;
- users;
- SSH;
- repositories;
- files;
- directories;
- kernel settings;
- storage mounts;
- networking;
- nftables;
- systemd services;
- container runtimes;
- Incus;
- Firecracker host preparation;
- monitoring agents;
- development tools.

Ansible should not become the runtime scheduler for highly dynamic workloads.

---

# 10. Idempotency

Running the same playbook repeatedly should converge to the same result.

Prefer native Ansible modules such as:

```text
apt
package
file
copy
template
user
systemd
mount
sysctl
lineinfile
blockinfile
get_url
unarchive
```

Avoid shell commands when an appropriate Ansible module exists.

This is undesirable:

```yaml
- shell: |
    apt update
    apt install foo
    mkdir -p /srv/foo
    echo something >> /etc/foo.conf
```

Prefer explicit tasks.

---

# 11. Shell and Command Usage

`command` or `shell` may be used when:

- no appropriate Ansible module exists;
- interacting with vendor-specific tools;
- invoking runtime-specific CLIs;
- performing operations that are inherently command-based.

When using command-based tasks:

- make them idempotent where possible;
- use `creates`;
- use `removes`;
- use explicit `changed_when`;
- use explicit `failed_when` when appropriate;
- avoid hidden side effects.

---

# 12. Base System

The common/base configuration should contain only tools useful across many boxes.

Possible packages include:

```text
curl
wget
git
vim
tmux
htop
btop
jq
rsync
unzip
ca-certificates
gnupg
lsof
pciutils
usbutils
ethtool
iproute2
dnsutils
```

Do not install packages merely because they are common in other homelab repositories.

Every dependency should have a reasonable purpose.

---

# 13. User Management

The repository should support configuration of a normal administrative user.

Typical responsibilities:

- create user when needed;
- configure sudo;
- install authorized SSH keys;
- create useful directories;
- configure shell defaults.

Prefer using the normal user with `sudo` rather than routinely operating as root.

---

# 14. SSH

SSH configuration should be secure but practical for homelab administration.

Possible settings include:

- public-key authentication;
- controlled password authentication;
- controlled root login;
- managed authorized keys.

Security settings must be configurable.

Do not hard-code aggressive settings that could unexpectedly lock the user out.

---

# 15. Networking

Networking must support:

- DHCP;
- static addressing;
- multiple interfaces;
- bridges;
- routed lab networks;
- VM/container networks;
- isolated networks.

Do not assume interface names such as:

```text
eth0
```

Interfaces may have names such as:

```text
enp1s0
eno1
nic0
```

Interface-specific configuration must be configurable.

Do not replace a working host network configuration unless explicitly requested.

---

# 16. nftables

Use **nftables** for new firewall and NAT configuration.

Do not introduce new iptables-based configuration unless required by external software.

nftables may manage:

- forwarding;
- NAT;
- VM networking;
- container networking;
- Firecracker TAP networking;
- isolated networks;
- explicitly exposed services.

Rules should be persistent across reboot.

Prefer readable templates or structured variables.

Avoid long sequences of imperative:

```text
nft add rule ...
```

commands when a declarative configuration file would be clearer.

---

# 17. Storage

Storage may include:

- eMMC;
- NVMe;
- SSD;
- HDD;
- virtual disks;
- dedicated lab volumes.

Mount points should be configurable.

Example:

```text
/srv/lab
```

A lab storage layout may include:

```text
/srv/lab/
├── incus/
├── firecracker/
├── containers/
├── images/
├── snapshots/
└── data/
```

Do not automatically repartition or format disks.

Any destructive storage operation must be explicitly enabled.

Never infer that a disk is safe to wipe.

---

# 18. Kernel and sysctl

Kernel configuration should be declarative.

Examples may include:

```text
net.ipv4.ip_forward
bridge-related parameters
virtualization-related parameters
```

Prefer Ansible sysctl modules.

Do not append settings manually unless necessary.

---

# 19. Docker

Docker may be installed where it provides the simplest workflow.

Docker remains a valid homelab runtime.

Do not replace Docker with containerd purely for architectural purity.

The user-facing configuration should be able to request:

```yaml
install:
  - docker
```

without requiring knowledge of implementation details.

---

# 20. containerd

containerd may be installed when useful for:

- Kubernetes;
- OCI workflows;
- Firecracker-related experiments;
- lower-level container runtime work.

Example:

```yaml
install:
  - containerd
```

containerd should not automatically become a dependency for every box.

---

# 21. Incus

Incus is a preferred system container and VM platform.

The Incus role may support:

- installation;
- initialization;
- storage pools;
- bridges;
- user permissions;
- container validation;
- VM validation where KVM is available.

Example user-facing request:

```yaml
install:
  - incus
```

The role should discover or validate the required host capabilities.

Do not require the user to classify the machine as an `incus_host`.

---

# 22. Firecracker

Firecracker support should focus on preparing a machine to run microVMs.

Example:

```yaml
install:
  - firecracker
```

The Firecracker role may configure:

- required packages;
- Firecracker binaries;
- KVM permissions;
- directory structure;
- kernel directories;
- rootfs directories;
- snapshot directories;
- TAP networking;
- nftables NAT;
- helper scripts or services.

Possible directory layout:

```text
/srv/lab/firecracker/
├── bin/
├── kernels/
├── rootfs/
├── vms/
└── snapshots/
```

Before configuration, validate requirements such as:

```text
/dev/kvm
```

If the requested capability is unavailable, fail clearly.

Do not silently skip a requested major feature.

---

# 23. Firecracker Runtime Boundary

Ansible should prepare the Firecracker host.

Ansible should not become the long-term Firecracker microVM scheduler.

Dynamic operations such as:

```text
create VM
start VM
stop VM
destroy VM
clone rootfs
restore snapshot
execute workload
```

should eventually belong to a dedicated runtime or CLI.

Possible future implementation languages include:

```text
Go
Rust
Python
```

Maintain a clean separation between persistent host provisioning and transient workload lifecycle.

---

# 24. OCI Image Direction

A future goal is to support reuse of OCI/Docker images for isolated workloads.

Possible flow:

```text
OCI image
   │
   ▼
container runtime
   │
   ▼
rootfs
   │
   ▼
Firecracker
```

Do not implement this prematurely.

The current repository should simply avoid architectural decisions that make this difficult later.

---

# 25. k3s

The repository may configure lightweight Kubernetes nodes.

Example:

```yaml
install:
  - k3s_server
```

or:

```yaml
install:
  - k3s_agent
```

k3s configuration should remain separate from the base host configuration.

Kubernetes must not become a dependency for ordinary machines.

---

# 26. Portable Lab

A portable lab machine should be usable without depending on the home network or external cloud services for basic operation.

It may contain:

```yaml
install:
  - development_tools
  - incus
  - firecracker
  - containerd
```

Possible additional configuration:

```yaml
storage:
  lab_mount: /srv/lab

networking:
  forwarding: true
```

The portable lab concept should emerge naturally from requested components.

Do not require a special `portable_lab` host classification unless a convenient preset is useful.

---

# 27. VPS and VM Nodes

A normal Linux VPS or VM should be provisioned through the same component-based configuration model.

Example:

```yaml
vps01:
  install:
    - docker
    - tailscale
    - node_exporter
```

The repository should not require separate logic merely because the machine happens to run on:

```text
Proxmox
Incus
KVM
a cloud provider
physical hardware
```

Only make platform-specific decisions when technically required.

---

# 28. Tailscale

Tailscale should be available as an optional component.

Example:

```yaml
install:
  - tailscale
```

Possible configuration may include:

- enable service;
- advertise routes;
- accept routes;
- exit-node behavior.

Authentication secrets must never be committed directly to the repository.

---

# 29. Monitoring

Monitoring should remain lightweight.

Components may include:

```text
node_exporter
smartctl exporter
hardware-specific exporters
```

Example:

```yaml
install:
  - node_exporter
```

Do not install a full Prometheus/Grafana stack on every machine unless explicitly requested.

Monitoring servers and monitoring agents should remain separate concerns.

---

# 30. Development Tools

Development machines may request:

```yaml
install:
  - development_tools
```

This may install items such as:

```text
build-essential
cmake
ninja
clang
gdb
python
rust tooling
other common development utilities
```

The exact list should remain readable and configurable.

Avoid turning this role into a massive collection of unrelated tools.

---

# 31. Power Management

Power-related configuration should be opt-in.

Example:

```yaml
power:
  wol: true
```

Possible functionality includes:

- Wake-on-LAN;
- CPU power policies;
- power-saving services;
- startup behavior.

Do not decide power settings solely based on whether a machine is physical or virtual.

Check the relevant capability where appropriate.

---

# 32. Architecture Awareness

The repository should handle relevant CPU architecture differences.

Possible architectures include:

```text
x86_64
aarch64
armv7
```

Do not download x86_64 binaries unconditionally.

Use:

```yaml
ansible_architecture
```

or explicit architecture maps.

Fail clearly when software does not support the target architecture.

---

# 33. Version Management

Important infrastructure software should use explicit or configurable versions where reproducibility matters.

Example:

```yaml
firecracker_version: "1.16.1"
```

Avoid silently downloading unspecified `latest` releases for critical components.

Version upgrades should ideally require changing one variable.

---

# 34. Downloads

For downloaded binaries and archives:

- prefer official sources;
- validate checksums where available;
- avoid arbitrary curl-to-shell installers;
- make downloads idempotent;
- avoid redownloading an already-installed desired version.

---

# 35. Configuration Templates

Prefer templates for managed configuration files.

Example:

```text
roles/nftables/templates/nftables.conf.j2
```

Keep templates readable.

Avoid excessive Jinja logic.

If a template becomes difficult to understand, simplify the variable model or split the configuration.

---

# 36. Handlers

Use handlers for service reloads and restarts.

Example flow:

```text
configuration changed
       │
       ▼
notify handler
       │
       ▼
restart service
```

Do not restart services on every playbook execution if nothing changed.

---

# 37. systemd

Persistent services should normally be managed through systemd.

Examples:

```text
nftables
docker
containerd
incus
node_exporter
custom Firecracker helper services
```

Ansible should make the desired service state explicit.

---

# 38. Secrets

Never commit:

- passwords;
- private SSH keys;
- API tokens;
- Tailscale authentication keys;
- cloud credentials;
- service secrets.

Use mechanisms such as:

- Ansible Vault;
- environment variables;
- encrypted secret files;
- external secret management.

Public SSH keys may be stored where appropriate.

---

# 39. Safe Defaults

Features that can disrupt access or destroy data must not activate implicitly.

Examples:

- repartitioning disks;
- formatting filesystems;
- replacing network configuration;
- enabling routing;
- opening firewall ports;
- removing firewall rules;
- deleting containers;
- deleting Incus storage;
- modifying SSH access.

Destructive or invasive operations must require explicit configuration.

---

# 40. Feature Dependencies

A requested component may have internal dependencies.

For example:

```text
firecracker
   │
   ├── KVM validation
   ├── nftables
   ├── TAP support
   └── required packages
```

The user should not have to manually request every implementation dependency.

Dependencies should be resolved internally where reasonable.

Do not expose unnecessary internal role structure through inventory.

---

# 41. Avoid Excessive Abstraction

Do not build generic frameworks until real duplication justifies them.

Prefer:

```yaml
- name: Install Incus
```

over creating a generic abstraction for installing arbitrary virtualization systems.

A small amount of duplication is acceptable when it improves readability.

---

# 42. Validation

Important components should perform lightweight validation.

Examples:

Incus:

```bash
incus version
```

Firecracker:

```bash
firecracker --version
test -e /dev/kvm
```

containerd:

```bash
ctr version
```

Docker:

```bash
docker version
```

Networking:

```bash
ip link show
```

The purpose is to detect clearly broken installations.

Do not build a large integration test framework unless it becomes necessary.

---

# 43. Testing Repository Changes

Before considering changes complete, prefer running:

```bash
ansible-playbook playbooks/site.yml --syntax-check
```

Where appropriate:

```bash
ansible-playbook playbooks/site.yml --check
```

Also run:

```bash
ansible-lint
```

if the repository uses it.

Do not make configuration harder to understand merely to satisfy stylistic lint rules.

---

# 44. Tags

Tags may be provided for convenient targeted execution.

Examples:

```text
base
network
firewall
storage
docker
containerd
incus
firecracker
k3s
monitoring
development
```

Avoid tagging every individual task.

Tags are an execution convenience, not the primary configuration model.

---

# 45. Documentation

Each substantial role should document:

- what it installs;
- important variables;
- defaults;
- assumptions;
- required capabilities;
- example configuration.

Documentation should be concise.

Do not duplicate the entire implementation in prose.

---

# 46. Expected User Experience

Adding a new machine should be simple.

The desired workflow is:

```text
1. Add hostname/IP.
2. Declare what should be installed/configured.
3. Run Ansible.
```

Example:

```yaml
new-box:
  ansible_host: 10.10.50.80

  install:
    - docker
    - tailscale
    - node_exporter
```

Then:

```bash
ansible-playbook playbooks/site.yml --limit new-box
```

The user should not need to remember:

```text
Which host taxonomy applies?
Which internal Ansible groups exist?
Which dependency roles must be included?
```

The repository should resolve these details internally.

---

# 47. Mental Model

The main mental model should remain:

```text
BOX
 │
 ├── install
 │
 ├── configure
 │
 └── services
```

For example:

```yaml
radxa-x4:
  install:
    - incus
    - firecracker
    - containerd

  storage:
    lab_mount: /srv/lab

  networking:
    forwarding: true
```

This is preferred over:

```yaml
host_type: baremetal

use_cases:
  - portable_lab
  - virtualization_host
  - container_host
```

---

# 48. Separation of Responsibilities

The intended architecture is:

```text
bootstrap.sh
    │
    └── make Ansible runnable

Ansible
    │
    └── configure persistent host state

cloud-init
    │
    └── initialize guests when useful

systemd
    │
    └── manage persistent services

Incus
    │
    └── system containers and general VMs

Firecracker
    │
    └── lightweight isolated microVMs

future runtime / CLI
    │
    └── dynamic Firecracker lifecycle

k3s
    │
    └── Kubernetes workloads
```

Do not blur these responsibilities without a practical reason.

---

# 49. AI Agent Rules

When modifying this repository, an AI agent must:

1. Inspect the existing repository before making architectural changes.
2. Preserve useful existing structure.
3. Prefer incremental changes over large rewrites.
4. Keep user-facing configuration simple.
5. Do not introduce host-type taxonomy unless technically necessary.
6. Do not require the user to memorize predefined use-case names.
7. Prefer desired components and explicit configuration.
8. Resolve role dependencies internally where reasonable.
9. Prefer native Ansible modules.
10. Maintain idempotency.
11. Avoid destructive operations.
12. Keep roles focused and readable.
13. Use explicit versions for important external binaries.
14. Use nftables for new firewall/NAT configuration.
15. Keep persistent provisioning separate from dynamic workload orchestration.
16. Detect technical capabilities when a requested feature depends on them.
17. Fail clearly when an explicitly requested feature cannot be supported.
18. Do not silently skip major requested functionality.
19. Avoid premature abstractions.
20. Explain meaningful architectural changes.

When several solutions are valid, prefer the one that is:

```text
simpler
more explicit
more readable
more reproducible
easier to debug
```

---

# 50. Final Principle

The repository should optimize for this experience:

```text
"I have a new box.
Here is what I want on it.
Configure it."
```

Not:

```text
"I have a new box.
First I need to understand the repository's internal classification system."
```

The inventory is the declaration of intent.

Ansible roles are the implementation detail.
