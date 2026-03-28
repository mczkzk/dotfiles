---
name: pr-review
description: Review GitHub PR and identify issues and improvements
argument-hint: "[number: GitHub PR number like 123] (empty = auto-detect from current branch)"
disable-model-invocation: true
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Grep
  - Glob
  - Agent
  - mcp__claude_ai_Slack__slack_search_channels
  - mcp__claude_ai_Slack__slack_search_public
  - mcp__claude_ai_Slack__slack_read_channel
  - mcp__claude_ai_Slack__slack_read_thread
  - mcp__claude_ai_Atlassian__getJiraIssue
  - mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql
  - mcp__claude_ai_Atlassian__getJiraIssueRemoteIssueLinks
---

Review GitHub PR and identify issues.

**Your role is orchestrator.** You do NOT review code yourself. You collect information, dispatch agents, and integrate results. Do NOT write review.md until ALL steps below are complete.

## Process

### Phase 1: Setup (sequential)

0. **Resolve PR Number**
   - If `$ARGUMENTS` is empty or not a number, auto-detect: `gh pr view --json number -q .number`
   - If auto-detect fails (no PR for current branch), warn and abort

1. **Get PR Details**
   - Check working tree: `git status --short` → if uncommitted changes exist, warn and abort
   - `gh pr checkout <PR number>`
   - `gh pr diff <PR number>`
   - `gh pr view <PR number> --comments`
   - `gh api repos/{owner}/{repo}/pulls/{number}/comments`

### Phase 2: Context Preparation (parallel, depends on Phase 1)

Launch **2a and 2b in parallel**:

2a. **Load Plan Context**
   - Extract ticket key from PR branch name or title (e.g., `PROJ-123`)
   - Search: `.claude/tasks/{TICKET-KEY}/` directory
   - If ticket key was found, always run `/jira-fetch {TICKET-KEY}` to get the latest JIRA state
   - Read these files (skip if absent):
     - `jira.md` — requirements, stakeholder decisions
     - `plan.md` — design, implementation decisions, investigation findings
     - `review-response.md` — prior review responses (avoid re-flagging)
     - `review.md` — previous review results (to update)

2b. **Check Project Rules & Skills**
   - Read rules from `~/.claude/rules/` and `.claude/rules/` whose path patterns match the changed files
   - Read skills from `.claude/skills/` relevant to the changed files (e.g., DB schema, API design)
   - Explicitly list each loaded rule/skill and include them as review criteria

**Wait for both 2a and 2b to complete before proceeding.**

### Phase 3: Review + External Context (parallel, depends on Phase 2)

Launch **ALL of the following in parallel**. Each agent returns a list of issues with the reason each was flagged.

**CRITICAL instruction for ALL agents**: Do NOT create any files (no `review.md`, no reports). Return findings as text output only. File writing is handled exclusively in Phase 6.

| Agent | Type | Responsibility |
|-------|------|----------------|
| **A** | `convention-checker` | Audit changes for compliance with CLAUDE.md and loaded rules/skills from 2b. Note: CLAUDE.md is guidance for Claude writing code, so not all instructions apply during review |
| **B** | `security-reviewer` | OWASP vulnerabilities, auth/authz, data exposure |
| **C** | `reuse-finder` | New definitions that duplicate existing code in the codebase |
| **D** | `git-historian` | Read git blame and history of modified code to identify bugs in light of historical context (e.g., reverted patterns being reintroduced) |
| **E** | `past-pr-reviewer` | Read previous PRs that touched these files, check for review comments that may also apply |
| **F** | `code-comment-checker` | Read code comments (TODO, NOTE, FIXME, invariants, contracts) in modified files, verify the PR complies |
| **G** | general-purpose (sonnet) | Shallow scan of the diff for obvious bugs. Focus on large bugs only, avoid nitpicks. Ignore likely false positives |

Also in parallel with the agents above (optional, skip if MCP unavailable):

- **External Context**:
  - **Slack**: Search for the PR URL or ticket key in relevant channels. Check for urgency signals
  - **Jira (related tickets)**: If the main ticket has issue links or belongs to an Epic, fetch linked issues

**Wait for ALL 7 agents to complete before proceeding to Phase 4.** External Context may still be in progress; it will be used in Phase 5.

### Phase 4: Confidence Scoring (depends on Phase 3 agents ALL complete)

