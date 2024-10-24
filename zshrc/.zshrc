# Path configuration - defined early to ensure proper precedence
# Define PATH before loading other configurations to avoid conflicts
typeset -U path  # Ensure unique entries in PATH
path=(
    /opt/homebrew/bin
    /usr/local/bin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
    ${GOPATH}/bin
    ${HOME}/.cargo/bin
    ${HOME}/.vimpkg/bin
    $path
)
export PATH

# Path to oh-my-zsh installation
export ZSH=/Users/assafdori/.oh-my-zsh

# Environment variables
export LANG=en_US.UTF-8
export EDITOR=/opt/homebrew/bin/nvim
export GOPATH='/Users/assafdori/go'
export KUBECONFIG=~/.kube/config
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Directory paths
export SECOND_BRAIN=("/Users/assafdori/Library/Mobile Documents/com~apple~CloudDocs/Documents/The Garden")
export ICLOUD=("/Users/assafdori/Library/Mobile Documents/com~apple~CloudDocs")
export REPOS="$HOME/Repositories"
export GITUSER="assafdori"
export GHREPOS="$REPOS/github.com/$GITUSER"
export XDG_CONFIG_HOME="$HOME"/.config

# Symbolic links
ln -sf "$SECOND_BRAIN" ~/garden
ln -sf "$ICLOUD" ~/icloud

# ZSH configuration
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload -Uz compinit bashcompinit
compinit
bashcompinit

# Shell completions
source <(kubectl completion zsh)
complete -C '/opt/homebrew/bin/aws_completer' aws

# Plugin sourcing
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Key bindings
bindkey '^w' autosuggest-execute
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
alias cat="bat --theme zenburn"
alias cl='clear'
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias of="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' | xargs nvim"
alias http="xh"
alias rr='ranger'
alias ff="fastfetch"
alias v="/opt/homebrew/bin/nvim"

# Git aliases
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
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

# Directory navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias sb="cd \$SECOND_BRAIN"
alias icloud="cd \$ICLOUD"
alias xdg="cd \"$XDG_CONFIG_HOME/\""
alias repos="cd $REPOS"
alias ghrepos="cd $GHREPOS"

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

# Tmux aliases
alias ta="tmux attach"
alias td="tmux detach"
alias mat='osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'

# Security aliases
alias pg="pwgen -sy -1 15 | pbcopy"

# Functions
# DevOps tmux session setup
devops() {
    local session_name="$GITUSER"

    if tmux has-session -t $session_name 2>/dev/null; then
        echo "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t $session_name
        return
    fi

    tmux new-session -d -s $session_name -n neovim
    tmux send-keys "nvim" C-m

    tmux new-window -t $session_name -n terminal
    tmux send-keys "clear" C-m

    tmux new-window -t $session_name -n git
    tmux send-keys "lazygit" C-m

    tmux new-window -t $session_name -n k9s
    tmux send-keys "k9s" C-m

    tmux new-window -t $session_name -n top
    tmux send-keys "btop" C-m

    tmux new-window -t $session_name -n logs
    tmux split-window -h
    tmux send-keys "tail -f /var/log/syslog" C-m
    tmux select-pane -t 1
    tmux send-keys "tail -f /var/log/auth.log" C-m

    tmux select-window -t $session_name:1
    tmux attach-session -t $session_name
}

# Navigation functions
cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

# Load additional tools
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval $(thefuck --alias)
eval "$(zoxide init zsh)"

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
