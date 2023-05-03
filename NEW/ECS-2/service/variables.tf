variable "aws_region" {
  type  = string
}
variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}

# "tags" {
#ption = "A map of tags to add to ECS Cluster"
#      = map(string)
#t     = {}
#
#variable "name"{}

variable "service_name" {
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
  type        = string
 
}
variable "container_memory" {
  default = ""
}

variable "image_url" {}
variable "container_cpu" {
  default = ""
}

variable "container_name"{}

variable"vpc_id"{}
variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster in which to deploy the service."
  type        = string
}
variable "container_port" {
 
}

variable "target_group_arn" {
 description = "The arn of the target group to point at the service containers."
  type        = string
  
}


variable "service_desired_count" {
  description = "The desired number of tasks in the service."
  type        = number
  
}
variable "ecs_service_role_name" {}
variable "task_definition"{}
variable "name"{}
variable "container_image"{}
variable "family"{}
variable "container_Port"{}
variable "host_Port"{}
variable "execution_role_arn"{}
variable "image"{}
variable"cpu"{}
variable"memory"{}
variable"containerPort"{}
variable"hostPort"{}



