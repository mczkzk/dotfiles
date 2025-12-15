---
description: Sync plan document with actual implementation progress
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
---

# Plan Sync Command

Synchronizes plan.md with current implementation state. Reflects progress, discovered issues, and corrects incorrect assumptions.

## Usage

```
/plan-sync [feature-name]
# Sync plan.md for specified feature

/plan-sync
# Auto-detect target from context
```

## Command Execution Steps

### 1. 🔍 Identify Target Files
- If feature-name provided: Load `plans/[feature-name]/plan.md`
- If no feature-name: Find most recently modified `plans/*/plan.md`
- Also load corresponding `plans/[feature-name]/search.md`

### 2. 📊 Gather Current Status
Ask user the following:

```
## Sync Check

### Completed Tasks
Which tasks have been completed? (Specify by task number)

### New Tasks
Any additional tasks discovered during implementation?

### Modified Tasks
Any tasks that changed from original plan? (Scope change, approach change, etc.)

### Removed Tasks
Any tasks that became unnecessary or should be skipped?

### Incorrect Assumptions
Any mistakes in search.md investigation?
(e.g., API spec was different, misunderstood existing code, etc.)

### Other Discoveries
Any findings or learnings to record in Implementation Notes?
```

### 3. ✏️ Update plan.md
Based on user responses:

- **Completed tasks**: Update `- [ ]` → `- [x]`
- **New tasks**: Add to appropriate Phase (renumber as needed)
- **Modified tasks**: Update task content, add comment explaining change reason
- **Removed tasks**: ~~Strikethrough~~ or delete (confirm with user)
- **Implementation Notes**: Append change history and discoveries

### 4. ✏️ Update search.md (If Assumptions Were Wrong)
- Add corrections to relevant investigation items
- Record error and correct information in Investigation Notes
- Format: `~~incorrect info~~ → correct info (discovered: YYYY-MM-DD)`

### 5. 📋 Output Sync Summary

```markdown
## Plan Sync Complete

### Change Summary
- ✅ Completed: X items
- ➕ Added: X items
- ✏️ Modified: X items
- 🗑️ Removed: X items
- 🔧 Assumption fixes: X items

### Updated Files
- plans/[feature-name]/plan.md
- plans/[feature-name]/search.md (if assumptions corrected)

### Remaining Tasks
- Incomplete: X items
- Next task: [task name]
```

## Implementation Notes Update Format

```markdown
### Sync Log - YYYY-MM-DD HH:MM

**Changes:**
- [completed] A.1 - Task name
- [added] B.3 - New task name (reason: discovered ○○ was needed)
- [modified] A.2 - old: ○○ → new: △△ (reason: due to ××)
- [removed] C.1 - Task name (reason: determined unnecessary)

**Assumption Corrections:**
- search.md: ○○ spec was actually ×× not △△

**Discoveries & Learnings:**
- Notable findings to record
```

## Key Principles

- **Implementation-driven**: Update plan based on actual progress
- **History preservation**: Record why changes were made
- **Assumption correction**: Honestly record investigation errors as learnings
- **Interactive**: Confirm with user before updating, no auto-decisions
- **Lightweight**: Keep simple so it can be called frequently

## Recommended Timing

- After completing a Phase
- When major approach changes occur
- After long work sessions as a checkpoint
- Whenever you think "this doesn't match the plan"
