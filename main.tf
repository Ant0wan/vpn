resource "aws_vpc" "openvpn" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "openvpn" {
  vpc_id     = aws_vpc.openvpn.id
  cidr_block = "10.0.0.0/24"
}

