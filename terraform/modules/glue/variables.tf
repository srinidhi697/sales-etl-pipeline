variable "project" {
  type = string
}
variable "env" {
  type = string
}
variable "bucket" {
  type = string
}
variable "glue_role_arn" {
  type = string
}

variable "redshift_cluster_id" {
  type = string
}

variable "redshift_db_name" {
  type    = string
  default = "dev"   # default Redshift DB
}

variable "redshift_master_username" {
  type = string
}

variable "redshift_master_password" {
  type      = string
  sensitive = true
}

variable "redshift_copy_role_arn" {
  type = string
}
