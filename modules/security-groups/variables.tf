variable "vpc_id" {
  type = string
}

variable "project_name" { type = string }

variable "usecase_type" { type = string }

variable "ingress_rules" {
  description = "List of ingress rules for the SG"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [] # no ingress by default
}

variable "egress_rules" {
  description = "List of egress rules for the SG"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }] # all egress by default
}
