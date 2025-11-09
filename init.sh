#!/usr/bin/env bash
set -euo pipefail

# Variables
: "${GHREPOS:="$HOME/code/assafdori"}"
DOTFILES="$GHREPOS/dotfiles"
BREWFILE_PATH="$DOTFILES/homebrew/Brewfile"
SECOND_BRAIN="$HOME/SecondBrain" # adjust if needed
ICLOUD="$HOME/iCloud"            # adjust if needed

# Colored output helpers
info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
success() { printf "\033[1;32m[SUCCESS]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; }

# Slow-print logo function
slow_print() {
  local str="$1"
  local delay="${2:-0.003}"
  while IFS= read -r line; do
    for ((i = 0; i < ${#line}; i++)); do
      printf "%s" "${line:i:1}"
      sleep "$delay"
    done
    printf "\n"
  done <<<"$str"
}

print_logo() {
  slow_print "
          Welcome to the Mac setup script!
           __________                                 
         .'----------\`.                              
         | .--------. |                             
         | |########| |       __________              
         | |########| |      /__________\\             
.--------| \`--------' |------|    --=-- |-------------.
|        \`----,-.-----'      |o ======  |             | 
|       ______|_|_______     |__________|             | Bootstrap MacOS
|      /  %%%%%%%%%%%%  \\                             | Environment
|     /  %%%%%%%%%%%%%%  \\                            | by: Assaf Dori
|     ^^^^^^^^^^^^^^^^^^^^
+-----------------------------------------------------+
"
}

# Spinner for long-running commands
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while kill -0 "$pid" 2>/dev/null; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# Start
print_logo
sleep 1

# Check internet
info "Checking internet connection..."
if ! ping -c 2 google.com &>/dev/null; then
  error "No internet connection. Connect and try again."
  exit 1
else
  success "Internet connection OK."
fi

sleep 0.5
ARCH=$(uname -m)
info "Detected architecture: $ARCH"
sleep 0.5

# Homebrew install
if ! command -v brew >/dev/null 2>&1; then
  info "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# Update Homebrew
info "Updating Homebrew..."
brew update &
spinner $!
success "Homebrew updated."

# Create directories
info "Creating directories..."
mkdir -p "$HOME/.config" "$GHREPOS" "$HOME/code/work"
success "Directories created."

# Brewfile install
if [ -f "$BREWFILE_PATH" ]; then
  info "Installing packages from Brewfile..."
  brew bundle --file="$BREWFILE_PATH" &
  spinner $!
  success "Brewfile packages installed."
else
  warn "No Brewfile found at $BREWFILE_PATH — skipping."
fi

# Ensure stow
if ! command -v stow >/dev/null 2>&1; then
  info "Installing GNU Stow..."
  brew install stow &
  spinner $!
  success "GNU Stow installed."
fi

exit 1

# Symlink shell & git configs
info "Symlinking .zshrc and .gitconfig..."
rm -f "$HOME/.zshrc" "$HOME/.gitconfig"
ln -s "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
ln -s "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
success "Configs symlinked."

# Stow dotfiles
info "Stowing dotfiles..."
cd "$DOTFILES"
stow . &
spinner $!
success "Dotfiles stowed."

# Source zshrc
info "You may now run: source \"$HOME/.zshrc\""

# TPM install
info "Installing tmux plugin manager..."
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" &
spinner $!
success "TPM installed."

info "Installing tmux plugins..."
"$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" &
spinner $!
success "Tmux plugins installed."

# Touch ID for sudo
read -r -p "Enable Touch ID for sudo operations? [y/N] " response
case "$response" in
[yY][eE][sS] | [yY])
  sudo sh -c 'sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template > /etc/pam.d/sudo_local'
  success "Touch ID enabled for sudo."
  ;;
*)
  warn "Skipped Touch ID setup."
  ;;
esac

# Fonts
info "Installing fonts..."
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"
cp ~/icloud/Documents/Fonts/* "$FONT_DIR/" 2>/dev/null || warn "No fonts found to copy."
success "Fonts installed."

# Symbolic links
info "Creating symbolic links for SecondBrain and iCloud..."
ln -sf "$SECOND_BRAIN" ~/garden
ln -sf "$ICLOUD" ~/icloud
success "Symbolic links created."

# SSH bootstrap
info "Bootstrapping SSH keys..."
SSH_SOURCE="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/ssh"
SSH_DEST="$HOME/.ssh"
SSH_CONFIG_SOURCE="$DOTFILES/ssh/config"
mkdir -p "$SSH_DEST"
if [ -f "$SSH_CONFIG_SOURCE" ]; then
  ln -sf "$SSH_CONFIG_SOURCE" "$SSH_DEST/config"
  success "SSH config symlinked."
else
  warn "No SSH config found, skipping."
fi
cp "$SSH_SOURCE"/* "$SSH_DEST"/ 2>/dev/null || warn "No SSH keys found to copy."
chmod 700 "$SSH_DEST"
chmod 600 "$SSH_DEST"/* 2>/dev/null || true
chmod 644 "$SSH_DEST"/*.pub 2>/dev/null || true
eval "$(ssh-agent -s)"
for key in "$SSH_DEST"/*; do [[ "$key" != *.pub ]] && ssh-add "$key" || true; done
success "SSH keys bootstrapped."

success "🎉 Mac setup complete!"
