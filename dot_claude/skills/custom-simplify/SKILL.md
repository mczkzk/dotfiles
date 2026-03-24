---
name: custom-simplify
description: "Run convention check and tests, then launch /simplify with context. Use instead of /simplify directly for safer, convention-aware code cleanup."
argument-hint: "[target: what to simplify like 'src/auth/' or 'files changed since main'] (empty = auto-detect)"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh:*)
  - Bash(git:*)
  - Agent
  - AskUserQuestion
---

# Custom Simplify

Pre-flight checks before `/simplify`: convention check + test verification.

## Process

### 0. Resolve Target
- If `$ARGUMENTS` is provided, use it as the target
- If empty, auto-detect in order:
  1. **PR detection**: `gh pr view --json number -q .number` → changed files (`gh pr diff <number> --name-only`)
  2. **Main branch diff**: `git diff main...HEAD --name-only`
  3. **Ask user**

### 1. Pre-Flight (parallel)

Launch **2 agents in parallel**:

| Agent | Role |
|-------|------|
| `convention-checker` | Check target files against project conventions and neighboring file patterns |
| `test-runner` | Run tests to confirm green before changes |

**If `test-runner` returns FAIL**: Report failure and stop. Fix tests first.

**If `test-runner` returns PASS**: Proceed.

### 2. Launch /simplify

Invoke `/simplify` with the resolved target and convention-checker findings:

```
Simplify the following files: [resolved target files]

Convention issues to address:
[convention-checker findings, if any]
```

### 3. Post-Check

After `/simplify` completes, run `test-runner` agent to verify no regressions.

- **PASS** → Done
- **FAIL** → Report which tests broke. Ask user whether to revert or fix.
