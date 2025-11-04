variable "region" {
  type    = string
  default = "ap-northeast-2"
}
111111
variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state lock"
  type        = string
  default     = "terraform-lock"
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "tf-bootstrap"
    ManagedBy = "Jenkins"
  }
}
