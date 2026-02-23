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

# Terraform completion
if [[ "$ARCH" == "arm64" ]]; then
  # Apple Silicon
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
elif [[ "$ARCH" == "x86_64" ]]; then
  # Intel Macs
  complete -o nospace -C /usr/local/bin/terraform terraform
fi