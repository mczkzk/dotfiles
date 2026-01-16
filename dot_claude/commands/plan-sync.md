---
description: Sync plan document with actual implementation progress
argument-hint: [optional: task ID like "PROJECT-123" or feature-name like "user-auth", auto-detected if omitted]
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash(git diff:*, git log:*, git status:*)
  - Task
---

# Plan Sync Command

Automatically syncs plan.md with actual implementation state using conversation context and codebase analysis.

## Command Execution Steps

### 1. 🔍 Identify Target Files
- **If feature-name provided**: Use `.agent/plans/[feature-name]/plan.md`
- **Otherwise**:
  1. Check current session's plan
  2. If not found, infer feature-name from context and check `.agent/plans/*/plan.md` (excluding `archive/`)

### 2. 📊 Gather Evidence (No User Prompts)

**From Conversation Context:**
- What tasks were discussed as completed
- Issues encountered and how they were resolved
- Approach changes or pivots made during implementation
- New discoveries or learnings mentioned
- Incorrect assumptions that were corrected

**From Codebase:**
- Check if mentioned files exist (Glob)
- Verify functions/classes/patterns exist (Grep)
- Review recent changes (git diff)
- Read relevant source files to confirm implementation

### 3. ✏️ Apply Updates Directly

Update plan.md immediately without confirmation:

- **Completed tasks**: `[ ]` → `[x]`
- **New tasks**: Add to appropriate Phase
- **Modified tasks**: Update description to match actual implementation
- **Removed tasks**: Delete or strikethrough
- **Assumption corrections**: Update search.md if exists

### 4. 📝 Append to Implementation Notes

Add sync log:

```markdown
### Sync Log - YYYY-MM-DD HH:MM

**Changes applied:**
- [completed] A.1 - Task name (evidence: src/feature.ts:45)
- [modified] B.2 - Changed approach from X to Y
- [added] C.3 - New task discovered during implementation
- [removed] D.1 - No longer needed

**Context sources:**
- Conversation: discussed completion of X, pivot from Y to Z
- Codebase: verified in src/*, git diff shows 15 files changed
```

### 5. 📋 Output Summary

After applying changes, output brief summary:

```markdown
## Plan Sync Complete

**Applied:**
- ✅ Completed: X tasks
- ✏️ Modified: X tasks
- ➕ Added: X tasks
- 🗑️ Removed: X tasks

**Updated files:**
- .agent/plans/[feature-name]/plan.md
```

## Analysis Techniques

### Conversation Context
- Recent messages about task completion
- Error discussions and resolutions
- "Actually we should..." or "Let's change to..." statements
- Questions answered that clarify implementation

### Codebase Verification
- `Glob` for files mentioned in tasks
- `Grep` for function/class names from task descriptions
- `git diff main...HEAD` for changed files
- `Read` to confirm implementation details

### Pattern Matching
- "Add function X" → Grep for "function X"
- "Create component Y" → Check Y.tsx exists
- "Update schema Z" → Check migration files

## Key Principles

- **Fully automatic**: No confirmation prompts (user can undo with cmd+z)
- **Context-aware**: Uses conversation history + codebase
- **Evidence-based**: Every change backed by source
- **Comprehensive**: Checks all tasks, not just recent
- **Preserve history**: Logs all changes in Implementation Notes

## Recommended Timing

- After completing a Phase
- Before `/pr-template`
- After long work sessions
- When resuming after context loss
