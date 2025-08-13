# Jenkins + Terraform: VPC Scaffold (Full)

Provision a VPC via Terraform from Jenkins with remote state (S3 + DynamoDB).
- Uses **instance profile** on Jenkins EC2 (no static keys).
- Environments: **dev / stage / prod**
- Network module creates: VPC, IGW, Public & Private Subnets (per AZ), NAT GW (single/per_az/none), Routes.

## Quick Start
1) Apply `bootstrap/` once (S3 bucket + DynamoDB table for backend).
2) Create Jenkins Pipeline from SCM pointing to this repo.
3) Build with Parameters: set `ENV`, `TF_STATE_BUCKET`, `TF_LOCK_TABLE` → Plan → Apply.

See `live/<env>/network/<env>.tfvars` to customize CIDR/AZ/NAT mode.
