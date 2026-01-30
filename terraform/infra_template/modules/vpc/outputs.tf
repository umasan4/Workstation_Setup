#------------------------------
# vpc
#------------------------------
output "VPC_ID" {
  value       = aws_vpc.VPC_NAME.id
  # 呼出し方法
  # moduleで vpc = module.vpc.main 
}