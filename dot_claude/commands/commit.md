---
description: Create a git commit with proper format following repository conventions
allowed-tools: 
  - Bash(git:*)
---

Create a git commit following these steps:

1. Run `git status` to see all untracked files
2. Run `git diff` to see both staged and unstaged changes
3. Run `git log --oneline -5` to see recent commit messages for style reference
4. Analyze all changes and draft an appropriate commit message
5. Add relevant untracked files to staging area if needed
6. Create the commit with a simple, concise message
   - Keep commit messages short and focused
   - Use simple git commit -m "message" format (avoid HEREDOC)
   - Focus on the main purpose, avoid detailed bullet points
   - Follow repository's existing commit message style