provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "foo" {
  name = "dev"
}

resource "aws_ecr_lifecycle_policy" "foopolicy" {
  repository = aws_ecr_repository.foo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

#ecr cache rule
resource "aws_ecr_pull_through_cache_rule" "example" {
  ecr_repository_prefix = "ecr-public"
  upstream_registry_url = "public.ecr.aws"
}

#ecr registry policy
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

resource "aws_ecr_registry_policy" "example" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "testpolicy",
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "ecr:ReplicateImage"
        ],
        Resource = [
          "arn:${data.aws_partition.current.partition}:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
        ]
      }
    ]
  })
}

#ecr scanning configuration
resource "aws_ecr_registry_scanning_configuration" "configuration" {
  scan_type = "ENHANCED"

  rule {
    scan_frequency = "CONTINUOUS_SCAN"
    repository_filter {
      filter      = "example"
      filter_type = "WILDCARD"
    }
  }
}

#ecr replications

resource "aws_ecr_replication_configuration" "example" {
  replication_configuration {
    rule {
      destination {
        region      = "us-east-1"
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}
