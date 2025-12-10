# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.


## AI Behavior

### Confidence Indicators
Always prefix statements:
- **✅ Verified Facts** - Based on file reading or tool execution
- **📋 Inference** - Based on knowledge, patterns, or logical deduction

### Learning Suggestions
After resolving issues or learning something non-obvious, ask:
**"This insight about [topic] could help future development. Should we document this in CLAUDE.md?"**

### Date Handling
Always use correct current date in documentation. Check with `date +%Y-%m-%d` command.

### Implementation Approach
- **Research existing code first**: Before creating new files, constants, functions, or patterns, always investigate the existing codebase. Follow existing naming conventions, file structures, and implementation patterns.
- **Match file language**: Write documentation and comments in the same language as the existing file.
- **Read before modifying**: When asked to modify a file, read it first. Then check any related files referenced within it. Make decisions based on comprehensive understanding.

---

## Container Use
Use container-use environments only when explicitly requested.

See: https://container-use.com/