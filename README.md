# Useful Bash Scripts

A collection of practical Bash scripts for **system setup, development tools, virtualization, and server administration** on Debian/Ubuntu-based systems.

---

## Included Scripts

### `setup-environment.sh`
Installs common development and system tools, including:

- system update and upgrade
- `traceroute`, `nmap`, `htop`, `curl`, `jq`, `net-tools`
- latest Git
- Ansible
- Websocat
- Kubectl + Bash completion
- Helm + Helm-Secrets
- VirtualBox + Vagrant
- Meld
- latest Golang

### `wg-stat.sh`
Displays WireGuard peer statistics in a clean table:

- config/client name
- external address
- received traffic
- transmitted traffic
- last handshake
- total traffic

Peers are automatically sorted by total traffic usage.

---

## Usage

```bash
git clone https://github.com/polunox/bash.git
cd bash
chmod +x *.sh