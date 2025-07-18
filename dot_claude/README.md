# Claude Code User Configuration

This repository manages user configuration and documentation for AI.

## Included Files

- [`CLAUDE.md`](CLAUDE.md) - AI behavior and development guidelines
- `commands/` - Custom command definitions
  - [`commit.md`](commands/commit.md) - Git commit creation command
  - [`plan-search.md`](commands/plan-search.md) - Investigation and requirements gathering command
  - [`plan-build.md`](commands/plan-build.md) - Plan document creation command
  - [`deepthink.md`](commands/deepthink.md) - Deep investigation command requiring complete understanding
- [`settings.json`](settings.json) - AI configuration file


## Development Workflow

For larger implementations, use this structured approach:

### 1. Investigation & Requirements | Normal Mode
- Run `/plan-search [feature-name]` to create investigation checklist
- System prompts for specifications, screenshots, requirements
- Complete all investigation items through interactive conversation
- Thorough codebase, database, and dependency analysis
- **Tip**: Save screenshots in `plans/` directory for easy reference during search phase

### 2. Plan Creation | Normal Mode  
- Run `/plan-build [feature-name]` (requires completed plan-search)
- Creates detailed plan document with automatic section completeness verification
- Document includes: API design, data structures, component architecture, test strategy

### 3. Implementation | Auto-accept Mode
- Use natural language: "go", "この計画を実装して", or specify plan document
- Auto-accept mode enables rapid, uninterrupted development cycles
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


## container-use setup

(Optional) If you want to use container-use, run the following command in your project repository:

```bash
claude mcp add -s project container-use -- container-use stdio
```

This creates a `.mcp.json` file in the project.

After Docker is running, run `/mcp` to test the connection.

See: https://docs.anthropic.com/en/docs/claude-code/mcp

> Ideally, MCP would be managed globally, but when you add MCP globally, it gets recorded in ~/.claude.json instead of ~/.claude/mcp.json. (see anthropics/claude-code\3098).


