variable "aws_region" {
  type  = string
}

variable "name" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}



