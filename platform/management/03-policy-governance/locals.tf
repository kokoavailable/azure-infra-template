locals {
  assignment_name_locations = "${var.project_prefix}-allowed-locs"

  # One built-in assignment per tag key; ARM name must be unique and <= 64 chars — slug + hash avoids collisions.
  tag_keys_for_require_tag_policy = var.assign_require_environment_tag_on_rg ? toset(var.mandatory_resource_group_tag_keys) : toset([])

  assignment_name_require_tag_on_rg = {
    for k in local.tag_keys_for_require_tag_policy : k => substr(
      "${var.project_prefix}-rq-${regexreplace(lower(k), "[^a-z0-9]+", "-")}-${substr(sha256(k), 0, 6)}",
      0,
      64
    )
  }
}
