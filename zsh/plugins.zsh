# Plugin sourcing
source ${_BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Initialize starship prompt
eval "$(starship init zsh)"

# Load additional tools
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# thefuck lazy wrapper - loads on first use
if (( $+commands[thefuck] )); then
  fuck() {
    unfunction fuck
    eval $(thefuck --alias)
    fuck "$@"
  }
fi

# zoxide lazy wrappers - loads on first use of z or zi
if (( $+commands[zoxide] )); then
  z() {
    unfunction z zi
    eval "$(zoxide init zsh)"
    z "$@"
  }

  zi() {
    unfunction z zi
    eval "$(zoxide init zsh)"
    zi "$@"
  }
fi

eval "$(atuin init zsh)"

# Source zsh-syntax-highlighting last (must wrap all widgets after they're registered)
source ${_BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh