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
- Task ID pattern: Contains hyphen followed by numbers (e.g., "PROJECT-123", "SIM-826")
- Feature name pattern: Hyphen followed by letters (e.g., "user-auth", "payment-flow")

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

```markdown
# Plan Search Investigation - [Feature Name]

**STRICT VERIFICATION PROTOCOL**:

Before marking ANY item complete:
- Evidence documented in Investigation Notes with specific details
- Can answer "How do you know this is true?" for this item
- Investigation Notes contain file paths, code examples, or test results
- Next person reading notes can verify your conclusion

**Rule: If Investigation Notes don't prove the check, uncheck the box**

**INCREMENTAL COMPLETION PROTOCOL**:
- Mark tasks complete ONE AT A TIME as you finish each investigation item
- Update checkboxes [ ] → [x] immediately when task is verified complete
- Do NOT batch multiple completions - check boxes individually upon completion
- Record findings in Investigation Notes before marking checkbox complete

## Requirements Gathering
- [ ] **Specifications provided**: Feature requirements and user stories documented
- [ ] **Feature prioritization**: Required vs optional feature priorities defined
- [ ] **UI/UX materials**: Screenshots, mockups, design references shared
- [ ] **Success criteria defined**: Clear definition of completion and acceptance criteria
- [ ] **Stakeholder alignment**: All parties agree on requirements and expectations

## Codebase Analysis

**REUSE DISCOVERY PROTOCOL**:
For each new type, function, or component planned, `Grep`/`Glob` the codebase for existing equivalents before assuming it needs to be created. Prefer reusing or extending existing definitions over creating new ones.

- [ ] **Entry points & impact scope**: Classes/modules where changes start, sync/async downstream impacts mapped
- [ ] **Similar features identified**: Existing patterns and implementations found for reference
- [ ] **Reusable components**: Available components and utilities documented
- [ ] **Code conventions aligned**: Naming patterns and architecture styles understood
- [ ] **Integration points mapped**: How feature connects with existing system architecture
- [ ] **Backwards compatibility scope**: Compatibility boundaries and breaking change impact assessed

## Database Investigation
- [ ] **Schema structure analysis**: Feature-relevant tables, columns, data types, and primary keys documented
- [ ] **Table relationship mapping**: Foreign key relationships with cardinality (1:1, 1:N, N:N) and constraint behaviors (CASCADE/RESTRICT/SET NULL) identified
- [ ] **Junction table identification**: Many-to-many intermediate tables with composite primary keys and additional fields documented
- [ ] **Constraint analysis**: Unique constraints, check constraints, and deletion impact chains mapped per table
- [ ] **Independent table identification**: Tables with no foreign key relationships to other tables documented
- [ ] **Data patterns & migration strategy**: Sample data examined, business rules identified, migration approach planned
- [ ] **Existing data backfill requirements**: For new columns, determine values for existing rows, identify data sources for backfill, define post-migration integrity verification
- [ ] **Query compatibility analysis**: Verify queries using new columns can retrieve existing data, assess NULL value impact on query results, determine if application-side NULL handling is needed

## External Dependencies
- [ ] **APIs validated**: Third-party service responses verified with real data
- [ ] **Package compatibility**: Library versions and capabilities confirmed
- [ ] **Integration testing**: External service behavior documented
- [ ] **Error handling defined**: Failure scenarios and fallbacks identified

## Test & Quality Strategy
- [ ] **Performance baselines**: Current latency & memory usage recorded
- [ ] **Coverage gaps identified**: Critical paths and testing requirements mapped
- [ ] **Cross-platform support**: Device and browser compatibility requirements defined
- [ ] **Regression protection**: Snapshot/golden tests for current behavior
- [ ] **Integration scenarios**: Happy/unhappy path test cases outlined

## Project Commands
- [ ] **Development workflow**: Server start/stop, watch, and development commands
- [ ] **Build & deployment**: Build, compile, deploy, and release commands
- [ ] **Code quality tools**: Lint, typecheck, format, and analysis commands
- [ ] **Database operations**: Migration, seeding, backup, and management commands
- [ ] **Package management**: Install, update, audit, and dependency commands
- [ ] **Testing execution**: Unit, integration, e2e, and performance test commands

## Deployment Strategy
- [ ] **Zero-downtime deployment**: Compatible release sequencing and migration approach planned
- [ ] **Feature toggle strategy**: Rollout/rollback without redeploy designed
- [ ] **Rollback plan**: Recovery procedures and data safety measures defined
- [ ] **Release verification**: Smoke tests and canary monitoring approach outlined

## Technical Validation
- [ ] **Configuration surface**: Flags, env vars, build-time options enumerated
- [ ] **Performance requirements**: Load, speed, and scalability needs defined
- [ ] **Security considerations**: Authentication, authorization, data protection
- [ ] **Monitoring & observability**: How feature will be observed, logged, and alerted in production

## Investigation Notes
Record key discoveries, decisions, and findings during investigation - BE DETAILED. Include specific technical details, version numbers, performance metrics, constraints discovered through testing or conversation. Document architectural decisions with rationale and alternatives considered. List any unresolved questions that need clarification. This preserves context that may be lost due to token limits.

*Record here*

---

**Status**: Investigation in progress
**Next Step**: Complete all checklist items, then run `/plan-build [feature-name]`
```

## Final Verification Before Status Update

**CRITICAL**: Before marking investigation as completed, perform these verification steps:

1. **Checklist Audit**: Read through ALL checklist items line by line
2. **Unchecked Items Check**: Search for `- [ ]` patterns in the file using grep or manual scan
3. **Status Logic**: Only mark completed if ZERO unchecked items exist
4. **Double Confirmation**: Re-read investigation notes to ensure completeness
5. **Verification Command**: Run `grep '\- \[ \]' "[filename]"` to confirm no unchecked items

**If ANY unchecked items remain**: Keep status as "Investigation in progress"

## Key Principles

- **Investigation First**: No planning without thorough investigation
- **Interactive Process**: Engage with user to gather all necessary information
- **Comprehensive Coverage**: All technical aspects must be explored
- **Documentation Focus**: Record findings for future reference
- **Blocking Mechanism**: `/plan` command checks for completed pre-plan
- **Strict Verification**: Never mark complete without 100% verification

## Integration with Planning

- `/plan-build [feature-name]` requires completed `[feature-name]/search.md`
- All checklist items must be marked `[x]`
- Investigation findings inform detailed planning
- Plan-search serves as foundation for plan document
