# Environment variables
export LANG=en_US.UTF-8
export EDITOR="nvim"
export MANPAGER="nvim +Man!"
export VISUAL="$EDITOR"
export GOPATH="$HOME/go"
export KUBECONFIG="$HOME/.kube/config"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$XDG_CONFIG_HOME/starship/starship.toml}"
export ARCH="$(uname -m)"

# Directory paths
export REPOS="${REPOS:-$HOME/code}"
export GITUSER="${GITUSER:-$USER}"
export GHREPOS="${GHREPOS:-$REPOS/$GITUSER}"
export DOTFILES="${DOTFILES:-$GHREPOS/dotfiles}"
export WORK_REPOS="${WORK_REPOS:-$REPOS/work}"
export ICLOUD="${ICLOUD:-$HOME/Library/Mobile Documents/com~apple~CloudDocs}"
export GARDEN="${GARDEN:-$ICLOUD/Documents/The Garden}"
export SSH_REMOTE_DIR="${SSH_REMOTE_DIR:-$ICLOUD/Documents/ssh}"
export SSH_REMOTE_DIR_ALT="${SSH_REMOTE_DIR_ALT:-$ICLOUD/Documents/SSH}"

# Update PATH
typeset -U path

# Homebrew first (arch-aware)
if [[ $ARCH == arm64 ]]; then
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
else
  path=(/usr/local/bin /usr/local/sbin $path)
fi

# User-level tools
path+=(
  $HOME/.local/bin
  $GOPATH/bin
  $HOME/.cargo/bin
  $HOME/.vimpkg/bin
)

export PATH

# Cache brew prefix (avoid subshell on every startup)
if [[ "$ARCH" == "arm64" ]]; then
  _BREW_PREFIX="/opt/homebrew"
else
  _BREW_PREFIX="/usr/local"
fi
