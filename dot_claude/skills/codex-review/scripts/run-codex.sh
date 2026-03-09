#!/bin/bash
# Run codex exec non-interactively and capture output
# Usage: run-codex.sh <context_file> [output_file]

set -euo pipefail

CONTEXT_FILE="${1:?Usage: run-codex.sh <context_file> [output_file]}"
OUTPUT_FILE="${2:-/tmp/codex-review-output-$$.txt}"

if [ ! -f "$CONTEXT_FILE" ]; then
  echo "Error: context file not found: $CONTEXT_FILE" >&2
  exit 1
fi

codex exec \
  --full-auto \
  --ephemeral \
  -o "$OUTPUT_FILE" \
  - < "$CONTEXT_FILE"

if [ -f "$OUTPUT_FILE" ]; then
  cat "$OUTPUT_FILE"
else
  echo "Error: codex did not produce output" >&2
  exit 1
fi
