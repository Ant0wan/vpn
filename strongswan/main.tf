provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

resource "aws_instance" "strongswan_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS in us-east-1. You may change this for other regions or AMIs.
  instance_type = "t2.micro" # Change this to your desired instance type

  key_name      = "your-aws-key-pair" # Replace this with the name of your AWS Key Pair, get it from BitWarden

  tags = {
    Name = "StrongSwan-IPSec-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y strongswan
              echo 1 > /proc/sys/net/ipv4/ip_forward
              EOF

  # Security group to allow inbound SSH and IPSec traffic
  security_groups = [aws_security_group.strongswan_sg.id]
}

resource "aws_security_group" "strongswan_sg" {
  name_prefix = "strongswan_sg"
}

resource "aws_security_group_rule" "allow_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.strongswan_sg.id
}

resource "aws_security_group_rule" "allow_ipsec" {
  type        = "ingress"
  from_port   = 500
  to_port     = 500
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.strongswan_sg.id
}

resource "aws_security_group_rule" "allow_esp" {
  type        = "ingress"
  from_port   = 50
  to_port     = 50
  protocol    = "esp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.strongswan_sg.id
}

output "server_ip" {
  value = aws_instance.strongswan_server.public_ip
}

