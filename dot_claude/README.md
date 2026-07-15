# Claude Code User Configuration

Global configuration for Claude Code (`~/.claude/`), managed via chezmoi.

## Structure

```
dot_claude/
├── CLAUDE.md              # Global instructions (loaded every session)
├── README.md              # This file
├── .jira.env              # JIRA API credentials (not in chezmoi, manually placed)
├── settings.json          # Permission and tool settings
├── statusline-command.sh  # Status line renderer
├── skills/                # Custom skills (see table below)
├── agents/                # Subagent definitions (used by skills via Agent tool)
├── rules/                 # Path-scoped rules (loaded when matching files)
└── scripts/               # Hook scripts
```

| File | Description |
|------|-------------|
| `rules/ts-guidelines.md` | TypeScript coding guidelines (`*.ts`, `*.tsx`) |
| `scripts/deny-check.sh` | Pre-tool use hook for command validation |
| `scripts/chezmoi-guard.sh` | Pre-tool use hook: blocks Write/Edit to chezmoi-managed paths, suggests source path |

## Skills

| Skill | Invoke | Usage |
|-------|--------|-------|
| `/commit` | manual | One-shot. Commits and done |
| `/custom-feature-dev` | manual | Fetches JIRA/GitHub context, creates plan.md/SPEC.md, launches `/feature-dev:feature-dev` |
| `/custom-simplify` | manual | Convention check + test → `/simplify` with context |
| `/create-draft-pr` | manual | One-shot. Creates draft PR with auto-filled template |
| `/pr-review` | manual | Orchestrated PR review: 11 parallel agents + confidence scoring + JIRA/Slack/plan.md context |
| `/pr-review-respond` | manual | Interactive. Refine reply text |
| `/scrum-poker` | manual | One-shot. Returns estimate only |
| `/jira-fetch` | manual | One-shot. Fetches JIRA ticket to `.claude/tasks/` |
| `/e2e-verify` | manual | Interactive. Verify UI with Playwright, take screenshots |
| `/video-debug` | manual | Extract frames from screen recording for visual debugging |
| `/spike-branch` | manual | Interactive. Spike implementation on throwaway branch, document findings, split into subtasks |
| `/deep-dive` | manual | Interactive. Discuss based on findings |
| `/cc-reference` | manual/auto | Check docs before writing config |
| `/new-repo` | manual | Interactive. Discuss repo name, create GitHub repo (local-first or GitHub-first) |
| `/chezmoi-edit` | manual/auto | Auto-resolves chezmoi source path when editing managed files under ~/ |

## Development Workflow

### My PR flow

0. **Spike** (if needed) — `/spike-branch` when the task is too complex to split upfront
1. **Implement** —
   - Small: Direct instructions or `/feature-dev:feature-dev`
   - Medium: `/custom-feature-dev [ticket or feature]`
   - Large: `/batch [instruction]` (repetitive; e.g. migrate all files from X to Y)
   - Stuck: `/codex:rescue [what to investigate or fix]` (delegate investigation/fix to Codex)
2. **Simplify** —
   - Small: `/simplify`
   - Medium/Large: `/custom-simplify [target]` (convention check + test + simplify)
3. **E2E** — `/e2e-verify` to verify UI changes with Playwright (optional)
4. **PR** — `/create-draft-pr` to create draft PR with auto-filled template
5. **Review** — fix if needed
   - Default: `/pr-review` (with agents + JIRA/Slack/plan.md)
   - Worried: `/codex:review` or `/codex:adversarial-review` (cross-model; latter challenges design choices)
6. **Respond** — `/pr-review-respond` when reviewer leaves comments (especially useful for English replies); fix if needed
7. **Archive** — Move completed tasks to `.claude/tasks/archive/`

`/commit` after each meaningful change. Push is always manual.

### Reviewing others' PRs
Run **Step 3** (E2E, optional) then **Step 5** (Review) from My PR flow.

## Agents (subagents)

Defined in `agents/`, invoked by skills via the Agent tool.

| Agent | Model | Used by | Role |
|-------|-------|---------|------|
| `test-runner` | haiku | custom-simplify | Run tests in isolated context |
| `reuse-finder` | sonnet | pr-review | Find existing code to reuse |
| `security-reviewer` | sonnet | pr-review | OWASP-focused security review |
| `convention-checker` | sonnet | pr-review, custom-simplify | Project convention compliance |
| `complexity-analyzer` | sonnet | scrum-poker | Code complexity metrics |
| `web-researcher` | sonnet | — | Web search for docs and solutions |
| `code-tracer` | sonnet | pr-review | Code path and dependency tracing |
| `git-historian` | sonnet | pr-review | Git blame, log, and change pattern analysis |
| `past-pr-reviewer` | sonnet | pr-review | Past PR comment re-applicability check |
| `code-comment-checker` | sonnet | pr-review | Code comment compliance verification |
| `claim-verifier` | sonnet | pr-review | Verify strong claims in comments match code behavior |
| `performance-checker` | sonnet | pr-review | Detect performance regressions on hot paths |
| `symmetry-checker` | sonnet | pr-review | Find asymmetric validation / control-flow gaps |
| `output-validity-checker` | sonnet | pr-review | Adversarially test whether normal input can yield no valid result |

Note: `/deep-dive` also supports **agent teams** (experimental) for parallel hypothesis-driven investigation where teammates debate and disprove each other's theories. Enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.json.

## Plugins / MCP

### Required by skills
- Slack MCP — Used by `/pr-review` for discussion context (MCP registry)
- Atlassian MCP — Used by `/jira-fetch`, `/pr-review` for JIRA context (MCP registry)

### [Bundled skills](https://code.claude.com/docs/en/skills#bundled-skills) (included with Claude Code)
- simplify — Code quality pass with 3 parallel agents (reuse, quality, efficiency). Called by `/custom-simplify`
- batch — Codebase-wide parallel changes. Decomposes into 5-30 units, each in isolated git worktree. **Each unit auto-creates a PR**

### Plugins (claude-plugins-official)
- [feature-dev](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/feature-dev) — Guided feature development with codebase exploration and architecture design
- [skill-creator](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator) — Create, modify, and eval custom skills

### Plugins (third-party)
- [codex-plugin-cc](https://github.com/openai/codex-plugin-cc) — Delegate investigation or fixes to Codex CLI as a rescue subagent (`/codex:rescue`, `/codex:setup`)

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
- [Agent Teams](https://code.claude.com/docs/en/agent-teams) — Coordinate multiple Claude instances as a team (experimental)
