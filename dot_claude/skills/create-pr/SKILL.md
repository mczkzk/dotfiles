---
name: create-pr
description: Open a GitHub PR with an auto-filled template from the repo's pull_request_template.md, or revise the body of an existing PR. Generic; a repo with its own PR conventions may ship a more specific skill that supersedes this one
argument-hint: "[base branch (default: auto-detect default branch)]"
disable-model-invocation: true
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Write
  - Grep
  - Glob
  - AskUserQuestion
  - ToolSearch
---

Author a PR body for the current branch, filling the repo's template.

**Two modes, same rules.** If the branch has no PR, open one. If it already has one, revise its body in place with `gh pr edit` — every rule below applies equally to a revision, which is when most of them get broken.

## Process

1. **Pre-flight Checks**
   - Verify current branch is not the default branch: `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`. If on default branch, abort with warning
   - Check for uncommitted changes: `git status --porcelain`. If any exist, warn and ask whether to proceed
   - Check the branch is pushed: `git rev-parse --abbrev-ref @{upstream}`. If not, ask the user to push first and abort
   - Check for an existing PR: `gh pr view --json number,url`. If one exists, say so and switch to revise mode

2. **Determine Base Branch**
   - Use `$ARGUMENTS` if provided, otherwise the default branch from step 1

3. **Gather Context**
   - `git log --oneline $(git merge-base HEAD origin/<base>)..HEAD` for commit history
   - `git diff origin/<base>...HEAD` for the full diff
   - **Revise mode**: `gh pr view --json body` first. The live body may contain edits the user made by hand (images they uploaded, wording they fixed). Build on it; never overwrite it with a locally cached copy
   - If `.claude/tasks/*/plan.md` matches the branch or ticket ID, read it as supplemental context
   - If the branch names a ticket, read the ticket. Its acceptance criteria and worked examples drive the testing plan
   - **Past PRs as style reference**: `gh pr list --author "@me" --state merged --base <base> --limit 5 --json title,body,labels` to learn title format, summary granularity, section usage, and frequently-applied labels. Skip silently if none. If the project's rules or CLAUDE.md designate a reference PR, fetch that one instead — it outranks this scan

4. **Find PR Template**
   - `git ls-files | grep -i pull_request_template`
   - Multiple hits (e.g. a `PULL_REQUEST_TEMPLATE/` directory): list them and ask which to use
   - No hits: use a minimal structure (Summary only)

5. **Fill Template**
   - **Preserve the template structure verbatim**, filling only the variable parts
     - Keep as-is: headings, fixed instructional text, checklists (`- [ ]`), HTML comments, tables, links, boilerplate
     - Change only: empty placeholders, spots explicitly marked for input, sections that clearly expect free-form content
     - Leave checkboxes unchecked unless the diff clearly satisfies them
   - **Describe behavior, not files.** Explain what changes for the user and why. No file-by-file breakdown — the diff already lists files. Naming the 1-2 riskiest files for reviewers is fine
   - **Testing sections**: build them per the testing-plan rule below
   - If the branch name carries an issue/ticket ID, include it (`Fixes #123`, `Fixes FOO-123`)
   - **Ticket links**: only some prefixes auto-link. Check the rendered body and write an explicit markdown link for any that stays plain text
   - **PR title**: search `.github/` for title validation (`pr-title-checker-config.json`, workflows with title checks, commitlint/semantic-release configs) and match the required pattern. Otherwise keep it under 70 chars, mirroring past PRs

6. **Fetch Available Labels**
   - `gh label list --limit 200`
   - Recommend 1-3 high-signal labels with short reasons, preferring ones the user has applied before

7. **Confirm and Publish**
   - Display: mode (create/revise), base branch, title, body, label recommendations
   - Ask for approval
   - If approved, write the body to a temp file (avoids shell escaping issues), then:
     - create: `gh pr create --base <base> --title "<title>" --body-file <temp>`
     - revise: `gh pr edit <number> --body-file <temp>`
   - Add labels with `gh pr edit <number> --add-label`, clean up the temp file, display the PR URL
   - If not approved, output the body for copy-paste and stop

## Mandatory Rules

- **Get explicit approval before creating or updating a PR.** Never run `gh pr create` or `gh pr edit` unattended
- **Build the testing plan as one numbered list, each step an action → the observed result.** No parallel "what I verified" section: it restates every claim twice, once past tense and once imperative. If a bullet in one section maps 1:1 onto a step in another, they are the same list. Three further constraints:
  - **The result must be checkable by the reviewer, not just by you.** "16,874 chars" is your measurement and means nothing on their data; "`diff` prints nothing" is a criterion they can apply. Quote your own counts only as corroboration, never as the pass condition
  - **State preconditions as requirements, then give an example.** "Needs a record split so that some rows carry an optional field and others do not. For example: …" reads as a condition the reviewer can satisfy their own way. "Setup: one split record, three children" reads as an order to reproduce your exact data
  - **Exclude everything CI runs.** Check `.github/workflows/` first; unit tests, lint, type checks and builds are never reviewer verification. List only what CI cannot do: manual UI steps, visual checks, environment-specific work. If nothing remains, write `Covered by CI`
- **Execute every procedure you write.** Menu paths, commands and file pairings go in only after you have run them and seen the result. A path recalled from memory is a guess, and a wrong one costs the reviewer more time than the whole section saves
- **Cover every branch the ticket's own examples imply.** A ticket's example table is chosen to succeed; enumerate the branches it demonstrates (with layers / without, duplicate names / unique, excluded source types) and exercise each. Verifying only the branch your test data happens to hit leaves the ticket's headline example untested
- **One run, one environment.** Every observation and number must come from a single execution. Mixing two runs or two projects forces the reviewer to reconcile identifiers that do not match.
- **Never hard-wrap a paragraph or a list item.** GitHub renders a single newline in a PR body as a `<br>`, so a line broken at column 90 for the editor's sake ships as a visible break mid-sentence. One paragraph, one line; one list item, one line, however long. Newlines belong only between blocks — paragraphs, list items, an `→` result line under its numbered step, and inside fenced code
- **Verify the published body, not what you wrote.** After `gh pr create` or `gh pr edit`, reload and check that the numbered list still has all its items and no `**` shows as literal text.
- **Never delete or paraphrase fixed text in the template** (headings, instructions, checklists, HTML comments, boilerplate). "No change needed" does not mean "can be omitted"
- **Leave no unanswered placeholder.** A `Yes/No`, `[describe]` or `<!-- ... -->` prompt that ships verbatim reads as "the author forgot". Answer it, or write `N/A` when a parent answer makes it moot (parent `No` → child `N/A`). Grep the finished body for `Yes/No` before showing it
- **Do not cite paths reviewers cannot open.** `.claude/` is commonly excluded via `.gitignore` or `.git/info/exclude`, so such a path means nothing on GitHub. Run `git check-ignore -v <path>` before referencing any path; if ignored, inline the finding instead
- **Do not name environment-specific identifiers.** Site, project and tenant names, run IDs, and record IDs from your own test data are unusable to a reviewer without access, and they put customer names into a permanent record. Describe the setup by its properties instead ("a project with one completed import and three child records"), so the reviewer can pick their own equivalent. Keep concrete values in the local verification notes
- **Justify a decision only with a source that says it.** Before citing a ticket as the reason for a choice, read it and confirm it covers your case — guidance about reading an API does not authorize how you write to it. If no source supports the decision, say it is your judgment or drop it
- Never force-push or modify commit history; never push branches automatically; never create new labels

## Notes

- English title and summary
- Label names are case-sensitive
- **Prioritize over enumerate.** Only high-impact changes; skip trivial detail
