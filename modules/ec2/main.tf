data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_2404.id
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

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
}

resource "aws_network_interface" "web_eni" {
  subnet_id       = var.subnet_id
  private_ips     = [var.static_private_ip]
  security_groups = [var.security_group_id]

  tags = {
    Name = "web-eni"
  }
}

resource "aws_eip" "web_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web_eni.id
  associate_with_private_ip = var.static_private_ip
  depends_on                = [aws_instance.web]

  tags = {
    Name = "web-eip"
  }
}
