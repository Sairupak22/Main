provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "innovation" {
  name = var.name
    tags = var.tags
}
resource "aws_ecs_task_definition" "dev" {
  family = var.family 
    container_definitions = jsonencode([
       {
      name      =var.name
      image = var.image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.containerPort
          hostPort      = var.hostPort
        }
      ]
    },
  ])
    volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }
} 

resource "aws_ecs_service" "service"{
  name            = var.service_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.dev.arn
  #  task_definition = "resource aws_ecs_task_definition"
  # task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.service_desired_count
  iam_role        = var.ecs_service_role_name
  launch_type     = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }
}

resource "aws_lb_target_group" "service" {
  name        = "coll"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

#  #depends_on = [aws_alb.my_lb]
}
