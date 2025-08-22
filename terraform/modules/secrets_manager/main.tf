resource "aws_secretsmanager_secret" "redshift_password" {
  name = "${var.project}-${var.env}-redshift-password"
}

resource "aws_secretsmanager_secret_version" "redshift_password_value" {
  secret_id     = aws_secretsmanager_secret.redshift_password.id
  secret_string = "Srinidhisk123_"   # Put real password ONCE here
}

output "redshift_secret_name" {
  value = aws_secretsmanager_secret.redshift_password.name
}
