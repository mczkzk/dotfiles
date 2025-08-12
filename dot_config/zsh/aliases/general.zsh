# ===============================
# General Aliases
# ===============================

# Global alias for clipboard copy
alias -g C='| pbcopy' # Copy filtered output to clipboard (e.g., ps aux | grep python C)

# Tool replacements
alias cat='bat'
alias vi='nvim'
alias vim='nvim'
alias view='nvim -R'

# Utility aliases
alias compress-latest-screen-recording='cd ~/Desktop && latest=$(ls -t *.mov | head -n1) && ffmpeg -i "$latest" -vcodec libx264 -crf 28 -preset veryfast -acodec aac -b:a 128k "${latest%.mov}.mp4"'