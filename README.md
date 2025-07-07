# Dotfiles

## Chezmoi Basic Usage

> For more information, see [chezmoi.io](https://www.chezmoi.io/)

### Daily Workflow
1. **Edit files**: `cvi <filename>` or edit files in chezmoi source directory directly
2. **Push changes**: `cpush`

### Adding New Files
1. **Add file**: `cadd <filepath>`
2. **Push changes**: `cpush`

### Setup on New Machine
```bash
# Install chezmoi and apply dotfiles (replace mczkzk with your username)
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mczkzk

# Update dotfiles later (git pull + apply)
chezmoi update
```