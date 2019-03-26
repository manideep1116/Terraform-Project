# VPC for the application
resource "aws_vpc" "home_vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "HomeVPC"
  }
}

#Creating Internet gateway to make subnets public and attach it to out homevpc. Internet gateway is only for public subnet.If we have database like RDS in our private subnet. We need to create a NAT gateway in public subnet for internet acces to private subnet.Here we have both public subnets in different az's.

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.home_vpc.id}"

  tags = {
    Name = "main"
  }
}

# Build subnets for our vpc
resource "aws_subnet" "public" {
  count                   = "${length(var.subnets_cidr)}"
  vpc_id                  = "${aws_vpc.home_vpc.id}"
  availability_zone       = "${element(var.azs,count.index)}"
  cidr_block              = "${element(var.subnets_cidr,count.index)}"  #element retrieves a single element from a list.
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-$(count.index+1}"
  }
}

# Create Route table, attach Internet gateway and associate with public subnets

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.home_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "publicRT"
  }
}

#attach route table to the public subnets.We are associating our route table to subnets.

resource "aws_route_table_association" "a" {
  count          = "${length(var.subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
