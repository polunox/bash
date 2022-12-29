#!/bin/bash

set -e

function checkOS {
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi
echo $OS
}

OS=$( checkOS)

if [ "$OS" != "Centos" ] && [ "$OS" != "RedHat" ]; then
  echo "The distro is $OS and we are good!"

  echo "Check and install updates..."
  sudo apt -qq update 2>/dev/null | grep packages | cut -d '.' -f 1 && sudo apt -qq upgrade -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sleep 3 && \
  
  echo "Install common packages"
  sudo apt -qq install traceroute -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo apt -qq install postgresql-client-common -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo apt -qq install postgresql-client-12 -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo apt -qq install nmap -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo apt -qq install htop -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo apt -qq install net-tools -y 2>/dev/null | grep packages | cut -d '.' -f 1
  
  echo "Install last version of GIT"
  sudo add-apt-repository ppa:git-core/ppa -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo apt -qq update 2>/dev/null | grep packages | cut -d '.' -f 1 \
  sudo apt -qq install git -y 2>/dev/null | grep packages | cut -d '.' -f 1
  
  echo "Install PIP"
  sudo apt -qq install python3-pip -y 2>/dev/null | grep packages | cut -d '.' -f 1
  
  echo "Install Ansible"
  sudo apt -qq install software-properties-common -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo apt-add-repository ppa:ansible/ansible -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  apt update 2>/dev/null | grep packages | cut -d '.' -f 1 && sudo apt -qq  install ansible -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo apt -qq install python3-argcomplete -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo activate-global-python-argcomplete3 2>/dev/null | grep packages | cut -d '.' -f 1
  
  echo "Install websocat"
  sudo wget -qO /usr/local/bin/websocat https://github.com/vi/websocat/releases/latest/download/websocat.x86_64-unknown-linux-musl 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo chmod a+x /usr/local/bin/websocat
  
  echo "Install kubectl"
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/amd64/kubectl 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  sudo apt -qq install bash-completion 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  echo 'source <(kubectl completion bash)' >> ~/.bashrc
  echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
  
  echo "Install helm"
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  apt update 2>/dev/null | grep packages | cut -d '.' -f 1 && sudo apt -qq install helm 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  helm plugin install https://github.com/jkroepke/helm-secrets --version v4.1.1
  
  echo "Install VBox and Vagrant"
  sudo apt -qq install virtualbox -y 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt -qq update 2>/dev/null | grep packages | cut -d '.' -f 1 && sudo apt -qq install vagrant -y 2>/dev/null | grep packages | cut -d '.' -f 1

  echo "Install Meld"
  git clone https://git.gnome.org/browse/meld && ln -s ~/meld/bin/meld /usr/bin/meld 2>/dev/null | grep packages | cut -d '.' -f 1
  
  echo "Install Visual Studio Code"
  sudo apt -qq install software-properties-common apt-transport-https 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
  sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ 2>/dev/null | grep packages | cut -d '.' -f 1 && \
  sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  apt update 2>/dev/null | grep packages | cut -d '.' -f 1 && sudo apt -qq install code 2>/dev/null | grep packages | cut -d '.' -f 1
  
else
  echo "The distro is not Ubuntu or any Debian OS"
fi
