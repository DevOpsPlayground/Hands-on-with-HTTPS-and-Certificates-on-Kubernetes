resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-igw"
  }
}

resource "aws_eip" "ngw_ip" {}

resource "aws_nat_gateway" "ngw" {
  count         = "${var.private_subnets > 0 ? 1 : 0}"
  allocation_id = "${aws_eip.ngw_ip.id}"
  subnet_id     = "${aws_subnet.public_subnets.0.id}"

  tags {
    Name = "${var.name}-ngw"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = "${var.public_subnets > 0 ? var.public_subnets : 1}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.cidr_block, 8, 10+count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.zones.names,count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-public-sn-${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = "${var.private_subnets}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr_block, 8, 100+count.index)}"
  availability_zone = "${element(data.aws_availability_zones.zones.names,count.index)}"

  tags {
    Name = "${var.name}-private-sn-${count.index}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-public-route-table"
  }
}

resource "aws_route" "public_route_to_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  route_table_id         = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table" "private_route_table" {
  count  = "${var.private_subnets > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-private-route-table"
  }
}

resource "aws_route" "private_route_to_ngw" {
  count                  = "${var.private_subnets > 0 ? 1 : 0}"
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.ngw.id}"
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = "${var.public_subnets > 0 ? var.public_subnets : 1}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id,count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = "${var.private_subnets}"
  subnet_id      = "${element(aws_subnet.private_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}
