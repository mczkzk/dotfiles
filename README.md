# Dotfiles

## Chezmoi Basic Usage

> For more information, see [chezmoi.io](https://www.chezmoi.io/)

### Daily Workflow

**Edit files:**
1. `cvi <filename>` or edit files in chezmoi source directory directly
2. `cpush`

**Add new files:**
1. `cadd <filepath>`
2. `cpush`

**Sync changes from other PCs:**
- `cupdate`

## Package Management

**Update Brewfile after installing new packages:**
- `brew bundle dump --force`

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
```