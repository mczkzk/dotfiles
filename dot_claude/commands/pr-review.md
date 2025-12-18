---
description: Review GitHub PR and identify issues and improvements
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
   - `gh pr view <PR number>` - Get PR info

2. **Review Changes**
   - Analyze implementation logic and correctness
   - Check code quality and patterns
   - Identify bugs, security issues, performance problems
   - Verify error handling and edge cases

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

2. **Issues Found**
   - Bugs and logic errors
   - Security vulnerabilities
   - Performance problems
   - Code quality issues
   - Architecture violations

3. **Required Changes**
   - Critical fixes needed
   - Code improvements
   - Refactoring suggestions

Focus on actionable items that need to be addressed before merging.