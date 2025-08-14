variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  # 따옴표 문제 방지: 예시는 문자열 안에 큰따옴표 없이 적습니다.
  description = "List of AZs (e.g. ap-northeast-2a, ap-northeast-2c)"
  type        = list(string)
}

variable "nat_mode" {
  description = "NAT strategy: single | per_az | none"
  type        = string
  default     = "single"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = null
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
