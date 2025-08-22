resource "aws_glue_catalog_database" "this" {
  name = "${var.project}-${var.env}-db"
}

resource "aws_glue_crawler" "this" {
  name          = "${var.project}-${var.env}-crawler"
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.this.name

  s3_target {
    path = "s3://${var.bucket}/"
  }

  depends_on = [aws_glue_catalog_database.this]
}

# -----------------------------
# Raw -> Silver Job
# -----------------------------
resource "aws_glue_job" "raw_to_silver" {
  name              = "${var.project}-${var.env}-raw-to-silver"
  role_arn          = var.glue_role_arn
  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  command {
    name            = "glueetl"
    script_location = "s3://${var.bucket}/scripts/raw_to_silver.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language" = "python"
    "--TempDir"      = "s3://${var.bucket}/temp/"
    "--SOURCE_PATH"  = "s3://${var.bucket}/raw/"
    "--TARGET_PATH"  = "s3://${var.bucket}/silver/"
  }
}

# -----------------------------
# Silver -> Gold Job
# -----------------------------
resource "aws_glue_job" "silver_to_gold" {
  name              = "${var.project}-${var.env}-silver-to-gold"
  role_arn          = var.glue_role_arn
  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  command {
    name            = "glueetl"
    script_location = "s3://${var.bucket}/scripts/silver_to_gold.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language" = "python"
    "--TempDir"      = "s3://${var.bucket}/temp/"
    "--SOURCE_PATH"  = "s3://${var.bucket}/silver/"
    "--TARGET_PATH"  = "s3://${var.bucket}/gold/"
  }
}

resource "aws_s3_object" "raw_to_silver" {
  bucket = var.bucket
  key    = "scripts/raw_to_silver.py"
  source = "${path.module}/../../../src/raw_to_silver.py"
}

resource "aws_s3_object" "silver_to_gold" {
  bucket = var.bucket
  key    = "scripts/silver_to_gold.py"
  source = "${path.module}/../../../src/silver_to_gold.py"
}

# -----------------------------
# Gold -> Redshift Job
# -----------------------------
resource "aws_glue_job" "gold_to_redshift" {
  name              = "${var.project}-${var.env}-gold-to-redshift"
  role_arn          = var.glue_role_arn
  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  command {
    name            = "glueetl"
    script_location = "s3://${var.bucket}/scripts/gold_to_redshift.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"        = "python"
    "--TempDir"             = "s3://${var.bucket}/temp/"
    "--SOURCE_PATH"         = "s3://${var.bucket}/gold/"
    "--REDSHIFT_CLUSTER_ID" = var.redshift_cluster_id
    "--REDSHIFT_DB"         = var.redshift_db_name
    "--REDSHIFT_USER"       = var.redshift_master_username
    "--REDSHIFT_PASSWORD"   = var.redshift_master_password
    "--REDSHIFT_ROLE"       = var.redshift_copy_role_arn
  }
}

# Upload Glue script placeholder
resource "aws_s3_object" "gold_to_redshift" {
  bucket = var.bucket
  key    = "scripts/gold_to_redshift.py"
  source = "${path.module}/../../../src/gold_to_redshift.py"
}
