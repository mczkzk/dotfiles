---
description: Estimate code complexity and effort using Scrum poker scale (0, 1, 2, 3, 5, 8, 13, 20, 40, 100)
argument-hint: [optional: task ID like "PROJECT-123" or feature name like "user-auth", omit for current context]
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
  - Write
  - Bash
---

# Scrum Poker Estimation Command

Analyzes code complexity and provides effort estimates using standard Scrum poker scale: **0, 1, 2, 3, 5, 8, 13, 20, 40, 100, ?**.

## Effort Scale Mapping

- **0** - No work needed / Already exists
- **1** - Trivial change (1-5 lines, single file)
- **2** - Simple feature (basic CRUD, minor UI change)
- **3** - Small feature (multiple files, some logic)
- **5** - Medium feature (new component, API integration)
- **8** - Large feature (complex logic, multiple components)
- **13** - Major feature (significant architecture changes)
- **20** - Epic feature (multiple subsystems affected)
- **40** - Large epic (major refactoring, new architecture)
- **100** - Massive undertaking (complete rewrites, new systems)
- **?** - Requirements too unclear to estimate (needs investigation)

## Analysis Factors

- **Lines of code** - File/feature size
- **Cyclomatic complexity** - Decision points and branching
- **Dependencies** - External libraries and integrations
- **Test coverage needs** - Testing complexity
- **Documentation requirements** - API docs, comments
- **Risk factors** - Potential blockers and unknowns

## ⚠️ Estimation Adjustment Rules (MUST Apply)

Apply the following adjustments to the base estimate. Cumulative when multiple factors apply.

### Adjustment Factors (+1 level each)
- **Modifying existing code** - Requires impact analysis and regression testing
- **External API/service integration** - Auth, error handling, rate limits, etc.
- **Including review & testing** - PR creation, review cycles, CI fixes
- **Unfamiliar codebase/domain** - Time to understand code and acquire domain knowledge
- **Cross-team coordination** - Communication overhead

### Uncertainty Adjustments (+1-2 levels)
- Ambiguous or undefined requirements
- Technical unknowns
- No prior experience with similar tasks

### Guidelines
- **Estimate for "anyone on the team can complete" not "my fastest implementation"**
- When in doubt, choose the higher estimate (correcting optimism bias)

## Output Format

```
## 🎯 Scrum Poker Estimate: [NUMBER or ?]

### 📊 Complexity Analysis
- **Files affected**: X files
- **Lines of code**: ~X LOC
- **Dependencies**: [list]
- **Risk factors**: [list]

### 🔍 Reasoning
[Detailed explanation of estimate]

### ⚠️ Assumptions & Risks
- [Key assumptions made]
- [Potential blockers or unknowns]

### 📋 Next Steps (if estimate is ?)
- [Specific investigation needed to clarify requirements]
- [Questions that need answers before estimation]
```

## Result Saving

After outputting the estimate, check for `.agent/plans/` directory and save results:

1. **Check for plans directory**:
   - Run `ls -d .agent/plans/*/` to check if `.agent/plans/[feature-name]/` directories exist
   - If no `.agent/plans/` directory exists → Skip saving (output only)

2. **Determine save location**:
   - If argument (feature-name) provided: Save to `.agent/plans/[feature-name]/scrum-poker-result.md`
   - If no argument: Find most recently modified `.agent/plans/*/` directory and save there

3. **Save result**:
   - Write the estimate output to `scrum-poker-result.md` in the determined location
   - Confirm save location to user

