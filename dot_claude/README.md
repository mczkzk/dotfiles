# Claude Code User Configuration

This repository manages user configuration and documentation for AI.

## Included Files

- [`CLAUDE.md`](CLAUDE.md) - AI behavior and development guidelines
- `commands/` - Custom command definitions
  - [`commit.md`](commands/commit.md) - Git commit creation command
  - [`deepthink.md`](commands/deepthink.md) - Deep investigation command requiring complete understanding
  - [`plan-build.md`](commands/plan-build.md) - Plan document creation command
  - [`plan-search.md`](commands/plan-search.md) - Investigation and requirements gathering command
  - [`pr-review.md`](commands/pr-review.md) - Code review between branches with implementation summary
  - [`pr-template.md`](commands/pr-template.md) - Generate PR title, summary, and test plan from git diff
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
- Use natural language: "go", "implement", or specify plan document
- Auto-accept mode or `claude --dangerously-skip-permissions` enables rapid, uninterrupted development cycles
- **Note**: Consider splitting tasks/PRs when plan documents exceed 1000 lines for better maintainability

### 4. Archive
- Move completed or shelved plan documents to `plans/archive/` directory
- Keeps active workspace clean while preserving work for reference

### Context Recovery
When context is lost during development:
- Reference the plan document
- Re-paste screenshots if needed
- Ensure all requirements are still captured


## Project Tips

### Incident Documentation
For individual projects, consider creating a `docs/incidents/` directory to document failures, major setbacks, and lessons learned. Add `@docs/incidents/` to your project's CLAUDE.md to help AI learn from past mistakes and prevent similar issues.

### Temporary Notes and Records
Create a `notes/` directory in your project for quick notes and records from AI conversations. This is useful for capturing insights, debugging information, or temporary findings that you want to preserve but aren't ready to formalize into documentation.


## Advanced Techniques

### Documentation Re-reading Technique
For any complex task or project, you can trade token consumption for comprehensive context by asking AI to:
```
Re-read project CLAUDE.md and ~/.claude/CLAUDE.md
```
This technique loads all available guidelines and rules at conversation start, ensuring AI has full context of your development standards and practices across all types of work.


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
