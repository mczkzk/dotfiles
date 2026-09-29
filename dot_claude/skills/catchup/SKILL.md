---
name: catchup
description: Catch up on where the current branch's task stands. Identifies the task from the branch name, reads the notes under .claude/tasks/<TASK>/ (plan, review, spike, JIRA), checks the actual commits and working tree against the plan, and checks the PR (CI, review state, unresolved threads), then reports what is done, what is left, and the next step. Use whenever the user wants to resume or re-orient on in-progress work, even without saying "catchup". For example "どこまでやったっけ", "続きから", "状況把握して", "このブランチ何してた？", "catch me up", "where was I", or at the start of a fresh session or after a context reset on a task branch.
argument-hint: "[task ID (optional)]"
---

# Catchup

The goal is to rebuild working context for an in-progress task as fast as possible so the user (and you) can resume. The notes in `.claude/tasks/` are claims written at some point in the past. The branch and the PR are the current truth. The most useful thing this skill produces is the gap between the two.

This skill is read-only apart from fetching missing JIRA info. Do not update plan.md here (that is `/plan-sync`'s job). If the plan is stale, say so and suggest `/plan-sync`.

## Step 1: Identify the task

If `$ARGUMENTS` is given, use it as the task ID and skip the branch lookup.

Otherwise, get the branch with `git branch --show-current` and list `ls .claude/tasks/`.

1. Strip known prefixes (`feature/`, `feat/`, `fix/`, `task/`, `spike/`) from the branch name.
2. Find the task directory whose name is a prefix of the branch name, **case-insensitively**, and ends at a `-` or at the end of the branch name (branch `abc-123-fix-login` matches directory `ABC-123`, but branch `ABC-1234-foo` must not match `ABC-123`). When several match, take the longest, because a directory like `ABC-000-add-foo` can sit next to other `ABC-000-...` directories.
3. If no directory matches but the branch contains a ticket key (`[A-Za-z]+-[0-9]+`), use the uppercased key as the task ID. The directory may simply not exist yet.

Ask the user (AskUserQuestion) when the task cannot be determined, for example on the repository's default branch (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`) or another long-lived branch such as `main`, `dev`, `develop`, `staging`, or on a branch with no ticket key and no matching directory. Offer the 3 most recently modified task directories as options (`ls -t .claude/tasks/ | grep -v archive | head -3`). Guessing wrong here wastes the whole run, so asking is cheaper.

## Step 2: Read the task notes

In `.claude/tasks/<TASK>/`, read whichever of these exist. Skip images and `screenshots/` (just note that screenshots exist).

| File | What it tells you |
|------|-------------------|
| `jira/jira.md` | Goal and acceptance criteria. Read this first |
| `plan.md` | Decisions, phases, task checklist, progress |
| `spike-*.md`, `split.md` | Findings from exploratory work |
| `jira-question-draft.md` | Open questions to PM (may still be unanswered) |
| `review.md` | Review findings on this PR |
| `review-response.md` | How those findings were answered |
| other `*.md` | Skim headings and read what looks relevant |

**If `jira/jira.md` is missing** and the task ID is a ticket key (not a placeholder number like `ABC-000-...`, and not a plain slug), run `/jira-fetch <TASK>` via the Skill tool, then read the result. If the fetch fails, continue without it and mention that.

If the directory does not exist at all, say so and continue with git and the PR only.

## Step 3: Check the branch

Determine the base branch: the PR's `baseRefName` if a PR exists (Step 4), otherwise `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`. Then run these in parallel:

```bash
git status --short
git log --oneline <base>..HEAD
git diff --stat <base>...HEAD
git log -1 --format='%cr' HEAD
git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null
```

Compare against plan.md:
- Which planned items have matching commits or changes, and which don't
- Changes that are not in the plan (scope drift, or plan is stale)
- Uncommitted changes. Look at `git diff` of them when they are small, because they are usually exactly where the user stopped
- Unpushed commits

Open the actual code only where the plan and the diff disagree, or where you need it to explain the next step. Reading the whole diff is not the point.

## Step 4: Check the PR

```bash
gh pr view --json number,url,title,state,isDraft,baseRefName,reviewDecision,mergeable,statusCheckRollup,updatedAt
```

If there is no PR, note it and move on.

If there is one, get unresolved review threads (GraphQL is the only way to get resolution state):

```bash
gh api graphql -f query='query($owner:String!,$repo:String!,$n:Int!){repository(owner:$owner,name:$repo){pullRequest(number:$n){reviewThreads(first:100){nodes{isResolved isOutdated path line comments(first:5){nodes{author{login} body createdAt}}}}}}}' -F owner='{owner}' -F repo='{repo}' -F n=<number>
```

Also look at top-level comments with `gh pr view <number> --comments` if review threads alone do not explain the review state. For failed CI checks, name the failing job. Only dig into logs if the user asks.

Cross-check with `review.md` / `review-response.md`: a finding marked as handled locally but still unresolved on GitHub is worth pointing out.

## Step 5: Report

Keep it short enough to read in under a minute. Use this structure, and drop any section that has nothing in it:

```
## <TASK>: <one-line goal>
Branch `<branch>` → `<base>` / PR #<n> (<state>, CI <pass|fail|pending>, review <decision>) / last commit <relative time>

### Done
- ...

### Left
- ...

### Open items
- Unresolved review threads (file:line and gist)
- Unanswered questions to PM
- Uncommitted or unpushed changes

### Plan vs reality
- Where plan.md and the branch disagree (omit if they agree)

### Next step
One concrete action, with the file or command to start from.
```

"Next step" is the most important line. Base it on evidence (the uncommitted diff, the first unchecked plan item, the oldest unresolved thread, a failing check), and if you are inferring, say what you inferred it from.
