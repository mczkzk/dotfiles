---
name: pr-template
description: Generate PR title and description from GitHub PR diff
argument-hint: "[number: GitHub PR number like 123] (empty = auto-detect from current branch)"
disable-model-invocation: true
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Grep
  - Glob
  - AskUserQuestion
---

Generate PR title, description, and recommended labels from PR diff.

## Process

0. **Resolve PR Number**
   - If `$ARGUMENTS` is empty or not a number, auto-detect: `gh pr view --json number -q .number`
   - If auto-detect fails (no PR for current branch), warn and abort

1. **Get PR Information**
   - `gh pr view <PR number> --json number,title,body,labels,baseRefName,headRefName`
   - `gh pr diff <PR number>`

2. **Check for Plan Document**
   - Search: current session plan → `.claude/plans/*/plan.md`
   - Read for requirements, architecture, tests

3. **Analyze Changes**
   - Changed files, features, bug fixes, config changes
   - Cross-reference with plan if available

4. **Fetch Available Labels**
   - `gh label list --limit 200`
   - If needed for richer metadata: `gh api repos/{owner}/{repo}/labels --paginate`
   - Use repository labels only (do not invent labels)

5. **Generate Output**
   - Follow existing structure or use minimal:
     - **Summary**: What changed and why (reference plan)
     - **Test Plan**: Steps reviewers can follow to verify changes (reference plan)
   - **Title**: Concise summary
   - **Label recommendations**: 1-3 high-signal labels with short reasons
   - **Description policy**:
     - Keep current PR body as baseline
     - Do not delete existing text unless user explicitly asks
     - Prefer additive edits (append/section update) over full rewrite

6. **Confirm Update**
   - Display generated title/body/label plan and summarize body diff (add/change/remove)
   - Ask: "Update PR title/body and labels with `gh pr edit`?"
   - If approved:
     1. **Re-fetch the latest PR body** (`gh pr view <PR number> --json body -q .body`) right before editing. Compare it with the body you based your draft on. If the remote body has changed (e.g., someone added images, videos, or comments), merge those additions into your draft — never silently discard them.
     2. Update PR title/body: `gh pr edit <PR number> --title "<new title>" --body-file <temp file>`
     3. Sync labels to recommendation:
        - Read current labels from `gh pr view <PR number> --json labels`
        - Compute delta:
          - Add missing recommended labels with `--add-label`
          - Remove non-recommended labels with `--remove-label` (except labels user says to keep)
        - Execute label update via `gh pr edit <PR number> --add-label ... --remove-label ...`
   - **Same-conversation shortcut**: If you already updated this PR body earlier in the same conversation, you MUST re-fetch the remote body before the second update. The user or CI may have modified it between your updates.
   - If not approved, provide copy-paste output only

## Mandatory Rules

- **Explicit user confirmation is required every time before PR updates**
- Never run `gh pr edit` without approval
- Never remove existing PR description text without explicit user instruction

## Notes

- English title and summary
- Label names are case-sensitive; use exact repository label names
- **Prioritize over enumerate**: Only include high-impact changes. Skip trivial details
- Leverage plan context when available
