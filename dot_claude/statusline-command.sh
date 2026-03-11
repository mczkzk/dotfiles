#!/usr/bin/env bash
# Two-line statusline based on robbyrussell theme
# Line 1: ➜ ~/path/to/dir git:(branch) ✗
# Line 2: ctx:N%  [Model]  5h:N%(HH:MM) 7d:N%(MM/DD HH:MM)

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory to ~
dir_path="${cwd:-$(pwd)}"
dir_path="${dir_path/#$HOME/~}"

# Git info
git_branch=""
git_dir="${cwd:-$(pwd)}"
if git -C "$git_dir" rev-parse --is-inside-work-tree 2>/dev/null | grep -q true; then
  branch=$(git -C "$git_dir" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$git_dir" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if git -C "$git_dir" status --porcelain 2>/dev/null | grep -q .; then
      git_branch=" \033[1;34mgit:(\033[0;31m${branch}\033[1;34m)\033[0m \033[0;33m✗\033[0m"
    else
      git_branch=" \033[1;34mgit:(\033[0;31m${branch}\033[1;34m)\033[0m"
    fi
  fi
fi

# Context usage
ctx_info=""
if [ -n "$used_pct" ]; then
  ctx_info="\033[0;33mctx:${used_pct%.*}%\033[0m"
fi

# Model info
model_info=""
if [ -n "$model" ]; then
  model_info="  \033[0;35m[${model}]\033[0m"
fi

# Usage limits (cached 60s)
# NOTE: /api/oauth/usage is an undocumented API. May break without notice.
# Official support is tracked at: https://github.com/anthropics/claude-code/issues/27915
usage_info=""
CACHE=/tmp/claude-usage-cache
if [ ! -f "$CACHE" ] || [ $(( $(date +%s) - $(stat -f%m "$CACHE") )) -gt 60 ]; then
  TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
    | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
  if [ -n "$TOKEN" ]; then
    curl -s -H "Authorization: Bearer $TOKEN" -H "anthropic-beta: oauth-2025-04-20" \
      https://api.anthropic.com/api/oauth/usage > "$CACHE" 2>/dev/null
  fi
fi
if [ -f "$CACHE" ] && jq -e '.five_hour' "$CACHE" >/dev/null 2>&1; then
  five_h=$(jq -r '.five_hour.utilization // 0 | round' "$CACHE")
  seven_d=$(jq -r '.seven_day.utilization // 0 | round' "$CACHE")
  _to_epoch() { date -jf "%Y-%m-%dT%H:%M:%S%z" "$(echo "$1" | sed 's/\.[0-9]*//; s/:00$/00/')" +%s 2>/dev/null; }
  five_h_reset=$(TZ=Asia/Tokyo date -r "$(_to_epoch "$(jq -r '.five_hour.resets_at' "$CACHE")")" +"%H:%M" 2>/dev/null)
  seven_d_reset=$(TZ=Asia/Tokyo date -r "$(_to_epoch "$(jq -r '.seven_day.resets_at' "$CACHE")")" +"%m/%d %H:%M" 2>/dev/null)
  usage_info="  \033[0;36m5h:${five_h}%(\033[0;90m${five_h_reset}\033[0;36m) 7d:${seven_d}%(\033[0;90m${seven_d_reset}\033[0;36m)\033[0m"
fi

# Line 1: directory + git
printf "\033[1;32m➜\033[0m  \033[0;36m%s\033[0m%b\n" "$dir_path" "$git_branch"
# Line 2: ctx + model + usage
printf "%b%b%b" "$ctx_info" "$model_info" "$usage_info"
