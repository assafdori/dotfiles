# =============================================================================
# Tmux
# =============================================================================

# Create a tmux layout for dev with editor, ai, and terminal
tml() {
  local current_dir="${PWD}"
  local session_name="${current_dir##*/}"
  local editor_pane ai_pane
  local ai="opencode"
  # Outside tmux: check for existing session, then create or attach
  if [[ -z "$TMUX" ]]; then
    if tmux has-session -t "=$session_name" 2>/dev/null; then
      echo "tmux session '$session_name' already exists, attaching..."
      tmux attach -t "=$session_name"
      return
    fi
    tmux new-session -d -s "$session_name" -c "$current_dir"
    tmux send-keys -t "$session_name" "tml" C-m
    tmux attach -t "$session_name"
    return
  fi

  # Already inside tmux — set up the layout
  editor_pane=$(tmux display-message -p '#{pane_id}')
  tmux split-window -h -p 35 -c "$current_dir"
  ai_pane=$(tmux display-message -p '#{pane_id}')
  tmux send-keys -t "$ai_pane" "$ai" C-m
  tmux select-pane -t "$editor_pane"
  tmux split-window -v -p 15 -c "$current_dir"
  tmux send-keys -t "$editor_pane" "$EDITOR ." C-m
  tmux select-pane -t "$editor_pane"
}

# =============================================================================
# Cloud
# =============================================================================

# AWS profile switcher
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

      sso_start_url=$(AWS_PROFILE="$profile" aws configure get sso_start_url 2>/dev/null)
      sso_account_id=$(AWS_PROFILE="$profile" aws configure get sso_account_id 2>/dev/null)
      sso_role=$(AWS_PROFILE="$profile" aws configure get sso_role_name 2>/dev/null)
      region=$(AWS_PROFILE="$profile" aws configure get region 2>/dev/null)

      account_id=$(AWS_PROFILE="$profile" aws sts get-caller-identity --query Account --output text 2>/dev/null)
      user_arn=$(AWS_PROFILE="$profile" aws sts get-caller-identity --query Arn --output text 2>/dev/null)

      if [[ -n "$sso_start_url" ]]; then
        echo "│ Type:        SSO Profile"

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

      if [[ -n "$region" ]]; then
        echo "│ Region:      $region"
      else
        echo "│ Region:      <not configured>"
      fi

      if [[ -n "$account_id" ]]; then
        echo "│ Account ID:  $account_id"
        echo "│ Status:      ✓ Active"
        if [[ -n "$user_arn" ]]; then
          identity_name=$(echo "$user_arn" | awk -F"/" "{print \$NF}")
          echo "│ Identity:    $identity_name"
        fi
      else
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
    local identity_type=$(echo "$user_arn" | grep -o "assumed-role\|user\|role" | head -1)
    local identity_name=$(echo "$user_arn" | awk -F'/' '{print $NF}')
    echo "│ Type:        ${identity_type:-user}"
    echo "│ Identity:    $identity_name"
  fi
  echo "╰─────────────────────────────────────────╯"
}

# GCP profile switcher
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

# GCP project switcher
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

# GCP drop profile/project
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

# =============================================================================
# Utilities
# =============================================================================

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

# Duckduckgo search
function ddg() {
    open "https://duckduckgo.com/?q=$*"
}

# Google search
function google() {
    open "https://www.google.com/search?q=$*"
}
