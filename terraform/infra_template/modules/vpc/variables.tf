#------------------------------
# tags
#------------------------------
variable "tags_name" { type = string }

#------------------------------
# vpc
#------------------------------
variable "vpc_cidr"    { type = string }
variable "vpc_tenancy" { 
    type    = string
    default = "default"
}