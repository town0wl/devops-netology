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
  value = module.test1.private_ip
}

output "test1_public_ip" {
  value = module.test1.public_ip
}
