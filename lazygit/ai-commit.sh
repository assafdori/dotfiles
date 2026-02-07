#!/bin/bash

# Get the staged diff
DIFF=$(git diff --cached)

if [ -z "$DIFF" ]; then
  echo "No staged changes to commit"
  exit 1
fi

# Create the prompt for OpenCode
PROMPT="Please suggest 10 commit messages for the following diff.

Format each message using conventional commits with an appropriate emoji:
<type>(<scope>): <description>

Available types:
- feat ✨ (new feature)
- fix 🐛 (bug fix)
- docs 📜 (documentation)
- style 🎨 (formatting, no code change)
- refactor 🔨 (refactoring)
- perf 🚀 (performance improvement)
- test 🚦 (tests)
- build 📦 (build system)
- ci 🦊 (CI/CD)
- chore 🔧 (maintenance)

Output only the numbered list (1-10), nothing else.

\`\`\`diff
$DIFF
\`\`\`"

# Get suggestions from OpenCode
echo "Generating commit message suggestions..." >&2
SUGGESTIONS=$(opencode run "$PROMPT" 2>/dev/null | grep -E "^[0-9]+\." | sed 's/^[0-9]*\. //')

if [ -z "$SUGGESTIONS" ]; then
  echo "Failed to generate suggestions" >&2
  exit 1
fi

# Let user pick with fzf
SELECTED=$(echo "$SUGGESTIONS" | fzf \
  --prompt="Select commit message: " \
  --height=50% \
  --reverse \
  --border \
  --preview-window=hidden)

if [ -n "$SELECTED" ]; then
  git commit -m "$SELECTED"
else
  echo "No commit message selected" >&2
  exit 1
fi
