provider "aws" {
  region = var.aws_region
}

module "networking" {
  source             = "./modules/networking"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.networking.vpc_id
}

module "ec2" {
  source            = "./modules/ec2"
  key_name          = var.key_name
  availability_zone = var.availability_zone
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.security_groups.sg_id
  static_private_ip = var.static_private_ip
}
