variable "project" { type = string }
variable "env"     { type = string }
variable "sfn_role_arn" {
  description = "IAM role ARN for Step Functions execution"
  type        = string
}

variable "lambda_arn" {
  description = "ARN of the Lambda function"
  type        = string
}
