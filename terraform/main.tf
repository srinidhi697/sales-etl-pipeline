module "s3" {
  source  = "./modules/s3"
  project = var.project
  env     = var.env
}

module "iam" {
  source             = "./modules/iam"
  project            = var.project
  env                = var.env
  region             = var.region
  lambda_arn         = module.lambda.start_crawler_arn
  step_functions_arn = module.step_functions.state_machine_arn
  bucket             = module.s3.bucket_name
}

module "glue" {
  source                   = "./modules/glue"
  project                  = var.project
  env                      = var.env
  bucket                   = module.s3.bucket_name
  glue_role_arn            = module.iam.glue_role_arn
  redshift_cluster_id      = module.redshift_cluster.cluster_identifier
  redshift_db_name         = "dev"
  redshift_master_username = var.redshift_master_username
  redshift_master_password = var.redshift_master_password
  redshift_copy_role_arn   = module.iam.redshift_copy_role_arn
}

module "step_functions" {
  source       = "./modules/step_functions"
  project      = var.project
  env          = var.env
  sfn_role_arn = module.iam.step_functions_role_arn
  lambda_arn   = module.lambda.start_crawler_arn # pass lambda output here
}

module "lambda" {
  source  = "./modules/lambda"
  project = var.project
  env     = var.env
}

module "eventbridge" {
  source          = "./modules/eventbridge"
  project         = var.project
  env             = var.env
  raw_bucket_name = module.s3.bucket_name
  sfn_arn         = module.step_functions.state_machine_arn
}

module "redshift_cluster" {
  source  = "./modules/redshift_cluster"
  project = var.project
  env     = var.env
  region  = var.region

  redshift_master_username = var.redshift_master_username
  redshift_master_password = var.redshift_master_password
  vpc_id                   = var.vpc_id
  redshift_copy_role_arn   = module.iam.redshift_copy_role_arn
}

module "sns" {
  source    = "./modules/sns"
  project   = var.project
  env       = var.env
  sns_email = var.sns_email
}

module "cloudwatch" {
  source         = "./modules/cloudwatch"
  project        = var.project
  env            = var.env
  sns_topic_arn  = module.sns.sns_topic_arn
  log_group_name = "/aws/etl/sales-pipeline"
}


