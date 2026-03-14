# Claude Code User Configuration

Global configuration for Claude Code (`~/.claude/`), managed via chezmoi.

## Structure

```
dot_claude/
├── CLAUDE.md              # Global instructions (loaded every session)
├── .jira.env              # JIRA API credentials (shared by jira-fetch, deploy etc.)
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
│   ├── jira-fetch/        # Fetch JIRA issues (requires ~/.claude/.jira.env)
│   ├── refactor/          # Martin Fowler style refactoring
│   └── scrum-poker/       # Estimate complexity (Scrum poker)
└── scripts/
    └── deny-check.sh      # Pre-tool use hook for command validation
```


## Development Workflow

### Common flow
1. **Implement** — Write code
2. **Refactor** — `/simplify` then `/refactor [target]` if needed
3. **Commit** — `/commit` (git push is always done manually)
4. **PR** — `/pr-template` to generate title and description
5. **Review** — `/pr-review` (main: local detailed review with security, plan alignment)
   - `/code-review` — Optional: posts to GitHub PR, confidence-scored
   - `/codex-review` — Optional: second opinion via OpenAI Codex
6. **Respond** — `/pr-review-respond` to address review comments

### Large feature flow
For implementations that need upfront planning:

1. **Investigation** — `/plan-search [feature-name]` to create checklist, gather specs
2. **Plan** — `/plan-build [feature-name]` to create architecture and implementation plan
3. **Implement** — `/plan-sync [feature-name]` to track progress against plan
4. **Refactor → Commit → PR → Review** — Same as common flow
5. **Archive** — Move completed plans to `.claude/plans/archive/`

Consider splitting tasks/PRs when plan documents exceed 1000 lines.

## Plugins / MCP

- [context7](https://github.com/upstash/context7) — Up-to-date library docs lookup (plugin)
- [code-review](https://github.com/anthropics/claude-code-marketplace/blob/main/code-review/README.md) — Automated PR code review (plugin)
  - Posts review comments to GitHub PR. 5 parallel agents + confidence scoring to filter false positives
  - For local detailed review (security, plan alignment, verification plan), use custom `/pr-review` instead
- [container-use](https://github.com/dagger/container-use) — Run containers from Claude Code (MCP)

## References

- [Best Practices](https://code.claude.com/docs/en/best-practices) — Tips and patterns for effective use
- [CLAUDE.md (Memory)](https://code.claude.com/docs/en/memory) — Persistent context configuration
- [Skills](https://code.claude.com/docs/en/skills) — Create and manage custom skills
- [Sub-agents](https://code.claude.com/docs/en/sub-agents) — Delegate tasks to specialized agents
- [Hooks](https://code.claude.com/docs/en/hooks-guide) — Automate workflows around tool events
- [MCP](https://code.claude.com/docs/en/mcp) — Connect external tools and services
- [Permissions](https://code.claude.com/docs/en/permissions) — Configure tool access and allowlists
