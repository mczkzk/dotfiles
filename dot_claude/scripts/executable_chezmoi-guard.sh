#!/bin/bash

# PreToolUse hook: Block direct writes to chezmoi-managed files under ~/
# When blocked, suggests the correct chezmoi source path.

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name' 2>/dev/null || echo "")
file_path=$(echo "$input" | jq -r '.tool_input.file_path' 2>/dev/null || echo "")

# Only check Write and Edit
if [ "$tool_name" != "Write" ] && [ "$tool_name" != "Edit" ]; then
  exit 0
fi

# Skip if no file_path
[ -z "$file_path" ] && exit 0

# Skip if already writing to chezmoi source dir
chezmoi_source="$HOME/.local/share/chezmoi"
if [[ "$file_path" == "$chezmoi_source"* ]]; then
  exit 0
fi

# Check if the file is under $HOME
if [[ "$file_path" != "$HOME"* ]]; then
  exit 0
fi

# Get relative path from $HOME
rel_path="${file_path#"$HOME"/}"

# Check if this path is managed by chezmoi
if chezmoi managed 2>/dev/null | grep -qxF "$rel_path"; then
  source_path=$(chezmoi source-path "$file_path" 2>/dev/null)
  if [ -n "$source_path" ]; then
    echo "BLOCKED: $file_path is managed by chezmoi. Edit the source instead: $source_path" >&2
  else
    echo "BLOCKED: $file_path is managed by chezmoi. Edit the source in $chezmoi_source instead." >&2
  fi
  exit 2
fi

exit 0
