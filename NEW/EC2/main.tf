provider "aws" {
  region = var.region
}

# resource "aws_instance" "syoft" {
#   ami           = var.ami
#   instance_type = var.instance_type
#   count = 1
  
#   tags = {
#     Name = "syoft"
#   }
# }
resource "aws_instance" "jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  count = 1
  key_name = "ec2.key"
  # secret_key = "../.ssh/terraform"
  # user_data = file("install_jenkins.sh")

  connection {
    type         = "ssh"
    user         = "ec2-user"
    host         =  self.public_ip
    private_key = file("~/Downloads/jenkins.pem")
    password = self.password_data
  
 }
#       provisioner "file" {
#         source = "install_jenkins.sh"
#         destination = "/tmp/install_jenkins.sh"
      
#       }

#       provisioner "remote-exec" {
#         inline = [
#           "sudo chmod +x /tmp/install_jenkins.sh",
#           "sh /tmp/install_jenkins.sh",
#         ]
#       }
#   tags = {
#     Name = "jenkins"
#   }
# }
provisioner "remote-exec" {
    inline = [
  
        # steps to setup docker ce
        "apt update",
        "apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common",
        "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -",
        "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" ",
        "apt update",
        "apt-cache policy docker-ce",
        "apt -y install docker-ce",

        # build Jenkins container image with default admin user
        "cd /tmp && docker build -t popularowl/jenkins .",

        # run newly built jenkins container on port 8080
        "docker run -d --name jenkins-server -p 8080:8080 popularowl/jenkins",

        # install remaining dependencies
        "apt -y install nginx",
        "apt -y install ufw",
        
        # setup debian firewall
        "ufw status verbose",
        "ufw default deny incoming",
        "ufw default allow outgoing",
        "ufw allow ssh",
        "ufw allow 22",
        "ufw allow 80",
        "yes | ufw enable",
        
        # update nginx configuration
        "rm -f /etc/nginx/sites-enabled/default",
        "cp -f /tmp/jenkins-proxy /etc/nginx/sites-enabled",
        "service nginx restart"        
]
    # connection {
    # type         = "ssh"
    # # secret_key = "../.ssh/terraform"
    # host         = self.public_ip
    # user         = "ec2-user"
  
 }
}

# # provisioner "file" {
# #     source      = "files/jenkins-proxy"
# #     destination = "/tmp/jenkins-proxy"
# # }

# # provisioner "file" {
# #     source      = "files/Dockerfile"
# #     destination = "/tmp/Dockerfile"
# # }

# # provisioner "file" {
# #     source      = "files/jenkins-plugins"
# #     destination = "/tmp/jenkins-plugins"
# # }

# # provisioner "file" {
# #     source      = "files/default-user.groovy"
# #     destination = "/tmp/default-user.groovy"
# # }
# #   provisioner "remote-exec"  {
# #     inline  = [
# #       "sudo yum install -y jenkins java-11-openjdk-devel",
# #       "sudo yum -y install wget",
# #       "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
# #       "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
# #       "sudo yum upgrade -y",
# #       "sudo yum install jenkins -y",
# #       "sudo systemctl start jenkins",
# #       "sudo ufw allow 8080",
# #       ]
# #    }
# #  connection {
# #     type         = "ssh"
# #     host         = self.public_ip
# #     user         = "ec2-user"
# #     private_key  = "docker.pem"

# #    }

#   # provisioner "remote-exec" { 
  
#   #   inline = [ 
#   #     "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
#   #     "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
#   #     "sudo apt update -qq",
#   #     "sudo apt install -y default-jre",
#   #     "sudo apt install -y jenkins",
#   #     "sudo systemctl start jenkins",
#   #     "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
#   #     "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
#   #     "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
#   #     "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
#   #     "sudo apt-get -y install iptables-persistent",
#   #     "sudo ufw allow 8080",
    
#   #   ]
#   #   }

#   # connection {
#   #   type        = "ssh"
#   #   host        = self.public_ip
#   #   user        = "ubuntu"
#   #   private_key = file("~/Downloads/jenkins.pem")
#   # }
# # user_data = <<-EOF
# #       "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
# #       "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
# #       "sudo apt update -qq",
# #       "sudo apt install -y default-jre",
# #       "sudo apt install -y jenkins",
# #       "sudo systemctl start jenkins",
# #       "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
# #       "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
# #       "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
# #       "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
# #       "sudo apt-get -y install iptables-persistent",
# #       "sudo ufw allow 8080",
    
# # EOF
# }


# # user_data = <<-EOF
# # #!/bin/bash
# # sudo yum update –y
# # sudo wget -O /etc/yum.repos.d/jenkins.repo \
# #     https://pkg.jenkins.io/redhat-stable/jenkins.repo
# # sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
# # sudo yum upgrade
# # sudo yum install jenkins java-1.8.0-openjdk-devel -y
# # sudo systemctl daemon-reload
# # sudo systemctl start jenkins
# # sudo systemctl status jenkins
# # EOF
# # }
# resource "aws_security_group" "jenkins20_secgrp" {
#   name = "jenkins20_secgrp"
#   description = "Allow ssh and HTTP traffic"
#   vpc_id = "vpc-008cad8c938e96d79"

