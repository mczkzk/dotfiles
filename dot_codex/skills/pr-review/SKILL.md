---
name: pr-review
description: Review a GitHub pull request or PR-like diff and identify concrete bugs, regressions, security risks, and missing tests. Use when the user asks to review a PR, audit a proposed change before merge, inspect `gh pr diff` output, or produce actionable review findings with severity and file references.
---

# PR Review

## Overview

Review code with a code-review mindset. Prioritize verifiable findings over summaries, and focus on correctness, behavior changes, edge cases, security, and test gaps.

## Workflow

1. Determine the review target.
   - If the user gives a PR number and the repository is clean, inspect the PR with `gh`.
   - If the worktree is dirty or `gh` is unavailable, review the current branch diff or the files the user points to instead of forcefully changing branches.
   - Never discard or overwrite unrelated local changes.

2. Gather review context before judging the patch.
   - Check `git status --short` to see whether checkout is safe.
   - Read the diff with `gh pr diff <number>` or `git diff`.
   - Read the PR description and review comments with `gh pr view <number> --comments` when available.
   - Open the changed files and enough surrounding code to understand call sites, data flow, and existing patterns.

3. Verify behavior, not style.
   - Look for logic bugs, missing validation, broken invariants, incorrect assumptions, authorization gaps, performance traps, migration risks, and incomplete error handling.
   - Check tests for coverage of the changed behavior, especially unhappy paths and compatibility edges.
   - Prefer findings that can be defended from the code or from a reproducible verification step.

4. Validate suspicious areas.
   - Run targeted tests, linters, or type checks when they materially increase confidence and the environment allows it.
   - If you cannot run verification, say so and downgrade confidence accordingly.

5. Report findings first.
   - Order findings by severity.
   - Include file references and the reason the behavior is risky.
   - Keep summaries brief and secondary.

## Review Criteria

- Correctness and behavioral regressions
- Security and authorization checks across the full call chain
- Data integrity, schema, and migration risks
- Error handling and fallback behavior
- Performance issues caused by the change
- Missing or weak tests for the changed behavior
- Architectural inconsistencies only when they create real risk

## Output Format

Present findings first. Use this shape unless the user requests something else:

```markdown
[severity] Short finding title
- Why it is a problem.
- Where it appears.
- What condition triggers it or how to verify it.
```

Severity labels to use:
- `[BLOCKER]` for merge-stopping issues
- `[MUST]` for required fixes
- `[SHOULD]` for important but negotiable issues
- `[SUGGESTION]` for non-critical improvements
- `[QUESTION]` when intent is unclear and risk depends on that answer
- `[FYI]` for useful context without an action request

If there are no findings, say that explicitly, then note residual risks or testing gaps.

## Guardrails

- Do not invent issues you cannot justify from the patch and surrounding code.
- Do not optimize for style nits when there are higher-risk correctness issues.
- Do not checkout another branch if the worktree is dirty unless the user explicitly wants that and the action is safe.
- Do not use destructive git commands to prepare the review.
