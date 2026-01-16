# Claude Code User Configuration

This repository manages user configuration and documentation for AI.

## Included Files

- [`CLAUDE.md`](CLAUDE.md) - AI behavior and development guidelines
- `commands/` - Custom command definitions
  - **Core Commands**
    - [`commit.md`](commands/commit.md) - Create a git commit with proper format following repository conventions
    - [`deepthink.md`](commands/deepthink.md) - Think deeply and investigate thoroughly about `<topic>`
    - [`reload-config.md`](commands/reload-config.md) - Reload Claude configuration files
  - **Planning Commands**
    - [`plan-search.md`](commands/plan-search.md) - Create investigation checklist for `<feature-name>` and gather requirements
    - [`plan-build.md`](commands/plan-build.md) - Create plan document for structured development
    - [`plan-sync.md`](commands/plan-sync.md) - Sync plan document with actual implementation progress
  - **PR Commands**
    - [`pr-review.md`](commands/pr-review.md) - Review GitHub PR `<number>` and identify issues and improvements
    - [`pr-review-respond.md`](commands/pr-review-respond.md) - Respond to PR review comments `<number>` with fixes and reply drafts
    - [`pr-template.md`](commands/pr-template.md) - Generate PR title and description from GitHub PR `<number>` diff
  - **Code Quality Commands**
    - [`refactor.md`](commands/refactor.md) - Perform Martin Fowler style refactoring on `<target>`
    - [`scrum-poker.md`](commands/scrum-poker.md) - Estimate code complexity and effort using Scrum poker scale
  - **Project-specific (samples)**
    - [`project/check.md`](commands/project/check.md) - Check Code Quality (requires project-specific adjustments)
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

### 2. Plan Creation  
- Run `/plan-build [feature-name]` (requires completed plan-search)
- Creates detailed plan document with automatic section completeness verification
- Document includes: API design, data structures, component architecture, test strategy

### 3. Implementation
- Auto-accept mode or `claude --dangerously-skip-permissions` enables rapid, uninterrupted development cycles
- Run `/plan-sync [feature-name]` periodically to sync plan with actual progress
  - Update completed/added/modified/removed tasks
  - Correct incorrect assumptions discovered during implementation
- Run `/reload-config` after modifying configuration files to refresh settings
  - Reloads `~/.claude/CLAUDE.md`, `~/.claude/skills`, `.claude/CLAUDE.md`, `.claude/skills`
  - Useful after updating project-specific guidelines or custom commands
- **Note**: Consider splitting tasks/PRs when plan documents exceed 1000 lines for better maintainability

### 4. Archive
- Move completed or shelved plan documents to `.agent/plans/archive/` directory
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
