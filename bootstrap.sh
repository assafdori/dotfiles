#!/usr/bin/env bash
set -euo pipefail

# Colored output helpers
info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
success() { printf "\033[1;32m[SUCCESS]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; }

# 1. Create base directories
info "Creating base directories..."
mkdir -p "$HOME/code" "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
success "Base directories created."

# 2. Install Xcode command line tools (needed for Git)
info "Installing Xcode command line tools..."
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
else
  success "Xcode CLI already installed."
fi

# 3. Install Homebrew
info "Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  success "Homebrew installed."
else
  success "Homebrew already installed."
fi

# 4. Install Git if missing
info "Ensuring Git is installed..."
if ! command -v git >/dev/null 2>&1; then
  brew install git
  success "Git installed."
else
  success "Git already installed."
fi

# 5. Fetch SSH keys from iCloud
SSH_REMOTE="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/SSH"
SSH_DEST="$HOME/.ssh"
if [ -d "$SSH_REMOTE" ]; then
  info "Copying SSH keys from iCloud..."
  cp "$SSH_REMOTE"/* "$SSH_DEST"/
  chmod 600 "$SSH_DEST"/*
  chmod 644 "$SSH_DEST"/*.pub 2>/dev/null || true
  chown "$USER":"$USER" "$SSH_DEST"/*
  success "SSH keys copied to $SSH_DEST."
else
  warn "No SSH keys found at $SSH_REMOTE. Please copy manually."
fi

# 6. Add keys to ssh-agent
info "Loading SSH keys into ssh-agent..."
eval "$(ssh-agent -s)"
for key in "$SSH_DEST"/*; do
  [[ "$key" != *.pub ]] && ssh-add "$key" || true
done
success "SSH keys loaded into ssh-agent."

# 7. Clone dotfiles repo
DOTFILES_DIR="$HOME/code/assafdori/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  info "Cloning dotfiles repository..."
  git clone git@github.com:assafdori/dotfiles.git "$DOTFILES_DIR"
  success "Dotfiles cloned to $DOTFILES_DIR."
else
  warn "Dotfiles repo already exists at $DOTFILES_DIR."
fi

info "Bootstrap complete. You can now run the main Mac setup script."
