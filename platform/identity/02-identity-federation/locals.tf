locals {
  github_repo_full = "${var.github_organization}/${var.github_repository}"

  federated_branch_names = distinct(concat(
    [var.default_branch],
    var.additional_github_branches
  ))

  federated_credentials = {
    for b in local.federated_branch_names : b => {
      display_name = "github-${replace(b, "/", "-")}"
      subject      = "repo:${local.github_repo_full}:ref:refs/heads/${b}"
    }
  }
}
