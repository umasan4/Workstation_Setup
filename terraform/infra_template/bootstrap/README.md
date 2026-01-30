# backend

## {backend} ブロック
- このブロックには、変数を指定できない（ハードコードが必要）  
このブロックは、init しないと読み込めないため

```properties
#------------------------------
# Terraform
#------------------------------
# terraform version
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
# terraform backend
  backend "s3" {
    bucket         = "<S3-BUCKET-NAME>"
    # tfstateの保存先
    key            = "<ENV_NAME>/terraform.tfstate"
    region         = "<REGION>"
    # ロック用 dynamodbのdb名
    dynamodb_table = "<DynamoDB-NAME>" 
    encrypt        = true
    profile        = "<IAM-USER-NAME>"
  }
}
# terraform provider
provider "aws" {
  region  = "<REGION>"
  profile = "<IAM-USER-NAME>"
}
```