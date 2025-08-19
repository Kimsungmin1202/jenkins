
vpc_name = "dev-vpc"
vpc_cidr = "10.20.0.0/16"
azs      = ["ap-northeast-2a","ap-northeast-2c"]
nat_mode = "single"

# ⬇️ 원하는 크기로 직접 지정 (AZ 순서와 개수는 azs와 동일해야 함)
public_subnet_cidrs  = ["10.20.0.0/25",   "10.20.0.128/25"]
private_subnet_cidrs = ["10.20.1.0/25",   "10.20.1.128/25"]

tags = { Environment = "dev", ManagedBy = "Jenkins", Project = "vpc" }

