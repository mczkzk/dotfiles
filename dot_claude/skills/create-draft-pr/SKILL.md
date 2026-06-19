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
   - If `.claude/tasks/*/plan.md` exists matching current branch or ticket ID, read it as supplemental context
   - **Past PRs as style reference**: `gh pr list --author "@me" --state merged --base <base> --limit 5 --json title,body,labels` to learn the user's typical title format, summary granularity, section usage, and frequently-applied labels. If none returned (e.g., first PR in this repo), skip silently

4. **Find PR Template**
   - Search tracked files: `git ls-files | grep -i pull_request_template`
   - If multiple results found (e.g., `PULL_REQUEST_TEMPLATE/` directory with multiple files), list them and ask user which to use
   - If single file found, read it
   - If none found, use minimal structure: Summary only

5. **Fill Template**
   - Analyze diff and commit history
   - Cross-reference with plan document if available
   - If template found: **preserve the template structure verbatim**, only filling in the variable parts
     - **Preserve as-is**: section headings, fixed instructional text, checklists (`- [ ]`), HTML comments (`<!-- ... -->`), tables, links, and any boilerplate
     - **Only modify**: empty placeholders, areas explicitly marked for input (e.g., `<!-- describe here -->`), or sections that clearly expect free-form content
     - **Do NOT omit a section just because there is nothing to add**. If a section is not applicable, write `N/A` (or follow the template's own convention if it specifies one) rather than deleting it
     - **Do NOT rewrite or paraphrase fixed text**. If unsure whether a line is fixed boilerplate or a placeholder, keep it
     - Checklists: leave items unchecked unless the diff clearly satisfies them
   - **Testing/verification sections**: Check `.github/workflows/` for what runs automatically on PRs (tests, lint, type checks). Do NOT list those runs in the testing plan; CI already reports them on the PR. Write only verification CI does not cover: manual testing steps, visual/UI checks, local-only scripts, environment-specific checks. If nothing beyond CI was done, state that briefly (e.g., `Covered by CI`)
   - If no template: write a Summary of what changed and why
   - If the branch name contains a recognizable issue/ticket ID, include it (e.g., `Fixes #123`, `Fixes FOO-123`). If none found, skip
   - **PR title**: Search `.github/` for title validation rules (e.g., `pr-title-checker-config.json`, workflows with title checks, commitlint/semantic-release configs). If found, generate a title matching the required pattern. If none found, generate a concise title (under 70 chars). When past PRs were fetched in step 3, mirror their title format (prefix conventions, casing, length) as a secondary guide
   - **Style alignment with past PRs**: If past PRs were fetched, match their tone and granularity (bullet vs. prose, depth of detail, presence/absence of optional sections). Validation rules and template structure still take precedence over past-PR style

6. **Fetch Available Labels**
   - `gh label list --limit 200`
   - Recommend 1-3 high-signal labels with short reasons. If past PRs were fetched in step 3, prefer labels the user has actually applied before when they fit the current diff

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
- **Never delete or paraphrase fixed text in the PR template** (headings, instructions, checklists, HTML comments, boilerplate). Only fill variable parts. "No change needed" does NOT mean "can be omitted"
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
