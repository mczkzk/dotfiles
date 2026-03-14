---
name: refactor
description: Improve existing code structure while preserving external behavior. Use when the user asks to refactor a file, simplify changed code, reduce duplication, split long functions, improve naming, remove dead code, or make code easier to maintain without changing product behavior.
---

# Refactor

Apply refactoring techniques in small, behavior-preserving steps.

## Safety Requirements

**MANDATORY before refactoring:**
- Tests exist and pass (`npm test`, `pytest`, etc.)
- Clean git status (committed changes)
- Can rollback easily

## Process

### 0. Resolve Target
- If target is provided, use it
- If target is empty, auto-detect in order:
  1. **PR detection**: `gh pr view --json number -q .number` — if a PR exists for the current branch, use its changed files (`gh pr diff <number> --name-only`)
  2. **Main branch diff**: `git diff main...HEAD --name-only` — if files differ from main, use those as target
  3. **Ask user**: If both above produce no results, ask what to refactor

### 1. Pre-Check
- Read target files and nearby call sites
- Identify the code smell or maintenance problem the refactor should solve
- Distinguish refactoring from feature work — if behavior must change, state that explicitly
- Run tests (must be green)
- Check git status (must be clean)

### 2. Reuse Discovery

Scan new definitions (types, functions, constants, interfaces) in target files and search the existing codebase for reusable equivalents:

1. List all newly added definitions in the target diff
2. Search the codebase for similar names, signatures, or shapes
3. If a match is found, replace the new definition with a reference to the existing one
4. If partially overlapping, consider extracting a shared abstraction

### 3. Refactoring Techniques

Select appropriate technique(s) based on the description:

**Extraction & Splitting**
- Extract Method — split long methods
- Extract Class — split classes with too many responsibilities
- Extract + Move Method — consolidate duplicated code

**Naming & Clarity**
- Rename Variable/Method/Class — improve unclear naming
- Replace Magic Number with Constant — name magic numbers

**Conditionals & Control Flow**
- Guard Clauses — flatten conditionals with early returns
- Decompose Conditional — break complex conditionals
- Replace Conditional with Polymorphism — type-based branching to OOP
- Remove Flag Argument — split flag args into separate methods

**Parameters & Data**
- Introduce Parameter Object — group too many params into an object
- Replace Primitive with Object — primitives to value objects
- Extract Class (Data Clump) — group co-used data together

**Encapsulation & Moving**
- Move Method/Field — relocate to correct responsibility owner
- Encapsulate Field — direct access to getter/setter
- Move Method (Feature Envy) — move methods that envy another class

**Visibility & Scope**
- Remove Unused Public — delete unused public APIs
- Minimize Public Surface — minimize exposure of internals
- Consolidate Exports — organize scattered exports

**Inheritance & Abstraction**
- Extract Superclass/Interface — extract common code from subclasses
- Replace Inheritance with Delegation — improper inheritance to delegation

**Simplification & Cleanup**
- Inline Method/Class — undo over-abstraction
- Remove Dead Code — delete unused code
- Replace Temp with Query — temporary vars to method calls
- Separate Query from Modifier — split side effects and queries
- Avoid Unnecessary Complexity — remove redundant indirection
- Consolidate Duplicate Definitions — merge definitions that overlap with existing ones

**Performance Optimization**
- Replace Loop Lookup with Map/Set — linear search to O(1)
- Cache Repeated Queries — cache repeatedly computed values

**Type Safety**
- Add Type Definitions — add types where possible (JS→TS, any→concrete, JSDoc annotations)

**Comments & Documentation**
- Remove Unnecessary Comments — delete What/obvious comments, keep only Why
- Verify Doc Accuracy — verify documentation matches implementation

**Git-Based**
- Analyze git diff — analyze branch diff and refactor

### 4. Micro-Cycle (Repeat)
1. **Small change** (one technique, one location)
2. **Test** (must stay green)
3. **Commit** (enable rollback)

### 5. Complete
- Run full test suite
- Run linting/type check
- Summarize structural changes
- State verification performed
- Call out residual risks

## Key Principles

- **Small steps** — One change at a time
- **Always green** — Tests pass after each step
- **Reversible** — Easy rollback at any point
- **Behavior preservation** — External behavior unchanged
- **Prefer project patterns** — over personal preference

## Guardrails

- Do not introduce new abstractions without concrete readability or maintenance benefit
- Do not bundle unrelated cleanups unless asked for a broader pass
- Do not use destructive git commands for rollback
- Do not claim behavior preservation unless verified with tests or code inspection
