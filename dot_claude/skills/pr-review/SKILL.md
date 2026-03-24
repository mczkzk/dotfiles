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

## Process

0. **Resolve PR Number**
   - If `$ARGUMENTS` is empty or not a number, auto-detect: `gh pr view --json number -q .number`
   - If auto-detect fails (no PR for current branch), warn and abort

1. **Get PR Details**
   - Check working tree: `git status --short` → if uncommitted changes exist, warn and abort
   - `gh pr checkout <PR number>`
   - `gh pr diff <PR number>`
   - `gh pr view <PR number> --comments`
   - `gh api repos/{owner}/{repo}/pulls/{number}/comments`

2. **Load Plan Context**
   - Extract ticket key from PR branch name or title (e.g., `PROJ-123`)
   - Search: `.claude/plans/{TICKET-KEY}/` directory
   - If ticket key was found, always run `/jira-fetch {TICKET-KEY}` to get the latest JIRA state
   - Read these files (skip if absent):
     - `jira.md` — requirements, stakeholder decisions
     - `plan.md` — design, implementation decisions, investigation findings
     - `review-response.md` — prior review responses (avoid re-flagging)
     - `review.md` — previous review results (to update)
   - Use this context to:
     - Verify implementation aligns with requirements and PM decisions
     - Avoid flagging intentional design decisions already documented
     - Check if prior review findings were addressed
     - Understand scope boundaries (what was explicitly excluded and why)

3. **Gather External Context** (optional, skip if MCP unavailable)
   - **Slack**: Search for the PR URL or ticket key in relevant channels
     - Check for direct mentions, urgency signals, or discussion threads
     - If found, note urgency level and key context (e.g., deadline, CVE, blocker)
   - **Jira (related tickets)**: If the main ticket has issue links or belongs to an Epic
     - Fetch linked issues to understand dependencies and blockers
     - Check sibling tasks under the same Epic for scope overlap
   - Prepend `[URGENT]` to the review output if urgency signals found (direct mentions requesting review, deadline pressure, CVE/security fixes)

4. **Check Project Rules & Skills**
   - Read rules from `~/.claude/rules/` and `.claude/rules/` whose path patterns match the changed files
   - Read skills from `.claude/skills/` relevant to the changed files (e.g., DB schema, API design)
   - Explicitly list each loaded rule/skill and include them as review criteria

5. **Understand Context**
   - Read changed and related files
   - Check config, dependencies, architecture

6. **Review Changes** (parallel agents)
   - Launch `security-reviewer`, `convention-checker`, and `reuse-finder` agents **in parallel** with your own review
   - Your review: Logic, correctness, quality, performance, edge cases
   - `security-reviewer` agent: OWASP vulnerabilities, auth/authz, data exposure
   - `convention-checker` agent: Project pattern compliance, naming, structure
   - `reuse-finder` agent: New definitions that duplicate existing code in the codebase
   - Merge agent findings into your review (deduplicate, apply severity labels)

7. **Create Verification Plan**
   - Prerequisites and setup
   - Test scenarios and expected results

8. **Save `review.md`** (do this BEFORE reporting to user)
   - Look for existing `.claude/plans/{ISSUE-KEY}/` directory matching the PR's ticket key
   - If found: write the full review (Summary, Findings, Verification Steps) to `review.md` in that directory
   - If not found: skip (do not create a new plan directory)
   - On repeated runs: update the existing `review.md` (do not create duplicates)

9. **Report** to user using the Output format below

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

3. **Findings**: Label each with severity
   - `[BLOCKER]`: Must fix before merge
   - `[MUST]`: Required changes
   - `[SHOULD]`: Important but negotiable
   - `[SUGGESTION]`: Improvements and alternatives
   - `[NIT]`: Minor issues (naming, formatting)
   - `[QUESTION]`: Clarifications needed
   - `[FYI]`: Notes and references

   For English PRs, each finding in `review.md` should follow this format:

   ```markdown
   ### [SHOULD] 日本語の説明タイトル

   日本語での詳細説明...

   > **PR Comment (EN):**
   > `_setShrink` is missing the `private` modifier. Other event handlers
   > in this file (`_setIncludesStockpileVolume`, `_setIsShrinkMenuOn`)
   > all use `private`.
   ```

