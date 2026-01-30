#------------------------------
# subnet
#------------------------------
resource "aws_subnet" "main" {
  for_each   = var.name_and_cidr
  vpc_id     = var.vpc_id
  tags       = { Name = var.tags }
}