
#module "vpc" {
#  source  = "terraform-aws-modules/vpc/aws"
#  version = "~> 3.0"
#
#  name = "eks-vpc"
#  cidr = "10.0.0.0/16"
#
#  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
#  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
#
#  enable_nat_gateway   = true
#  single_nat_gateway   = true
#  enable_dns_hostnames = true
#
#  enable_flow_log                      = true
#  create_flow_log_cloudwatch_iam_role  = true
#  create_flow_log_cloudwatch_log_group = true
#
#  public_subnet_tags = {
#    "kubernetes.io/cluster/eks" = "shared"
#    "kubernetes.io/role/elb"              = 1
#  }
#
#  private_subnet_tags = {
#    "kubernetes.io/cluster/eks" = "shared"
#    "kubernetes.io/role/internal-elb"     = 1
#  }
#
#  tags = merge(local.tags, {  tool = "EKS" })
#}
#
#resource "aws_security_group" "for_ssh" {
#  name = "for-ssh"
#  vpc_id      = module.vpc.vpc_id
#
#  ingress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = merge(local.tags, {})
#}

/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(local.tags, {
    Name                             = "eks-vpc"
    Environment                      = "eks",
    "kubernetes.io/cluster/Demo-eks" = "shared"
  })
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
    Name                             = "eks-igw"
    Environment                      = "eks",
    "kubernetes.io/cluster/Demo-eks" = "shared"
  })
}
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}
/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]
  tags = merge(local.tags, {
    Name                             = "eks-nat"
    Environment                      = "eks",
    "kubernetes.io/cluster/Demo-eks" = "shared"
  })
}
/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = "3"
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name                             = "eks-public-subnet"
    Environment                      = "eks",
    "kubernetes.io/cluster/Demo-eks" = "shared" // tolko odnoy TODO
  })
}
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = "3"
  cidr_block              = element(var.private_subnets, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name                             = "eks-private-subnet"
    Environment                      = "eks",
  })
}
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
    Name                             = "eks-private-route-table"
    Environment                      = "eks"
  })
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
    Name                             = "eks-public-route-table"
    Environment                      = "eks",
  })
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = "3"
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = "3"
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "eks_sg" {
  name        = "eks-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = merge(local.tags, {
    Environment                      = "eks"
  })
}