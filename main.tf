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

# EC2 Instance for GitHub Actions Runner
module "web_instance" {
  source            = "./modules/ec2"
  key_pair_name     = var.key_pair_name
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.webserver_security_groups.sg_id
  static_private_ip = var.static_private_ip
  instance_name     = var.instance_name
  instance_type     = var.instance_type
  volume_size       = var.volume_size
  volume_type       = var.volume_type

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              DEBIAN_FRONTEND=noninteractive apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2
              cat >/var/www/html/index.html <<'EOPAGE'
              <!doctype html>
              <html lang="en">
              <head><meta charset="utf-8"><title>AWS Web Server</title></head>
              <body style="font-family: sans-serif; padding: 2rem;">
                <h1>Hello from Apache on EC2</h1>
                <p>Deployed via Terraform + ENI + EIP in a public subnet.</p>
              </body>
              </html>
              EOPAGE
              EOF
}
