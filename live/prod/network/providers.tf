# live/prod/network/providers.tf
variable "region" {
  type    = string
  default = "ap-northeast-2"
}

# prod 계정: AssumeRole 없음 → Jenkins EC2의 인스턴스 프로파일을 그대로 사용
provider "aws" {
  region = var.region
  # 필요하면 공통 태그도 여기서 지정 가능
  # default_tags {
  #   tags = { ManagedBy = "Jenkins", Project = "vpc", Environment = "prod" }
  # }
}

# AZ 자동 선택용 (azs 미지정 시 상위 2개 쓰도록 main.tf에서 사용)
data "aws_availability_zones" "available" {
  state = "available"
}

