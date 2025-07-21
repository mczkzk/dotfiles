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

---

## Container Use
ALWAYS use ONLY Environments for ANY and ALL file, code, or shell operations—NO EXCEPTIONS—even for simple or generic requests.

DO NOT install or use the git cli with the environment_run_cmd tool. All environment tools will handle git operations for you. Changing ".git" yourself will compromise the integrity of your environment.

You MUST inform the user how to view your work using `container-use log <env_id>` AND `container-use checkout <env_id>`. Failure to do this will make your work inaccessible to others.

See: https://container-use.com/