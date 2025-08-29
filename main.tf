provider "aws" {
  region = var.aws_region
}

module "networking" {
  source             = "./modules/networking"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  aws_region         = var.aws_region
}

module "security_groups" {
  source           = "./modules/security-groups"
  vpc_id           = module.networking.vpc_id
  allowed_ip_cidrs = var.allowed_ip_cidrs
}

module "ec2" {
  source            = "./modules/ec2"
  key_pair_name     = var.key_pair_name
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.security_groups.sg_id
  static_private_ip = var.static_private_ip
}
