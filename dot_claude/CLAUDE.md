# Global Instructions

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

## chezmoi
- Before editing any file under `~/`, run `chezmoi managed | grep <filename>` to check
- If managed: NEVER edit `~/` directly. Edit the chezmoi source instead

## Tool Config
- When writing hooks, settings.json/config.toml, MCP config, plugins, skills, or agents: if there is any uncertainty about syntax, field names, or current behavior, search the latest official docs first instead of relying on memory

## Code Style
- Before writing code, read existing code in the same file/directory to match its patterns
- Comments: only write intent (Why), not obvious operations (What)
- Comments must be plain language anyone can understand. No jargon or abbreviations that require prior knowledge (e.g., "no-op")
- Comments language: match existing comments in the file. New files use English
- When date/day-of-week matters, always run `date` to get the actual value. Never guess
