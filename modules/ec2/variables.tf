variable "key_pair_name" { type = string }
variable "subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "static_private_ip" { type = string }
variable "instance_name" { type = string }
variable "instance_type" { type = string }
variable "volume_size" { type = number }
variable "volume_type" { type = string }
variable "iam_instance_profile" {
  description = "The IAM instance profile to attach to the EC2 instance"
  type        = string
  default     = null
}
variable "user_data" {
  description = "Cloud-init script for the ec2 instance"
  type        = string
}

