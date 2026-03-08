---
name: refactor
description: Improve existing code structure while preserving external behavior. Use when the user asks to refactor a file, simplify changed code, reduce duplication, split long functions, improve naming, remove dead code, or make code easier to maintain without changing product behavior.
---

# Refactor

## Overview

Refactor in small, behavior-preserving steps. Prefer targeted structural improvements with verification after each meaningful change instead of broad rewrites.

## Workflow

1. Understand the target before editing.
   - Read the relevant files and nearby call sites.
   - Identify the code smell or maintenance problem the refactor should solve.
   - Distinguish refactoring from feature work. If behavior must change, state that explicitly instead of hiding it inside the refactor.

2. Check safety constraints.
   - Inspect `git status --short` so you know whether unrelated local changes exist.
   - Avoid destructive cleanup and never revert user changes you did not make.
   - Find the smallest useful verification command: focused tests, type checks, linters, or a build step.

3. Apply small, reversible changes.
   - Make one coherent improvement at a time.
   - Prefer extraction, renaming, dead-code removal, guard clauses, duplication consolidation, and responsibility cleanup.
   - Keep public behavior stable unless the user requested a behavior change.

4. Verify continuously.
   - Run the relevant checks after each substantial batch.
   - If the repository has no useful automated checks, use the strongest available local validation and say what remains unverified.

5. Finish with proof.
   - Summarize the structural changes.
   - State the verification performed.
   - Call out residual risks when the refactor could not be fully exercised.

## Common Refactor Moves

- Extract a long function into smaller units
- Rename unclear variables, methods, or types
- Replace magic values with named constants
- Collapse duplicated logic into one implementation
- Introduce guard clauses to flatten nested conditionals
- Move logic to the module or type that owns the responsibility
- Remove dead code and stale comments
- Tighten public surface area when the API is not used externally
- Add or improve types when they reduce ambiguity without changing runtime behavior

## Decision Rules

- Preserve behavior first. Refactoring is not a pretext for hidden feature changes.
- Prefer existing project patterns over personal preference.
- Keep changes scoped. If the best design requires a large rewrite, explain that tradeoff before expanding the task.
- When tests fail before you start, do not assume the refactor caused it. Isolate the failure and report it clearly.

## Guardrails

- Do not introduce new abstractions without a concrete readability or maintenance benefit.
- Do not bundle unrelated cleanups into the same refactor unless the user asked for a broader pass.
- Do not use destructive git commands for rollback.
- Do not claim behavior preservation unless you verified it with code inspection, tests, or another concrete check.
