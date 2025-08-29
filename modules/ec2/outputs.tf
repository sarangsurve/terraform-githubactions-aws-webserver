output "instance_id" {
  value = aws_instance.web.id
}

output "web_eip" {
  value = aws_eip.web_eip.public_ip
}
