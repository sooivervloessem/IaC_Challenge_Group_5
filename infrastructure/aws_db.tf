# Create database instance
resource "aws_db_instance" "team5-db" {
  allocated_storage       = 10
  db_name                 = var.aws_db_database
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  username                = var.aws_db_username
  password                = var.aws_db_password
  identifier              = "team5db"
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = false
  backup_retention_period = 7

  db_subnet_group_name   = aws_db_subnet_group.team5-db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.team5-db-security-group.id]

  depends_on = [aws_db_subnet_group.team5-db-subnet-group, aws_security_group.team5-db-security-group]
}

# Create database subnet group
resource "aws_db_subnet_group" "team5-db-subnet-group" {
  name       = "team5-db-subnet-group"
  subnet_ids = module.team5-vpc.private_subnets

  tags = {
    Name = "Team5 db subnet group"
  }

  depends_on = [module.team5-vpc]
}

# Create database security group
resource "aws_security_group" "team5-db-security-group" {
  name        = "team5-db-security-group"
  description = "Security group for the DB to only allow incoming traffic from ECS"
  vpc_id      = module.team5-vpc.vpc_id

  # Only allow SQL traffic from the ECS security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.team5-ecs-sg.id] # Reference the LB security group ID
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_security_group.team5-ecs-sg]
}

