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
| `/commit` | manual | fork | 一発完了。コミットして終わり |
| `/refactor` | manual | main | 対話的。修正結果を見て追加指示 |
| `/pr-template` | manual | main | 対話的。文章の推敲を繰り返す |
| `/pr-review` | manual | main | 対話的。レビュー結果から修正指示 |
| `/pr-review-respond` | manual | main | 対話的。返信テキストを推敲 |
| `/plan-search` | manual | main | 対話的。ユーザーと調査を進める |
| `/plan-build` | manual | fork | 一発完了。ファイル生成して終わり |
| `/plan-sync` | manual | main | 一発完了だが軽量、forkは不要 |
| `/scrum-poker` | manual | fork | 一発完了。見積結果だけ返る |
| `/jira-fetch` | manual | main | 一発完了だが軽量、forkは不要 |
| `/deep-dive` | manual | main | 対話的。調査結果をもとに議論 |
| `/cc-reference` | manual | fork | 設定を書く前にドキュメント確認 |
| `edit-dotfile` | auto | main | dotfile編集時に自動でchezmoiパス解決 |

- **fork**: 別コンテキストで実行、メインの会話を汚さない（結果の要約のみ返る）
- **main**: メインコンテキストで実行、後続の会話で結果を参照できる
- **auto**: descriptionマッチで自動トリガー（スラッシュコマンド不要）

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
