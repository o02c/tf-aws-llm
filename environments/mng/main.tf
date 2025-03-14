terraform {
  backend "s3" {
    bucket       = "mgt-tfstate-654654512164"
    key          = "tf-aws-llm/mng/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}

provider "aws" {
  region  = var.region

  default_tags {
    tags = {
      System     = var.system_name
      Env        = var.environment
      Repository = "tf-aws-llm"
    }
  }
}

# IAM Identity Store related modules
data "aws_caller_identity" "this" {}

module "iam_identitystore" {
  source = "./modules/iam_identitystore"
}
