provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "default" {
  id = "vpc-08cd654ebd17167be"
}

data "aws_iam_instance_profile" "sudir" {
  name = "sudir"
}

resource "aws_security_group" "trend_sg" {
  name   = "trend-jenkins-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "trend-jenkins-sg" }
}

resource "aws_instance" "jenkins" {
  ami                         = "ami-0f58b397bc5c1f2e8"
  instance_type               = "t3.medium"
  subnet_id                   = "subnet-0873ec2670e616225"
  vpc_security_group_ids      = [aws_security_group.trend_sg.id]
  iam_instance_profile        = data.aws_iam_instance_profile.sudir.name
  key_name                    = "project-2"
  associate_public_ip_address = true

  user_data = <<-USERDATA
    #!/bin/bash
    apt-get update -y
    apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      git \
      unzip \
      wget \
      fontconfig \
      openjdk-21-jdk

    # Docker
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) \
      signed-by=/etc/apt/keyrings/docker.asc] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      > /etc/apt/sources.list.d/docker.list
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu

    # Jenkins repo key via keyserver
    gpg --keyserver keyserver.ubuntu.com \
      --recv-keys 7198F4B714ABFC68
    gpg --export 7198F4B714ABFC68 \
      > /usr/share/keyrings/jenkins-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] \
      https://pkg.jenkins.io/debian-stable binary/" \
      > /etc/apt/sources.list.d/jenkins.list
    apt-get update -y
    apt-get install -y jenkins
    systemctl enable jenkins
    systemctl start jenkins
    usermod -aG docker jenkins
  USERDATA

  tags = { Name = "jenkins-server" }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
