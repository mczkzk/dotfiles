---
description: Review GitHub PR <number> and identify issues and improvements
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Grep
---

Review a GitHub Pull Request and identify issues that need to be fixed.

## Usage

```
/pr-review <PR number>
```

**Examples:**
- `/pr-review 123`
- `/pr-review 456`

## Process

1. **Get PR Details**
   - `gh pr diff <PR number>` - Get diff
   - `gh pr view <PR number> --comments` - Get PR info and discussion comments
   - `gh api repos/{owner}/{repo}/pulls/{number}/comments` - Get inline review comments on code

2. **Review Changes**
   - Analyze implementation logic and correctness
   - Check code quality and patterns
   - Identify bugs, security issues, performance problems
   - Verify error handling and edge cases

## Review Principles

- **Only flag verifiable problems** - Report issues with concrete evidence (bugs, security, performance)
- **When uncertain, ask questions** - If you cannot determine whether something is good or bad, write a concise question in English for the author
- **Don't criticize unfamiliar patterns** - Unknown intent ≠ bad code

## Review Criteria

### Code Quality
- Inconsistent naming or formatting
- Missing error handling
- Unclear variable/function names
- Unnecessary comments or missing critical ones

### Logic & Correctness
- Incorrect implementation
- Unhandled edge cases
- Performance issues

### Security
- Authorization not passed through call chain
- Data access without authorization checks
- Cross-resource access without ownership verification
- Authorization checks only at entry points

### Code Smells
- Code duplication
- Unused code or dead code
- Hardcoded values
- Over/under-engineered abstractions
- Multiple responsibilities in single function/class

### Architecture
- Violates existing patterns
- Poor separation of concerns
- Hard to maintain or extend

### Testing
- Missing test coverage
- Poor test quality

## Output Format

1. **Summary**
   - Changed files and scope

2. **Questions for Author** (if any)
   - Write concise questions in English when you cannot determine if implementation is good or bad
   - User will copy-paste these to GitHub PR comments

3. **Issues Found**
   - Bugs and logic errors
   - Security vulnerabilities
   - Performance problems
   - Code quality issues
   - Architecture violations

4. **Required Changes**
   - Critical fixes needed
   - Code improvements
   - Refactoring suggestions

Focus on actionable items that need to be addressed before merging.