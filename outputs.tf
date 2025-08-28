output "http_url" {
  value       = "http://${aws_eip.web_eip.public_ip}:80"
  description = "Convenient HTTP URL"
}
