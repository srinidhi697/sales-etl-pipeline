variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "sales-etl-pipeline"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  type = string
}
variable "redshift_master_username" {
  type = string
}

variable "redshift_master_password" {
  type      = string
  sensitive = true
}

variable "sns_email" {}

