#!/bin/bash
sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo \https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo yum upgrade
sudo apt update
sudo apt install openjdk-8-jre -y
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo ufw allow 8080
sudo ufw status
sudo ufw allow OpenSSH sudo ufw enable
sudo ufw enable
sudo ufw status
sudo cat ?var/lib/jenkins/secrets/initalAdminPassword
