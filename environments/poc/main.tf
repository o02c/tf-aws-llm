terraform {
  backend "s3" {
    bucket       = "mgt-tfstate-654654512164"
    key          = "tf-aws-llm/poc/terraform.tfstate"
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

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  system_name          = var.system_name
  environment          = var.environment
}

module "ec2" {
  source = "./modules/ec2"

  instance_type             = var.instance_type
  ami_id                    = var.ami_id
  vpc_id                    = module.vpc.vpc_id
  subnet_id                 = module.vpc.public_subnet_id
  security_group_id         = module.vpc.ec2_security_group_id
  key_name                  = var.key_name
  system_name               = var.system_name
  environment               = var.environment
  auto_stop_cron_expression = var.ec2_auto_stop_cron_expression
  auto_stop_enabled         = var.ec2_auto_stop_enabled
}

module "rds" {
  source = "./modules/rds"
  count  = var.enable_rds ? 1 : 0

  db_instance_class    = var.db_instance_class
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.private_subnet_id
  security_group_id    = module.vpc.rds_security_group_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  system_name          = var.system_name
  environment          = var.environment
}

module "bedrock" {
  source = "./modules/bedrock"

  system_name                     = var.system_name
  environment                     = var.environment
  region                          = var.region
  log_retention_days              = 90
  enable_model_invocation_logging = true
}
