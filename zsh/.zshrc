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

# Autoload custom functions
ZSHRC_DIR="${${(%):-%N}:A:h}"
fpath=("$ZSHRC_DIR/functions" $fpath)
autoload -Uz awsprofile gcpprofile gcpproject gcpdrop devops

# Cache brew prefix (avoid subshell on every startup)
if [[ "$ARCH" == "arm64" ]]; then
  _BREW_PREFIX="/opt/homebrew"
else
  _BREW_PREFIX="/usr/local"
fi

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

# kubectl lazy-load completion
if (( $+commands[kubectl] )); then
  _kubectl_lazy() {
    unfunction _kubectl_lazy
    source <(command kubectl completion zsh)
    _kubectl "$@"
  }
  compdef _kubectl_lazy kubectl
fi

# AWS CLI autocompletion
if [[ "$ARCH" == "arm64" ]]; then
  # Apple Silicon
  complete -C '/opt/homebrew/bin/aws_completer' aws
elif [[ "$ARCH" == "x86_64" ]]; then
  # Intel Macs
  complete -C '/usr/local/bin/aws_completer' aws
fi

# gcloud lazy-load (path + completion)
if (( $+commands[gcloud] )); then
  _gcloud_lazy() {
    unfunction _gcloud_lazy
    
    # Source path and completion based on arch
    if [[ "$ARCH" == "arm64" ]]; then
      [[ -f /opt/homebrew/share/google-cloud-sdk/path.zsh.inc ]] && source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
      [[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ]] && source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
    elif [[ "$ARCH" == "x86_64" ]]; then
      [[ -f /usr/local/share/google-cloud-sdk/path.zsh.inc ]] && source /usr/local/share/google-cloud-sdk/path.zsh.inc
      [[ -f /usr/local/share/google-cloud-sdk/completion.zsh.inc ]] && source /usr/local/share/google-cloud-sdk/completion.zsh.inc
    fi
    
    _gcloud "$@"
  }
  compdef _gcloud_lazy gcloud
fi

# Plugin sourcing
source ${_BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Key bindings
bindkey '^w' forward-word
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey 'jj' vi-cmd-mode

# Initialize starship prompt
eval "$(starship init zsh)"

# Base aliases
alias la=tree
alias cat="bat"
alias cl='clear'
alias l="eza -l --icons --git -a"
alias ls="eza --icons"
alias lt="eza --tree --level=2 --long --icons --git"
alias of="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' | xargs nvim"
alias cp="cp -riv"
alias rm="rm -i"
alias http="xh"
alias rr='ranger'
alias ff="fastfetch"
alias v="nvim"


# Git aliases
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gs="git status --short"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(red)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

# Docker aliases
alias dco="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"
alias minikube-start="minikube start --addons=metrics-server"

# Directory navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias garden="cd \$GARDEN"
alias icloud="cd \$ICLOUD"
alias xdg="cd \"$XDG_CONFIG_HOME/\""
alias repos="cd $REPOS"
alias ghrepos="cd $GHREPOS"
alias work="cd $REPOS/work/"

# Kubernetes aliases
alias k="kubectl"
alias ka="kubectl apply -f"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kl="kubectl logs"
alias kgpo="kubectl get pod"
alias kgd="kubectl get deployments"
alias kc="kubectx"
alias kns="kubens"
alias kl="kubectl logs -f"
alias ke="kubectl exec -it"
alias kcns='kubectl config set-context --current --namespace'
alias k8s='nvim +"lua require(\"kubectl\").open()"'

# Terraform aliases
alias tf="terraform"
alias tfsl="terraform state list"
alias tfdev="terraform apply -var-file=dev.tfvars"
alias tfprod="terraform apply -var-file=prod.tfvars"

# Tmux aliases
alias ta="tmux attach || tmux new -A -s default"
alias tn="tmux new-session -s \$(pwd | sed 's/.*\///g')"
alias td="tmux detach"
alias mat='osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'

# Password generation
pg() {
  local password
  password=$(pwgen -sy -1 15)
  printf "%s" "$password" | pbcopy
  echo "Password: $password (copied to clipboard)"
}

# Find and copy IP address to clipboard
ip() {
  local ip_address
  ip_address=$(curl -s4 https://ip.me)
  printf "%s" "$ip_address" | pbcopy   # no newline
  echo "IP address: $ip_address (copied to clipboard)"
}

# Cloud aliases
alias aws-profile=awsprofile
alias gcp-profile=gcpprofile
alias gcp-project=gcpproject
alias gcp-drop=gcpdrop

# Sesh session management
function ss() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡ attach to session > ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

# Copy-cat function: cap
cap() {
  # If no arguments and nothing on stdin, show usage
  if [[ -t 0 && $# -eq 0 ]]; then
    echo "Usage: cap [file ...]"
    return 1
  fi

  if [[ $# -gt 0 ]]; then
    # Remove trailing whitespace/newlines before copying
    content=$(cat "$@" | sed -e 's/[[:space:]]*$//')
    printf "%s" "$content" | pbcopy
    echo "Copied contents of: $* to clipboard"
  else
    # Handle stdin input
    content=$(cat | sed -e 's/[[:space:]]*$//')
    printf "%s" "$content" | pbcopy
    echo "Copied input from stdin to clipboard"
  fi
}

# Finder function: open current directory in Finder
finder() {
    open .
}
zle -N finder
bindkey '^f' finder

# Navigation functions
cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

# Yank to the system clipboard
function vi-yank-xclip {
    zle vi-yank
   echo "$CUTBUFFER" | pbcopy -i
}
zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip

# Duckduckgo search
function ddg() {
    open "https://duckduckgo.com/?q=$*"
}

# Google search
function google() {
    open "https://www.google.com/search?q=$*"
}

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

# stern lazy-load completion
if (( $+commands[stern] )); then
  _stern_lazy() {
    unfunction _stern_lazy
    source <(command stern --completion=zsh)
    _stern "$@"
  }
  compdef _stern_lazy stern
fi

# helm lazy-load completion
if (( $+commands[helm] )); then
  _helm_lazy() {
    unfunction _helm_lazy
    source <(command helm completion zsh)
    _helm "$@"
  }
  compdef _helm_lazy helm
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

# Terraform completion
if [[ "$ARCH" == "arm64" ]]; then
  # Apple Silicon
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
elif [[ "$ARCH" == "x86_64" ]]; then
  # Intel Macs
  complete -o nospace -C /usr/local/bin/terraform terraform
fi

# Source zsh-syntax-highlighting last (must wrap all widgets after they're registered)
source ${_BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
