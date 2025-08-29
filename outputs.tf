output "http_url" {
  value       = "http://${module.ec2.web_eip}:80"
  description = "Public URL of the web server"
}
