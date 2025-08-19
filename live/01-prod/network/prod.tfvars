vpc_name = "prod-vpc"
vpc_cidr = "10.20.0.0/16"
azs      = ["ap-northeast-2a","ap-northeast-2c"]
nat_mode = "single"
tags = { Environment = "prod", ManagedBy = "Jenkins", Project = "vpc" }
