#!/usr/bin/env bash
# Three-line statusline based on robbyrussell theme
# Line 1: ➜ ~/path/to/dir git:(branch) ✗
# Line 2: 🧠 Model │ 📐 N%
# Line 3: 🔋 5h N% →HH:MM │ 7d N% →MM/DD

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
  ctx_info="📐 \033[0;33mctx ${used_pct%.*}%\033[0m"
fi

# Model info
model_info=""
if [ -n "$model" ]; then
  model_info="🧠 \033[0;35m${model}\033[0m"
fi

# Usage limits (built-in rate_limits field, resets_at is epoch seconds)
usage_info=""
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$five_h" ]; then
  seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0')
  # Round to integer
  five_h=$(printf '%.0f' "$five_h")
  seven_d=$(printf '%.0f' "$seven_d")
  five_h_reset=$(TZ=Asia/Tokyo date -r "$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at')" +"%H:%M" 2>/dev/null)
  seven_d_reset=$(TZ=Asia/Tokyo date -r "$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at')" +"%m/%d" 2>/dev/null)
  usage_info="🔋 \033[0;36m5h ${five_h}% \033[0;90m→${five_h_reset}\033[0m │ \033[0;36m7d ${seven_d}% \033[0;90m→${seven_d_reset}\033[0m"
fi

# Line 1: directory + git
printf "\033[1;32m➜\033[0m  \033[0;36m%s\033[0m%b\n" "$dir_path" "$git_branch"
# Line 2: ctx + model
printf "%b │ %b\n" "$model_info" "$ctx_info"
# Line 3: usage limits
printf "%b" "$usage_info"
