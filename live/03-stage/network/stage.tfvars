vpc_name = "stage-vpc"
vpc_cidr = "10.40.0.0/16"
azs      = ["ap-northeast-2a","ap-northeast-2c"]
nat_mode = "single"
tags = { Environment = "stage", ManagedBy = "Jenkins", Project = "vpc" }
