variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for the public subnet (must be inside vpc_cidr)"
}

variable "key_pair_name" {
  type        = string
  description = "SSH key pair name to use for the EC2 instance"
}

# Must be inside the public_subnet_cidr and not a reserved IP
variable "static_private_ip" {
  type        = string
  description = "Static private IP for the ENI"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "volume_size" {
  description = "Volume size"
  type        = number
  default     = 8
}

variable "volume_type" {
  description = "Volume size"
  type        = string
  default     = "gp3"
}

variable "project_name" {
  description = "Project name tag"
  type        = string
  default     = "Terraform Project"
}

variable "allowed_ip_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"] # change this in production!
}
