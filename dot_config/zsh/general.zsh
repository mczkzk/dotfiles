# ===============================
# General
# ===============================

# Global alias
alias -g C='| pbcopy'

# Tool replacements
alias cat='bat'
alias vi='nvim'
alias vim='nvim'
alias view='nvim -R'

# Claude Code
alias cc='claude --dangerously-skip-permissions'

# Utilities
alias compress-latest-screen-recording='cd ~/Desktop && latest=$(ls -t *.mov | head -n1) && ffmpeg -i "$latest" -vcodec libx264 -crf 28 -preset veryfast -acodec aac -b:a 128k "${latest%.mov}.mp4"'
