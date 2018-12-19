# Define our VPC
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "sandbox-vpc"
    Environment = "Sandbox"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
      Name = "sandbox default sg"
      Environment = "Sandbox"
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "public"
    Environment = "Sandbox"
  }
}

# Define the private subnet(s)
resource "aws_subnet" "private-subnet-a" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_a_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "private a"
    Environment = "Sandbox"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "igw"
    Environment = "Sandbox"
  }
}

# Define the route table
resource "aws_route_table" "tf-public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public subnet rt"
    Environment = "Sandbox"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "tf-public-rt-as" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.tf-public-rt.id}"
}

resource "aws_eip" "nat" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]

  tags {
    Name = "Elastic IP"
    Environment = "Sandbox"
  }
}

resource "aws_nat_gateway" "ngw" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  allocation_id = "${aws_eip.nat.id}"

  tags {
    Name = "NAT Gateway"
    Environment = "Sandbox"
  }
}

resource "aws_route_table" "tf-private-rt-a" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags {
    Name = "private-a subnet rt"
    Environment = "Sandbox"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "tf-private-rt-aas" {
  subnet_id = "${aws_subnet.private-subnet-a.id}"
  route_table_id = "${aws_route_table.tf-private-rt-a.id}"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = [
  "${aws_route_table.tf-private-rt-a.id}",
  ]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
  "${aws_default_security_group.default.id}",
  ]

  subnet_ids          = [
    "${aws_subnet.private-subnet-a.id}",
  ]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id       = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    "${aws_default_security_group.default.id}",
  ]

  subnet_ids          = [
    "${aws_subnet.private-subnet-a.id}",
  ]
}


resource "aws_vpc_endpoint" "ec2" {
  vpc_id       = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
  "${aws_default_security_group.default.id}",
  ]

  subnet_ids          = [
    "${aws_subnet.private-subnet-a.id}",
  ]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id       = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    "${aws_default_security_group.default.id}",
  ]

  subnet_ids          = [
    "${aws_subnet.private-subnet-a.id}",
  ]
}
