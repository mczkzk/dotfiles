---
description: Review GitHub PR <number> and identify issues and improvements
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Grep
  - Glob
---

Review GitHub PR and identify issues.

## Usage

```
/pr-review <PR number>
```

## Process

1. **Get PR Details**
   - `gh pr diff <PR number>`
   - `gh pr view <PR number> --comments`
   - `gh api repos/{owner}/{repo}/pulls/{number}/comments`

2. **Understand Context**
   - Read changed and related files
   - Check config, dependencies, architecture

3. **Review Changes**
   - Logic, correctness, quality, patterns
   - Bugs, security, performance, edge cases

4. **Create Verification Plan**
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
- **Smells**: Duplication, dead code, hardcoded values
- **Architecture**: Pattern violations, separation of concerns
- **Testing**: Coverage, quality

## Output

1. **Summary**: Changed files and scope
2. **Verification Steps** (if any): Prerequisites, setup, test scenarios, expected results, edge cases
3. **Questions** (if any): For unclear implementation (copy to GitHub comments)
4. **Issues**: Bugs, security, performance, quality
5. **Changes**: Fixes and improvements