provider "aws" {
  region = var.region
  assume_role {
    role_arn     = "arn:aws:iam::363714837532:role/TerraformDeployRole"
    session_name = "jenkins-terraform"
    # external_id = "cjenm-deploy"   # 3단계에서 External ID 사용했다면 이 줄 주석 해제
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}
