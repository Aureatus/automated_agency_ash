# Configure AWS Provider
provider "aws" {
  region = "eu-west-1"
  
  default_tags {
    tags = {
      Project     = "automated-agency"
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}

# Configure Terraform behavior
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "automated-agency-terraform-state"
    key     = "terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }

  required_version = ">= 1.0.0"
}
