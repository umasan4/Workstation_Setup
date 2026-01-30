#------------------------------
# variables
#------------------------------
variable "env" {
  description = "remote backend用、環境ごとに作成する"
  type        = list(string)
  default     = ["dev", "prod"]
}

#------------------------------
# s3_bucket
#------------------------------
resource "aws_s3_bucket" "remote" {
  for_each = toset(var.env)

  # s3名 大文字は使用禁止
  bucket   = "<S3-BUCKET-NAME>-${each.key}"

  # Terraformコマンドによる誤削除防止
  lifecycle { prevent_destroy = true }

  tags = {
    Name        = "remote-${each.key}"
    Environment = "${each.key}"
  }
}

#------------------------------
# s3_bucket_versioning
#------------------------------
resource "aws_s3_bucket_versioning" "remote_versioning" {
  for_each = toset(var.env)
  bucket   = aws_s3_bucket.remote[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

#------------------------------
# s3_bucket_encryption
#------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "remote_encryption" {
  for_each = toset(var.env)
  bucket   = aws_s3_bucket.remote[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#------------------------------
# s3_bucket_access_block
#------------------------------
resource "aws_s3_bucket_public_access_block" "remote_accessblock" {
  for_each = toset(var.env)
  bucket   = aws_s3_bucket.remote[each.key].id

  block_public_acls       = true # 新規のパブリックACL作成を禁止
  block_public_policy     = true # 新規のパブリックバケットポリシーの適用を禁止
  ignore_public_acls      = true # 既存のパブリックACLを無視
  restrict_public_buckets = true # 既存のパブリックバケットポリシーを無視
}

#------------------------------
# s3_bucket_policy
#------------------------------
resource "aws_s3_bucket_policy" "remote_policy" {
  for_each = toset(var.env)
  bucket   = aws_s3_bucket.remote[each.key].id

  # public_access_block 作成後に本リソースを作成する
  depends_on = [aws_s3_bucket_public_access_block.remote_accessblock]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. バケットの削除を禁止
      {
        Sid       = "DenyDeleteBucket"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:DeleteBucket"
        Resource  = aws_s3_bucket.remote[each.key].arn
      },
      # 2. HTTP（非SSL）通信の拒否
      {
        Sid       = "EnforceSecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.remote[each.key].arn,
          "${aws_s3_bucket.remote[each.key].arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

#------------------------------
# DynamoDB
#------------------------------
resource "aws_dynamodb_table" "remote_locks" {
  for_each     = toset(var.env)
  name         = "remote-locks-${each.key}"
  billing_mode = "PAY_PER_REQUEST" # 課金モード <オンデマンド>
  hash_key     = "LockID"          # 主キー

  # 削除保護
  lifecycle { prevent_destroy = true }

  # ロック用カラム
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "remote-locks-${each.key}"
    Environment = "${each.key}"
  }
}