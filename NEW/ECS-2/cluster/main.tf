provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "innovation" {
  name = var.name
    tags = var.tags
#  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
#default_capacity_provider_strategy {
#  capacity_provider = "FARGATE_SPOT"
#  weight                   = 100  
}
