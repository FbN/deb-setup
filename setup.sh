#!/bin/bash

# Use the 'stable' tag which is more consistent than 'latest'
NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz"

# Exit on error
set -e

echo "🚀 Starting system customization..."

# 1. Update and install base dependencies
sudo apt update
sudo apt install -y zsh git curl wget build-essential unzip ripgrep fd-find

echo "📦 Installing Neovim..."
# Use the 'stable' tag which is more consistent than 'latest'
# Download with -f (fail on 404) and -L (follow redirects)
if curl -fsSL -o nvim-linux64.tar.gz "$NVIM_URL"; then
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz
    rm nvim-linux64.tar.gz

    # Link nvim to path and set as default vi/vim
    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
    sudo ln -sf /usr/local/bin/nvim /usr/local/bin/vi
    sudo ln -sf /usr/local/bin/nvim /usr/local/bin/vim
else
    echo "❌ Error: Failed to download Neovim. Please check your internet connection or the URL."
    exit 1
fi

# Link nvim to path and set as default vi/vim
sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
sudo ln -sf /usr/local/bin/nvim /usr/local/bin/vi
sudo ln -sf /usr/local/bin/nvim /usr/local/bin/vim

# 3. Install LazyVim
echo "✨ Setting up LazyVim..."
# Required: backup existing configs if they exist
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
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
cat << 'EOF' > ~/.zshrc
# --- History Configuration ---
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# --- Pure Prompt Setup ---
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

# --- Aliases ---
alias vi='nvim'
alias vim='nvim'

# --- Path ---
#export PATH="$PATH:/usr/local/bin"
#EOF

# 6. Set Zsh as default shell
echo "🔧 Setting Zsh as default shell..."
sudo chsh -s $(which zsh) $USER

echo "✅ Setup complete! Please log out and log back in (or run 'zsh') to see changes."
