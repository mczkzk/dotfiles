---
name: create-draft-pr
description: Create a draft GitHub PR with an auto-filled template from the repo's pull_request_template.md, or revise the body of an existing PR
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
  - mcp__playwright__browser_navigate
  - mcp__playwright__browser_click
  - mcp__playwright__browser_file_upload
  - mcp__playwright__browser_evaluate
  - mcp__playwright__browser_wait_for
  - mcp__playwright__browser_resize
  - mcp__playwright__browser_take_screenshot
---

Author a PR body for the current branch, filling the repo's template.

**Two modes, same rules.** If the branch has no PR, create a draft one. If it already has one, revise its body in place with `gh pr edit` — every rule below applies equally to a revision, which is when most of them get broken.

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
   - **Verification evidence**: check `.claude/tasks/<ticket>/screenshots/` (where `/e2e-verify` saves output). If present, read its `README.md` for measured results and `ls` the `*.png` files. The findings belong in the testing plan; the images get attached in step 8. **Read every image you intend to attach**
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
     - create: `gh pr create --draft --base <base> --title "<title>" --body-file <temp>`
     - revise: `gh pr edit <number> --body-file <temp>`
   - Add labels with `gh pr edit <number> --add-label`, clean up the temp file, display the PR URL
   - If not approved, output the body for copy-paste and stop

8. **Attach Screenshots** (only if step 3 found images worth attaching)

   GitHub has **no API for uploading images** to a PR body — `--body-file` can only reference URLs that already exist, and the CLI team closed the `--image` request as "not planned" because the upload needs a browser for temporary S3 credentials. So the upload drives the same flow a human drag-and-drop uses.

   Dead ends, do not try: committing PNGs and linking `raw.githubusercontent.com`, or a Gist. Both need a token to fetch, so **the images render broken in a private repo**.

   - Load the tools: `ToolSearch("select:mcp__playwright__browser_navigate,mcp__playwright__browser_click,mcp__playwright__browser_file_upload,mcp__playwright__browser_evaluate,mcp__playwright__browser_wait_for")`. If Playwright MCP is unavailable, skip this step and tell the user the body has no images
   - `browser_navigate` to the PR URL. **A 404 on a private repo means the browser is not logged in** — an anonymous request cannot tell "missing" from "no access". Confirm at `https://github.com/`: marketing page means logged out, dashboard means logged in. Ask the user to log in in that window; never try to log in for them
   - Pick the fewest images that carry the evidence. Drop any whose incidental content you would not want in the PR (aerial imagery, coordinates, customer names) when it is not itself the evidence
   - **Some things cannot be captured this way.** The DevTools panel is not an attachable page, so neither Playwright nor the Chrome DevTools MCP can screenshot it (`list_pages` shows only inspected pages). For that kind of evidence, either read the data programmatically and state it in text, or ask the user to capture it
   - **Annotate at the unit of comparison, and only when needed.** The test: name what the reviewer should conclude, then ask whether the bare image already forces it. A file list whose names and count *are* the finding needs no boxes. But when the finding is a contrast across N items, box **all N** — boxing only the odd one out reads as "this one is broken" instead of "compare these". Put the legend in empty space, never over the subject. Use the method in the `e2e-verify` skill's "Annotated screenshots" section
   - Upload via the PR's **bottom comment box**, not the body editor: the asset URL is not bound to whichever box uploaded it, and this avoids touching the body mid-edit
     1. `browser_click` on `button:has-text("Paste, drop, or click to add files")` to open the file chooser. The underlying `input[type=file]` is `hidden`, so clicking it directly fails
     2. `browser_file_upload` with absolute paths
     3. `browser_wait_for` a few seconds, then read the inserted markdown: `browser_evaluate` → `() => document.querySelector('#new_comment_field').value`
     4. Clear the box so nothing is posted by accident: set `.value = ''` and dispatch an `input` event
   - Rewrite the alt text — the upload names it after the file (`10-plan-folder-contents`); say what the image shows
   - Place each image **inside the step it belongs to**, indented to the list level and separated by blank lines. A raw `<img>` at column 0 opens an HTML block that swallows the following lines, so the rest of the list renders as literal text with visible `**`
   - Then `gh pr edit <number> --body-file <temp>` and verify the render per the rules below

