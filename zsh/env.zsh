# Environment variables
export LANG=en_US.UTF-8
export EDITOR="nvim"
export MANPAGER="nvim +Man!"
export VISUAL="$EDITOR"
export GOPATH="$HOME/go"
export KUBECONFIG="$HOME/.kube/config"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export ARCH="$(uname -m)"

# Directory paths
export GARDEN=("$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/The Garden")
export ICLOUD=("$HOME/Library/Mobile Documents/com~apple~CloudDocs")
export REPOS="$HOME/code"
export GITUSER="$USER"
export GHREPOS="$REPOS/$GITUSER"
export XDG_CONFIG_HOME="$HOME"/.config
export DOTFILES="$HOME/code/$GITUSER/dotfiles"

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