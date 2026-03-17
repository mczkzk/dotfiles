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
| `/deep-dive` | manual | main | Interactive. Discuss based on findings |
| `/cc-reference` | manual | fork | Check docs before writing config |
| `edit-dotfile` | auto | main | Auto-resolves chezmoi path when editing dotfiles |

- **fork**: Runs in a separate context, keeps main conversation clean (only summary returned)
- **main**: Runs in main context, results available for follow-up conversation
- **auto**: Auto-triggered by description match (no slash command needed)

## Development Workflow

### Common flow
1. **Implement** — Write code
2. **Refactor** — `/simplify` then `/refactor [target]` if needed
   - Optional: `codex /refactor` in a separate terminal for second opinion, paste results into Claude Code
3. **Commit** — `/commit` (git push is always done manually)
4. **PR** — `/pr-template` to generate title and description
5. **Review** — `/pr-review` (local detailed review with security, plan alignment)
   - Optional: `/code-review` plugin — posts to GitHub PR, confidence-scored
   - Optional: `codex /pr-review` — second opinion in a separate terminal, paste results into Claude Code
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

### Required by skills
- Slack MCP — Used by `/plan-search` for discussion context (MCP registry)
- Atlassian MCP — Used by `/plan-search` (MCP registry)

### Recommended — Claude Code official plugins
- code-review — PR code review. For local detailed review, use custom `/pr-review` instead
- skill-creator — Create, modify, and eval custom skills

### Recommended — MCP servers
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
