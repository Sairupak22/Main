
resource "aws_workspaces_workspace" "continuum" {
  directory_id = var.directory_id   
  bundle_id    = data.aws_workspaces_bundle.value_windows.id

  # Administrator is always present in a new directory.
  for_each = toset(var.user_name)
  user_name = each.key

  workspace_properties {
    compute_type_name                         = "VALUE"
    user_volume_size_gib                      = var.user_volume_size_gib 
    root_volume_size_gib                      = var.root_volume_size_gib
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = var.running_mode_auto_stop_timeout_in_minutes
  }
  timeouts {
    create = "60m"
    delete = "2h"
  
}

  tags = {
    Department = "IT"
  }
}
data "aws_workspaces_bundle" "value_windows" {
  bundle_id = var.bundle_id # Value with Windows 10 (English)
}
