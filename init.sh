#!/usr/bin/env bash

set -euo pipefail
set -e :          # exit on error
set -u :          # treat unset variables as error
set -o pipefail : # capture error code in piped commands

# Variables
: "${GHREPOS:="$HOME/Repositories/github.com/assafdori"}"
DOTFILES_DIR="$GHREPOS/dotfiles"
BREWFILE_PATH="$DOTFILES_DIR/homebrew/Brewfile"

echo "Welcome to the Mac setup script!"

sleep 2

# Check internet connection
echo "Checking internet connection..."
if ! ping -c 3 google.com &>/dev/null; then
  echo "No internet connection. Please connect to the internet and try again."
  exit 1
else
  echo "Internet connection is good."
fi

sleep 2

echo "Setting up your Mac..."

# Detect architecture for Apple Silicon vs Intel
ARCH=$(uname -m)

# 1. Check for Homebrew and install if we don't have it
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Depending on architecture, add to the correct profile file
  if [ "$ARCH" = "arm64" ]; then
    # Apple Silicon
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    # Intel
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >>"$HOME/.zprofile"
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# 2. Update Homebrew
echo "Updating Homebrew..."
brew update

# 3. Ensure Homebrew Bundle is tapped and run bundle
if ! brew tap | grep -q "^homebrew/bundle\$"; then
  brew tap homebrew/bundle
fi

if [ -f "$BREWFILE_PATH" ]; then
  echo "Installing packages from Brewfile..."
  brew bundle --file="$BREWFILE_PATH"
else
  echo "No Brewfile found at $BREWFILE_PATH — skipping Homebrew bundle."
fi

# 4. Create directories
echo "Creating directories..."
mkdir -p "$HOME/.config"
mkdir -p "$GHREPOS"
mkdir -p "$HOME/Repositories/github.com/work"

# 5. Make sure stow is installed
if ! command -v stow >/dev/null 2>&1; then
  echo "Installing GNU Stow..."
  brew install stow
fi

# 6. Symlink your main shell config
echo "Symlinking .zshrc..."
rm -f "$HOME/.zshrc"
ln -s "$DOTFILES_DIR/zshrc/.zshrc" "$HOME/.zshrc"

# 7. Stow everything
#    If your .stowrc is properly configured, just run stow from $DOTFILES_DIR
echo "Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow .

# 8. Source the zshrc
echo "Sourcing .zshrc..."
source "$HOME/.zshrc"

# 9. Install tmux plugin manager
echo "Installing tmux plugin manager..."
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# 10. Install tmux plugins
echo "Installing tmux plugins..."
"$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"

echo "Done! Your Mac is set up."
