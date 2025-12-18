# Claude Code User Configuration

This repository manages user configuration and documentation for AI.

## Included Files

- [`CLAUDE.md`](CLAUDE.md) - AI behavior and development guidelines
- `commands/` - Custom command definitions
  - [`commit.md`](commands/commit.md) - Git commit creation command
  - [`deepthink.md`](commands/deepthink.md) - Deep investigation command requiring complete understanding
  - [`plan-build.md`](commands/plan-build.md) - Plan document creation command
  - [`plan-search.md`](commands/plan-search.md) - Investigation and requirements gathering command
  - [`plan-sync.md`](commands/plan-sync.md) - Sync plan with implementation progress
  - [`pr-review.md`](commands/pr-review.md) - Review GitHub PR and identify issues and improvements
  - [`pr-template.md`](commands/pr-template.md) - Generate PR title and description from GitHub PR diff
  - [`refactor.md`](commands/refactor.md) - Martin Fowler style refactoring command
  - [`scrum-poker.md`](commands/scrum-poker.md) - Code complexity estimation using Scrum poker scale
- `scripts/`
  - [`deny-check.sh`](scripts/deny-check.sh) - Pre-tool use hook for command validation
- [`settings.json`](settings.json) - AI configuration file


## Development Workflow

For larger implementations, use this structured approach:

### 1. Investigation & Requirements
- Run `/plan-search [feature-name]` to create investigation checklist
- System prompts for specifications, screenshots, requirements
- Complete all investigation items through interactive conversation
- Thorough codebase, database, and dependency analysis
- **Tip**: Save screenshots in `plans/` directory for easy reference during search phase

### 2. Plan Creation  
- Run `/plan-build [feature-name]` (requires completed plan-search)
- Creates detailed plan document with automatic section completeness verification
- Document includes: API design, data structures, component architecture, test strategy

### 3. Implementation
- Auto-accept mode or `claude --dangerously-skip-permissions` enables rapid, uninterrupted development cycles
- Run `/plan-sync [feature-name]` periodically to sync plan with actual progress
  - Update completed/added/modified/removed tasks
  - Correct incorrect assumptions discovered during implementation
- **Note**: Consider splitting tasks/PRs when plan documents exceed 1000 lines for better maintainability

### 4. Archive
- Move completed or shelved plan documents to `plans/archive/` directory
- Keeps active workspace clean while preserving work for reference


## Project Tips

### AI Context Documentation
For individual projects, consider creating an `agent-docs/` directory to organize AI-specific documentation such as architecture overview, domain glossary, API patterns, coding conventions, database schema, and external dependencies.

Reference this directory with `@agent-docs/` in your project's CLAUDE.md to provide comprehensive context for AI assistance.


## MCP

### serena
https://github.com/oraios/serena#claude-code

May no longer be needed?

### context7
https://github.com/upstash/context7?tab=readme-ov-file#claude-code-local-server-connection

```
claude mcp add --transport http context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: YOUR_API_KEY"
```

### container-use

(Optional) If you want to use container-use, run the following command in your project repository:

```bash
claude mcp add -s project container-use -- container-use stdio
```

This creates a `.mcp.json` file in the project.

After Docker is running, run `/mcp` to test the connection.

See: https://docs.anthropic.com/en/docs/claude-code/mcp

> Ideally, MCP would be managed globally, but when you add MCP globally, it gets recorded in ~/.claude.json instead of ~/.claude/mcp.json. (see anthropics/claude-code\3098).
