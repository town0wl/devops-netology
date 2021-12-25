data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "current_region" {
  value = data.aws_region.current.name
}

output "test1_priv_ip" {
  value = aws_instance.test1.private_ip
}

output "test1_subnet_id" {
  value = aws_instance.test1.subnet_id
}
