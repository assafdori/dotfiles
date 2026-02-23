# Key bindings
bindkey '^w' forward-word
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey 'jj' vi-cmd-mode

# ZLE widgets
zle -N finder
bindkey '^f' finder

zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip