#------------------------------
# tags
#------------------------------
variable "tags" { type = string }
variable "env" { type = string }
variable "project" { type = string }

#------------------------------
# vpc
#------------------------------
variable "vpc_cidr" { type = string }
variable "vpc_tenancy" {
  type    = string
  default = "default"
}

#------------------------------
# subnet
#------------------------------
variable "vpc_id" { type = string }
variable "name_and_cidr" {
  description = "{key:name = value:cidr}"
  type        = map(string)

  # 宣言例: 
  # name_and_cidr = {
  #  "dev"  = "192.168.0.0/24"
  #  "prod" = "192.168.1.0/24"
  # }
}