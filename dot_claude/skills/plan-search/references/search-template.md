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
