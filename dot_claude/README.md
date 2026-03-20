# Claude Code User Configuration

Global configuration for Claude Code (`~/.claude/`), managed via chezmoi.

## Structure

```
dot_claude/
├── CLAUDE.md              # Global instructions (loaded every session)
├── .jira.env              # JIRA API credentials (shared by jira-fetch, deploy etc.)
├── settings.json          # Permission and tool settings
├── skills/                # Custom skills (see table below)
├── rules/                 # Path-scoped rules (loaded when matching files)
└── scripts/               # Hook scripts
```

| File | Description |
|------|-------------|
| `rules/ts-guidelines.md` | TypeScript coding guidelines (`*.ts`, `*.tsx`) |
| `scripts/deny-check.sh` | Pre-tool use hook for command validation |

## Skills

| Skill | Invoke | Context | Usage |
|-------|--------|---------|-------|
| `/commit` | manual | fork | One-shot. Commits and done |
| `/refactor` | manual | main | Interactive. Review changes, give follow-up instructions |
| `/pr-template` | manual | main | Interactive. Iterate on PR title and description |
| `/pr-review` | manual | main | Interactive. Fix issues from review findings |
| `/pr-review-respond` | manual | main | Interactive. Refine reply text |
| `/plan-search` | manual | main | Interactive. Research with user |
| `/plan-build` | manual | fork | One-shot. Generates plan files and done |
| `/plan-sync` | manual | main | One-shot, lightweight — no fork needed |
| `/scrum-poker` | manual | fork | One-shot. Returns estimate only |
| `/jira-fetch` | manual | main | One-shot, lightweight — no fork needed |
| `/e2e-verify` | manual | main | Interactive. Verify UI with Playwright, take screenshots |
| `/deep-dive` | manual | main | Interactive. Discuss based on findings |
| `/cc-reference` | manual | fork | Check docs before writing config |
| `edit-dotfile` | auto | main | Auto-resolves chezmoi path when editing dotfiles |

- **fork**: Runs in a separate context, keeps main conversation clean (only summary returned)
- **main**: Runs in main context, results available for follow-up conversation
- **auto**: Auto-triggered by description match (no slash command needed)

## Development Workflow

### My PR flow
1. **Implement** — Write code
2. **Commit** — `/commit` after each step (git push is always done manually)
3. **E2E** (optional) — `/e2e-verify` to verify UI changes with Playwright
4. **Refactor** — `/simplify` (bundled), `/refactor [target]`, `codex /refactor`
5. **PR** — `/pr-template` to generate title and description
6. **Review** — `/pr-review`, `/code-review` (plugin), `codex /pr-review`. Fix and re-commit if needed
7. **Respond** — `/pr-review-respond` when reviewer leaves comments (especially useful for English replies)

### Reviewing others' PRs
1. **Review** — `/pr-review`, `/code-review` (plugin), `codex /pr-review`
2. **E2E** (optional) — `/e2e-verify` to verify UI changes with Playwright

### Large feature flow
For implementations that need upfront planning:

For self-contained features (clear requirements, single session), use `/feature-dev` (plugin) instead.
For features requiring external context (JIRA/Slack), multi-session tracking, or documented plans:
1. **Investigation** — `/plan-search [feature-name]` to create checklist, gather specs
2. **Plan** — `/plan-build [feature-name]` to create architecture and implementation plan
3. **Implement** — Build from plan.md, running `/plan-sync [feature-name]` periodically to track progress
4. **Commit → E2E → Refactor → PR → Review** — Same as my PR flow
5. **Archive** — Move completed plans to `.claude/plans/archive/`

Consider splitting tasks/PRs when plan documents exceed 1000 lines.

## Plugins / MCP

`codex` = [OpenAI Codex CLI](https://github.com/openai/codex). Separate tool, used as second opinion for review/refactor.

### Required by skills
- Slack MCP — Used by `/plan-search`, `/pr-review` for discussion context (MCP registry)
- Atlassian MCP — Used by `/plan-search` for JIRA context (MCP registry)

### Bundled skills (included with Claude Code)
- simplify — Quick code quality pass (used in refactor step)

### Plugins (claude-plugins-official)
- feature-dev — Guided feature development with codebase exploration and architecture design
- code-review — PR code review. For local detailed review, use custom `/pr-review` instead
- skill-creator — Create, modify, and eval custom skills

### MCP servers
- [context7](https://github.com/upstash/context7) — Library docs lookup (MCP registry, by Upstash)
- [playwright](https://github.com/microsoft/playwright-mcp) — Browser automation and testing (by Microsoft)
- [chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) — Chrome DevTools debugging (by Google Chrome team)

## References

- [Best Practices](https://code.claude.com/docs/en/best-practices) — Tips and patterns for effective use
- [CLAUDE.md (Memory)](https://code.claude.com/docs/en/memory) — Persistent context configuration
- [Skills](https://code.claude.com/docs/en/skills) — Create and manage custom skills
- [Sub-agents](https://code.claude.com/docs/en/sub-agents) — Delegate tasks to specialized agents
- [Hooks](https://code.claude.com/docs/en/hooks-guide) — Automate workflows around tool events
- [MCP](https://code.claude.com/docs/en/mcp) — Connect external tools and services
- [Permissions](https://code.claude.com/docs/en/permissions) — Configure tool access and allowlists