For each finding from Phase 3, launch a **separate haiku agent** to score it independently (0-100). The scorer receives: the PR diff, the finding description, and the list of CLAUDE.md/rules files from 2b. Scoring rubric (give verbatim to each scorer agent):
  - `0`: Not confident at all. False positive that doesn't stand up to light scrutiny, or a pre-existing issue
  - `25`: Somewhat confident. Might be real, but could be a false positive. Couldn't verify. If stylistic, not explicitly called out in CLAUDE.md/rules
  - `50`: Moderately confident. Verified real, but a nitpick or rare in practice. Not very important relative to the PR
  - `75`: Highly confident. Double-checked and very likely real and will be hit in practice. Directly mentioned in CLAUDE.md/rules
  - `100`: Absolutely certain. Double-checked and confirmed. Happens frequently, evidence directly confirms

For CLAUDE.md-flagged issues, the scorer must verify the CLAUDE.md actually calls out that issue specifically.

**Wait for ALL scorers to complete before proceeding.**

### Phase 5: Integrate (depends on Phase 3 External Context + Phase 4 BOTH complete)

- Merge all agent findings: deduplicate, apply severity labels, attach confidence scores
- Use Plan Context (from 2a) to:
  - Exclude findings about intentional design decisions already documented
  - Check if prior review findings were addressed
  - Understand scope boundaries (what was explicitly excluded and why)
- Use External Context (from Phase 3) for urgency signals:
  - Prepend `[URGENT]` if urgency signals found (direct mentions requesting review, deadline pressure, CVE/security fixes)
- **Important**: Only flag findings in files tracked by git (`git ls-files`). Do NOT flag content in `.gitignore`d or auto-generated files
- Create Verification Plan: prerequisites, setup, test scenarios, expected results

### Phase 6: Output (depends on Phase 5)

6a. **Save `review.md`** (do this BEFORE reporting to user)
   - Look for existing `.claude/tasks/{ISSUE-KEY}/` directory matching the PR's ticket key
   - If found: write the full review (Summary, Findings, Verification Steps) to `review.md` in that directory
   - If not found: skip (do not create a new task directory)
   - On repeated runs: update the existing `review.md` (do not create duplicates)

6b. **Report** to user using the Output format below

## Principles

- Flag verifiable problems only
- Ask questions when uncertain
- Don't criticize patterns already established in the project
- **Review language**: Detect the PR language from title/body/comments. If the PR is in English, each finding in `review.md` must include a `> **PR Comment (EN):**` block right after the Japanese explanation. This block should be copy-pasteable as a GitHub review comment. If the PR is in Japanese, Japanese only.

## Criteria

- **Quality**: Naming, error handling, comments
- **Logic**: Implementation, edge cases, performance
- **Security**: Authorization in call chain, data access checks, cross-resource ownership, entry point validation
- **Smells**: Duplication, dead code, hardcoded values, reinventing existing definitions
- **Architecture**: Pattern violations, separation of concerns
- **Testing**: Coverage, quality

## Output

1. **Summary**: Changed files and scope

2. **Verification Steps** (if any): Prerequisites, setup, test scenarios, expected results, edge cases

3. **Findings**: Label each with severity and confidence score. Include a GitHub permalink (full SHA + line range) for each finding.
   - `[BLOCKER]`: Must fix before merge
   - `[MUST]`: Required changes
   - `[SHOULD]`: Important but negotiable
   - `[SUGGESTION]`: Improvements and alternatives
   - `[NIT]`: Minor issues (naming, formatting)
   - `[QUESTION]`: Clarifications needed
   - `[FYI]`: Notes and references

   For English PRs, each finding in `review.md` should follow this format:

   ```markdown
   ### [SHOULD] 日本語の説明タイトル (confidence: 85)

   https://github.com/{owner}/{repo}/blob/{full-sha}/path/to/file.ext#L13-L17

   日本語での詳細説明...

   > **PR Comment (EN):**
   > `_setShrink` is missing the `private` modifier. Other event handlers
   > in this file (`_setIncludesStockpileVolume`, `_setIsShrinkMenuOn`)
   > all use `private`.
   ```

   For Japanese PRs:

   ```markdown
   ### [SHOULD] 説明タイトル (confidence: 85)

   https://github.com/{owner}/{repo}/blob/{full-sha}/path/to/file.ext#L13-L17

   詳細説明...
   ```

