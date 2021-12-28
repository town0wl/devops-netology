terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70"
    }
  }

  backend "s3" {
    bucket = "terra-bucket-djfwak"
    key    = "netology/test/simple/terra"
    region = "eu-north-1"
    dynamodb_table = "terra-locktable"
  }

}
