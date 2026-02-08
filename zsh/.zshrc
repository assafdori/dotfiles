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

# ZSH configuration
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload -Uz compinit bashcompinit
compinit
bashcompinit

# Kubectl completion
source <(kubectl completion zsh)

# AWS CLI autocompletion
if [[ "$ARCH" == "arm64" ]]; then
  # Apple Silicon
  complete -C '/opt/homebrew/bin/aws_completer' aws
elif [[ "$ARCH" == "x86_64" ]]; then
  # Intel Macs
  complete -C '/usr/local/bin/aws_completer' aws
fi

# GCP CLI autocompletion
if [[ "$ARCH" == "arm64" ]]; then
  # Apple Silicon
  if [ -f /opt/homebrew/share/google-cloud-sdk/path.zsh.inc ]; then
    source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
  fi

  if [ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ]; then
    source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
  fi
elif [[ "$ARCH" == "x86_64" ]]; then
  # Intel Macs
  if [ -f /usr/local/share/google-cloud-sdk/path.zsh.inc ]; then
    source /usr/local/share/google-cloud-sdk/path.zsh.inc
  fi

  if [ -f /usr/local/share/google-cloud-sdk/completion.zsh.inc ]; then
    source /usr/local/share/google-cloud-sdk/completion.zsh.inc
  fi
fi

