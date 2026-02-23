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
TOTAL_STEPS=12
CURRENT_STEP=0

# Colored output helpers with emojis
info() {
	printf "${BLUE}ℹ️  [INFO]${RESET} %b\n" "$*"
	sleep 0.5
}
success() {
	printf "${GREEN}✅ [SUCCESS]${RESET} %b\n" "$*"
	sleep 0.8
}
warn() {
	printf "${YELLOW}⚠️  [WARN]${RESET} %b\n" "$*"
	sleep 0.5
}
error() {
	printf "${RED}❌ [ERROR]${RESET} %b\n" "$*" >&2
}

# Step counter
step() {
	CURRENT_STEP=$((CURRENT_STEP + 1))
	printf "\n${BOLD}[Step %d/%d]${RESET} ${BOLD}%s${RESET}\n" "$CURRENT_STEP" "$TOTAL_STEPS" "$*"
	sleep 0.4
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
	printf "\n${GREEN}${BOLD}🎉 Setup completed successfully!${RESET}\n"
	printf "${CYAN}Your macOS development environment is ready!${RESET}\n\n"
}
: "${GHREPOS:="$HOME/code/$USER"}"
DOTFILES="$GHREPOS/dotfiles"
BREWFILE_PATH="$DOTFILES/homebrew/Brewfile"
SECOND_BRAIN="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/The Garden" # adjust if needed
ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs"                            # adjust if needed

# Verify dotfiles directory exists
if [ ! -d "$DOTFILES" ]; then
	error "Dotfiles directory not found at ${BOLD}$DOTFILES${RESET}"
	error "Please run ${BOLD}bootstrap.sh${RESET} first or ensure the dotfiles are cloned"
	exit 1
fi

# Enhanced logo function with color
print_logo() {
	printf "\n${BOLD}"
	cat <<"EOF"
+----------------------------------------------------------+
|                                                          |
|         💻 MACOS DEVELOPMENT ENVIRONMENT SETUP 💻        |
|                                                          |
|            Welcome to the Mac setup script!              |
|          Bootstrap MacOS Development Environment         |
|                    by: Assaf Dori                        |
|                                                          |
+----------------------------------------------------------+
EOF
	printf "${RESET}\n"
}

