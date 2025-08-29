variable "vpc_id" {
  type = string
}

variable "allowed_ip_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
