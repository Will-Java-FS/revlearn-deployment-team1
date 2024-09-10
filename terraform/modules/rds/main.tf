resource "aws_security_group" "rds_sg" {
  name_prefix = var.sg_name_prefix

  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  tags = var.tags
}

resource "aws_db_subnet_group" "revlearn_db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_db_instance" "revlearn_db_tc" {
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  identifier           = var.db_identifier
  username             = var.username
  password             = var.password
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.revlearn_db_subnet_group.name

  skip_final_snapshot = var.skip_final_snapshot

  tags = var.tags
}
