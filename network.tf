provider "aws" {}
##### NEED TO : #####
#export AWS_ACCESS_KEY_ID="anaccesskey"
#export AWS_SECRET_ACCESS_KEY="asecretkey"
#export AWS_DEFAULT_REGION="us-west-2"

resource "aws_vpc" "Network" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true

  tags = {
    Name = "tf-network"
  }
}

resource "aws_subnet" "Public" {
  vpc_id     = "${aws_vpc.Network.id}"
  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "tf-network"
  }
}

resource "aws_internet_gateway" "Network-GW" {
  vpc_id = "${aws_vpc.Network.id}"

  tags = {
    Name = "tf-network"
  }
}

resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.Network.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Network-GW.id}"
  }

  tags = {
    Name = "tf-network"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-007fae589fdf6e955"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = "${aws_network_interface.web_net_int.id}"
    device_index         = 0
  }

  tags = {
    Name = "tf-network"
  }
}

resource "aws_network_interface" "web_net_int" {
  subnet_id   = "${aws_subnet.Public.id}"
  private_ips = ["10.0.1.100"]

  tags = {
    Name = "tf-network"
  }
}

