variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "lambda_arn" {
  description = "ARN of the crawler Lambda"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "step_functions_arn" {
  type = string
}

variable "bucket" {
  type = string
}
