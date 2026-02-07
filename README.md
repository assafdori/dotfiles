# Dotfiles

![asset](assets/assets.jpg)

#### these dotfiles are super opinionated and will most likely require modifications to work for you

## What's inside?

- Custom terminal stuff (aliases, prompts, etc.)
- Neovim config for when I need to get things done fast
- Settings to keep things smooth

## Quick Start

On a fresh Mac, run this one-liner to set everything up automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/assafdori/dotfiles/main/bootstrap.sh | bash
```

This will:

1. Install Xcode CLI tools, Homebrew, and Git
2. Copy SSH keys from iCloud
3. Clone this dotfiles repository
4. Automatically run the full setup script (`setup.sh`)
