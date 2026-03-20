---
name: plan-search
description: Create investigation checklist for <feature-name> and gather requirements
argument-hint: <identifier: task ID like "PROJECT-123" or feature-name like "user-auth">
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - LS
  - Task
  - Bash
  - mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql
  - mcp__claude_ai_Atlassian__getJiraIssue
  - mcp__claude_ai_Atlassian__search
  - mcp__claude_ai_Slack__slack_search_public_and_private
  - mcp__claude_ai_Slack__slack_read_thread
  - Agent
---

# Plan Search Command

Creates investigation checklist and gathers requirements before plan document creation.

## Command Flow

### 0. JIRA Information Fetch (Automatic for Task IDs)
**Identifier Pattern Detection**:
- Task ID pattern: Matches `^[A-Z]+-\d+$` (e.g., "PROJECT-123")
- Feature name pattern: Everything else (e.g., "user-auth", "payment-flow")

**If identifier is a task ID**, execute JIRA fetch:
1. **Check for existing JIRA data**:
   - Look for `.claude/plans/[identifier]/jira.md`
   - If exists → Skip to step 4
2. **Fetch JIRA data** (try in order until one succeeds):
   - **Primary**: If `jira-fetch` skill is available → invoke `/jira-fetch [identifier]`
   - **Fallback (MCP)**: If skill not available or fetch fails → use MCP tools:
     a. `mcp__claude_ai_Atlassian__getJiraIssue` to fetch the ticket directly
     b. If direct fetch fails → `mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql` with `key = [identifier]`
   - If all methods fail → Log warning and proceed to step 1 (non-blocking)
3. **Read JIRA data** (if available):
   - Read `.claude/plans/[identifier]/jira.md`
   - Use JIRA ticket information in Requirements Gathering
4. **Search related discussions in Slack**:
   - Use `mcp__claude_ai_Slack__slack_search_public_and_private` to search for the identifier (e.g., "PROJECT-123")
   - If relevant threads found → use `mcp__claude_ai_Slack__slack_read_thread` to read full context
   - Record key discussions, decisions, and context in Investigation Notes
   - This step is non-blocking: if Slack MCP is unavailable or returns no results, proceed

**If identifier is a feature name** (no hyphen):
- Skip JIRA fetch
- Still search Slack using `mcp__claude_ai_Slack__slack_search_public_and_private` for the feature name
- Record any relevant discussions found in Investigation Notes

### 1. Create Investigation File
- Generate `.claude/plans/[feature-name]/search.md`
- Include comprehensive investigation checklist
- All items must be completed before `/plan-build` command

### 2. Requirements Gathering
Prompt user to provide:
- **Specifications**: Technical requirements, user stories
- **Screenshots**: UI mockups, design references
- **Context**: Background information, constraints
- **Examples**: Similar features, reference implementations

### 3. Interactive Investigation
Guide user through checklist completion:
- Codebase analysis
- Database investigation
- External dependencies validation
- Technical requirements clarification

**Parallel investigation**: When multiple checklist sections are independent (e.g., Database + External Dependencies), use subagents to investigate in parallel

## Investigation Checklist Template

Read template from `references/search-template.md` (relative to this skill directory: `${CLAUDE_SKILL_DIR}/references/search-template.md`) and use it to generate the investigation file.

## Final Verification Before Status Update

**CRITICAL**: Before marking investigation as completed, perform these verification steps:

1. **Checklist Audit**: Read through ALL checklist items line by line
2. **Unchecked Items Check**: Search for `- [ ]` patterns in the file using grep or manual scan
3. **Status Logic**: Only mark completed if ZERO unchecked items exist
4. **Double Confirmation**: Re-read investigation notes to ensure completeness
5. **Verification Command**: Run `grep '\- \[ \]' "[filename]"` to confirm no unchecked items

**If ANY unchecked items remain**: Keep status as "Investigation in progress"

## Protocols

### Strict Verification
- Before marking ANY item complete, evidence must exist in Investigation Notes
- Evidence = specific details: file paths, code examples, test results
- Can answer "How do you know this is true?" for every checked item
- **If Investigation Notes don't prove it, don't check the box**

### Incremental Completion
- Mark tasks complete ONE AT A TIME
- Update `[ ]` → `[x]` immediately when verified
- Record findings in Investigation Notes BEFORE marking checkbox

## Key Principles

- **Investigation First**: No planning without thorough investigation
- **Interactive Process**: Engage with user to gather all necessary information
- **Comprehensive Coverage**: All technical aspects must be explored
- **Documentation Focus**: Record findings for future reference
- **Blocking Mechanism**: `/plan` command checks for completed pre-plan

## Integration with Planning

- `/plan-build [feature-name]` requires completed `[feature-name]/search.md`
- All checklist items must be marked `[x]`
- Investigation findings inform detailed planning
- Plan-search serves as foundation for plan document
