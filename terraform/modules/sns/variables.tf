variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "sns_email" {
  description = "Email address to subscribe to the SNS topic"
  type        = string
}
