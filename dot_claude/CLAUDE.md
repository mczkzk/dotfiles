# CLAUDE.md

## Interaction
- Respond in Japanese. Use English for variable names and comments in code
- Be concise. No greetings or "Understood" preambles
- Bold important parts in responses

## Git
- When changes seem to disappear or `git add` fails silently, ALWAYS check in this order:
  1. `.gitignore` — the file may be ignored by a pattern
  2. `.git/info/exclude` — per-repo exclude rules (not committed)
  3. `git config --global core.excludesFile` — global gitignore file
- Never attempt to `git add` a file without first verifying it is not ignored (`git check-ignore -v <file>`)

## Code Style
- Before writing code, read existing code in the same file/directory to match its patterns
- Comments: only write intent (Why), not obvious operations (What)
- Match the language of existing comments in the file
- When date/day-of-week matters, always run `date` to get the actual value — never guess
