---
name: plan-build
description: Create plan document for structured development
argument-hint: "[task ID or feature-name]"
disable-model-invocation: true
context: fork
allowed-tools:
  - Task
  - Read
  - Glob
  - Grep
  - Write
  - LS
---

# Plan Build Command

Creates detailed plan documents from completed plan-search investigations.

## Command Execution Steps

1. **Find Plan Search**:
   - If feature-name provided: Look for `.claude/plans/[feature-name]/search.md` file
   - If no feature-name: Search `.claude/plans/` directory for `*/search.md` files (excluding `archive/` subdirectory) and identify from context

2. **STRICT Completion Verification**:
   - Search file for `- [ ]` patterns using grep or manual scan
   - If ANY unchecked items found → STOP, return error message
   - Verify status shows "Investigation completed"
   - Only proceed if 100% verified complete
   - Run verification command: `grep '\- \[ \]' ".claude/plans/[feature-name]/search.md"` to confirm zero results

3. **Guidelines & Standards Review**:
   - Re-read CLAUDE.md and ~/.claude/CLAUDE.md for development standards and behavioral guidelines
   - Re-read .claude/skills/ and ~/.claude/skills/ for specialized workflows and patterns
   - Record applicable rules and project skills in the "Applicable Rules & Skills" section of the plan

4. **Create Plan Document**:
   - Read template from `references/plan-template.md` (relative to this skill directory: `${CLAUDE_SKILL_DIR}/references/plan-template.md`)
   - Generate `.claude/plans/[feature-name]/plan.md` using the template ONLY after verification and guidelines review complete
   - Structure implementation in Test → Code → Refactor cycles (t-wada TDD practices)
   - Use plan-search investigation findings to fill plan sections

5. **MANDATORY Section Completeness Verification**:
   - Count sections in generated plan document
   - MUST contain exactly 9 sections: Applicable Rules & Skills, Requirements Summary, Architecture Impact, File Changes, Testing Strategy, Implementation Plan, Risk Assessment, Commands Reference, Implementation Notes
   - Run verification command: `grep -c "^## " ".claude/plans/[feature-name]/plan.md"`
   - If count ≠ 8 or any section missing → STOP, return error, regenerate missing sections

## Key Principles

- **Plan Search Required**: Must have completed `[feature-name]/search.md` before planning
- **Verification-Based**: Never trust status alone - verify actual checkbox states
- **Investigation-Driven**: Uses investigation findings to create plan document
- **Template-Consistent**: Ensures consistency across all plan documents
- **Section-Complete**: Generated plan MUST contain exactly 9 template sections
- **TDD-First**: Follow t-wada practices with Red-Green-Refactor cycles
- **Implementation-Ready**: Creates actionable tasks for development
