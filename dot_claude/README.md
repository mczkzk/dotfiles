# Claude Code User Configuration

Global configuration for Claude Code (`~/.claude/`), managed via chezmoi.

## Structure

```
dot_claude/
├── CLAUDE.md              # Global instructions (loaded every session)
├── settings.json          # Permission and tool settings
├── rules/                 # Path-scoped rules (loaded when matching files)
│   └── ts-guidelines.md   # TypeScript coding guidelines (*.ts, *.tsx)
├── skills/                # Custom skills (invoked via /name)
│   ├── commit/            # Git commit with repo conventions
│   ├── deepthink/         # Deep investigation on a topic
│   ├── edit-dotfile/      # Edit dotfiles via chezmoi
│   ├── plan-search/       # Investigation checklist for features
│   ├── plan-build/        # Create plan document from search
│   ├── plan-sync/         # Sync plan with implementation progress
│   ├── pr-review/         # Review GitHub PR
│   ├── pr-review-respond/ # Respond to PR review comments
│   ├── pr-template/       # Generate PR title and description
│   ├── codex-review/      # Delegate review to OpenAI Codex CLI
│   ├── jira-fetch/        # Fetch JIRA issues (requires .jira.env)
│   ├── refactor/          # Martin Fowler style refactoring
│   └── scrum-poker/       # Estimate complexity (Scrum poker)
└── scripts/
    └── deny-check.sh      # Pre-tool use hook for command validation
```

### Skills: Auto vs Manual

| Auto (Claude invokes when relevant) | Manual only (`/name`) |
|---|---|
| commit, deepthink, refactor, edit-dotfile | codex-review, plan-search, plan-build, plan-sync, pr-review, pr-review-respond, pr-template, scrum-poker |

Manual skills have `disable-model-invocation: true` in frontmatter.

## Development Workflow

For larger implementations, use this structured approach:

### 1. Investigation & Requirements
- `/plan-search [feature-name]` — Create investigation checklist
- Gather specifications, screenshots, requirements interactively
- Complete all investigation items through codebase/DB/dependency analysis

### 2. Plan Creation
- `/plan-build [feature-name]` — Requires completed plan-search
- Creates plan document with section completeness verification
- Includes: architecture, file changes, testing strategy, implementation plan

### 3. Implementation
- `/plan-sync [feature-name]` — Periodically sync plan with actual progress
- `/reload-config` — After modifying CLAUDE.md or skills
- Consider splitting tasks/PRs when plan documents exceed 1000 lines

### 4. Archive
- Move completed plans to `.claude/plans/archive/`

## CLAUDE.md Best Practices

See: https://code.claude.com/docs/en/best-practices

## MCP

### context7
https://github.com/upstash/context7

```
claude mcp add --transport http context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: YOUR_API_KEY"
```

### container-use

(Optional) Run in your project repository:

```bash
claude mcp add -s project container-use -- container-use stdio
```

Creates `.mcp.json` in the project. After Docker is running, run `/mcp` to test.

> Ideally MCP would be managed globally, but global MCP gets recorded in `~/.claude.json` instead of `~/.claude/mcp.json`. (see anthropics/claude-code#3098)

## References

- [Best Practices](https://code.claude.com/docs/en/best-practices) — Tips and patterns for effective use
- [CLAUDE.md (Memory)](https://code.claude.com/docs/en/memory) — Persistent context configuration
- [Skills](https://code.claude.com/docs/en/skills) — Create and manage custom skills
- [Sub-agents](https://code.claude.com/docs/en/sub-agents) — Delegate tasks to specialized agents
- [Hooks](https://code.claude.com/docs/en/hooks-guide) — Automate workflows around tool events
- [MCP](https://code.claude.com/docs/en/mcp) — Connect external tools and services
- [Permissions](https://code.claude.com/docs/en/permissions) — Configure tool access and allowlists
