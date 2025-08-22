resource "aws_vpc" "redshift_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "redshift_subnet_a" {
  vpc_id                  = aws_vpc.redshift_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "redshift_subnet_b" {
  vpc_id                  = aws_vpc.redshift_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
}

resource "aws_redshift_subnet_group" "this" {
  name       = "${var.project}-${var.env}-rs-subnet-group"
  subnet_ids = [aws_subnet.redshift_subnet_a.id, aws_subnet.redshift_subnet_b.id]
}

resource "aws_security_group" "redshift_sg" {
  name        = "${var.project}-${var.env}-rs-sg"
  description = "Allow Redshift access"
  vpc_id      = aws_vpc.redshift_vpc.id

  ingress {
    description = "Allow access from my IP"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_redshift_cluster" "this" {
  cluster_identifier  = "${var.project}-${var.env}-redshift"
  node_type           = "ra3.xlplus"
  master_username     = var.redshift_master_username
  master_password     = var.redshift_master_password
  cluster_type        = "single-node"

  publicly_accessible = false
  skip_final_snapshot = true
  

  vpc_security_group_ids = [aws_security_group.redshift_sg.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.this.name
  iam_roles = [var.redshift_copy_role_arn]

    lifecycle {
    ignore_changes = [
      master_password,
      node_type,
      cluster_type,
      automated_snapshot_retention_period,
      encrypted
    ]
  }
}