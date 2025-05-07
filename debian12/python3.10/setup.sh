#!/bin/bash

set -e

# Ensure script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "❌ Please run this script as root (e.g. sudo ./setup.sh)"
   exit 1
fi

echo "🔄 Updating system..."
apt update && apt upgrade -y

echo "📦 Installing required packages..."
apt install -y \
    curl \
    htop \
    git \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    gnupg

apt install -y \
    make \
    build-essential \
    libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncursesw5-dev \
    xz-utils tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev

echo "🐙 Installing GitHub CLI..."
type -p gpg >/dev/null || apt install -y gpg
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update && apt install -y gh

echo "🐍 Installing Python 3.10..."
wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz
tar xzf Python-3.10.0.tgz
cd Python-3.10.0
./configure --enable-optimizations
make -j$(nproc)
make altinstall
cd ..
rm -rf Python-3.10.0

echo "☕ Installing OpenJDK..."
apt install -y default-jdk

# Install NVM and Node.js LTS version for the non-root user
if [ "$SUDO_USER" ]; then
  USER_HOME=$(eval echo "~$SUDO_USER")
  echo "📦 Installing NVM and Node.js LTS for user: $SUDO_USER"

  sudo -u "$SUDO_USER" bash <<'EOF'
    export PROFILE="$HOME/.bashrc"
    export NVM_DIR="$HOME/.nvm"

    echo "➡️ Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    echo "➡️ Loading NVM..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    echo "➡️ Installing latest LTS Node.js..."
    nvm install --lts

    echo "➡️ Setting default Node.js..."
    nvm alias default 'lts/*'

    echo "➡️ Installing gtop..."
    npm install -g gtop
EOF

else
  echo "⚠️ Skipping NVM install: script was run as root with no sudo user context."
fi

echo "✅ All done. You may need to log out and back in to use Node.js or run:"
echo "   source ~/.bashrc"
