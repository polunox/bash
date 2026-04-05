#!/bin/bash

set -euo pipefail  # Exit on error, unset variable, or failed pipe

# -----------------------------
# Function: Detect OS and version
# -----------------------------
function detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS="Debian"
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/redhat-release ]; then
        OS=$(awk '{print $1}' /etc/redhat-release)
        VER=$(awk '{print $3}' /etc/redhat-release)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    echo "$OS"
}

# -----------------------------
# Function: Ensure script is run with sudo/root
# -----------------------------
function check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root or use sudo"
        exit 1
    fi
}

# -----------------------------
# Function: Update & upgrade system
# -----------------------------
function update_system() {
    echo "Updating and upgrading system..."
    apt-get update -qq
    apt-get upgrade -y -qq
}

# -----------------------------
# Function: Install common packages
# -----------------------------
function install_common_packages() {
    echo "Installing common packages..."
    apt-get install -y -qq \
        traceroute \
        postgresql-client-common \
        postgresql-client-12 \
        nmap \
        htop \
        curl \
        jq \
        net-tools \
        software-properties-common \
        python3-pip \
        bash-completion
}

# -----------------------------
# Function: Install latest Git
# -----------------------------
function install_git() {
    echo "Installing latest Git..."
    add-apt-repository -y ppa:git-core/ppa
    apt-get update -qq
    apt-get install -y -qq git
}

# -----------------------------
# Function: Install Ansible
# -----------------------------
function install_ansible() {
    echo "Installing Ansible..."
    apt-add-repository -y ppa:ansible/ansible
    apt-get update -qq
    apt-get install -y -qq ansible python3-argcomplete
    activate-global-python-argcomplete3 || true
}

# -----------------------------
# Function: Install websocat
# -----------------------------
function install_websocat() {
    echo "Installing websocat..."
    wget -qO /usr/local/bin/websocat \
        https://github.com/vi/websocat/releases/latest/download/websocat.x86_64-unknown-linux-musl
    chmod a+x /usr/local/bin/websocat
}

# -----------------------------
# Function: Install kubectl
# -----------------------------
function install_kubectl() {
    echo "Installing kubectl..."
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
    echo 'source <(kubectl completion bash)' >> ~/.bashrc
    echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
}

# -----------------------------
# Function: Install Helm
# -----------------------------
function install_helm() {
    echo "Installing Helm..."
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" \
        | tee /etc/apt/sources.list.d/helm-stable-debian.list
    apt-get update -qq
    apt-get install -y -qq helm
    helm plugin install https://github.com/jkroepke/helm-secrets --version v4.1.1
}

# -----------------------------
# Function: Install VirtualBox & Vagrant
# -----------------------------
function install_vbox_vagrant() {
    echo "Installing VirtualBox & Vagrant..."
    apt-get install -y -qq virtualbox
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        | tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update -qq
    apt-get install -y -qq vagrant
}

# -----------------------------
# Function: Install Meld
# -----------------------------
function install_meld() {
    echo "Installing Meld..."
    if [ ! -d ~/meld ]; then
        git clone https://git.gnome.org/browse/meld ~/meld
    fi
    ln -sf ~/meld/bin/meld /usr/bin/meld
}

# -----------------------------
# Function: Install Golang
# -----------------------------
function install_golang() {
    echo "Installing latest Golang..."
    
    GO_LATEST=$(curl -s https://go.dev/VERSION?m=text)
    
    if command -v go >/dev/null 2>&1; then
        INSTALLED_VERSION=$(go version | awk '{print $3}')
        if [ "$INSTALLED_VERSION" == "$GO_LATEST" ]; then
            echo "Golang $GO_LATEST is already installed."
            return
        else
            echo "Updating Golang from $INSTALLED_VERSION to $GO_LATEST..."
            rm -rf /usr/local/go
        fi
    fi

    wget -q https://golang.org/dl/${GO_LATEST}.linux-amd64.tar.gz -O /tmp/go.tar.gz
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz

    if ! grep -q 'export PATH=$PATH:/usr/local/go/bin' ~/.profile; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
    fi
    export PATH=$PATH:/usr/local/go/bin

    echo "Golang $GO_LATEST installed successfully."
}

# -----------------------------
# Main script execution
# -----------------------------
check_root
OS=$(detect_os)
echo "Detected OS: $OS"

if [[ "$OS" == "Ubuntu" || "$OS" == "Debian" ]]; then
    update_system
    install_common_packages
    install_git
    install_ansible
    install_websocat
    install_kubectl
    install_helm
    install_vbox_vagrant
    install_meld
    install_golang
    echo "All installations completed successfully!"
else
    echo "Unsupported distro: $OS. Exiting."
    exit 1
fi