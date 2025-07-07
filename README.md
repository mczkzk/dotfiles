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

### Setup on New Machine
```bash
# First, backup existing dotfiles if they exist
mkdir -p ~/dotfiles_backup
[ -f ~/.zshrc ] && mv ~/.zshrc ~/dotfiles_backup/
[ -f ~/.gitconfig ] && mv ~/.gitconfig ~/dotfiles_backup/
[ -d ~/.claude ] && mv ~/.claude ~/dotfiles_backup/

# Install chezmoi and apply dotfiles (replace mczkzk with your username)
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mczkzk

# Create git user config file with your email
echo '[user]
	email = your.email@example.com' > ~/.gitconfig_user
```