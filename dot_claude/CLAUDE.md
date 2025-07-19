# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.


## AI Behavior

### Command Policy
- **Keep commands simple** - single file operations, single searches, single bash commands
- **Avoid complex multi-step operations** - break into small steps
- **No Task tool with long prompts** - use simple operations

### Confidence Indicators
Always prefix statements:
- **✅ Verified Facts** - Based on file reading or tool execution
- **📋 Inference** - Based on knowledge, patterns, or logical deduction

### Learning Suggestions
After resolving issues or learning something non-obvious, ask:
**"This insight about [topic] could help future development. Should we document this in CLAUDE.md?"**

### Date Handling
Always use correct current date in documentation. Check with `date +%Y-%m-%d` command.

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
- Preserve backward compatibility in minor and patch versions
- Follow Postel’s Law and design tolerant readers for compatibility
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

---

## Container Use
ALWAYS use ONLY Environments for ANY and ALL file, code, or shell operations—NO EXCEPTIONS—even for simple or generic requests.

DO NOT install or use the git cli with the environment_run_cmd tool. All environment tools will handle git operations for you. Changing ".git" yourself will compromise the integrity of your environment.

You MUST inform the user how to view your work using `container-use log <env_id>` AND `container-use checkout <env_id>`. Failure to do this will make your work inaccessible to others.

See: https://container-use.com/