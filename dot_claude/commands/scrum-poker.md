---
description: Estimate code complexity and effort using Scrum poker scale (0, 1, 2, 3, 5, 8, 13, 20, 40, 100)
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
---

# Scrum Poker Estimation Command

Analyzes code complexity and provides effort estimates using standard Scrum poker scale: **0, 1, 2, 3, 5, 8, 13, 20, 40, 100, ?**.

## Usage

```
/scrum-poker [file-path-or-feature-description]
# Estimates effort for specific file or feature

/scrum-poker
# Estimates effort for current context or recent changes
```

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
- **Ambiguous requirements** - Add 1-2 points for unclear specs or missing details

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

