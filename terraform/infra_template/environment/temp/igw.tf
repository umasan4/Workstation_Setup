module "IGW_NAME" {
  source = "../../modules/igw"
  vpc_id = module.VPC_NAME.VPC_ID
  tags   = "${var.env}-igw-${var.project}"
}