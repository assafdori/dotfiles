# Symlink SSH config
SSH_CONFIG_SOURCE="$DOTFILES/ssh/config"
SSH_DEST="$HOME/.ssh"

if [ -f "$SSH_CONFIG_SOURCE" ]; then
  echo "Symlinking SSH config..."
  mkdir -p "$SSH_DEST"
  rm -f "$SSH_DEST/config"
  ln -s "$SSH_CONFIG_SOURCE" "$SSH_DEST/config"
  echo "SSH config symlinked successfully."
else
  echo "No SSH config found at $SSH_CONFIG_SOURCE, skipping symlink."
fi
