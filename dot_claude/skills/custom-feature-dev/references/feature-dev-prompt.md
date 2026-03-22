Implement: $TITLE

## Requirements
$REQUIREMENTS

## Context
$CONTEXT

## Instructions
- **SSoT**: `.claude/plans/$FEATURE_ID/plan.md` and `docs/SPEC.md` (if exists) are the single source of truth. Update them at every implementation milestone, BEFORE moving to the next task. They survive context resets.
- Read CLAUDE.md and ~/.claude/CLAUDE.md first for project rules and conventions.
- After codebase exploration (once you understand the scope and affected files), re-read `.claude/skills/` and `~/.claude/skills/` to identify relevant skills and rules. Record them in the "Applicable Rules & Skills" section of plan.md.
- MCP tools are available for external services (Slack, JIRA, GitHub, etc). Use them when you need more context.
- If you need information from external tools you don't have access to (internal wikis, private repos, etc), ask the user how to retrieve it.
- For publicly available information (library docs, API references, etc), use web search directly without asking.
