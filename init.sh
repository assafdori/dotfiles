#!/usr/bin/env bash

set -euo pipefail

# Variables
: "${GHREPOS:="$HOME/code/assafdori"}"
DOTFILES="$GHREPOS/dotfiles"
BREWFILE_PATH="$DOTFILES/homebrew/Brewfile"

print_logo() {
  cat <<"EOF"

          Welcome to the Mac setup script!
           __________                                 
         .'----------`.                              
         | .--------. |                             
         | |########| |       __________              
         | |########| |      /__________\             
.--------| `--------' |------|    --=-- |-------------.
|        `----,-.-----'      |o ======  |             | 
|       ______|_|_______     |__________|             | Bootstrap MacOS
|      /  %%%%%%%%%%%%  \                             | Envrionment
|     /  %%%%%%%%%%%%%%  \                            | 
|     ^^^^^^^^^^^^^^^^^^^^                            | by: Assaf Dori
+-----------------------------------------------------+ 
EOF
}

print_logo

sleep 2

# Check internet connection
echo "🌐 Checking internet connection..."
sleep 1
if ! ping -c 3 google.com &>/dev/null; then
  echo "❌ No internet connection. Please connect to the internet and try again."
  exit 1
else
  echo "✅ Internet connection is good."
fi

sleep 2

echo "⚙️ Setting up your Mac..."
sleep 1

# Detect architecture for Apple Silicon vs Intel
ARCH=$(uname -m)

# 1. Check for Homebrew and install if we don't have it
if ! command -v brew >/dev/null 2>&1; then
  echo "🍺 Homebrew not found. Installing..."
  sleep 1
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
echo "🔄 Updating Homebrew..."
sleep 1
brew update

# 3. Create directories
echo "📁 Creating directories..."
sleep 1
echo "Creating $HOME/.config"
mkdir -p "$HOME/.config"
echo "Creating $GHREPOS"
mkdir -p "$GHREPOS"
echo "Creating $HOME/code/work"
mkdir -p "$HOME/code/work"

# 4. Ensure Homebrew Bundle is tapped and run bundle
if [ -f "$BREWFILE_PATH" ]; then
  echo "📦 Installing packages from Brewfile..."
  sleep 1
  brew bundle --file="$BREWFILE_PATH"
else
  echo "⚠️ No Brewfile found at $BREWFILE_PATH — skipping Homebrew bundle."
  sleep 1
fi

# 5. Make sure stow is installed
if ! command -v stow >/dev/null 2>&1; then
  echo "📦 Installing GNU Stow..."
  sleep 1
  brew install stow
fi

# 6. Symlink your main shell config
echo "🔗 Symlinking .zshrc..."
sleep 1
rm -f "$HOME/.zshrc"
ln -s "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"

# 7. Symlink your main git config
echo "🔗 Symlinking .gitconfig..."
sleep 1
rm -f "$HOME/.gitconfig"
ln -s "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# 8. Stow everything
#    If your .stowrc is properly configured, just run stow from $DOTFILES_DIR
echo "📦 Stowing dotfiles..."
sleep 1
cd "$DOTFILES"
stow .

# 9. Source the zshrc
echo "✅ Configuration complete. You'll need to restart your shell or run:"
sleep 1
echo "source \"$HOME/.zshrc\""
sleep 2

# 10. Install tmux plugin manager
echo "📦 Installing tmux plugin manager..."
sleep 1
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# 11. Install tmux plugins
echo "🔌 Installing tmux plugins..."
sleep 1
"$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"

## 12. Ask if to enable Touch ID for sudo
read -r -p "Enable Touch ID for sudo operations? [y/N] " response
case "$response" in
[yY][eE][sS] | [yY])
  sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
  echo "✅ Touch ID for sudo enabled."
  ;;
*)
  echo "❌ Skipped."
  ;;
esac

sleep 1

## 13. Install Fonts
echo "🎨 Installing fonts..."
sleep 1
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"
cp ~/icloud/Documents/Fonts/ "$FONT_DIR"

# 14. Symbolic links
echo "🔗 Creating symbolic links..."
sleep 1
ln -sf "$SECOND_BRAIN" ~/garden
ln -sf "$ICLOUD" ~/icloud

# 15. Bootstrap SSH keys
echo "🔐 Bootstrapping SSH keys and config..."
sleep 1

SSH_SOURCE="/Users/assafdori/Library/Mobile Documents/com~apple~CloudDocs/Documents/ssh"
SSH_DEST="$HOME/.ssh"

# Symlink SSH config
SSH_CONFIG_SOURCE="$DOTFILES/ssh/config"
SSH_DEST="$HOME/.ssh"

if [ -f "$SSH_CONFIG_SOURCE" ]; then
  echo "🔗 Symlinking SSH config..."
  sleep 1
  mkdir -p "$SSH_DEST"
  rm -f "$SSH_DEST/config"
  ln -s "$SSH_CONFIG_SOURCE" "$SSH_DEST/config"
  echo "✅ SSH config symlinked successfully."
else
  echo "❌ No SSH config found at $SSH_CONFIG_SOURCE, skipping symlink."
  sleep 1
fi

# Copy keys from iCloud folder
cp "$SSH_SOURCE"/* "$SSH_DEST"/
sleep 1

# Fix permissions
chmod 700 "$SSH_DEST"
chmod 600 "$SSH_DEST"/*
chmod 644 "$SSH_DEST"/*.pub 2>/dev/null || true

# Start ssh-agent if not running
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)"
fi

# Add all private keys (optional)
for key in "$SSH_DEST"/*; do
  if [[ "$key" != *.pub ]]; then
    ssh-add "$key" || true
  fi
done
echo "🔑 SSH keys bootstrapped."
sleep 1

echo "🎉 Done! Your Mac is set up."
