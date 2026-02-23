#!/usr/bin/env bash
set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# Progress tracking
TOTAL_STEPS=7
CURRENT_STEP=0

# Colored output helpers with emojis
info() {
  printf "${BLUE}ℹ️  [INFO]${RESET} %b\n" "$*"
  sleep 0.8
}
success() {
  printf "${GREEN}✅ [SUCCESS]${RESET} %b\n" "$*"
  sleep 1.2
}
warn() {
  printf "${YELLOW}⚠️  [WARN]${RESET} %b\n" "$*"
  sleep 0.8
}
error() {
  printf "${RED}❌ [ERROR]${RESET} %b\n" "$*" >&2
}

# Step counter
step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  printf "\n${BOLD}[Step %d/%d]${RESET} ${BOLD}%s${RESET}\n" "$CURRENT_STEP" "$TOTAL_STEPS" "$*"
  sleep 0.6
}

# Section header with border
section() {
  local text="$1"
  local width=60
  printf "\n${BOLD}"
  printf -- '-%.0s' $(seq 1 $width)
  printf "\n  %s\n" "$text"
  printf -- '-%.0s' $(seq 1 $width)
  printf "${RESET}\n"
}

# Progress bar
progress_bar() {
  local current=$1
  local total=$2
  local width=40
  local percentage=$((current * 100 / total))
  local filled=$((width * current / total))
  local empty=$((width - filled))

  printf "\r${BOLD}["
  printf '#%.0s' $(seq 1 $filled)
  printf -- '-%.0s' $(seq 1 $empty)
  printf "]${RESET} ${percentage}%%"

  if [ "$current" -eq "$total" ]; then
    printf "\n"
  fi
}

# Banner
print_banner() {
  printf "\n${BOLD}"
  cat <<"EOF"
+----------------------------------------------------------+
|                                                          |
|        🚀 BOOTSTRAP SCRIPT FOR MACOS DOTFILES 🚀         |
|                                                          |
|              Setting up your development                 |
|                   environment...                         |
|                                                          |
+----------------------------------------------------------+
EOF
  printf "${RESET}\n"
}

# Summary tracking
declare -a SUMMARY_ITEMS=()
add_summary() {
  SUMMARY_ITEMS+=("$1")
}

# Print summary at the end
print_summary() {
  section "📊 INSTALLATION SUMMARY"
  printf "\n${BOLD}Completed actions:${RESET}\n\n"
  for item in "${SUMMARY_ITEMS[@]}"; do
    printf "  ${GREEN}✓${RESET} %s\n" "$item"
  done
  printf "\n${GREEN}${BOLD}🎉 Bootstrap completed successfully!${RESET}\n"
  printf "${CYAN}Next: Run ${UNDERLINE}setup.sh${RESET}${CYAN} to complete installation${RESET}\n\n"
}

# Start
print_banner

step "Creating base directories"
if [ -d "$HOME/code" ] && [ -d "$HOME/.ssh" ]; then
  info "Base directories already exist"
  chmod 700 "$HOME/.ssh" 2>/dev/null || true
  add_summary "Base directories (already present)"
else
  info "Creating ${BOLD}~/code${RESET} and ${BOLD}~/.ssh${RESET}..."
  mkdir -p "$HOME/code" "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  success "Base directories created"
  add_summary "Created base directories (~/code, ~/.ssh)"
fi

step "Installing Xcode command line tools"
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode CLI tools (this may take a while)..."
  xcode-select --install
  success "Xcode CLI tools installed"
  add_summary "Installed Xcode command line tools"
else
  success "Xcode CLI already installed"
  add_summary "Xcode command line tools (already present)"
fi

step "Installing Homebrew"
ARCH=$(uname -m)
info "Detected architecture: ${BOLD}$ARCH${RESET}"
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
  success "Homebrew installed"
  add_summary "Installed Homebrew package manager"
else
  success "Homebrew already installed"
  add_summary "Homebrew (already present)"
fi

step "Installing Git"
if ! command -v git >/dev/null 2>&1; then
  info "Installing Git via Homebrew..."
  brew install git
  success "Git installed"
  add_summary "Installed Git version control"
else
  success "Git already installed"
  add_summary "Git (already present)"
fi

step "Setting up SSH keys from iCloud"
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
  # Count files first
  total_keys=$(find "$SSH_REMOTE" -maxdepth 1 -type f | wc -l | tr -d ' ')
  info "Copying ${BOLD}${total_keys} SSH keys${RESET} from ${BOLD}iCloud${RESET}..."

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
  success "SSH keys copied to ${BOLD}$SSH_DEST${RESET} (${total_keys} files)"
  add_summary "Copied SSH keys from iCloud (${total_keys} files)"
else
  warn "No SSH keys found at iCloud location"
  warn "Please copy SSH keys manually to ${BOLD}~/.ssh${RESET}"
  add_summary "SSH keys (manual setup required)"
fi

# Create minimal SSH config for keychain persistence (will be replaced by full config in setup.sh)
if [ ! -f "$SSH_DEST/config" ]; then
  info "Creating minimal SSH config for keychain persistence..."
  cat >"$SSH_DEST/config" <<'EOF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
EOF
  chmod 600 "$SSH_DEST/config"
  success "Minimal SSH config created"
fi

# Add keys to ssh-agent and keychain
info "Loading SSH keys into ssh-agent..."
eval "$(ssh-agent -s)"
keys_added=0
for key in "$SSH_DEST"/*; do
  # Only add private keys (files that are not .pub, not config, and are regular files)
  if [ -f "$key" ] && [[ "$key" != *.pub ]] && [[ "$(basename "$key")" != "config" ]] && [[ "$(basename "$key")" != "known_hosts"* ]]; then
    # Use --apple-use-keychain on macOS 12.2+ for keychain integration
    if ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add -K "$key" 2>/dev/null || ssh-add "$key" 2>/dev/null; then
      keys_added=$((keys_added + 1))
    else
      warn "Failed to add key: $(basename "$key")"
    fi
  fi
done
success "SSH keys loaded into ssh-agent and keychain ($keys_added keys)"

step "Cloning dotfiles repository"
DOTFILES_DIR="$HOME/code/$USER/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  info "Cloning dotfiles from ${BOLD}github.com/assafdori/dotfiles${RESET}..."
  if git clone git@github.com:assafdori/dotfiles.git "$DOTFILES_DIR"; then
    success "Dotfiles cloned to ${BOLD}$DOTFILES_DIR${RESET}"
    add_summary "Cloned dotfiles repository"
  else
    error "Failed to clone dotfiles repository"
    error "Please check your SSH keys and try again"
    exit 1
  fi
else
  info "Dotfiles repo already exists at ${BOLD}$DOTFILES_DIR${RESET}"
  # Check if we can access the repo
  if [ -d "$DOTFILES_DIR/.git" ]; then
    if git -C "$DOTFILES_DIR" remote get-url origin &>/dev/null; then
      info "Repository is accessible"
      add_summary "Dotfiles repository (already present)"
    else
      warn "Repository exists but may not be properly configured"
    fi
  fi
fi

# Print summary
print_summary

# Run setup.sh if it exists
section "🚀 LAUNCHING MAIN SETUP"
if [ -f "$DOTFILES_DIR/setup.sh" ]; then
  info "Starting dotfiles installation..."
  sleep 2
  # Forward stdin/stdout/stderr properly
  bash "$DOTFILES_DIR/setup.sh" </dev/tty
else
  warn "setup.sh not found"
  warn "Please run it manually from ${BOLD}$DOTFILES_DIR${RESET}"
fi
