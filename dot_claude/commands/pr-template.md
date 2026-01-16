---
description: Generate PR title and description from GitHub PR <number> diff
argument-hint: <number: GitHub PR number like 123>
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Grep
  - Glob
  - AskUserQuestion
---

Generate PR title and description from PR diff. Confirm before updating with `gh pr edit`.

## Process

1. **Get PR Information**
   - `gh pr view <PR number>`
   - `gh pr diff <PR number>`

2. **Check for Plan Document**
   - Search: current session plan → `.agent/plans/*/plan.md`
   - Read for requirements, architecture, tests

3. **Analyze Changes**
   - Changed files, features, bug fixes, config changes
   - Cross-reference with plan if available

4. **Generate Template**
   - Follow existing structure or use minimal:
     - **Summary**: What changed and why (reference plan)
     - **Test Plan**: Verification steps (reference plan)
   - **Title**: Concise summary

5. **Confirm Update**
   - Display generated content
   - Ask: "Update with `gh pr edit`?"
   - Execute or let user copy manually

## Notes

- English title and summary
- Leverages plan for context
- User confirms before update