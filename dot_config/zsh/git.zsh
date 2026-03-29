# ===============================
# Git
# ===============================

# Aliases
alias gcleanall='git restore . && git clean -fd'

# Add a git worktree with auto-naming
gwtadd() {
  local repo=$(basename "$(pwd)")
  local branch="$1"
  local base="${2:-HEAD}"
  if [[ -z "$branch" ]]; then
    echo "Usage: gwtadd branch-name [base-branch]"
    return 1
  fi

  local worktree_path="../wt-${repo}-${branch//\//-}"

  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    echo "Using existing branch '${branch}'"
    git worktree add "${worktree_path}" "${branch}"
  else
    echo "Creating new branch '${branch}' from '${base}'"
    git worktree add -b "${branch}" "${worktree_path}" "${base}"
  fi
}

# Check if current branch has conflicts with target branches
gconflict() {
  emulate -L zsh
  setopt PIPE_FAIL
  local list=0 keep=0 do_fetch=1
  local -a targets=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -l|--list) list=1 ;;
      -k|--keep) keep=1 ;;
      -n|--no-fetch) do_fetch=0 ;;
      -h|--help)
        cat << 'EOF'
Usage: gconflict [-l] [-k] [-n] [target...]

Options:
  -l, --list      Show conflicted files list
  -k, --keep      Keep merge state (don't auto-abort)
  -n, --no-fetch  Skip git fetch
  -h, --help      Show this help

Examples:
  gconflict                    # Check against origin/main (default)
  gconflict origin/develop     # Check against origin/develop
  gconflict main dev           # Check against multiple branches
  gconflict -l origin/main     # Show conflicted files
EOF
        return 0 ;;
      *) targets+=("$1") ;;
    esac
    shift
  done
  [[ ${#targets[@]} -eq 0 ]] && targets=(origin/main)
  (( do_fetch )) && git fetch --all --prune >/dev/null
  local ret=0
  for t in "${targets[@]}"; do
    echo "==> $t"
    local base; base=$(git merge-base HEAD "$t") || { echo "  (merge-base failed)"; ret=2; continue; }
    if git merge-tree "$base" HEAD "$t" | grep -q '^<<<<<<< '; then
      echo "  ❌ conflict"; ret=1
      if (( list )); then
        git merge --no-commit --no-ff "$t" >/dev/null 2>&1 || true
        git diff --name-only --diff-filter=U | sed 's/^/  - /'
        (( ! keep )) && git merge --abort >/dev/null 2>&1
      fi
    else
      echo "  ✅ clean"
    fi
  done
  return $ret
}
