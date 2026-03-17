# [Feature Name] - Development Plan

**STRICT IMPLEMENTATION PROTOCOL**:

Before marking ANY implementation task complete:
- Evidence documented in Implementation Notes with specific details (code snippets, test results, file paths)
- Can answer "How do you know this works?" for this task
- Implementation Notes contain proof of functionality (test output, working code)
- Next person reading notes can verify your implementation

**Rule: If Implementation Notes don't prove the task completion, uncheck the box**

**INCREMENTAL COMPLETION PROTOCOL**:
- Mark tasks complete ONE AT A TIME as you finish each implementation step
- Update checkboxes [ ] → [x] immediately when task is verified complete
- Do NOT batch multiple completions - check boxes individually upon completion
- Record implementation evidence in Implementation Notes before marking checkbox complete
- Plans can evolve during implementation - add new tasks when requirements change

**NO QUICK FIXES PROTOCOL**:
- NO implementation until complete understanding is achieved
- NO quick fixes or workarounds - fundamental understanding takes priority
- NO lint suppressions, ignore comments, or error suppression
- NO temporary solutions - pursue root causes only
- Use web search or ask user when information is missing
- Take unlimited time for proper analysis and implementation
- Research findings and insights are valuable even without immediate implementation

---

## Requirements Summary
- [ ] Feature requirement 1
- [ ] Feature requirement 2
- [ ] Feature requirement 3

## Architecture Impact
- **Affected Components**: List of components that will be modified
- **Integration Points**: How this feature connects with existing systems
- **Dependencies**: External libraries, APIs, or services required

## File Changes

### Modified Files
- `src/component1.js` - Add new functionality
- `src/component2.js` - Update existing method
- `tests/component1.test.js` - Add test cases

### New Files
- `src/features/new-feature.js` - Core implementation
- `src/features/new-feature.test.js` - Test suite

## Testing Strategy

### TDD Cycle Testing (Development Phase) - t-wada practices
1. **Red Phase**: Write failing test first
   - Define expected behavior through test specification
   - Ensure test fails (Red) before writing implementation

2. **Green Phase**: Write minimal implementation
   - Implement only what's needed to make test pass
   - Focus on functionality, not optimization

3. **Refactor Phase**: Improve code quality
   - Clean up implementation while keeping tests green
   - Apply SOLID principles and design patterns

**Test Examples**:
- **Basic functionality test**
  - Input: [specific input]
  - Expected: [expected output]
- **Edge case test**
  - Input: [edge case input]
  - Expected: [expected behavior]

## Implementation Plan

### Phase A: [Descriptive Phase Name]
- [ ] **A.1** [Task description]
  - [ ] Specific subtask 1
  - [ ] Specific subtask 2
  - [ ] TDD cycle validation (focused tests)
- [ ] **A.2** [Another task]
  - [ ] Implementation details
  - [ ] Error handling
  - [ ] Unit tests
- [ ] **A.CHECKPOINT** Phase A Integration Testing
  - [ ] Run related module/component test suite
  - [ ] Verify no regression in connected components
  - [ ] Document any test failures and fixes

### Phase B: [Another Phase Name]
- [ ] **B.1** [Task description]
  - [ ] Specific implementation
  - [ ] Integration steps
  - [ ] TDD validation
- [ ] **B.CHECKPOINT** Full Test Suite Validation
  - [ ] Execute complete test suite
  - [ ] Address any failing tests from schema/integration changes
  - [ ] Update Implementation Notes with test results

## Risk Assessment
- **Technical Risks**: Potential technical challenges
- **Dependencies**: External dependency risks
- **Mitigation**: Strategies to address identified risks

## Commands Reference
Record useful commands for this implementation (server startup, linting, testing, database operations, etc.)

*command here*

## Implementation Notes
Record ALL discoveries that impact development - BE COMPREHENSIVE! Include technical details, code snippets, command outputs, error solutions, performance insights, useful patterns, shortcuts, unsolved issues, failed approaches, and any knowledge that helps future implementation. Document complete context to preserve knowledge across sessions.

*Record here*

**Remember**: Comprehensive plan documentation during implementation saves multiples of that time in future development and maintenance.

---

**Status**: Ready for implementation
**Next Step**: Begin implementation using plan document
