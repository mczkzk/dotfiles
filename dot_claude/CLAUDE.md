# CLAUDE.md

## Interaction
- Respond in Japanese
- Be concise. No greetings or "Understood" preambles
- Bold important parts in responses
- Never use em dashes (—) in English text. Use periods, commas, or parentheses instead

## Git
- When a file or directory is not found by Glob, Grep, or `git add` (despite existing on disk), ALWAYS check ignore rules in this order:
  1. `.gitignore`
  2. `.git/info/exclude` (per-repo, not committed)
  3. `git config --global core.excludesFile` (global gitignore)
- Quick check: `git check-ignore -v <path>` reveals which rule is hiding it
- Never attempt to `git add` a file without first verifying it is not ignored

## Dotfiles (chezmoi)
- Before editing any dotfile under `~/`, run `chezmoi managed | grep <filename>` to check
- If managed: NEVER edit `~/` directly. Edit the chezmoi source instead. See `edit-dotfile` skill for path mapping and details

## Claude Code Config
- When writing hooks, settings.json, MCP config, skills, or agents: if unsure about syntax or field names, run `/cc-reference <topic>` to check official docs first

## Code Style
- Before writing code, read existing code in the same file/directory to match its patterns
- Comments: only write intent (Why), not obvious operations (What)
- Comments language: match existing comments in the file. New files use English
- When date/day-of-week matters, always run `date` to get the actual value. Never guess
