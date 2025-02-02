# IAM role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "automated-agency-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "automated-agency-ec2-role"
  }
}

# Policy to allow EC2 to access Parameter Store
resource "aws_iam_role_policy" "parameter_store_access" {
  name = "parameter-store-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/automated-agency/*",
          "arn:aws:kms:eu-west-1:${data.aws_caller_identity.current.account_id}:key/*"
        ]
      }
    ]
  })
}

# Instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "automated-agency-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Policy to allow EC2 to pull from ECR
resource "aws_iam_role_policy" "ecr_access" {
  name = "ecr-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# GitHub Actions IAM User
resource "aws_iam_user" "github_actions" {
  name = "github-actions-automated-agency"
}

# GitHub Actions Policy
resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-automated-agency-policy"
  description = "Policy for GitHub Actions to push to ECR and deploy to EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "github_actions" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# Create access keys
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

# Output the credentials (these will be used in GitHub Secrets)
output "github_actions_access_key_id" {
  value = aws_iam_access_key.github_actions.id
}

output "github_actions_secret_access_key" {
  value     = aws_iam_access_key.github_actions.secret
  sensitive = true
}