variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

# null이면 첫 2개 AZ 자동 사용
variable "azs" {
  type    = list(string)
  default = null
}

variable "nat_mode" {
  type    = string
  default = "single"  # single | per_az | none
}

variable "tags" {
  type    = map(string)
  default = { ManagedBy = "Jenkins", Project = "vpc" }
}

variable "public_subnet_cidrs"  { type = list(string) default = null }
variable "private_subnet_cidrs" { type = list(string) default = null }