## Mandatory Rules

- **Get explicit approval before creating or updating a PR.** Never run `gh pr create` or `gh pr edit` unattended
- **Build the testing plan as one numbered list, each step an action → the observed result.** No parallel "what I verified" section: it restates every claim twice, once past tense and once imperative. If a bullet in one section maps 1:1 onto a step in another, they are the same list. Four further constraints:
  - **The result must be checkable by the reviewer, not just by you.** "16,874 chars" is your measurement and means nothing on their data; "`diff` prints nothing" is a criterion they can apply. Quote your own counts only as corroboration, never as the pass condition
  - **State preconditions as requirements, then give an example.** "Needs an area split so that some rows carry a layer range and others do not. For example: …" reads as a condition the reviewer can satisfy their own way. "Setup: one area split, three distributions" reads as an order to reproduce your exact data
  - **Exclude everything CI runs.** Check `.github/workflows/` first; unit tests, lint, type checks and builds are never reviewer verification. List only what CI cannot do: manual UI steps, visual checks, environment-specific work. If nothing remains, write `Covered by CI`
  - **Keep the evidence symmetric.** If some steps carry a screenshot and one does not, that gap reads as an oversight. Either give it evidence or say plainly why it has none
- **Execute every procedure you write.** Menu paths, commands and file pairings go in only after you have run them and seen the result. A path recalled from memory is a guess, and a wrong one costs the reviewer more time than the whole section saves
- **Cover every branch the ticket's own examples imply.** A ticket's example table is chosen to succeed; enumerate the branches it demonstrates (with layers / without, duplicate names / unique, excluded source types) and exercise each. Verifying only the branch your test data happens to hit leaves the ticket's headline example untested
- **One run, one environment.** Screenshots and numbers must come from a single execution. Mixing two runs or two projects forces the reviewer to reconcile identifiers that do not match. If the branches genuinely need separate setups, label each run and say why
- **Verify the published body, not the draft.** After `gh pr edit`, reload and check: every `<img>` has `naturalWidth > 0` (GitHub rewrites `user-attachments/assets/...` to a signed `private-user-images.githubusercontent.com` URL, so match that host), the numbered list still has all its items, and no `**` shows as literal text
- **Never delete or paraphrase fixed text in the template** (headings, instructions, checklists, HTML comments, boilerplate). "No change needed" does not mean "can be omitted"
- **Leave no unanswered placeholder.** A `Yes/No`, `[describe]` or `<!-- ... -->` prompt that ships verbatim reads as "the author forgot". Answer it, or write `N/A` when a parent answer makes it moot (parent `No` → child `N/A`). Grep the finished body for `Yes/No` before showing it
- **Do not cite paths reviewers cannot open.** `.claude/` is commonly excluded via `.gitignore` or `.git/info/exclude`, so such a path means nothing on GitHub. Run `git check-ignore -v <path>` before referencing any path; if ignored, inline the finding or attach the image instead
- **Do not name environment-specific identifiers.** Jobsite, project and tenant names, plan or run IDs, and record IDs from your own test data are unusable to a reviewer without access, and they put customer names into a permanent record. Describe the setup by its properties instead ("a project with a completed soil distribution, three distributions"), so the reviewer can pick their own equivalent. Keep concrete values in the local verification notes
- **Justify a decision only with a source that says it.** Before citing a ticket as the reason for a choice, read it and confirm it covers your case — guidance about reading an API does not authorize how you write to it. If no source supports the decision, say it is your judgment or drop it
- Never force-push or modify commit history; never push branches automatically; never create new labels

## Notes

- English title and summary
- Label names are case-sensitive
- **Prioritize over enumerate.** Only high-impact changes; skip trivial detail
