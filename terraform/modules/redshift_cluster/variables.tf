variable "project" { type = string }
variable "env"     { type = string }
variable "region"  { type = string }

variable "redshift_master_username" { type = string }

variable "redshift_master_password" {
  type      = string
  sensitive = true
}

variable "redshift_copy_role_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}
