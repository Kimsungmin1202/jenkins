module "network" {
  source   = "../../../modules/network"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  azs      = var.azs == null ? slice(data.aws_availability_zones.available.names, 0, 2) : var.azs
  nat_mode = var.nat_mode
  tags     = var.tags
}
output "vpc_id"             { value = module.network.vpc_id }
output "public_subnet_ids"  { value = module.network.public_subnet_ids }
output "private_subnet_ids" { value = module.network.private_subnet_ids }