# Plugin sourcing
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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
awsprofile() {
  # Check if AWS CLI is installed
  if ! command -v aws &>/dev/null; then
    echo "Error: AWS CLI is not installed"
    return 1
  fi

  # Get available profiles
  local profiles
  profiles=$(aws configure list-profiles 2>/dev/null) || {
    echo "Error: Failed to list AWS profiles"
    return 1
  }

  if [[ -z "$profiles" ]]; then
    echo "No AWS profiles found"
    return 1
  fi

  # Add clear option and format profiles with current indicator
  local profile_list=""
  local current_marker=""
  
  # Add option to clear/unset profile
  profile_list="[Clear Profile]"
  
  # Add each profile with current indicator
  while IFS= read -r prof; do
    if [[ "$AWS_PROFILE" == "$prof" ]]; then
      current_marker="● "
    else
      current_marker="  "
    fi
    profile_list="$profile_list\n${current_marker}${prof}"
  done <<< "$profiles"

  # Build prompt showing current profile
  local prompt="Select AWS profile"
  if [[ -n "$AWS_PROFILE" ]]; then
    prompt="Select AWS profile (current: $AWS_PROFILE)"
  fi

  # Create preview script for fzf
  local preview_script='
    profile=$(echo {} | sed "s/^[● ]*//" | sed "s/^\[Clear Profile\]//")
    if [[ -z "$profile" ]] || [[ "$profile" == "[Clear Profile]" ]]; then
      echo "╭─────────────────────────────────────────╮"
      echo "│ Clear the current AWS profile           │"
      echo "╰─────────────────────────────────────────╯"
    else
      echo "╭─────────────────────────────────────────╮"
      echo "│ Profile: $profile"
      echo "├─────────────────────────────────────────┤"
      
      # Check if this is an SSO profile
      sso_start_url=$(AWS_PROFILE="$profile" aws configure get sso_start_url 2>/dev/null)
      sso_account_id=$(AWS_PROFILE="$profile" aws configure get sso_account_id 2>/dev/null)
      sso_role=$(AWS_PROFILE="$profile" aws configure get sso_role_name 2>/dev/null)
      region=$(AWS_PROFILE="$profile" aws configure get region 2>/dev/null)
      
      # Try to get identity (this will fail if SSO session expired)
      account_id=$(AWS_PROFILE="$profile" aws sts get-caller-identity --query Account --output text 2>/dev/null)
      user_arn=$(AWS_PROFILE="$profile" aws sts get-caller-identity --query Arn --output text 2>/dev/null)
      
      # Display SSO info if available
      if [[ -n "$sso_start_url" ]]; then
        echo "│ Type:        SSO Profile"
        
        # Extract organization name from SSO URL
        org_name=$(echo "$sso_start_url" | sed -n "s|https://\([^.]*\)\.awsapps\.com.*|\1|p")
        if [[ -n "$org_name" ]]; then
          echo "│ Org:         $org_name"
        fi
        
        if [[ -n "$sso_account_id" ]]; then
          echo "│ SSO Account: $sso_account_id"
        fi
        if [[ -n "$sso_role" ]]; then
          echo "│ SSO Role:    $sso_role"
        fi
      fi
      
      # Display region
      if [[ -n "$region" ]]; then
        echo "│ Region:      $region"
      else
        echo "│ Region:      <not configured>"
      fi
      
      # Show live credentials status
      if [[ -n "$account_id" ]]; then
        echo "│ Account ID:  $account_id"
        echo "│ Status:      ✓ Active"
        if [[ -n "$user_arn" ]]; then
          identity_name=$(echo "$user_arn" | awk -F"/" "{print \$NF}")
          echo "│ Identity:    $identity_name"
        fi
      else
        # No active session
        if [[ -n "$sso_start_url" ]]; then
          echo "│ Status:      ⚠ SSO login required"
          echo "│"
          echo "│ Run: aws sso login --profile $profile"
        else
          echo "│ Status:      ⚠ Unable to authenticate"
        fi
      fi
      
      echo "╰─────────────────────────────────────────╯"
    fi
  '

  # Select profile with enhanced fzf UI including preview
  local selection
  selection=$(echo -e "$profile_list" | fzf \
    --prompt "$prompt: " \
    --height 80% \
    --reverse \
    --border rounded \
    --border-label " AWS Profiles " \
    --header "● = current profile | ↑↓ navigate | enter select" \
    --preview "$preview_script" \
    --preview-window "right:45%:wrap" \
    --color "border:#589df6,label:#89b4fa,header:#cba6f7,preview-border:#589df6" \
    --pointer "▶" \
    --marker "✓") || {
    echo "No profile selected"
    return 1
  }

  # Handle clear profile option
  if [[ "$selection" == "[Clear Profile]" ]]; then
    if [[ -n "$AWS_PROFILE" ]]; then
      local old_profile="$AWS_PROFILE"
      unset AWS_PROFILE
      unset AWS_DEFAULT_REGION
      echo "✓ Cleared AWS profile: $old_profile"
    else
      echo "No AWS profile currently set"
    fi
    return 0
  fi

  # Remove the current indicator marker if present
  selection="${selection#● }"
  selection="${selection#  }"

  # Set the profile
  export AWS_PROFILE="$selection"
  
  # Show profile details with formatting
  echo "╭─────────────────────────────────────────╮"
  echo "│ AWS Profile: $AWS_PROFILE"
  echo "├─────────────────────────────────────────┤"
  
  # Get and display account details
  local account_id region user_arn
  account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
  user_arn=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)
  region=$(aws configure get region 2>/dev/null)
  
  if [[ -n "$account_id" ]]; then
    echo "│ Account ID:  $account_id"
  fi
  if [[ -n "$region" ]]; then
    echo "│ Region:      $region"
  fi
  if [[ -n "$user_arn" ]]; then
    # Extract identity type and name from ARN
    local identity_type=$(echo "$user_arn" | grep -o "assumed-role\|user\|role" | head -1)
    local identity_name=$(echo "$user_arn" | awk -F'/' '{print $NF}')
    echo "│ Type:        ${identity_type:-user}"
    echo "│ Identity:    $identity_name"
  fi
  echo "╰─────────────────────────────────────────╯"
}
alias aws-profile=awsprofile

