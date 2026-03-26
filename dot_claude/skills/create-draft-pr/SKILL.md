---
name: create-draft-pr
description: Create a draft GitHub PR with auto-filled template from repo's pull_request_template.md
argument-hint: "[base branch (default: auto-detect default branch)]"
disable-model-invocation: true
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Grep
  - Glob
  - AskUserQuestion
---

Create a draft GitHub PR for the current branch, auto-filling the repo's PR template.

## Process

1. **Pre-flight Checks**
   - Verify current branch is not the default branch: `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`
   - If on default branch, abort with warning
   - Check for uncommitted changes: `git status --porcelain`
   - If uncommitted changes exist, warn and ask whether to proceed
   - Check if branch is pushed: `git rev-parse --abbrev-ref @{upstream}` — if not pushed, ask user to push first and abort

2. **Determine Base Branch**
   - If `$ARGUMENTS` provided, use as base branch
   - Otherwise: auto-detect default branch from step 1

3. **Gather Context**
   - `git log --oneline $(git merge-base HEAD origin/<base>)..HEAD` for commit history
   - `git diff origin/<base>...HEAD` for full diff
   - If `.claude/plans/*/plan.md` exists matching current branch or ticket ID, read it as supplemental context

4. **Find PR Template**
   - Search tracked files: `git ls-files | grep -i pull_request_template`
   - If multiple results found (e.g., `PULL_REQUEST_TEMPLATE/` directory with multiple files), list them and ask user which to use
   - If single file found, read it
   - If none found, use minimal structure: Summary only

5. **Fill Template**
   - Analyze diff and commit history
   - Cross-reference with plan document if available
   - If template found: fill each section present in the template based on actual changes
   - If no template: write a Summary of what changed and why
   - If the branch name contains a recognizable issue/ticket ID, include it (e.g., `Fixes #123`, `Fixes FOO-123`). If none found, skip
   - **PR title**: Search `.github/` for title validation rules (e.g., `pr-title-checker-config.json`, workflows with title checks, commitlint/semantic-release configs). If found, generate a title matching the required pattern. If none found, generate a concise title (under 70 chars)

6. **Fetch Available Labels**
   - `gh label list --limit 200`
   - Recommend 1-3 high-signal labels with short reasons

7. **Confirm and Create**
   - Display: base branch, title, body, label recommendations
   - Ask: "Create draft PR with these details?"
   - If approved:
     1. Write body to temp file to avoid shell escaping issues
     2. `gh pr create --draft --base <base> --title "<title>" --body-file <temp file>`
     3. Add labels: `gh pr edit <number> --add-label <labels>`
     4. Clean up temp file
     5. Display PR URL
   - If not approved, provide copy-paste output only

## Mandatory Rules

- **Explicit user confirmation is required before creating the PR**
- Never run `gh pr create` without approval
- Never force-push or modify commit history
- Never push branches automatically; ask the user to push if needed
- Never create new labels; only use existing repository labels

## Notes

- English title and summary
- Label names are case-sensitive; use exact repository label names
- **Prioritize over enumerate**: Only include high-impact changes. Skip trivial details
- Leverage plan context when available
- If PR already exists for this branch, notify the user and abort
