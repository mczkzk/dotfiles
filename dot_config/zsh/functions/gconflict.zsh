# ===============================
# Git Conflict Check Function
# ===============================

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

Git conflict checker - Check if current branch has conflicts with target branches

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
  gconflict -n -l main         # Check without fetch, show files

Output:
  ✅ clean    - No conflicts found
  ❌ conflict - Conflicts detected
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
    local base; base=$(git merge-base HEAD "$t") || { echo "  (merge-base失敗)"; ret=2; continue; }
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