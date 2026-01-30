output "subnet_ids" {
  description = "リソースMapからIDだけを抽出した、新たなMapを作成する"
  # NAMEは自身の環境のsubnet名に変更
  value       = {for key, value in aws_subnet.NAME : key => value.id }
}

#-----------------------------------
# 動作解説
#-----------------------------------
# 前提
  # for_eachやforは、MAPを作成する
  # key   : subnet名が入る
  # value : id, arn, cidr_block等が入る

# 作成される Mapイメージ
  # {
  #   "dev"  = "subnet-0xyz7777",
  #   "prod" = "subnet-01234abcd"
  # }

# どう取り出す？ (例: dev を取り出すには)
  # subnet_ids = { "dev" = module.subnet_base.subnet_ids["dev"] }

# どう取り出す？ (例: 中身を全て取り出すには)
  # 1. for_each  = var.subnet_ids
  # 2. subnet_id = each.value