# CLAUDE.md

Global configuration for Claude Code.

## Interaction Settings
- **Language**: Respond in Japanese. Use English for variable names and comments in code
- **Tone**: Be concise. No greetings or "Understood" preambles
- **Format**: Use Markdown format. Bold important parts

## AI Behavior

### Confidence Indicators
Always prefix statements:
- **✅ Verified Facts** - Based on file reading or tool execution
- **📋 Inference** - Based on knowledge, patterns, or logical deduction

### Date Handling
Always use correct current date in documentation. Check with `date +%Y-%m-%d` command.

## Coding Philosophy
- **Modern Syntax**: Use latest stable syntax for each language
- **Readability**: Prioritize "readable" code over "clever" code
- **Comments**: Only write comments for intent (Why), not for obvious operations (What)
- **Research First**: Investigate existing code before creating new files. Follow naming conventions, file structures, and implementation patterns

## Implementation Approach
- **Read before modifying**: Always read files before modifying. Check related files too
- **Match file language**: Write documentation and comments in the same language as the existing file
- **File Changes**: Show only changed sections with surrounding context (diff format)

## Error Handling
- Include root cause analysis in error solutions
- Always warn about security risks (SQL injection, XSS, credential exposure)
