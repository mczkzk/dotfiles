# Claude Code User Configuration

Global configuration for Claude Code (`~/.claude/`), managed via chezmoi.

## Structure

```
dot_claude/
├── CLAUDE.md              # Global instructions (loaded every session)
├── .jira.env              # JIRA API credentials (shared by jira-fetch, deploy etc.)
├── settings.json          # Permission and tool settings
├── skills/                # Custom skills (see table below)
├── agents/                # Subagent definitions (used by skills via Agent tool)
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
| `/custom-feature-dev` | manual | main | Fetches JIRA/GitHub context, creates plan.md/SPEC.md, launches `/feature-dev:feature-dev` |
| `/commit` | manual | main | One-shot. Commits and done |
| `/refactor` | manual | main | Interactive. Review changes, give follow-up instructions |
| `/create-draft-pr` | manual | main | One-shot. Creates draft PR with auto-filled template |
| `/pr-review` | manual | fork | One-shot. Returns review findings to act on in main |
| `/pr-review-respond` | manual | main | Interactive. Refine reply text |
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
1. **Implement** — Direct instructions or `/feature-dev:feature-dev`
2. **Commit** — `/commit` after each step (git push is always done manually)
3. **E2E** (optional) — `/e2e-verify` to verify UI changes with Playwright
4. **Refactor** — `/simplify` (bundled), `/refactor [target]`, `codex /refactor`
5. **PR** — `/create-draft-pr` to create draft PR with auto-filled template
6. **Review** — `/pr-review`, `/code-review:code-review`, `codex /pr-review`. Fix and re-commit if needed
7. **Respond** — `/pr-review-respond` when reviewer leaves comments (especially useful for English replies)

### Reviewing others' PRs
1. **Review** — `/pr-review`, `/code-review:code-review`, `codex /pr-review`
2. **E2E** (optional) — `/e2e-verify` to verify UI changes with Playwright

### Large feature flow
For complex features that span multiple sessions, need external context (JIRA/GitHub Issues), or benefit from a persistent plan document:
1. **Implement** — `/custom-feature-dev [ticket or feature]`
2. **Commit → E2E → Refactor → PR → Review** — Same as my PR flow
3. **Archive** — Move completed plans to `.claude/plans/archive/`

## Agents (subagents)

Defined in `agents/`, invoked by skills via the Agent tool.

| Agent | Model | Used by | Role |
|-------|-------|---------|------|
| `test-runner` | haiku | refactor | Run tests in isolated context |
| `reuse-finder` | sonnet | refactor | Find existing code to reuse |
| `security-reviewer` | sonnet | pr-review | OWASP-focused security review |
| `convention-checker` | sonnet | pr-review | Project convention compliance |
| `complexity-analyzer` | sonnet | scrum-poker | Code complexity metrics |
| `web-researcher` | sonnet | — | Web search for docs and solutions |
| `code-tracer` | sonnet | — | Code path and git history tracing |

Note: `/deep-dive` also supports **agent teams** (experimental) for parallel hypothesis-driven investigation where teammates debate and disprove each other's theories. Enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.json.

## Plugins / MCP

`codex` = [OpenAI Codex CLI](https://github.com/openai/codex). Separate tool, used as second opinion for review/refactor.

### Required by skills
- Slack MCP — Used by `/pr-review` for discussion context (MCP registry)
- Atlassian MCP — Used by `/jira-fetch`, `/pr-review` for JIRA context (MCP registry)

### Bundled skills (included with Claude Code)
- simplify — Quick code quality pass (used in refactor step)

### Plugins (claude-plugins-official)
- [feature-dev](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/feature-dev) — Guided feature development with codebase exploration and architecture design
- [code-review](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review) — PR code review. For local detailed review, use custom `/pr-review` instead
- [skill-creator](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator) — Create, modify, and eval custom skills

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
