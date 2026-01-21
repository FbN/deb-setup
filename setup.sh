#!/bin/bash

# Use the 'stable' tag which is more consistent than 'latest'
# Exit on error
set -e

echo "🚀 Starting system customization..."

# 1. Update and install base dependencies
sudo apt update
sudo apt install -y zsh git curl wget build-essential unzip ripgrep fd-find

echo "📦 Installing Neovim..."
# 1. Detect Architecture
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    FILE="nvim-linux-x86_64.tar.gz"
    DIR_NAME="nvim-linux-x86_64"
elif [ "$ARCH" = "aarch64" ]; then
    FILE="nvim-linux-arm64.tar.gz"
    DIR_NAME="nvim-linux-arm64"
else
    echo "Error: Unsupported architecture ($ARCH)."
    exit 1
fi

# 2. Define URL
URL="https://github.com/neovim/neovim/releases/latest/download/$FILE"

echo "Detected $ARCH. Downloading from: $URL"

# 3. Download and Install
# Download to /tmp to keep your directory clean
curl -LO "$URL"

# Remove old version if it exists
sudo rm -rf "/opt/$DIR_NAME"

# Extract to /opt
sudo tar -C /opt -xzf "$FILE"

# 4. Create Symbolic Link
# This makes the 'nvim' command available globally
sudo ln -sf "/opt/$DIR_NAME/bin/nvim" /usr/local/bin/nvim

# Cleanup
rm "$FILE"

echo "Neovim installation complete! Try running 'nvim --version'"
# Link nvim to path and set as default vi/vim
sudo ln -sf /opt/$DIR_NAME/bin/nvim /usr/local/bin/nvim
sudo ln -sf /usr/local/bin/nvim /usr/local/bin/vi
sudo ln -sf /usr/local/bin/nvim /usr/local/bin/vim

# 3. Install LazyVim
echo "✨ Setting up LazyVim..."
# Required: backup existing configs if they exist
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
rm -Rf ~/.config/nvim
git clone https://github.com/LazyVim/starter ~/.config/nvim
# Remove the .git folder so you can start your own repo later
rm -rf ~/.config/nvim/.git

# 4. Install Zsh and Pure Prompt
echo "🐚 Configuring Zsh and Pure Prompt..."
# Create directory for zsh plugins
mkdir -p "$HOME/.zsh"

# Install Pure prompt and its dependency zsh-async
if [ ! -d "$HOME/.zsh/pure" ]; then
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
fi

# 5. Create .zshrc with History and Prompt settings
echo "📝 Writing .zshrc configuration..."
printf '
# History configuration
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Pure Prompt
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

# Aliases
alias vi="nvim"
alias vim="nvim"
' > ~/.zshrc

# 6. Set Zsh as default shell
echo "🔧 Setting Zsh as default shell..."
sudo chsh -s $(which zsh) $USER

echo "✅ Setup complete! Please log out and log back in (or run 'zsh') to see changes."