#   ingress{
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port = 443
#     to_port = 443
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#    egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
# # resource "aws_s3_bucket" "jenkins_artifacts" {
# #   bucket = "jenkins-artifacts"
# # }
# resource "aws_s3_bucket" "jenkins_artifacts" {
#   bucket = "jenkinsart"
# }

# configured aws provider with proper credentials
# provider "aws" {
#   region = var.region
# }


# create default vpc if one does not exit
# resource "aws_default_vpc" "default_vpc" {

#   tags    = {
#     Name  = "default vpc"
#   }
# }


# use data source to get all avalablility zones in region
# data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
# resource "aws_default_subnet" "default_az1" {
#   availability_zone = data.aws_availability_zones.available_zones.names[0]

#   tags   = {
#     Name = "default subnet"
#   }
# }


# create security group for the ec2 instance
# resource "aws_security_group" "ec2_security_group" {
#   name        = "ec2 security group"
#   description = "allow access on ports 8080 and 22"
#   vpc_id      = "vpc-008cad8c938e96d79"
 
#   # allow access on port 8080
#   ingress {
#     description      = "http proxy access"
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   # allow access on port 22
#   ingress {
#     description      = "ssh access"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = -1
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags   = {
#     Name = "jenkins server security group"
#   }
# }


# # use data source to get a registered amazon linux 2 ami
# # data "aws_ami" "amazon_linux_2" {
# #   most_recent = true
# #   owners      = ["amazon"]
  
# #   filter {
# #     name   = "owner-alias"
# #     values = ["amazon"]
# #   }

# #   filter {
# #     name   = "name"
# #     values = ["amzn2-ami-hvm*"]
# #   }
# # }


# # launch the ec2 instance and install website
# resource "aws_instance" "ec2_instance" {
#   ami                    = "ami-007855ac798b5175e"
#   instance_type          = "t2.micro"
#   # subnet_id              = aws_default_subnet.default_az1.id
#   # vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
#   key_name               = "jenkins"
#   # user_data            = file("install_jenkins.sh")

#   tags = {
#     Name = "jenkins"
#   }
# }
# # data "aws_key_pair" "example" {
# #   key_name = "ec2.key"
# #   filter {
# #     name   = "tag:Component"
# #     values = ["web"]
# #   }
# # }

# # an empty resource block
# resource "null_resource" "name" {

#   # ssh into the ec2 instance 
#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file("~/Downloads/jenkins.pem")
#     host        = aws_instance.ec2_instance.public_ip
#   }

#   # copy the install_jenkins.sh file from your computer to the ec2 instance 
#   provisioner "file" {
#     source      = "install_jenkins.sh"
#     destination = "/tmp/install_jenkins.sh"
#   }

#   # set permissions and run the install_jenkins.sh file
#   provisioner "remote-exec" {
#     inline = [
#       "sudo chmod +x /tmp/install_jenkins.sh",
#       "sh /tmp/install_jenkins.sh",
#     ]
#   }

#   # wait for ec2 to be created
#   # depends_on = [aws_instance.ec2_instance]
# }


# print the url of the jenkins server
# output "website_url" {
#   value     = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "8080"])
# }



#  resource "aws_security_group" "ec2_security_group" {
#   name        = "ec2 security group"
#   description = "allow access on ports 8080 and 22"
#   vpc_id      = "vpc-008cad8c938e96d79"
 
#   # allow access on port 8080
#   ingress {
#     description      = "http proxy access"
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   # allow access on port 22
#   ingress {
#     description      = "ssh access"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = -1
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags   = {
#     Name = "jenkins server security group"
#   }
# }
# resource "aws_instance" "jenkinsec2" {
#   ami                    = "ami-007855ac798b5175e"
#   instance_type          = "t2.micro"
#   # subnet_id              = aws_default_subnet.default_az1.id
#   security_groups = ["${aws_security_group.ec2_security_group.name}"]
#   key_name               = "jenkins"
#   # user_data            = file("install_jenkins.sh")
#     user_data = <<-EOF
#          #!/bin/bash
#          sudo apt-get update
#          sudo apt install -y oprnjdk-8-jre-headless
#          wget -q -o - http://pkg/jenkins-ci.org/debin/jenkins-ci.org.key | sudo apt-key add -
#          sudo sh -c 'echo deb http://pkg.jenkins-ci.otg/debin-stable binary/ > /etc/apt/sources.list.d/jenkins.list
#          sudo apt update
#          sudo apt install -y jenkins
#          sudo systemctl start jenkins
#         sudo yum update -y
#         sudo wget -O /etc/yum.repos.d/jenkins.repo \https://pkg.jenkins.io/redhat-stable/jenkins.repo
#         sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
#         sudo yum upgrade
#         sudo yum install jenkins java-1.8.0-openjdk-devel -y
#         sudo systemctl daemon-reload
#         sudo systemctl start jenkins
#         sudo systemctl status jenkins
# EOF
# tags = {
#     Name = "jenkins"
#   }
# }
  # tags = {
  #   Name = "jenkins"
  # }
