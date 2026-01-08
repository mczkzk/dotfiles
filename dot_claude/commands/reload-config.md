---
description: Reload Claude configuration files
allowed-tools:
  - Read
---

**Reload global and project-specific configuration files.**

Read the following files in order:

1. `~/.claude/CLAUDE.md` - Global configuration
2. `~/.claude/skills` - Global skill definitions (all files if directory)
3. `.claude/CLAUDE.md` - Project-specific configuration
4. `.claude/skills` - Project-specific skill definitions (all files if directory)

**Execution steps:**
- Check file existence before reading
- If directory, read all files within
- If file doesn't exist, report and skip
- After completion, report briefly "Configuration reloaded"

**Notes:**
- Use this command after configuration changes or to refresh settings
- Don't display file contents, only report loading results
