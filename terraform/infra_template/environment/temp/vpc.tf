#------------------------------
# vpc
#------------------------------
module "VPC_NAME" {
  source      = "../../modules/vpc"
  vpc_cidr    = var.vpc_cidr
  vpc_tenancy = var.vpc_tenancy
  tags_name   = "${var.project}_vpc_${var.env}"
}