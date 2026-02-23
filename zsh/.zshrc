# Resolve directory of this file (follows symlinks)
ZSHRC_DIR="${${(%):-%N}:A:h}"

# Source modular config files
source "$ZSHRC_DIR/env.zsh"           # Environment variables, PATH, brew prefix
source "$ZSHRC_DIR/options.zsh"       # setopt, zstyle, compinit
source "$ZSHRC_DIR/completions.zsh"   # Lazy-load completions (kubectl, aws, gcloud, etc.)
source "$ZSHRC_DIR/plugins.zsh"       # Plugin sourcing (autosuggestions, starship, fzf, etc.)
source "$ZSHRC_DIR/functions.zsh"     # Shell functions
source "$ZSHRC_DIR/aliases.zsh"       # Aliases
source "$ZSHRC_DIR/keybindings.zsh"   # Key bindings (after functions — registers zle widgets)
