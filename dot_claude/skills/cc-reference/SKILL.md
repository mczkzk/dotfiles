---
name: cc-reference
description: Look up Claude Code best practices from official docs before writing configuration. Use when creating or editing hooks (settings.json hooks), MCP server config, settings.json permissions (allow/deny), CLAUDE.md files, skills, agents, keybindings, or any Claude Code configuration file.
argument-hint: <topic: what to configure, like "skill for deployment" or "hook for pre-commit">
disable-model-invocation: true
context: fork
---

Claude Code configuration formats change frequently. Always check the current docs before writing — stale patterns cause silent failures.

## Reference chain (in order)

1. **Official docs (primary)** — web search for `site:docs.anthropic.com/en/docs/claude-code <topic>` and `site:docs.anthropic.com/en/docs/claude-code <config-type>`
   - Hooks: search for "claude code hooks"
   - Settings/permissions: search for "claude code settings permissions"
   - MCP: search for "claude code mcp servers"
   - Skills: search for "claude code skills"
   - Agents: search for "claude code agents"
2. **Community examples (supplemental)** — fetch from `https://github.com/anthropics/claude-code` or `https://github.com/affaan-m/everything-claude-code` if official docs lack examples
3. **Apply** — write the configuration based on what you found, not what you assumed

## Fetching community examples

```bash
# List available examples
gh api repos/affaan-m/everything-claude-code/contents/<dir> -q '.[].name'

# Read a specific file
gh api repos/affaan-m/everything-claude-code/contents/<path> -q .content | base64 -d
```

## What to verify before writing

- **Frontmatter fields** — supported field names and types (these change between versions)
- **Hook event names** — exact event identifiers and when they fire
- **Permission patterns** — correct syntax for allow/deny in settings.json
- **MCP transport types** — stdio vs sse vs http, auth config shape
- **Tool name format** — how to reference tools in allowed-tools lists
