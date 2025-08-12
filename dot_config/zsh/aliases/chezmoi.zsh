# ===============================
# Chezmoi Configuration & Aliases
# ===============================

# Chezmoi completion
eval "$(chezmoi completion zsh)"

# Chezmoi aliases
alias cadd='chezmoi add'
alias cvi='chezmoi edit'
alias cpush='chezmoi apply && cd "$(chezmoi source-path)" && git add . && git commit -m "update dotfiles" && git push'
alias cdiff='chezmoi diff'
alias capply='chezmoi apply'
alias ccd='chezmoi cd'
alias cupdate='chezmoi update'