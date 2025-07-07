---
description: Create investigation checklist and gather requirements
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - LS
  - Task
---

# Plan Search Command

Creates investigation checklist and gathers requirements before plan document creation.

## Usage

```
/plan-search [feature-name]
# Creates investigation checklist and starts requirements gathering
```

## Command Flow

### 1. Create Investigation File
- Generate `plans/[feature-name]-search.md`
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

## Investigation Checklist Template

```markdown
# Plan Search Investigation - [Feature Name]

**STRICT VERIFICATION PROTOCOL**:

Before marking ANY item complete:
✓ Evidence documented in Investigation Notes with specific details
✓ Can answer "How do you know this is true?" for this item  
✓ Investigation Notes contain file paths, code examples, or test results
✓ Next person reading notes can verify your conclusion

**Rule: If Investigation Notes don't prove the check, uncheck the box**

**INCREMENTAL COMPLETION PROTOCOL**:
✓ Mark tasks complete ONE AT A TIME as you finish each investigation item
✓ Update checkboxes [ ] → [x] immediately when task is verified complete
✓ Do NOT batch multiple completions - check boxes individually upon completion
✓ Record findings in Investigation Notes before marking checkbox complete

## 📋 Requirements Gathering
- [ ] **Specifications provided**: Technical requirements documented
- [ ] **UI/UX materials**: Screenshots, mockups, design references shared
- [ ] **User stories**: Clear understanding of user needs
- [ ] **Constraints identified**: Technical, business, or timeline limitations
- [ ] **Success criteria defined**: Clear definition of completion

## 🔍 Codebase Analysis
- [ ] **Entry points & impact scope**: Classes/modules where changes start, sync/async downstream impacts mapped
- [ ] **Similar features identified**: Existing patterns and implementations found for reference
- [ ] **Reusable components**: Available components and utilities documented
- [ ] **Code conventions aligned**: Naming patterns and architecture styles understood
- [ ] **Integration points mapped**: How feature connects with existing system architecture

## 🗄️ Database Investigation
- [ ] **Current schema mapped**: Existing tables, columns, relationships, and constraints documented
- [ ] **Data patterns sampled**: Actual data examined to understand structure and volume
- [ ] **Domain rules identified**: Business constraints and validation requirements documented
- [ ] **External data verified**: Third-party API responses logged and data structures confirmed
- [ ] **Migration strategy planned**: Forward/backward compatibility, rollback approach, performance impact
- [ ] **Anti-patterns avoided**: No assumptions without verification, no copy-paste patterns without analysis

## 🔗 External Dependencies
- [ ] **APIs validated**: Third-party service responses verified with real data
- [ ] **Package compatibility**: Library versions and capabilities confirmed
- [ ] **Integration testing**: External service behavior documented
- [ ] **Error handling defined**: Failure scenarios and fallbacks identified

## 🧪 Test & Quality Strategy
- [ ] **Performance baselines**: Current latency & memory usage recorded
- [ ] **Coverage gaps identified**: Critical paths and testing requirements mapped
- [ ] **Regression protection**: Snapshot/golden tests for current behavior
- [ ] **Integration scenarios**: Happy/unhappy path test cases outlined

## ⌨️ Project Commands
- [ ] **Development workflow**: Server start/stop, watch, and development commands
- [ ] **Build & deployment**: Build, compile, deploy, and release commands
- [ ] **Code quality tools**: Lint, typecheck, format, and analysis commands
- [ ] **Database operations**: Migration, seeding, backup, and management commands
- [ ] **Package management**: Install, update, audit, and dependency commands
- [ ] **Testing execution**: Unit, integration, e2e, and performance test commands

## 🚀 Deployment Strategy
- [ ] **Zero-downtime deployment**: Compatible release sequencing and migration approach planned
- [ ] **Feature toggle strategy**: Rollout/rollback without redeploy designed
- [ ] **Rollback plan**: Recovery procedures and data safety measures defined
- [ ] **Release verification**: Smoke tests and canary monitoring approach outlined

## ⚡ Technical Validation
- [ ] **Configuration surface**: Flags, env vars, build-time options enumerated
- [ ] **Performance requirements**: Load, speed, and scalability needs defined
- [ ] **Security considerations**: Authentication, authorization, data protection
- [ ] **Monitoring & observability**: How feature will be observed, logged, and alerted in production

## 📝 Investigation Notes
Record key discoveries, decisions, and findings during investigation - BE DETAILED. Include specific technical details, version numbers, performance metrics, constraints discovered through testing or conversation. Document architectural decisions with rationale and alternatives considered. List any unresolved questions that need clarification. This preserves context that may be lost due to token limits.

*Record here*

---

**Status**: ⚠️ Investigation in progress
**Next Step**: Complete all checklist items, then run `/plan-build [feature-name]`
```

## Final Verification Before Status Update

**CRITICAL**: Before marking investigation as completed, perform these verification steps:

1. **Checklist Audit**: Read through ALL checklist items line by line
2. **Unchecked Items Check**: Search for `- [ ]` patterns in the file using grep or manual scan
3. **Status Logic**: Only mark completed if ZERO unchecked items exist
4. **Double Confirmation**: Re-read investigation notes to ensure completeness
5. **Verification Command**: Run `grep '\- \[ \]' "[filename]"` to confirm no unchecked items

**If ANY unchecked items remain**: Keep status as "⚠️ Investigation in progress"

## Key Principles

- **Investigation First**: No planning without thorough investigation
- **Interactive Process**: Engage with user to gather all necessary information
- **Comprehensive Coverage**: All technical aspects must be explored
- **Documentation Focus**: Record findings for future reference
- **Blocking Mechanism**: `/plan` command checks for completed pre-plan
- **Strict Verification**: Never mark complete without 100% verification

## Integration with Planning

- `/plan-build [feature-name]` requires completed `[feature-name]-search.md`
- All checklist items must be marked `[x]` 
- Investigation findings inform detailed planning
- Plan-search serves as foundation for plan document