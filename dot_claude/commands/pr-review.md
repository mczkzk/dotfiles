---
description: Review code changes between branches and provide implementation summary and code review
allowed-tools: 
  - Bash(git:*)
  - Read
  - Grep
---

Perform a comprehensive code review comparing the current working branch with a target branch (default: main).

## Usage

```
/pr-review [target-branch]
```

**Examples:**
- `/pr-review` - Compare with main branch
- `/pr-review develop` - Compare with develop branch
- `/pr-review feature/auth` - Compare with feature/auth branch

## Review Process

1. **Identify Changes**
   - Run `git diff [target-branch]...HEAD --name-only` to list changed files
   - Run `git diff [target-branch]...HEAD --stat` to show change statistics

2. **Analyze Implementation**
   - Review each changed file for:
     - Purpose and functionality
     - Code quality and patterns
     - Potential issues or improvements
     - Architecture impact

3. **Generate Review**
   - **Implementation Summary**: What was implemented and why
   - **Code Quality**: Style, patterns, and best practices
   - **Potential Issues**: Bugs, performance, security concerns
   - **Suggestions**: Improvements and optimizations
   - **Architecture Impact**: How changes affect overall system

## Review Criteria

### ✅ **Code Quality**
- Consistent code style and formatting
- Proper error handling
- Clear variable and function naming
- Appropriate comments and documentation

### 🔍 **Logic Review**
- Correct implementation logic
- Edge case handling
- Performance considerations

### 🔒 **Security & Authorization**
- Authorization parameters are passed through entire call chain to data access layer
- Data access operations verify ALL authorization constraints when filtering/querying
- No authorization parameter is received but unused in actual data filtering
- Cross-resource access is prevented (accessing resource B through resource A without ownership verification)
- Relationship constraints are enforced at data access time, not only at schema level
- Authorization checks at entry points alone are insufficient; data layer must independently verify access rights

### 🏗️ **Architecture**
- Follows existing patterns
- Proper separation of concerns
- Maintainable and extensible design
- Integration with existing systems

### 🧪 **Testing**
- Test coverage for new functionality
- Test quality and effectiveness
- Integration test considerations

## Output Format

The review includes:

1. **📊 Change Summary**
   - Files modified, added, deleted
   - Lines of code changes
   - Scope of modifications

2. **🎯 Implementation Overview**
   - Main features/changes implemented
   - Key architectural decisions
   - Integration points

3. **✨ Strengths**
   - Well-implemented aspects
   - Good practices followed
   - Quality improvements

4. **⚠️ Areas for Improvement**
   - Potential issues or bugs
   - Code quality concerns
   - Performance optimizations
   - Security considerations

5. **🚀 Recommendations**
   - Specific improvement suggestions
   - Best practice recommendations
   - Future enhancement ideas

## Notes

- **Read-only operation**: No code modifications are made
- **Comprehensive analysis**: Reviews both implementation and design
- **Context-aware**: Considers existing codebase patterns
- **Actionable feedback**: Provides specific, implementable suggestions

This command helps ensure code quality and consistency before merging changes, providing valuable feedback for continuous improvement.