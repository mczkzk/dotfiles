---
name: custom-feature-dev
description: Feature development kickstarter. Fetches external context (JIRA, GitHub Issues), creates plan.md and SPEC.md, then launches /feature-dev with full context. Use this whenever the user wants to start building a feature, gives a task/ticket number, or says something like "this issue/ticket to implement".
argument-hint: "<requirements description or issue number (e.g. PROJ-123, issue-45, add-user-auth)>"
disable-model-invocation: true
---

# Custom Feature Dev

One command to go from a ticket number or feature idea to a running `/feature-dev` session with full context.

## Step 1: Parse Input

Classify `$ARGUMENTS` into one of:

| Pattern | Type | Example |
|---|---|---|
| `^[A-Z]+-\d+$` | JIRA ticket | `PROJ-123` |
| Number-only (and `.claude/jira-prefix` exists) | JIRA ticket | `123` -> `{PREFIX}-123` |
| `^#?\d+$` | GitHub Issue | `#45` or `45` (stored as `issue-45`) |
| URL containing `atlassian` | JIRA ticket | extract key from URL |
| URL containing `github.com` with `/issues/` | GitHub Issue | extract owner/repo and number |
| Everything else | Feature description | `add-user-auth` |

**If ambiguous** (e.g. bare number with no `.claude/jira-prefix`): ask the user what it is.

For feature descriptions, propose a kebab-case `feature-name` to the user for confirmation (used as directory name).

Set `$FEATURE_ID` to the resolved identifier (e.g. `PROJ-123`, `issue-45`, or `add-user-auth`). For GitHub Issues, strip `#` and prefix with `issue-`.

## Step 2: Fetch External Context

### JIRA Ticket

1. Run `/jira-fetch $FEATURE_ID`
2. Read the generated `.claude/plans/$FEATURE_ID/jira.md`
3. Check for linked issues, subtasks, parent tickets in jira.md
4. If there are important linked tickets (blockers, "is caused by", related work), fetch those too with `/jira-fetch` and note their summaries

### GitHub Issue

1. Run: `gh issue view <number> --json title,body,comments,labels,assignees,milestone`
2. Save to `.claude/plans/$FEATURE_ID/issue.md`
3. Check for referenced issues/PRs in the body and comments

### Feature Description (no external ticket)

- The user's description itself is the requirement
- Ask the user if there are any related tickets, docs, or links they want to include

Store all gathered info in `.claude/plans/$FEATURE_ID/`.

## Step 3: Create plan.md

Read the template from `${CLAUDE_SKILL_DIR}/references/plan-template.md` and fill in:

- `$FEATURE_ID` -- the resolved identifier
- `$TITLE` -- ticket summary or feature description
- `$APPLICABLE_RULES_AND_SKILLS` -- leave as `*To be filled after codebase exploration.*`
- `$REQUIREMENTS` -- from JIRA/GitHub/user description, be specific
- `$RELATED_CONTEXT` -- links to related tickets (with status and summary), key decisions from comments/discussions

Save to `.claude/plans/$FEATURE_ID/plan.md`.

This file is intentionally lean. feature-dev fills in architecture and implementation details during its phases.

## Step 4: SPEC.md (Personal Repos Only)

Check if this is a personal repository:

```bash
git remote get-url origin 2>/dev/null
```

**Personal repo indicators** (any of these):
- No git remote (local-only project)
- URL contains the user's GitHub username (matches pattern `github.com/<username>/`)

If unsure, ask the user.

**If personal repo** and `docs/SPEC.md` does not exist:
1. Create `docs/SPEC.md` with the project's overall specification
2. Read existing README, CLAUDE.md, and source code structure to populate it
3. Keep it high-level: purpose, core features, tech stack, key decisions

**If `docs/SPEC.md` already exists**: skip.

## Step 5: Update CLAUDE.md

Check if CLAUDE.md already contains "SSoT" (grep for it). If not, add the following block at the **top** of CLAUDE.md (after any existing frontmatter):

```markdown
## SSoT (Single Source of Truth) -- DO NOT REMOVE
**You MUST keep these files up-to-date at every implementation milestone. This is non-negotiable.**
- `.claude/plans/$FEATURE_ID/plan.md` -- investigation findings, implementation progress, decisions
- `docs/SPEC.md` -- project specification (personal repos only, skip if not exists)

Update these files BEFORE moving to the next task. They are the persistent record that survives context resets.
```

If the SSoT block already exists, update the plan path to the current `$FEATURE_ID` but don't duplicate the block.

## Step 6: Launch /feature-dev

Read the prompt template from `${CLAUDE_SKILL_DIR}/references/feature-dev-prompt.md` and fill in:

- `$TITLE` -- ticket summary or feature description
- `$REQUIREMENTS` -- same as plan.md
- `$CONTEXT` -- key info from JIRA comments, linked tickets, GitHub issue discussion. Include file pointers:
  - JIRA: "Full ticket details are in `.claude/plans/$FEATURE_ID/jira.md`"
  - GitHub: "Full issue details are in `.claude/plans/$FEATURE_ID/issue.md`"
- `$FEATURE_ID` -- the resolved identifier

Invoke `/feature-dev:feature-dev` with the filled prompt.
