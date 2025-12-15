---
description: Generate PR title, summary, and test plan from git diff between working branch and target branch
allowed-tools:
  - Bash(git:*)
  - Read
  - Grep
  - Glob
---

Generate a pull request template with title, summary, and test plan based on code changes between the current working branch and a target branch (default: main).

## Usage

```
/pr-template [target-branch]
```

**Examples:**
- `/pr-template` - Generate PR template comparing with main branch
- `/pr-template develop` - Compare with develop branch
- `/pr-template feature/auth` - Compare with feature/auth branch

## Analysis Process

1. **Check for Plan Document**
   - Search for `plans/*/plan.md` files in the repository
   - If found, read plan.md to understand:
     - Requirements Summary (the "why")
     - Architecture Impact and design decisions
     - Testing Strategy for test plan reference
     - Implementation Notes for context and learnings

2. **Identify Changes**
   - Run `git diff [target-branch]...HEAD --name-only` to list changed files
   - Run `git diff [target-branch]...HEAD --stat` to show change statistics
   - Run `git diff [target-branch]...HEAD` to analyze actual code changes

3. **Analyze Implementation**
   - Review each changed file to understand:
     - Purpose and functionality of changes
     - New features or bug fixes implemented
     - Modified components and their interactions
     - Configuration or dependency changes
   - Cross-reference with plan.md to verify completeness

4. **Generate PR Template**
   - **Title**: Concise, descriptive title summarizing the main change
   - **Summary**: Bullet points explaining what was changed and why (leverage plan.md Requirements)
   - **Test Plan**: Step-by-step instructions for manual testing (leverage plan.md Testing Strategy)

## Template Format

The generated template follows this structure:

### Title
```
Brief description of main change
```

### Summary
```
## Summary
- What was implemented/changed and why
- Key technical decisions
- Impact on existing functionality

## Tags
- Multiple relevant tags based on change type (feat, fix, refactor, docs, test, chore, style, perf, etc.)
```

### Test Plan
```
## Test Plan
Step-by-step verification instructions
Edge cases to test
Integration points to verify
```

## Information Gathering

If the diff doesn't provide enough context to generate a complete template, the command will:

1. **Request Additional Context**
   - Ask about the motivation for changes
   - Request clarification on complex modifications
   - Inquire about testing requirements

2. **Suggest File Reviews**
   - Recommend reading related files for better context
   - Ask about dependencies or configuration changes
   - Request information about breaking changes

## Output Requirements

- **Title**: Clear, concise description without type prefix
- **Summary**: Written in English, explains the "what" and "why"
- **Test Plan**: Actionable steps that reviewers can follow
- **Professional tone**: Suitable for team collaboration

## Notes

- **Plan-aware**: References plan.md for requirements, design decisions, and test strategy
- **Context-aware**: Considers existing codebase patterns and conventions
- **Comprehensive**: Covers both technical changes and business impact
- **Actionable**: Provides clear testing and verification steps
- **Interactive**: Asks for clarification when needed for completeness

This command streamlines the PR creation process by automatically generating professional, comprehensive pull request descriptions based on actual code changes and plan documentation.