# Generate private key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "deployer" {
  key_name   = "automated-agency-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Store private key in AWS Parameter Store
resource "aws_ssm_parameter" "ssh_private_key" {
  name  = "/automated-agency/ssh/private-key"
  type  = "SecureString"
  value = tls_private_key.ssh.private_key_pem
}