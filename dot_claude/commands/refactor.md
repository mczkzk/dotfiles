---
description: Perform Martin Fowler style refactoring with systematic approach
allowed-tools:
  - Read
  - Edit
  - MultiEdit
  - Glob
  - Grep
  - Bash(test:*, lint:*, build:*)
  - mcp__ide__getDiagnostics
---

# Refactor Command

Apply Martin Fowler refactoring techniques through natural language requests.

## Usage
```
/refactor [description of what needs refactoring]
```

**Examples:**
```
/refactor files changed since main branch
/refactor xxx.ts is too long and needs splitting
/refactor this function has duplicate code
/refactor complex nested conditions in auth.py
```

## Safety Requirements

⚠️ **MANDATORY before refactoring:**
- Tests exist and pass (`npm test`, `pytest`, etc.)
- Clean git status (committed changes)
- Can rollback easily

## Process

### 1. Pre-Check
- Read target files
- Run tests (must be green)
- Check git status (must be clean)

### 2. Auto-Technique Selection
- **"too long" / "splitting"** → Extract Method
- **"duplicate code"** → Extract + Move Method  
- **"complex conditions"** → Guard Clauses
- **"doing too many things"** → Extract Class
- **"changed since main"** → Analyze git diff

### 3. Micro-Cycle (Repeat)
1. **Small change** (one technique, one location)
2. **Test** (must stay green)
3. **Commit** (enable rollback)

### 4. Complete
- Run full test suite
- Run linting/type check
- Verify improved readability

## Key Principles

- **Small steps** - One change at a time
- **Always green** - Tests pass after each step  
- **Reversible** - Easy rollback at any point
- **Behavior preservation** - External behavior unchanged

> 💡 **Fowler's Rule**: "If you make a mistake, it's easy to find the bug"