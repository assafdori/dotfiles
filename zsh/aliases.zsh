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
alias gitlogue='gitlogue --background false'

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

# Cloud aliases
alias aws-profile=awsprofile
alias gcp-profile=gcpprofile
alias gcp-project=gcpproject
alias gcp-drop=gcpdrop