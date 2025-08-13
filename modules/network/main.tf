locals {
  az_count        = length(var.azs)
  computed_public  = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  computed_private = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + local.az_count)]

  public_cidrs  = var.public_subnet_cidrs  != null ? var.public_subnet_cidrs  : local.computed_public
  private_cidrs = var.private_subnet_cidrs != null ? var.private_subnet_cidrs : local.computed_private
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = var.vpc_name })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.vpc_name}-igw" })
}

resource "aws_subnet" "public" {
  for_each = { for idx, az in var.azs : idx => { az = az, cidr = local.public_cidrs[idx] } }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                         = "${var.vpc_name}-public-${each.key}"
    "kubernetes.io/role/elb"     = "1"
  })
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in var.azs : idx => { az = az, cidr = local.private_cidrs[idx] } }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name                                  = "${var.vpc_name}-private-${each.key}"
    "kubernetes.io/role/internal-elb"     = "1"
  })
}

resource "aws_eip" "nat" {
  count  = var.nat_mode == "none" ? 0 : (var.nat_mode == "per_az" ? local.az_count : 1)
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.vpc_name}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "nat" {
  count         = length(aws_eip.nat)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.nat_mode == "per_az" ? aws_subnet.public[tonumber(count.index)].id : values(aws_subnet.public)[0].id

  tags       = merge(var.tags, { Name = "${var.vpc_name}-nat-${count.index}" })
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.vpc_name}-public-rt" })
}

resource "aws_route" "public_0" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  tags     = merge(var.tags, { Name = "${var.vpc_name}-private-rt-${each.key}" })
}

# Only create private default route if NAT exists
resource "aws_route" "private_default" {
  for_each               = var.nat_mode == "none" ? {} : aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_mode == "per_az" ? aws_nat_gateway.nat[tonumber(each.key)].id : aws_nat_gateway.nat[0].id
  depends_on             = [aws_nat_gateway.nat]
}

output "vpc_id"             { value = aws_vpc.this.id }
output "public_subnet_ids"  { value = [for s in aws_subnet.public  : s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }
output "internet_gateway_id" { value = aws_internet_gateway.igw.id }
output "nat_gateway_ids"     { value = aws_nat_gateway.nat[*].id }
output "azs"                 { value = var.azs }
