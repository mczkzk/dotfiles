---
name: spike-branch
description: Exploratory spike implementation for complex tasks. When a task feels too large or uncertain to split into subtasks upfront, this skill implements everything in a throwaway spike branch to discover unknowns, then documents findings for proper task decomposition. Use when the user says "spike", "let's try implementing this first", "this is too complex to split", or wants to explore a large task before committing to a plan.
argument-hint: "<task description or context (optional)>"
---

# Spike - Exploratory Implementation

Complex tasks are hard to split correctly without implementation experience. This skill sets up a spike branch and then works interactively with the user to implement, verify, and learn. The code is throwaway. The knowledge is the product.

## Guard: Branch Check

Verify the current branch is a task branch. If it matches any of these, **stop**:
- `main`, `master`, `dev`, `develop`, `development`, `stg`, `staging`, `prod`, `production`, `release/*`

## Step 1: Understand Context

Determine the task name from the current branch by stripping prefixes (`feature/`, `feat/`, `task/`).
- `feature/large-task` -> `large-task`

Check `.claude/plans/$TASK/` for existing spike docs:
- **No existing spikes**: spike-1.
- **spike-N.md exists**: Read all. Summarize key takeaways to the user. Next number = highest + 1.

If `$ARGUMENTS` is provided, treat as additional context.

## Step 2: Create Spike Branch

```bash
git checkout -b "spike/$TASK-$N"
```

Tell the user what you've learned from previous spikes (if any). Start implementing.

## Step 3: Implement

Implement the entire task end-to-end as fast as possible.

- **Speed over quality.** Skip tests, polish, edge cases.
- **Commit regularly.** Small commits with descriptive messages for later reference.
- **Flag surprises immediately.** Hidden dependencies, unexpected complexity, ordering constraints.

Once done, tell the user and wait for them to verify. They will check the app, test behavior, and give feedback. Fix and iterate based on their input.

## Step 4: Wrap Up (when the user says so)

When the user decides the spike is done, draft `.claude/plans/$TASK/spike-$N.md` together. Let the user review and refine:

```markdown
# Spike $N: $TASK

## Status
<!-- succeeded / abandoned (and why) -->

## What Was Attempted

## Key Discoveries
<!-- Things you couldn't have known without implementing -->

## Problems Encountered

## Dependencies and Ordering

## Architecture Decisions

## Recommendations for Next Spike / Implementation
```

Focus on what's **not obvious from reading the code alone**. The "why" and the "what surprised me".

Commit the doc, then tell the user the spike branch name so they can push it.

## When the User Says "OK, Let's Split"

Write `.claude/plans/$TASK/split.md`:

```markdown
# Task Split: $TASK

Based on spike-1 through spike-$N.

## Subtasks (in implementation order)

### 1. <subtask-title>
- Branch: `$TASK/<subtask-name>`
- PR target: `$PARENT_BRANCH`
- Description: ...
- Key considerations: ...
- Depends on: (none / subtask N)
```

Each subtask: independently reviewable, ordered by dependency, small enough to implement with confidence.
