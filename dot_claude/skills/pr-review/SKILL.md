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
   - If ticket key was found and `jira.md` does not exist, run `/jira-fetch {TICKET-KEY}` to retrieve it
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

3. **Check Project Rules**
   - Read rules from `~/.claude/rules/` and `.claude/rules/` whose path patterns match the changed files
   - Explicitly list each loaded rule and include them as review criteria

4. **Understand Context**
   - Read changed and related files
   - Check config, dependencies, architecture

5. **Review Changes**
   - Logic, correctness, quality, patterns
   - Bugs, security, performance, edge cases

6. **Create Verification Plan**
   - Prerequisites and setup
   - Test scenarios and expected results

## Principles

- Flag verifiable problems only
- Ask questions when uncertain
- Don't criticize unfamiliar patterns

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

## Plans Integration

After review, save results to `.claude/plans/`:
- Look for existing plan directory matching the PR's ticket key (e.g., `.claude/plans/{ISSUE-KEY}/`)
- If found: create or **update** `review.md` in that directory
- If not found: skip (do not create a new plan directory)
- On repeated runs: update the existing `review.md` (do not create duplicates)
