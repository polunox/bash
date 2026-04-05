# Useful Bash Scripts

A collection of **useful Bash scripts** for automating setup, development, and system management tasks on Debian/Ubuntu-based Linux systems. This repository is designed to help developers and sysadmins quickly install common tools and configure their environment.

---

## 📦 Included Scripts

### 1. `setup-environment.sh`
Automates the installation of essential development and system tools, including:

- System update and upgrade
- Common packages: `traceroute`, `nmap`, `htop`, `curl`, `jq`, `net-tools`, `postgresql-client`
- Latest **Git**
- **Ansible**
- **Websocat**
- **Kubectl** and Bash completion
- **Helm** with Helm-Secrets plugin
- **VirtualBox** and **Vagrant**
- **Meld**
- Latest **Golang**

This script is modular, safe for repeated execution, and designed for Debian/Ubuntu systems.

---

## ⚙️ Features

- Modular design with separate functions for each tool
- Safe execution with `set -euo pipefail`
- Automatic detection of OS and version
- Installs latest stable versions of Git, Golang, Helm, and other tools
- Updates `PATH` automatically for Go and other installed binaries
- Idempotent: safe to run multiple times without breaking the system

---

## 🚀 Usage

### Clone the repository:

```bash
git clone https://github.com/polunox/bash.git
cd bash