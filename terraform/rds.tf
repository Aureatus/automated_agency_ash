# Fetch the database password from Parameter Store
data "aws_ssm_parameter" "db_password" {
  name = "/automated-agency/database/password"
}

# Create DB subnet group
resource "aws_db_subnet_group" "main" {
  name       = "automated-agency-db-subnet"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "automated-agency-db-subnet"
  }
}

resource "aws_db_instance" "main" {
  identifier     = "automated-agency-db"
  instance_class = "db.t4g.micro"
  engine         = "postgres"
  engine_version = "15"

  allocated_storage     = 20
  storage_type         = "gp2"
  skip_final_snapshot  = true

  db_name  = "automated_agency"
  username = "postgres"
  password = data.aws_ssm_parameter.db_password.value

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az = false
}