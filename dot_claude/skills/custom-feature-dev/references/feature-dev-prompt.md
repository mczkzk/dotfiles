Implement: $TITLE

## Requirements
$REQUIREMENTS

## Context
$CONTEXT

## Instructions
- **Feature briefing before questions**: Assume the user is seeing this ticket for the first time. After codebase exploration and BEFORE asking any clarifying questions, present a briefing written for a newcomer engineer, in plain language:
  - What the feature is from the user's point of view, and where it appears in the UI
  - Domain terms used in the ticket, each explained in one sentence (no unexplained jargon)
  - How the current implementation works (overview level: main flow and key files)
  - What this ticket changes and why
  Then, when asking clarifying questions, give each question its own background: why the question arises, what each option implies, and your recommendation. Never ask a question that relies on knowledge the briefing has not covered.
- **SSoT**: `.claude/tasks/$FEATURE_ID/plan.md` and `docs/SPEC.md` (if exists) are the single source of truth. Update them at every implementation milestone, BEFORE moving to the next task. They survive context resets.
- **TDD**: Write tests first, then implement. Follow the Red → Green → Refactor cycle.
- Read CLAUDE.md and ~/.claude/CLAUDE.md first for project rules and conventions.
- After codebase exploration (once you understand the scope and affected files), re-read `.claude/skills/` and `~/.claude/skills/` to identify relevant skills and rules. Record them in the "Applicable Rules & Skills" section of plan.md.
- MCP tools are available for external services (Slack, JIRA, GitHub, etc). Use them when you need more context.
- If you need information from external tools you don't have access to (internal wikis, private repos, etc), ask the user how to retrieve it.
- For publicly available information (library docs, API references, etc), use web search directly without asking.
