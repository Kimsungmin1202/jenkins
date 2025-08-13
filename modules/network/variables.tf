variable "vpc_name" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" {
  description = "List of AZs to use (e.g. ["ap-northeast-2a","ap-northeast-2c"])"
  type        = list(string)
}
variable "nat_mode" {
  description = "NAT strategy: single | per_az | none"
  type        = string
  default     = "single"
}
variable "public_subnet_cidrs" { type = list(string) default = null }
variable "private_subnet_cidrs" { type = list(string) default = null }
variable "tags" { type = map(string) default = {} }
