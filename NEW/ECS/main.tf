provider "aws" {
  region = var.region
}

resource "aws_kms_key" "key" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
}

resource "aws_cloudwatch_log_group" "devlog" {
  name = "syoftdev"
}

resource "aws_ecs_cluster" "cluster" {
  name = var.name
  
  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.key.arn
      logging    = var.logging

      log_configuration {
        cloud_watch_encryption_enabled = var.cloud_watch_encryption_enabled
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.devlog.name
      }
    }
  }
}
#vpc
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = "dev"
  }
}
resource "aws_subnet" "public_us_east_1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public Subnet us-east-1a"
  }
}
resource "aws_subnet" "public_us_east_1b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/28"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public Subnet us-east-1b"
  }
}
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My VPC - Internet Gateway"
  }
}
resource "aws_route_table" "my_vpc_public" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }
    tags = {
        Name = "Public Subnets Route Table for My VPC"
    }
}
resource "aws_route_table_association" "my_vpc_us_east_1a_public" {
    subnet_id = aws_subnet.public_us_east_1a.id
    route_table_id = aws_route_table.my_vpc_public.id
}
resource "aws_route_table_association" "my_vpc_us_east_1b_public" {
    subnet_id = aws_subnet.public_us_east_1b.id
    route_table_id = aws_route_table.my_vpc_public.id
}
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound connections"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow HTTP Security Group"
  }
}

#launch config

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = var.name_prefix
  image_id      = var.image_id
  instance_type = var.instance_type
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier       = [aws_subnet.public_us_east_1a.id, aws_subnet.public_us_east_1b.id]

  lifecycle {
    create_before_destroy = true
  }
}

#task

resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "183535165110.dkr.ecr.us-east-1.amazonaws.com/dev:django_project"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    # {
    #   name      = "second"
    #   image     = "183535165110.dkr.ecr.us-east-1.amazonaws.com/syoftdev:nodejs"
    #   cpu       = 10
    #   memory    = 256
    #   essential = true
    #   portMappings = [
    #     {
    #       containerPort = 443
    #       hostPort      = 443
    #     }
    #   ]
    # }
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

resource "aws_ecs_service" "ubuntu" {
  name            = "ubuntu"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 3
#   iam_role        = aws_iam_role.test_role.arn
    # iam_role        =  aws_iam_role.ecs_task_execution_role.arn                    
    #  iam_role           = data.aws_iam_policy.test_role.arn
#   iam_role        = var.ecs_service_role_name
    # iam_role           = "arn:aws:iam::183535165110:role/aws-service-role/replication.ecr.amazonaws.com/AWSServiceRoleForECRReplication"
#   depends_on      = [aws_iam_role.test_role]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.front_end.arn
    container_name   = "second"
    container_port   = 443
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }
}

resource "aws_lb" "front_end" {
   name               = "dev"
  load_balancer_type = "network"
  internal           = true
  # load_balancer_type = "application"

  subnet_mapping {
    subnet_id            = aws_subnet.public_us_east_1a.id
    private_ipv4_address = "10.0.0.0/28"
  }

  subnet_mapping {
    subnet_id            = aws_subnet.public_us_east_1b.id
    private_ipv4_address = "10.0.1.0/26"
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_launch_configuration.as_conf.id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.example.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_ecs_task_set" "task_set" {
  service         = aws_ecs_service.ubuntu.id
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.front_end.arn
    container_name   = "second"
    container_port   = 8080
  }
}