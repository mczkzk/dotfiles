# ===============================
# GitHub New Repository Function
# ===============================

ghnew() {
  local repo_name
  read "repo_name?Enter repository name: "
  gh repo create "$repo_name" --private --clone --add-readme
}