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
ARCH=$(uname -m)
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH based on architecture
  if [ "$ARCH" = "arm64" ]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >>"$HOME/.zprofile"
    eval "$(/usr/local/bin/brew shellenv)"
  fi
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
# Try lowercase first (matches setup.sh), fallback to uppercase
SSH_REMOTE_LOWER="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/ssh"
SSH_REMOTE_UPPER="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/SSH"
if [ -d "$SSH_REMOTE_LOWER" ]; then
  SSH_REMOTE="$SSH_REMOTE_LOWER"
elif [ -d "$SSH_REMOTE_UPPER" ]; then
  SSH_REMOTE="$SSH_REMOTE_UPPER"
else
  SSH_REMOTE=""
fi

SSH_DEST="$HOME/.ssh"
if [ -n "$SSH_REMOTE" ] && [ -d "$SSH_REMOTE" ]; then
  info "Copying SSH keys from iCloud..."
  # Copy files, forcing overwrite of existing read-only files
  for key_file in "$SSH_REMOTE"/*; do
    if [ -f "$key_file" ]; then
      cp -f "$key_file" "$SSH_DEST/"
    fi
  done
  # Set proper permissions on private keys (600) and public keys (644)
  find "$SSH_DEST" -maxdepth 1 -type f ! -name "*.pub" -exec chmod 600 {} \;
  find "$SSH_DEST" -maxdepth 1 -type f -name "*.pub" -exec chmod 644 {} \;
  # Ensure ownership is correct
  chown -R "$(id -un):$(id -gn)" "$SSH_DEST"
  success "SSH keys copied to $SSH_DEST."
else
  warn "No SSH keys found at $SSH_REMOTE. Please copy manually."
fi

# 5b. Create minimal SSH config for keychain persistence (will be replaced by full config in setup.sh)
if [ ! -f "$SSH_DEST/config" ]; then
  info "Creating minimal SSH config for keychain persistence..."
  cat >"$SSH_DEST/config" <<'EOF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
EOF
  chmod 600 "$SSH_DEST/config"
  success "Minimal SSH config created."
fi

# 6. Add keys to ssh-agent and keychain
info "Loading SSH keys into ssh-agent..."
eval "$(ssh-agent -s)"
for key in "$SSH_DEST"/*; do
  # Only add private keys (files that are not .pub, not config, and are regular files)
  if [ -f "$key" ] && [[ "$key" != *.pub ]] && [[ "$(basename "$key")" != "config" ]] && [[ "$(basename "$key")" != "known_hosts"* ]]; then
    # Use --apple-use-keychain on macOS 12.2+ for keychain integration
    if ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add -K "$key" 2>/dev/null || ssh-add "$key" 2>/dev/null; then
      : # Key added successfully
    else
      warn "Failed to add key: $(basename "$key")"
    fi
  fi
done
success "SSH keys loaded into ssh-agent and keychain."

# 7. Clone dotfiles repo
DOTFILES_DIR="$HOME/code/$USER/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  info "Cloning dotfiles repository..."
  if git clone git@github.com:assafdori/dotfiles.git "$DOTFILES_DIR"; then
    success "Dotfiles cloned to $DOTFILES_DIR."
  else
    error "Failed to clone dotfiles repository. Please check your SSH keys and try again."
    exit 1
  fi
else
  warn "Dotfiles repo already exists at $DOTFILES_DIR."
  # Check if we can access the repo
  if [ -d "$DOTFILES_DIR/.git" ]; then
    info "Verifying repository access..."
    if git -C "$DOTFILES_DIR" remote get-url origin &>/dev/null; then
      success "Repository is accessible."
    else
      warn "Repository exists but may not be properly configured."
    fi
  fi
fi

info "Bootstrap complete. Running main Mac setup script..."
sleep 1

# Run setup.sh if it exists
if [ -f "$DOTFILES_DIR/setup.sh" ]; then
  info "Starting dotfiles installation..."
  # Forward stdin/stdout/stderr properly
  bash "$DOTFILES_DIR/setup.sh" </dev/tty
else
  warn "setup.sh not found. Please run it manually from $DOTFILES_DIR"
fi
