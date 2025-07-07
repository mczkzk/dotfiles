# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI Behavior

### Command Policy

Keep commands simple to avoid permission requests.

**Good:**
- Single file operations (Read, Edit one file)
- Single pattern searches (Glob, Grep)
- Single bash commands

**Avoid:**
- Complex multi-step operations in one command
- Task tool with long prompts
- Multiple tools coordination

Break complex operations into small, simple steps.

### Confidence Indicators

Always indicate whether statements are based on evidence or inference.

**✅ Verified Facts** - Based on file reading or tool execution:
```
✅ Confirmed: DATABASE_URL is defined in src/config.ts:15
```

**📋 Inference** - Based on knowledge, patterns, or logical deduction:
```
📋 Likely: This error suggests a type mismatch based on the stack trace
```

Never state assumptions as confirmed facts. Always prefix statements with ✅ or 📋.

### Learning Suggestions

Proactively suggest documenting insights and discoveries.

After resolving issues or learning something non-obvious, ask:
**"This insight about [topic] could help future development. Should we document this in CLAUDE.md?"**

- Focus on actionable knowledge that saves time or prevents errors
- Be specific about what was learned and why it's valuable
- Document command patterns, workarounds, project-specific quirks

### Date Handling

Always use correct current date in documentation. Check with `date +%Y-%m-%d` command.

- Use YYYY-MM-DD format (ISO 8601)
- Never copy old template dates without updating
- Verify dates match actual work date before committing

### User Input Shortcuts

**Basic Responses:**
- `y` - YES (approve/execute)
- `n` - NO (reject/stop)
- `u` - undo last AI action/change

Shortcuts are for standalone use. Use full sentences for complex instructions.

### Investigation Guidelines

When receiving investigation or question requests, focus on research not implementation.

**Response approach:**
- Gather information systematically 
- Temporary code changes for investigation are allowed
- Clean up temporary changes afterwards
- Document findings clearly
- Do NOT implement or edit permanently without explicit request

### External Dependency Problem-Solving Guidelines

When external dependencies have limitations, always design the ideal solution first.

**Approach:**
1. Document root cause and impact
2. Define ideal API/solution with benefits
3. Present proposal to user
4. Only implement work-arounds if ideal is rejected
5. Tag work-arounds as technical debt

**Anti-patterns:**
- Jumping to regex parsing or type assertions
- Suppressing type/compile errors
- Creating hacks without user awareness

---

## Development Guidelines

### Development Methodologies

- Use Test-Driven Development (t-wada practices)
- Use Refactoring (Martin Fowler techniques)

### API Design Guidelines

- Use Richardson Maturity Model Level 2 minimum, Level 3 selectively
- Use REST principles for HTTP APIs
- Follow RFC 9457 for error responses
- Implement OAuth 2.0 or JWT for authentication
- Document with OpenAPI 3.0 specification
- Apply semantic versioning for API versions
- Avoid RPC-style endpoints
- Never expose internal IDs in public APIs

### Database Design Guidelines

- Follow normalization principles (1NF, 2NF, 3NF)
- Use foreign key constraints for referential integrity
- Apply proper indexing strategies
- Implement database migrations (forward and rollback)
- Use connection pooling
- Follow ACID properties for transactions
- Avoid N+1 query problems
- Never store sensitive data in plain text
- Never run untested migrations in production