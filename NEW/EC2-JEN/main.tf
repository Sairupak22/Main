provider "aws" {
    region         = var.region
}

resource "aws_instance" "instance" {
ami                    = var.ami
instance_type          = var.instance
user_data              = var.ec2_user_data
vpc_security_group_ids = [aws_security_group.security_group.id]

tags = {
 Name                  = "Jenkins Instance"
}
}

resource "aws_security_group" "security_group" { 
vpc_id                 = var.vpc

ingress {
description            = "Allow SSH from my Public IP"
from_port              = 22
to_port                = 22
protocol               = "tcp"
cidr_blocks            = ["172.31.0.0/16"]  
}

ingress {
description            = "Allows Access to the Jenkins Server"
from_port              = 8080
to_port                = 8080
protocol               = "tcp"
cidr_blocks            = ["0.0.0.0/0"]
}

ingress {
description           = "Allows Access to the Jenkins Server"
from_port             = 443
to_port               = 443
protocol              = "tcp"
cidr_blocks           = ["0.0.0.0/0"]
}

egress {
from_port             = 0
to_port               = 0
protocol              = "-1"
cidr_blocks           = ["0.0.0.0/0"]
}
tags = {
  Name                = "Jenkins Security Group"
}
}

resource "aws_s3_bucket" "jojenkinsbucket" {
bucket                = "syoftjenkinsbucket"
}

resource "aws_s3_bucket_acl" "jenkinsbucketacl" {
bucket                = aws_s3_bucket.jojenkinsbucket.id
acl                   = "private"
}