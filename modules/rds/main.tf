resource "aws_db_subnet_group" "this" {
  name = "${var.identifier}-subnet-group"

  subnet_ids = values(var.subnet_ids)

  tags = {
    Name = "${var.identifier}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine         = var.engine
  engine_version = var.engine_version

  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  skip_final_snapshot   = true
  deletion_protection   = false
  publicly_accessible   = false
  multi_az              = false

  db_name  = var.database_name
  username = var.username
  password = var.password

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  backup_retention_period = 1

  tags = {
    Name = var.identifier
  }
}