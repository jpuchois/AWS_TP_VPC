provider "aws" {}
##### NEED TO : #####
#export AWS_ACCESS_KEY_ID="anaccesskey"
#export AWS_SECRET_ACCESS_KEY="asecretkey"
#export AWS_DEFAULT_REGION="AZ"


resource "aws_vpc" "Network" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true

  tags = {
    Name = "labVPC"
    Context = "TP_VPC"
  }
}

############# PUBLIC SUBNET #############
resource "aws_subnet" "PublicA" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-3a"

  map_public_ip_on_launch = true

  tags = {
    Name = "PublicA"
    Context = "TP_VPC"
  }
}
resource "aws_subnet" "PublicB" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-3b"

  map_public_ip_on_launch = true

  tags = {
    Name = "PublicB"
    Context = "TP_VPC"
  }
}
resource "aws_subnet" "PublicC" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-3c"

  map_public_ip_on_launch = true

  tags = {
    Name = "PublicC"
    Context = "TP_VPC"
  }
}

############# APP SUBNET #############
resource "aws_subnet" "PrivateA" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.10.0/24"
  availability_zone = "eu-west-3a"
  tags = {
    Name = "PrivateA"
    Context = "TP_VPC"
  }
}
resource "aws_subnet" "PrivateB" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.11.0/24"
  availability_zone = "eu-west-3b"


  tags = {
    Name = "PrivateB"
    Context = "TP_VPC"
  }
}
resource "aws_subnet" "PrivateC" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.12.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    Name = "PrivateC"
    Context = "TP_VPC"
  }
}

############# DATABASE SUBNET #############
resource "aws_subnet" "DBA" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.20.0/24"
  availability_zone = "eu-west-3a"
  tags = {
    Name = "DB_A"
    Context = "TP_VPC"
  }
}
resource "aws_subnet" "DBB" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.21.0/24"
  availability_zone = "eu-west-3b"


  tags = {
    Name = "DB_B"
    Context = "TP_VPC"
  }
}
resource "aws_subnet" "DBC" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.22.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    Name = "DB_C"
    Context = "TP_VPC"
  }
}



resource "aws_internet_gateway" "Network-GW" {
  vpc_id = "${aws_vpc.Network.id}"

  tags = {
    Name = "labVPCIGW"
    Context = "TP_VPC"
  }
}

resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.Network.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Network-GW.id}"
  }

  tags = {
    Name = "publicRT"
    Context = "TP_VPC"
  }
}

resource "aws_route_table_association" "route_pubA" {
  subnet_id      = "${aws_subnet.PublicA.id}"
  route_table_id = "${aws_route_table.route.id}"
}

resource "aws_route_table_association" "route_pubB" {
  subnet_id      = "${aws_subnet.PublicB.id}"
  route_table_id = "${aws_route_table.route.id}"
}

resource "aws_route_table_association" "route_pubC" {
  subnet_id      = "${aws_subnet.PublicC.id}"
  route_table_id = "${aws_route_table.route.id}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${aws_vpc.Network.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-007fae589fdf6e955"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.PublicB.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  key_name = "${var.key}"
  tags = {
    Name = "Bastion"
    Context = "tf-network"
  }
}
#
#resource "aws_network_interface" "web_net_int" {
#  subnet_id   = "${aws_subnet.Public.id}"
#  private_ips = ["10.0.1.100"]
#
#  tags = {
#    Name = "tf-network"
#  }
#}

