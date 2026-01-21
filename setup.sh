#!/usr/bin/env bash
set -euo pipefail

# Variables
: "${GHREPOS:="$HOME/code/$USER"}"
DOTFILES="$GHREPOS/dotfiles"
BREWFILE_PATH="$DOTFILES/homebrew/Brewfile"
SECOND_BRAIN="$HOME/SecondBrain" # adjust if needed
ICLOUD="$HOME/iCloud"            # adjust if needed

# Verify dotfiles directory exists
if [ ! -d "$DOTFILES" ]; then
  error "Dotfiles directory not found at $DOTFILES"
  error "Please run bootstrap.sh first or ensure the dotfiles are cloned."
  exit 1
fi

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
|       ______|_|_______     |__________|              | Bootstrap MacOS
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

# Verify Homebrew is installed (should be done by bootstrap.sh)
if ! command -v brew >/dev/null 2>&1; then
  error "Homebrew not found. Please run bootstrap.sh first."
  exit 1
fi
success "Homebrew found."

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

# Symlink shell & git configs
info "Symlinking .zshrc and .gitconfig..."
rm -f "$HOME/.zshrc" "$HOME/.gitconfig"
ln -s "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
ln -s "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
success "Configs symlinked."

# Stow dotfiles
info "Stowing dotfiles..."
cd "$DOTFILES"
stow . 2>&1 && success "Dotfiles stowed." || warn "Some dotfiles may have conflicts. Continuing anyway..."

# TPM install
info "Installing tmux plugin manager..."
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm" &
  spinner $!
  success "TPM installed."
else
  success "TPM already installed."
fi

info "Installing tmux plugins..."
"$HOME/.config/tmux/plugins/tpm/scripts/install_plugins.sh" &
spinner $!
success "Tmux plugins installed."

# Touch ID for sudo
if [ -t 0 ]; then
  # Only prompt if stdin is a terminal
  info ""
  read -r -p "Enable Touch ID for sudo operations? [y/N] " response
  case "$response" in
  [yY][eE][sS] | [yY])
    sudo sh -c 'sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template > /etc/pam.d/sudo_local' 2>/dev/null && success "Touch ID enabled for sudo." || warn "Failed to enable Touch ID (may require manual setup)."
    ;;
  *)
    warn "Skipped Touch ID setup."
    ;;
  esac
else
  warn "Skipping Touch ID setup (non-interactive mode)."
fi

# Symbolic links (create before fonts so fonts can use icloud symlink)
info "Creating symbolic links for SecondBrain and iCloud..."
ln -sf "$SECOND_BRAIN" ~/garden
ln -sf "$ICLOUD" ~/icloud
success "Symbolic links created."

# Fonts (after icloud symlink is created)
info "Installing fonts..."
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"
if [ -d ~/icloud/Documents/Fonts ] && [ -n "$(ls -A ~/icloud/Documents/Fonts 2>/dev/null)" ]; then
  cp ~/icloud/Documents/Fonts/* "$FONT_DIR/" 2>/dev/null || warn "Failed to copy some fonts."
  success "Fonts installed."
else
  warn "No fonts found to copy."
fi

# SSH config (replace minimal config from bootstrap.sh with full config from dotfiles)
info "Setting up SSH config..."
SSH_DEST="$HOME/.ssh"
SSH_CONFIG_SOURCE="$DOTFILES/ssh/config"
mkdir -p "$SSH_DEST"

if [ -f "$SSH_CONFIG_SOURCE" ]; then
  ln -sf "$SSH_CONFIG_SOURCE" "$SSH_DEST/config"
  success "SSH config symlinked (replaced minimal config from bootstrap)."
else
  warn "No SSH config found in dotfiles, skipping."
fi

success "🎉 Mac setup complete!"

# Note about .zshrc
info ""
info "Your dotfiles are now configured!"
info "New zsh terminal sessions will automatically load your configuration."
if [ -n "${ZSH_VERSION:-}" ]; then
  info "Since you're in zsh, you can run 'source ~/.zshrc' to load the config in this session."
fi
info ""
