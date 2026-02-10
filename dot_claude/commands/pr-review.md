---
description: Review GitHub PR <number> and identify issues and improvements
argument-hint: <number: GitHub PR number like 123>
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Grep
  - Glob
---

Review GitHub PR and identify issues.

## Process

1. **Get PR Details**
   - Check working tree: `git status --short` → if uncommitted changes exist, warn and abort
   - `gh pr checkout <PR number>`
   - `gh pr diff <PR number>`
   - `gh pr view <PR number> --comments`
   - `gh api repos/{owner}/{repo}/pulls/{number}/comments`

2. **Check for Plan Document**
   - Search: current session plan → `.agent/plans/*/plan.md`
   - If found, verify alignment with requirements, architecture, tests

3. **Understand Context**
   - Read changed and related files
   - Check config, dependencies, architecture

4. **Review Changes**
   - Logic, correctness, quality, patterns
   - Bugs, security, performance, edge cases

5. **Create Verification Plan**
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

3. **Findings**: Label each with severity
   - `[BLOCKER]`: Must fix before merge
   - `[MUST]`: Required changes
   - `[SHOULD]`: Important but negotiable
   - `[SUGGESTION]`: Improvements and alternatives
   - `[NIT]`: Minor issues (naming, formatting)
   - `[QUESTION]`: Clarifications needed
   - `[FYI]`: Notes and references