gcpprofile() {
  local config
  config=$(gcloud config configurations list --format="value(name)" \
    | fzf --prompt "Select GCP configuration: ") || {
      echo "❌ No GCP configuration selected."
      return 1
    }
  export CLOUDSDK_ACTIVE_CONFIG_NAME="$config"
  echo "👷🏼 Working with GCP configuration: $CLOUDSDK_ACTIVE_CONFIG_NAME"
}
alias gcp-profile=gcpprofile

gcpproject() {
  local project
  project=$(gcloud projects list --format="value(projectId)" \
    | fzf --prompt="Select GCP project: ") || {
      echo "❌ No GCP project selected."
      return 1
    }

  export CLOUDSDK_CORE_PROJECT="$project"
  echo "👷🏼 Working with GCP project: $CLOUDSDK_CORE_PROJECT"
}
alias gcp-project=gcpproject

gcpdrop() {
  if ! gcloud config configurations describe empty >/dev/null 2>&1; then
    echo "⚙️ Creating 'empty' GCP configuration..."
    gcloud config configurations create empty >/dev/null 2>&1 || {
      echo "❌ Failed to create empty config."
      return 1
    }
  fi

  gcloud config configurations activate empty >/dev/null 2>&1
  unset CLOUDSDK_ACTIVE_CONFIG_NAME
  unset CLOUDSDK_CORE_PROJECT

  echo "🧹 Dropped GCP profile/project → switched to 'empty' configuration"
}
alias gcp-drop=gcpdrop


# Tmux session management
devops() {
    local session_name="${1:-$GITUSER}" # Default session name is $GITUSER

    # Check if tmux is available
    command -v tmux >/dev/null 2>&1 || { echo "tmux is not installed."; return 1; }

    # Check if already inside a tmux session
    if [ -n "$TMUX" ]; then
        echo "Already inside a tmux session. Setting up 'devops' environment in the current session..."
        
        # Clear existing windows (optional: prevent clutter)
        tmux kill-window -a 2>/dev/null

        # Create windows and panes for the current session
        tmux new-window -n neovim
        tmux send-keys "nvim" C-m

        tmux new-window -n terminal
        tmux send-keys "clear" C-m

        tmux new-window -n git
        tmux send-keys "lazygit" C-m

        tmux new-window -n k9s
        tmux send-keys "k9s" C-m

        tmux new-window -n top
        tmux send-keys "btop" C-m

        tmux new-window -n logs
        tmux split-window -h
        tmux send-keys "tail -f /var/log/syslog" C-m
        tmux select-pane -t 1
        tmux send-keys "tail -f /var/log/auth.log" C-m

        tmux select-window -t neovim # Focus on the first window
    else
        # If not inside tmux, create a new session
        if tmux has-session -t $session_name 2>/dev/null; then
            echo "Session '$session_name' already exists. Attaching..."
            tmux attach-session -t $session_name
            return
        fi

        echo "Creating new tmux session '$session_name'..."
        tmux new-session -d -s $session_name -n neovim
        tmux send-keys "nvim" C-m

        tmux new-window -t $session_name -n yazi
        tmux send-keys "yazi" C-m

        tmux new-window -t $session_name -n git
        tmux send-keys "lazygit" C-m

        tmux new-window -t $session_name -n k9s
        tmux send-keys "k9s" C-m

        tmux new-window -t $session_name -n top
        tmux send-keys "btop" C-m

        tmux new-window -t $session_name -n helm
        tmux send-keys "helm tui" C-m

        tmux select-window -t $session_name:1
        tmux attach-session -t $session_name
    fi
}

# Sesh session management
function ss() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
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
eval $(thefuck --alias)
source <(stern --completion=zsh)
source <(helm completion zsh)
eval "$(zoxide init zsh)"

eval "$(atuin init zsh)"

autoload -U +X bashcompinit && bashcompinit

# Terraform completion
if [[ "$ARCH" == "arm64" ]]; then
  # Apple Silicon
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
elif [[ "$ARCH" == "x86_64" ]]; then
  # Intel Macs
  complete -o nospace -C /usr/local/bin/terraform terraform
fi