# Spinner for long-running commands (enhanced with emoji)
spinner() {
	local pid=$1
	local delay=0.1
	local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
	while kill -0 "$pid" 2>/dev/null; do
		local temp=${spinstr#?}
		printf " ${BOLD}%s${RESET}  " "${spinstr:0:1}"
		spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b\b"
	done
	printf "    \b\b\b\b"
}

# Start
print_logo
sleep 0.5

step "Checking system requirements"
info "Checking internet connection..."
if ! ping -c 2 google.com &>/dev/null; then
	error "No internet connection. Connect and try again"
	exit 1
else
	success "Internet connection OK"
fi

ARCH=$(uname -m)
info "Detected architecture: ${BOLD}$ARCH${RESET}"
add_summary "System architecture: $ARCH"

# Verify Homebrew is installed (should be done by bootstrap.sh)
if ! command -v brew >/dev/null 2>&1; then
	error "Homebrew not found. Please run ${BOLD}bootstrap.sh${RESET} first"
	exit 1
fi
success "Homebrew found"

step "Updating Homebrew"
info "Updating package manager..."
brew update &
spinner $!
success "Homebrew updated"
add_summary "Updated Homebrew to latest version"

step "Creating directories"
# Check if directories already exist
if [ -d "$HOME/.config" ] && [ -d "$GHREPOS" ] && [ -d "$HOME/code/work" ]; then
	info "Directory structure already exists"
	add_summary "Directory structure (already present)"
else
	info "Setting up ${BOLD}~/.config${RESET}, ${BOLD}~/code${RESET} structures..."
	mkdir -p "$HOME/.config" "$GHREPOS" "$HOME/code/work"
	success "Directories created"
	add_summary "Created directory structure"
fi

step "Installing Brewfile packages"
if [ -f "$BREWFILE_PATH" ]; then
	info "Installing packages from ${BOLD}Brewfile${RESET}..."
	info "This may take several minutes..."
	brew bundle --upgrade --file="$BREWFILE_PATH" &
	spinner $!
	success "Brewfile packages installed"
	add_summary "Installed all Brewfile packages"
else
	warn "No Brewfile found at ${BOLD}$BREWFILE_PATH${RESET} — skipping"
fi

step "Installing GNU Stow"
if ! command -v stow >/dev/null 2>&1; then
	info "Installing GNU Stow for symlink management..."
	brew install stow &
	spinner $!
	success "GNU Stow installed"
	add_summary "Installed GNU Stow"
else
	success "GNU Stow already installed"
fi

step "Symlinking shell and git configs"
info "Linking ${BOLD}.zshrc${RESET} and ${BOLD}.gitconfig${RESET}..."
rm -f "$HOME/.zshrc" "$HOME/.gitconfig"
ln -s "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
ln -s "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
success "Configs symlinked"
add_summary "Symlinked shell and git configurations"

step "Stowing dotfiles"
info "Creating symlinks for all dotfiles..."
cd "$DOTFILES"
if stow . 2>&1; then
	success "Dotfiles stowed"
	add_summary "Stowed all dotfiles"
else
	warn "Some dotfiles may have conflicts. Continuing anyway..."
	add_summary "Stowed dotfiles (with warnings)"
fi

step "Installing tmux plugin manager"
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
	info "Cloning TPM repository..."
	git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm" &
	spinner $!
	success "TPM installed"
	add_summary "Installed tmux plugin manager (TPM)"
else
	success "TPM already installed"
fi

info "Installing tmux plugins..."
"$HOME/.config/tmux/plugins/tpm/scripts/install_plugins.sh" &
spinner $!
success "Tmux plugins installed"
add_summary "Installed all tmux plugins"

step "Configuring Touch ID for sudo"
# Check if Touch ID is already enabled
if sudo grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local 2>/dev/null; then
	info "Touch ID for sudo already enabled"

	# Check if pam-reattach is also configured (needed for tmux)
	if sudo grep -q "^auth.*pam_reattach.so" /etc/pam.d/sudo_local 2>/dev/null; then
		info "pam-reattach already configured for tmux support"
		add_summary "Touch ID for sudo (already enabled with tmux support)"
	else
		info "Adding pam-reattach for tmux support..."
		# Find the pam_reattach.so path
		if [ -f "/opt/homebrew/lib/pam/pam_reattach.so" ]; then
			PAM_REATTACH_PATH="/opt/homebrew/lib/pam/pam_reattach.so"
		elif [ -f "/usr/local/lib/pam/pam_reattach.so" ]; then
			PAM_REATTACH_PATH="/usr/local/lib/pam/pam_reattach.so"
		else
			warn "pam_reattach.so not found - install with: brew install pam-reattach"
			add_summary "Touch ID for sudo (tmux support needs pam-reattach)"
		fi

		if [ -n "${PAM_REATTACH_PATH:-}" ]; then
			# Add pam_reattach.so before pam_tid.so
			sudo sed -i '' "s|^auth.*sufficient.*pam_tid\.so|auth       optional       $PAM_REATTACH_PATH\nauth       sufficient     pam_tid.so|" /etc/pam.d/sudo_local
			success "pam-reattach configured - Touch ID now works in tmux"
			add_summary "Configured pam-reattach for Touch ID in tmux"
		fi
	fi
elif [ -t 0 ]; then
	# Only prompt if stdin is a terminal
	printf "\n"
	read -r -p "$(printf "${CYAN}Enable Touch ID for sudo operations? [y/N]${RESET} ")" response
	case "$response" in
	[yY][eE][sS] | [yY])
		# Find the pam_reattach.so path
		if [ -f "/opt/homebrew/lib/pam/pam_reattach.so" ]; then
			PAM_REATTACH_PATH="/opt/homebrew/lib/pam/pam_reattach.so"
		elif [ -f "/usr/local/lib/pam/pam_reattach.so" ]; then
			PAM_REATTACH_PATH="/usr/local/lib/pam/pam_reattach.so"
		else
			PAM_REATTACH_PATH=""
		fi

		if [ -n "$PAM_REATTACH_PATH" ]; then
			# Create sudo_local with both pam_reattach and pam_tid
			sudo sh -c "cat > /etc/pam.d/sudo_local <<EOF
