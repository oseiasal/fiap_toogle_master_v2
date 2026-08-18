resource "aws_db_instance" "auth_db" {
  identifier             = "auth-db"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  skip_final_snapshot    = true

  tags = {
    Project = var.project_name
    Service = "Auth"
  }
}

resource "aws_db_instance" "main_db" {
  identifier             = "main-db"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  skip_final_snapshot    = true

  tags = {
    Project = var.project_name
    Service = "Flag"
  }
}

resource "aws_db_instance" "targeting_db" {
  identifier             = "targeting-db"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  skip_final_snapshot    = true

  tags = {
    Project = var.project_name
    Service = "Targeting"
  }
}
