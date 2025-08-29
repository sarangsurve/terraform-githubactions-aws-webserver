output "http_url" {
  value       = "http://${module.web_instance.web_eip}:80"
  description = "Public URL of the web server"
}
