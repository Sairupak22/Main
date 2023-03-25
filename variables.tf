variable "user_name" {
  type    = list(string)  
}
variable "root_volume_encryption" {}
variable "user_volume_encryption" {}
variable "user_volume_size_gib" {}
variable "root_volume_size_gib" {}
variable "running_mode_auto_stop_timeout_in_minutes" {}
variable "bundle_id" {}
# variable "running_mode" {}
variable "wait_for_ready_timeout" {}
variable "directory_id" {}