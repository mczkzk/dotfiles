---
description: Respond to PR review comments <number> with fixes and reply drafts
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Edit
  - Grep
  - Glob
  - mcp__ide__getDiagnostics
---

Respond to PR review comments by fixing issues and generating reply drafts.

## Usage

```
/pr-review-respond <PR number>
```

## Process

1. **Get Review Comments**
   - `gh pr view <PR number> --comments`
   - `gh api repos/{owner}/{repo}/pulls/{number}/comments`

2. **Analyze and Prioritize**
   - Categorize: Critical / Important / Optional
   - Create action items

3. **Take Action**
   - Code changes if needed
   - Explanations for misunderstandings
   - Run tests after fixes

4. **Generate Reply Drafts**
   - Casual, brief tone (engineer-to-engineer)
   - Use abbreviations: "L45" for line 45, "+" for "and"
   - Reference files and line numbers
   - Format as copy-pasteable markdown

## Output

### Changes Made
- List modified files with descriptions

### Suggested Replies
- Quote original comment
- Provide casual reply (e.g., "Fixed at L47 + test", "Done")
- User copies to GitHub

### Test Results
- Test status, linting, type checks

## Principles

- Fix first, reply later
- Casual tone with evidence (file:line refs)
- No auto-posting
