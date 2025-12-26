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

Respond to review comments on your Pull Request by fixing issues and generating reply drafts.

## Usage

```
/pr-review-respond <PR number>
```

**Examples:**
- `/pr-review-respond 123`
- `/pr-review-respond 456`

## Process

1. **Get Review Comments**
   - `gh pr view <PR number> --comments` - Get discussion comments
   - `gh api repos/{owner}/{repo}/pulls/{number}/comments` - Get inline review comments on code
   - Organize comments by file and line number

2. **Analyze and Prioritize**
   - Identify issues that need code changes
   - Categorize: Critical / Important / Optional
   - Create action items list

3. **Implement Fixes**
   - Address each comment with code changes
   - Run tests to verify fixes
   - Ensure no regressions

4. **Generate Reply Drafts**
   - Create concise reply for each comment
   - **Tone**: Keep it casual and brief (engineer-to-engineer, not formal)
   - Use short sentences, abbreviations OK (e.g., "L45" for line 45, "+" for "and")
   - Explain what was fixed and how
   - Reference file paths and line numbers
   - Format as copy-pasteable markdown

## Output Format

```markdown
## PR Review Response Summary

**PR #123**: [PR Title]

### Changes Made

**Modified files:**
- `src/component.ts:45-50` - Added null check
- `src/utils.ts:120` - Fixed typo in function name
- `tests/component.test.ts` - Added test case for edge case

### Suggested Replies

Copy and paste these replies to GitHub review comments:

---

#### Comment by @reviewer on `src/component.ts:45`
> This function should handle null case

**Reply:**
```
Fixed at L47-49 + added test
```

---

#### Comment by @reviewer on `src/utils.ts:120`
> Typo in function name: "proceess" should be "process"

**Reply:**
```
Done, updated all refs
```

---

### Test Results
- ✅ All tests passing
- ✅ No new linting errors
- ✅ Type checks passed
```

## Key Principles

- **Fix first, reply later**: Implement changes before drafting replies
- **Casual tone**: Brief, engineer-friendly replies (e.g., "Fixed at L45 + test", "Done, see commit")
- **Evidence-based**: Reference specific lines/files in replies
- **Test validation**: Verify all fixes with tests
- **No auto-posting**: User manually copies replies to GitHub
