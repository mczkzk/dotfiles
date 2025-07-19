# Check Code Quality

This command executes code quality checks and tests sequentially that can be run easily even during implementation. Use this to course-correct before deviating too far.

## Check Items

1. **Lint** - Check code quality and consistency
2. **Format** - Check and fix code formatting
3. **Type Check** - Verify type consistency
4. **Server Tests** - Backend unit tests
5. **Frontend Tests** - Frontend unit tests

## Usage

```
/check
```

**Recommended for use during implementation**:
- During new feature implementation
- While refactoring
- After making significant changes
- Final check before commits

## Executed Commands

The following commands are executed sequentially:

```bash
# 1. Lint Check
<container-tool> exec <service> <package-manager> <lint-script>

# 2. Format
<container-tool> exec <service> <package-manager> <format-script>

# 3. Type Check
<container-tool> exec <service> <package-manager> <type-check-script>

# 4. Server Tests
<container-tool> exec <service> <package-manager> <server-test-script>

# 5. Frontend Tests
<container-tool> exec <service> <package-manager> <frontend-test-script>
```

## Error Handling

- If any step fails, processing stops at that point
- Results for each step are displayed, making problem identification easy
- Steps after a failed step are not executed

## Recommended Workflow

### 🔄 **During Implementation**
1. Run `/check` after implementing part of a feature
2. Fix issues immediately if found
3. Continue implementation while course-correcting
4. Maintain quality before deviating too far

### 🚀 **Final Verification**
1. Run `/check` after completing implementation
2. Verify all checks pass
3. Fix issues and re-run if problems are found
4. Commit and create PR after all checks pass

## Notes

- Ensure container environment is running
- May take time (especially during test execution)
- Avoid running other tasks in parallel

This command enables easy code quality checks even during implementation, allowing course correction before deviating too far and enabling early bug detection.
