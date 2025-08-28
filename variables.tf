variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for the public subnet (must be inside vpc_cidr)"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  type        = string
  description = "AZ for the subnet/instance"
  default     = "ap-south-1a"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name"
  default     = "main_key"
}

# Must be inside the public_subnet_cidr and not a reserved IP
variable "static_private_ip" {
  type        = string
  description = "Static private IP for the ENI"
  default     = "10.0.1.50"
}