# sudo_local: local config file which survives system update and is included for sudo
# pam_reattach.so enables Touch ID to work inside tmux sessions
auth       optional       $PAM_REATTACH_PATH
# pam_tid.so enables Touch ID for sudo
auth       sufficient     pam_tid.so
EOF"
			success "Touch ID enabled for sudo (with tmux support)"
			add_summary "Enabled Touch ID for sudo with tmux support"
		else
			# Fallback to just pam_tid if pam_reattach not found
			if sudo sh -c 'sed "s/^#auth.*pam_tid\.so/auth       sufficient     pam_tid.so/" /etc/pam.d/sudo_local.template > /etc/pam.d/sudo_local' 2>/dev/null; then
				success "Touch ID enabled for sudo"
				warn "Install pam-reattach for tmux support: brew install pam-reattach"
				add_summary "Enabled Touch ID for sudo (tmux support requires pam-reattach)"
			else
				warn "Failed to enable Touch ID (may require manual setup)"
			fi
		fi
		;;
	*)
		warn "Skipped Touch ID setup"
		;;
	esac
else
	warn "Skipping Touch ID setup (non-interactive mode)"
fi

step "Creating symbolic links"
if [ -L "$HOME/garden" ] && [ -L "$HOME/icloud" ]; then
	info "Symbolic links already exist, updating..."
	ln -sfn "$SECOND_BRAIN" ~/garden
	ln -sfn "$ICLOUD" ~/icloud
	info "Symbolic links updated"
	add_summary "Updated ~/garden and ~/icloud symlinks"
else
	info "Linking ${BOLD}~/garden${RESET} to Second Brain..."
	ln -sfn "$SECOND_BRAIN" ~/garden
	info "Linking ${BOLD}~/icloud${RESET} to iCloud Drive..."
	ln -sfn "$ICLOUD" ~/icloud
	success "Symbolic links created"
	add_summary "Created ~/garden and ~/icloud symlinks"
fi

step "Installing fonts"
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"
if [ -d "$ICLOUD/Documents/Fonts" ] && [ -n "$(ls -A "$ICLOUD/Documents/Fonts" 2>/dev/null)" ]; then
	info "Copying fonts from iCloud..."
	font_count=$(ls -1 "$ICLOUD/Documents/Fonts" 2>/dev/null | wc -l | tr -d ' ')
	if cp ~/icloud/Documents/Fonts/* "$FONT_DIR/" 2>/dev/null; then
		success "Fonts installed (${font_count} files)"
		add_summary "Installed ${font_count} fonts from iCloud"
	else
		warn "Failed to copy some fonts"
	fi
else
	warn "No fonts found in iCloud to copy"
fi

step "Setting up SSH config"
SSH_DEST="$HOME/.ssh"
SSH_CONFIG_SOURCE="$DOTFILES/ssh/config"
mkdir -p "$SSH_DEST"

if [ -f "$SSH_CONFIG_SOURCE" ]; then
	info "Symlinking SSH config from dotfiles..."
	ln -sf "$SSH_CONFIG_SOURCE" "$SSH_DEST/config"
	success "SSH config symlinked (replaced minimal config from bootstrap)"
	add_summary "Configured SSH with dotfiles config"
else
	warn "No SSH config found in dotfiles, skipping"
fi

# Final summary
print_summary

# Note about .zshrc
section "🎯 NEXT STEPS"
printf "\n${GREEN}✅ Your dotfiles are now configured!${RESET}\n\n"
printf "  ${BLUE}•${RESET} New ${BOLD}zsh${RESET} terminal sessions will automatically load your configuration\n"
if [ -n "${ZSH_VERSION:-}" ]; then
	printf "  ${BLUE}•${RESET} Since you're in zsh, run ${BOLD}${UNDERLINE}source ~/.zshrc${RESET} to load the config now\n"
fi
printf "\n${CYAN}Enjoy your freshly configured macOS development environment! 🚀${RESET}\n\n"
