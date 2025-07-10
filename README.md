# Dotfiles

> For more information, see [chezmoi.io](https://www.chezmoi.io/)

## Daily Workflow

**Edit files:**
1. `cvi <filename>` or edit files in chezmoi source directory directly
2. `cpush`

**Add new files:**
1. `cadd <filepath>`
2. `cpush`

**Sync changes from other PCs:**
- `cupdate`

> Aliases are defined in [.zshrc](dot_zshrc)

## Package Management

**Update Brewfile:**
- Automatic: `brew bundle dump --force` (overwrites with all installed packages + VS Code extensions)
- Manual: Check with `brew list` and `code --list-extensions`, then add lines manually

**Sync packages:**
- `brew bundle` (install new packages)
- `brew bundle cleanup --force` (remove old packages)

## Setup on New Machine

**1. Backup existing dotfiles:**
```bash
mkdir -p ~/dotfiles_backup
[ -f ~/.zshrc ] && mv ~/.zshrc ~/dotfiles_backup/
[ -f ~/.gitconfig ] && mv ~/.gitconfig ~/dotfiles_backup/
[ -d ~/.claude ] && mv ~/.claude ~/dotfiles_backup/
[ -f ~/Brewfile ] && mv ~/Brewfile ~/dotfiles_backup/
```

**2. Install chezmoi and apply dotfiles:**

Option A (Homebrew):
```bash
brew install chezmoi
chezmoi init --apply mczkzk
```

Option B (Direct install):
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mczkzk
```

**3. Create git user config:**
```bash
echo '[user]
	email = your.email@example.com' > ~/.gitconfig_user
```

**4. Install packages:**
```bash
brew bundle
source ~/.zshrc
```