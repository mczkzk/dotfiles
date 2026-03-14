---
name: pr-review
description: Review GitHub PR and identify issues and improvements. Use when the user asks to review a PR, audit a proposed change before merge, inspect `gh pr diff` output, or produce actionable review findings with severity and file references.
---

# PR Review

Review code with a code-review mindset. Prioritize verifiable findings over summaries, and focus on correctness, behavior changes, edge cases, security, and test gaps.

## Process

### 0. Resolve PR Number
- If the user gives a PR number, use it
- Otherwise auto-detect: `gh pr view --json number -q .number`
- If auto-detect fails (no PR for current branch), warn and abort

### 1. Get PR Details
- Check working tree: `git status --short` → if dirty, warn and review via `git diff` instead of checking out
- `gh pr diff <PR number>`
- `gh pr view <PR number> --comments`
- `gh api repos/{owner}/{repo}/pulls/{number}/comments`

### 2. Check for Plan Document
- Search `.codex/plans/*/plan.md` or `.claude/plans/*/plan.md`
- If found, verify alignment with requirements, architecture, tests

### 3. Understand Context
- Read changed and related files (call sites, data flow, existing patterns)
- Check config, dependencies, architecture

### 4. Review Changes
- Logic bugs, missing validation, broken invariants, incorrect assumptions
- Authorization gaps across the full call chain
- Performance traps, migration risks, incomplete error handling
- Test coverage for changed behavior, especially unhappy paths

### 5. Validate Suspicious Areas
- Run targeted tests, linters, or type checks when possible
- If verification cannot be run, state so and downgrade confidence

### 6. Create Verification Plan
- Prerequisites and setup
- Test scenarios and expected results

## Principles

- Flag verifiable problems only — do not invent issues you cannot justify from the patch
- Ask questions when uncertain
- Don't criticize unfamiliar patterns or optimize for style nits over correctness
- Never discard or overwrite unrelated local changes
- Never use destructive git commands to prepare the review

## Criteria

- **Correctness**: Behavioral regressions, logic errors, edge cases
- **Security**: Authorization in call chain, data access checks, cross-resource ownership, entry point validation
- **Data Integrity**: Schema and migration risks
- **Error Handling**: Fallback behavior, incomplete handling
- **Performance**: Issues caused by the change
- **Testing**: Coverage and quality for changed behavior
- **Smells**: Duplication, dead code, hardcoded values, reinventing existing definitions
- **Architecture**: Pattern violations, separation of concerns (only when they create real risk)

## Output

Present findings first, ordered by severity.

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

If there are no findings, say that explicitly, then note residual risks or testing gaps.
