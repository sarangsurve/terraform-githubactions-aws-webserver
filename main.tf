provider "aws" {
  region = var.aws_region
}

# Get your current public IP
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  my_ip_cidr = chomp(data.http.my_ip.response_body) == "" ? "0.0.0.0/0" : "${chomp(data.http.my_ip.response_body)}/32"
}

module "networking" {
  source             = "./modules/networking"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  aws_region         = var.aws_region
}

module "webserver_security_groups" {
  source       = "./modules/security-groups"
  vpc_id       = module.networking.vpc_id
  project_name = var.project_name
  usecase_type = var.usecase_type
  ingress_rules = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [local.my_ip_cidr]
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.allowed_incoming_ip_cidrs
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.allowed_incoming_ip_cidrs
    }
  ]
  egress_rules = [
    {
      description = "All egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = var.allowed_outgoing_ip_cidrs
    }
  ]
}

module "ec2" {
  source            = "./modules/ec2"
  key_pair_name     = var.key_pair_name
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.webserver_security_groups.sg_id
  static_private_ip = var.static_private_ip
}
