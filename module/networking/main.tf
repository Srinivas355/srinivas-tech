resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags             = var.vpc_tags
}
# Internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}
resource "aws_subnet" "public" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.main.id
  availability_zone = local.az_names[count.index]
  cidr_block        = var.pub_cidrs[count.index]
}
# associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

# Create route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}
resource "aws_subnet" "private" {
  count             = var.subnet_count
  availability_zone = local.az_names[count.index]
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.pri_cidrs[count.index]
}
# associate public subnets with public route table
resource "aws_route_table_association" "private" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}
resource "aws_instance" "nat_instance" {
  ami        = "ami-06f621d90fa29f6d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.*.id[0]
  associate_public_ip_address = true
  tags = {
    Name = "NAT_Instance"
  }
}
