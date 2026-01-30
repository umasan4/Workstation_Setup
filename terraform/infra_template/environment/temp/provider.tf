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
    key            = "<ENV_NAME>/terraform.tfstate"
    region         = "<REGION>"
    dynamodb_table = "<DynamoDB-NAME>"
    encrypt        = true
    profile        = "<IAM-USER-NAME>"
  }
}
# terraform provider
provider "aws" {
  region  = "<REGION>"
  profile = "<IAM-USER-NAME>"

  default_tags {
    tags = {
      Project = var.project
      Env     = var.env
    }
  }
}