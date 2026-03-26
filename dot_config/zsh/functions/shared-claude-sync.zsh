# ===============================
# Shared Claude Sync Function
# ===============================

shared-claude-sync() {
  local repo=~/github/shared-claude
  git -C "$repo" add -A && \
  git -C "$repo" commit -m "update shared-claude" && \
  git -C "$repo" push
}