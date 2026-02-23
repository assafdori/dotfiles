# ZSH configuration
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
ZSH_COMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump-${HOST}"
autoload -Uz compinit bashcompinit
if [[ -n "$ZSH_COMPDUMP"(#qN.mh+24) ]]; then
  compinit -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP" -C
fi
bashcompinit