# ===============================
# Chezmoi
# ===============================

eval "$(chezmoi completion zsh)"

# Aliases
alias cadd='chezmoi add'
alias capply='chezmoi apply'
alias ccd='chezmoi cd'
alias cdiff='chezmoi diff'
alias cupdate='chezmoi update'
alias cvi='chezmoi edit'

# Sync and push: auto-detect which side changed per file
cpush() {
  local src="$(chezmoi source-path)"
  local status_output
  status_output=$(chezmoi status 2>/dev/null)

  if [[ -z "$status_output" ]]; then
    cd "$src" && git add . && git commit -m "update dotfiles" && git push
    return
  fi

  # col1: home changed, col2: source changed (apply effect)
  echo "$status_output" | while IFS= read -r line; do
    local col1="${line[1]}" col2="${line[2]}" file="${line[3,-1]}"
    file="${file## }"
    if [[ "$col1" != " " && "$col2" != " " ]]; then
      echo "BOTH: $file"
      chezmoi merge "$HOME/$file"
    elif [[ "$col2" != " " ]]; then
      echo "source -> home: $file"
      chezmoi apply "$HOME/$file"
    elif [[ "$col1" != " " ]]; then
      echo "home -> source: $file"
      chezmoi re-add "$HOME/$file"
    fi
  done || return 1

  cd "$src" && git add . && git commit -m "update dotfiles" && git push
}
