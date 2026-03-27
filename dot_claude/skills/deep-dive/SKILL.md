---
name: deep-dive
description: Deep-dive investigation using all available tools (codebase, web, MCP, GitHub) to find root causes
argument-hint: <topic: subject like "authentication flow" or "performance bottleneck">
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git:*)
  - Bash(gh:*)
  - Agent
  - WebSearch
  - WebFetch
  - ToolSearch
  - mcp__claude_ai_Slack__*
  - mcp__claude_ai_Atlassian__*
  - mcp__claude_ai_Notion__*
  - mcp__claude_ai_Microsoft_365__*
---

Find the root cause. Do not stop until you find it or exhaust every possible avenue.

## Core Principles

1. **No implementation** - research only, no code changes
2. **Never settle** - if the first approach fails, try another. And another. Keep going
3. **Use everything** - codebase, web, MCP, GitHub, Slack, git history, stack traces, whatever exists
4. **Ask user for leads** - "Do you have logs/metrics for this?", "Is there a tool that could show X?"
5. **Don't guess** - ask when information is missing
6. **No time limits** - thoroughness over speed

## Agent Team Investigation

For complex or ambiguous problems, create an **agent team** for parallel hypothesis-driven investigation.

### When to Use Agent Teams

- Root cause is unclear and multiple hypotheses exist
- Problem spans multiple systems or layers
- Single-threaded investigation would take too long

### Team Structure

Create a team with **3-5 investigators**, each assigned a different hypothesis or investigation angle.

```
Create an agent team to investigate: $ARGUMENTS

Spawn N teammates, each investigating a different hypothesis:
- Teammate 1: [hypothesis A - e.g., "race condition in async handler"]
- Teammate 2: [hypothesis B - e.g., "cache invalidation timing"]
- Teammate 3: [hypothesis C - e.g., "upstream API behavior change"]
...

CRITICAL INSTRUCTIONS FOR ALL TEAMMATES:
- Research only, no code changes
- Post your findings and evidence as you discover them
- Actively challenge other teammates' theories with counter-evidence
- If another teammate's evidence disproves your hypothesis, acknowledge it and pivot
- If you find evidence supporting another teammate's theory, share it
- The goal is scientific debate: the surviving theory is likely the root cause
```

### Investigation Flow

1. **Hypothesis Generation** - Analyze the problem, propose 3-5 distinct hypotheses
2. **Team Creation** - Spawn teammates, one per hypothesis
3. **Parallel Investigation** - Each teammate gathers evidence for/against their hypothesis
4. **Cross-Examination** - Teammates challenge each other's findings via direct messages
5. **Convergence** - Surviving hypothesis with strongest evidence becomes the conclusion
6. **Synthesis** - Leader consolidates all findings into a final report

### Debate Rules for Teammates

- **Evidence-based only** - Every claim must cite specific code (file:line), logs, docs, or test results
- **Actively disprove** - Don't just prove your own theory; try to break others'
- **Pivot when wrong** - If evidence kills your hypothesis, switch to investigating the strongest remaining theory
- **Share freely** - If you find something relevant to another teammate's investigation, message them directly

### Output

After team convergence:

```markdown
## Deep-Dive Result: $ARGUMENTS

### Root Cause
[The surviving hypothesis with evidence summary]

### Evidence Chain
1. [Evidence A] - file:line or source
2. [Evidence B] - file:line or source
...

### Eliminated Hypotheses
- [Hypothesis X]: Disproved by [evidence]
- [Hypothesis Y]: Disproved by [evidence]

### Recommendations
- [What to fix and how]
```

## MCP Sweep Phase

Agent teammates use specialized types (e.g., `feature-dev:code-explorer`) that **cannot access MCP tools**. Only the main conversation (skill runner) can use MCP tools (Slack, JIRA, Confluence, Notion, etc.).

**Run this phase in parallel with agent team investigation, or immediately after agents report back.**

### When to Run

- Always, if MCP servers are available in the conversation
- Especially for: context behind decisions, discussions, related tickets, design docs

### What to Search

Using `ToolSearch` to fetch MCP tool schemas, then search across:

1. **Slack** (`mcp__claude_ai_Slack__slack_search_public_and_private`): keywords from the topic, ticket IDs, related terms in relevant channels
2. **JIRA** (`mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql`): related tickets, linked issues, comments on the main ticket
3. **Confluence** (`mcp__claude_ai_Atlassian__searchConfluenceUsingCql`): design docs, architecture decisions, meeting notes
4. **Notion** (`mcp__claude_ai_Notion__notion-search`): specs, planning docs

### Strategy

- Use `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` first to get cloudId
- Run multiple MCP searches in parallel (different keywords, different sources)
- Read promising thread contexts with `mcp__claude_ai_Slack__slack_read_thread`
- Integrate MCP findings into the final report alongside agent findings

## Simple Investigation (Fallback)

For straightforward problems where the cause is likely singular, skip the agent team and investigate directly using all available tools including MCP.
