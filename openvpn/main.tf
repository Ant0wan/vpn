resource "aws_vpc" "openvpn" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "openvpn" {
  vpc_id     = aws_vpc.openvpn.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_security_group" "openvpn" {
  vpc_id = aws_vpc.openvpn.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "openvpn" {
  ami                = "ami-0c94855ba95c71c99"
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.openvpn.id
  key_name           = "my_key_pair"
  security_group_ids = [aws_security_group.openvpn.id]

  # Could execute Ansible from Terraform from here
  user_data = <<-EOF
              #!/bin/bash
              wget https://s3.amazonaws.com/aws.openvpn/2.8.8/openvpn-as-2.8.8-Ubuntu18.amd_64.deb
              dpkg -i openvpn-as-2.8.8-Ubuntu18.amd_64.deb
              rm openvpn-as-2.8.8-Ubuntu18.amd_64.deb

              sudo passwd openvpn  # Set a password for the OpenVPN admin user

              sudo /usr/local/openvpn_as/bin/ovpn-init --batch \
                --self_signed \
                --org "My Organization" \
                --common_name "openvpn.example.com" \
                --admin_user "openvpn"

              sudo systemctl start openvpnas
              EOF
}
