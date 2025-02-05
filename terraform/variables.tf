# AWS Region
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

# VPC and Subnet Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (EC2)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (RDS)"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}