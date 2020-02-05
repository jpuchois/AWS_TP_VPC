provider "aws" {}
##### NEED TO : #####
#export AWS_ACCESS_KEY_ID="anaccesskey"
#export AWS_SECRET_ACCESS_KEY="asecretkey"
#export AWS_DEFAULT_REGION="AZ"




resource "aws_vpc" "Network" {
  cidr_block = "${var.cidr_block}"
  enable_dns_support = true

  tags = {
    Name = "labVPC"
    env = "${var.environnement}"
    Context = "TP_VPC"
  }
}
############# PUBLIC SUBNET #############
resource "aws_subnet" "Public" {
  count      = "${length(var.availability_zones)}"
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "${cidrsubnet(var.cidr_block, 8, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  map_public_ip_on_launch = true

  tags = {
    Name    = "Public subnet - ${element(var.availability_zones, count.index)}"
    env     = "${var.environnement}"
    Context = "TP_VPC"
  }
}
############## APP SUBNET #############
resource "aws_subnet" "Application" {
  count      = "${length(var.availability_zones)}"
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "${cidrsubnet(var.cidr_block, 8, count.index + 10)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  map_public_ip_on_launch = false

  tags = {
    Name    = "Application subnet - ${element(var.availability_zones, count.index)}"
    env     = "${var.environnement}"
    Context = "TP_VPC"
  }
}
############## BDD SUBNET #############
resource "aws_subnet" "Database" {
  count      = "${length(var.availability_zones)}"
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "${cidrsubnet(var.cidr_block, 8, count.index + 20)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  map_public_ip_on_launch = false

  tags = {
    Name    = "Database subnet - ${element(var.availability_zones, count.index)}"
    env     = "${var.environnement}"
    Context = "TP_VPC"
  }
}





resource "aws_internet_gateway" "Network-GW" {
  vpc_id = "${aws_vpc.Network.id}"

  tags = {
    Name    = "lab_VPC_IGW"
    env     = "${var.environnement}"
    Context = "TP_VPC"
  }
}

resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.Network.id}"

  tags = {
    Name    = "publicRT"
    env     = "${var.environnement}"
    Context = "TP_VPC"
  }
}
resource "aws_route" "public_IGW" {
  route_table_id         = "${aws_route_table.route.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.Network-GW.id}"
}




resource "aws_route_table_association" "route_app_to_public" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.Public.*.id, count.index)}"
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

#resource "aws_instance" "bastion" {
#  ami           = "ami-007fae589fdf6e955"
#  instance_type = "t2.micro"
#  subnet_id = "${aws_subnet.Public.id}"
#  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
#  key_name = "${var.key}"
#  tags = {
#    Name = "Bastion"
#    Context = "tf-network"
#  }
#}

#resource "aws_network_interface" "web_net_int" {
#  subnet_id   = "${aws_subnet.Public.id}"
#  private_ips = ["10.0.1.100"]
#
#  tags = {
#    Name = "tf-network"
#  }
#}

