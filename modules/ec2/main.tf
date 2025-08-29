data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/*/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  ami                  = data.aws_ami.ubuntu_2404.id
  instance_type        = var.instance_type
  key_name             = var.key_pair_name
  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web_eni.id
  }

  user_data = var.user_data

  tags = {
    Name = "${replace(lower(var.instance_name), " ", "-")}"
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
  depends_on                = [aws_instance.this]

  tags = {
    Name = "web-eip"
  }
}
