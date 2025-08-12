# ===============================
# Git Worktree Add Function
# ===============================

gwtadd() {
  repo=$(basename "$(pwd)")
  branch="$1"
  base="${2:-HEAD}"
  if [ -z "$branch" ]; then
    echo "Usage: gwtadd branch-name [base-branch]"
    return 1
  fi

  # Create worktree path (replace / with - in branch name)
  worktree_path="../wt-${repo}-${branch//\//-}"

  # Check if branch exists
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    echo "Using existing branch '${branch}'"
    git worktree add "${worktree_path}" "${branch}"
  else
    echo "Creating new branch '${branch}' from '${base}'"
    git worktree add -b "${branch}" "${worktree_path}" "${base}"
  fi
}