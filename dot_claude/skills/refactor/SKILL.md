---
name: refactor
description: Perform refactoring on <target>
argument-hint: "[target: what to refactor like 'files changed since main' or 'xxx.ts too long'] (empty = auto-detect from PR or main diff)"
allowed-tools:
  - Read
  - Edit
  - MultiEdit
  - Glob
  - Grep
  - Bash(gh:*)
  - Bash(git:*)
  - Bash
  - Agent
  - AskUserQuestion
  - mcp__ide__getDiagnostics
---

# Refactor Command

Apply refactoring techniques through natural language requests.

## Safety Requirements

**MANDATORY before refactoring:**
- Tests exist and pass (`npm test`, `pytest`, etc.)
- Clean git status (committed changes)
- Can rollback easily

## Process

### 0. Resolve Target
- If `$ARGUMENTS` is provided, use it as the refactoring target
- If `$ARGUMENTS` is empty, auto-detect in order:
  1. **PR detection**: `gh pr view --json number -q .number` — if a PR exists for the current branch, use its changed files (`gh pr diff <number> --name-only`)
  2. **Main branch diff**: `git diff main...HEAD --name-only` — if files differ from main, use those as target
  3. **Ask user**: If both above produce no results, ask the user what to refactor

### 1. Check Project Rules & Skills
- Read rules from `~/.claude/rules/` and `.claude/rules/` whose path patterns match the target files
- Read skills from `.claude/skills/` relevant to the target (e.g., DB schema, API design)
- Explicitly list each loaded rule/skill and follow them during refactoring

### 2. Pre-Check
- Read target files
- Run tests via subagent (must be green) — keeps test output out of main context
- Check git status (must be clean)

### 3. Reuse Discovery

Scan new definitions (types, functions, constants, interfaces) in target files and search the existing codebase for reusable equivalents:

1. List all newly added definitions in the target diff
2. For each, `Grep` / `Glob` the codebase for similar names, signatures, or shapes
3. If a match is found, replace the new definition with a reference to the existing one
4. If partially overlapping, consider extracting a shared abstraction

### 4. Refactoring Techniques

Select appropriate technique(s) based on the description:

**Extraction & Splitting**
- Extract Method - Split long methods into smaller ones
- Extract Class - Split classes with too many responsibilities
- Extract + Move Method - Consolidate duplicated code

**Naming & Clarity**
- Rename Variable/Method/Class - Improve unclear naming
- Replace Magic Number with Constant - Give names to magic numbers

**Conditionals & Control Flow**
- Guard Clauses - Flatten conditions with early returns
- Decompose Conditional - Break down complex conditional expressions
- Replace Conditional with Polymorphism - Replace type-based branching with OOP
- Remove Flag Argument - Replace flag arguments with separate methods

**Parameters & Data**
- Introduce Parameter Object - Group excessive arguments into an object
- Replace Primitive with Object - Replace primitives with value objects
- Extract Class (Data Clump) - Group data that is always used together

**Encapsulation & Moving**
- Move Method/Field - Move to where the responsibility belongs
- Encapsulate Field - Replace direct access with getters/setters
- Move Method (Feature Envy) - Move methods that heavily use another class

**Visibility & Scope**
- Remove Unused Public - Remove public APIs not used externally
- Minimize Public Surface - Minimize exposure of internal implementation
- Consolidate Exports - Consolidate scattered exports/public members

**Inheritance & Abstraction**
- Extract Superclass/Interface - Extract common code from subclasses
- Replace Inheritance with Delegation - Replace inappropriate inheritance with delegation

**Simplification & Cleanup**
- Inline Method/Class - Undo over-abstraction
- Remove Dead Code - Delete unused code
- Replace Temp with Query - Replace temporary variables with method calls
- Separate Query from Modifier - Separate side effects from queries
- Avoid Unnecessary Complexity - Eliminate redundant indirection or unnecessary steps
- Consolidate Duplicate Definitions - Merge definitions that duplicate existing ones

**Performance Optimization**
- Replace Loop Lookup with Map/Set - Replace linear search in loops with O(1) access
- Cache Repeated Queries - Cache repeatedly computed values

**Type Safety**
- Add Type Definitions - Add types where possible (JS→TS, any→concrete types, JSDoc type annotations, etc.)

**Comments & Documentation**
- Remove Unnecessary Comments - Delete what-comments, obvious comments, and commented-out code; keep only why-comments
- Verify Doc Accuracy - Verify consistency between documentation and implementation

**Git-Based**
- Analyze git diff - Analyze diffs between branches and refactor accordingly

### 5. Micro-Cycle (Repeat)
1. **Small change** (one technique, one location)
2. **Test via subagent** (must stay green)
3. **Commit** (enable rollback)

### 6. Complete
- Run full test suite + linting/type check via subagent
- Verify improved readability

## Key Principles

- **Small steps** - One change at a time
- **Always green** - Tests pass after each step
- **Reversible** - Easy rollback at any point
- **Behavior preservation** - External behavior unchanged
