# Path to your oh-my-zsh installation.
export ZSH=/Users/assafdori/.oh-my-zsh
# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit
source <(kubectl completion zsh)
complete -C '/usr/local/bin/aws_completer' aws

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# You may need to manually set your language environment
export LANG=en_US.UTF-8

export EDITOR=/opt/homebrew/bin/nvim

alias la=tree
alias cat="bat --theme gruvbox-dark"

# Git
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

# Define paths for second brain and iCloud (storing as arrays because of spaces in the path)
export SECOND_BRAIN=("/Users/assafdori/Library/Mobile Documents/com~apple~CloudDocs/Documents/The Garden")
export ICLOUD=("/Users/assafdori/Library/Mobile Documents/com~apple~CloudDocs")

# Create symbolic links
ln -sf "$SECOND_BRAIN" ~/garden
ln -sf "$ICLOUD" ~/icloud

# Define paths for repositories
export REPOS="$HOME/Repositories"
export GITUSER="assafdori"
export GHREPOS="$REPOS/github.com/$GITUSER"
export XDG_CONFIG_HOME="$HOME"/.config

# Docker
alias dco="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# Dirs
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

# GO
export GOPATH='/Users/assafdori/go'

# VIM
alias v="/opt/homebrew/bin/nvim"

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/assafdori/.vimpkg/bin:${GOPATH}/bin:/Users/assafdori/.cargo/bin

alias cl='clear'

# K8S
export KUBECONFIG=~/.kube/config
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
alias podname=''
alias m="minikube"

# Terraform
alias tf="terraform"
alias tfsl="terraform state list"

# Tmux
alias ta="tmux attach"
alias td="tmux detach"

# HTTP requests with xh!
alias http="xh"

# VI Mode!!!
bindkey jj vi-cmd-mode

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias of="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' | xargs nvim"

# SEC STUFF
alias pg="pwgen -sy -1 15 | pbcopy"

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH=/opt/homebrew/bin:$PATH

alias mat='osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'

alias rr='ranger'

# Function to create a tmux session for DevOps
devops() {
    local session_name="$GITUSER"

    # Check if the session already exists
    if tmux has-session -t $session_name 2>/dev/null; then
        echo "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t $session_name
        return
    fi

    # Create a new tmux session starting with the Code (nvim) window
    tmux new-session -d -s $session_name -n neovim
    tmux send-keys "nvim" C-m

    # 2. General terminal window
    tmux new-window -t $session_name -n terminal
    tmux send-keys "clear" C-m

    # 3. Git window for version control management (lazygit)
    tmux new-window -t $session_name -n git
    tmux send-keys "lazygit" C-m

    # 4. K9s window for Kubernetes management
    tmux new-window -t $session_name -n k9s
    tmux send-keys "k9s" C-m

    # 5. htop window for system monitoring
    tmux new-window -t $session_name -n top
    tmux send-keys "btop" C-m

    # 6. Logs window - Split horizontally with two log monitoring panes
    tmux new-window -t $session_name -n logs
    tmux split-window -h
    tmux send-keys "tail -f /var/log/syslog" C-m   # Left pane
    tmux select-pane -t 1
    tmux send-keys "tail -f /var/log/auth.log" C-m  # Right pane

    # Optional: Start in the Code window
    tmux select-window -t $session_name:1

    # Attach to the session
    tmux attach-session -t $session_name
}

# navigation
cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

# misc
alias ff="fastfetch"

eval "$(zoxide init zsh)"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
