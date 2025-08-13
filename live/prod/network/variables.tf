variable "region"   { type = string  default = "ap-northeast-2" }
variable "vpc_name" { type = string }
variable "vpc_cidr" { type = string }
variable "azs"      { type = list(string)  default = null } # null → first 2 AZs
variable "nat_mode" { type = string default = "single" }    # single | per_az | none
variable "tags"     { type = map(string) default = { ManagedBy = "Jenkins", Project = "vpc" } }
