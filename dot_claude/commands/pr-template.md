---
description: Generate PR title and description from GitHub PR diff
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Grep
  - Glob
  - AskUserQuestion
---

Generate PR title and description from an existing GitHub Pull Request's diff. After generation, confirm whether to update the PR with `gh pr edit`.

## Usage

```
/pr-template <PR number>
```

**Examples:**
- `/pr-template 123`
- `/pr-template 456`

## Process

1. **Get PR Information**
   - `gh pr view <PR number>` - Get current title and description
   - `gh pr diff <PR number>` - Get code changes

2. **Check for Plan Document**
   - Search for `plans/*/plan.md` files
   - If found, read plan.md for:
     - Requirements and motivation
     - Architecture decisions
     - Testing strategy

3. **Analyze Changes**
   - Review changed files and their purpose
   - Identify new features or bug fixes
   - Note configuration or dependency changes
   - Cross-reference with plan.md if available

4. **Generate Template**
   - Follow existing PR description structure if present
   - If PR description is empty, use minimal template:
     - **Summary**: What changed and why (reference plan.md)
     - **Test Plan**: Step-by-step verification (reference plan.md)
   - **Title**: Concise, descriptive summary

5. **Confirm Update**
   - Display generated title and description
   - Ask: "Update this PR with `gh pr edit`?"
   - If yes: Run `gh pr edit <PR number> --title "..." --body "..."`
   - If no: User can manually copy parts they want

## Notes

- Title and summary written in English
- Leverages plan.md if available for context
- Shows current PR content for reference
- User confirms before updating PR