# Create ECR repository
resource "aws_ecr_repository" "app" {
  name = "automated-agency"
  force_delete = true  # Allows terraform destroy to work without manual cleanup

  image_scanning_configuration {
    scan_on_push = true
  }
}