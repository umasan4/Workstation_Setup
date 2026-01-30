#------------------------------
# subnet
#------------------------------
module "SUBNET_NAME" {
  source        = "../../modules/subnet"
  name_and_cidr = var.name_and_cidr
  vpc_id        = module.vpc.vpc_main
  tags          = "${var.project}-subnet-${var.env}"
}