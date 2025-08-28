terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "web-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "web-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "web-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "web-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow HTTP, HTTPS, SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_network_interface" "web_eni" {
  subnet_id       = aws_subnet.public.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

  tags = {
    Name = "web-eni"
  }
}

resource "aws_eip" "web_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web_eni.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.igw]

  tags = {
    Name = "web-eip"
  }
}

resource "aws_instance" "web" {
  ami               = "ami-02d26659fd82cf299"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "my-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web_eni.id
  }

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

  tags = {
    Name = "apache-web-server"
  }

  depends_on = [aws_eip.web_eip]
}

output "http_url" {
  value       = "http://${aws_eip.web_eip.public_ip}:80"
  description = "Convenient HTTP URL"
}
