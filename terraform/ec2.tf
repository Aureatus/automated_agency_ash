# Get the latest Ubuntu ARM64 AMI
data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 instance
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu_arm64.id
  instance_type = "t4g.micro"
  key_name      = aws_key_pair.deployer.key_name

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              export DEBIAN_FRONTEND=noninteractive

              # Update system
              apt-get update
              apt-get upgrade -y

              # Install Docker
              apt-get install -y ca-certificates curl gnupg
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              chmod a+r /etc/apt/keyrings/docker.gpg
              echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              # Install AWS CLI
              apt-get install -y awscli

              # Create directory for app
              mkdir -p /opt/automated-agency

              # Create docker-compose.yml
              cat > /opt/automated-agency/docker-compose.yml <<'DOCKER'
              version: '3.8'
              services:
                web:
                  image: ${aws_ecr_repository.app.repository_url}:latest
                  ports:
                    - "80:4000"
                  environment:
                    - DB_HOST=${aws_db_instance.main.endpoint}
                    - DB_NAME=${aws_db_instance.main.db_name}
                    - DB_USER=${aws_db_instance.main.username}
                    - DB_PASSWORD=$DB_PASSWORD
                    - SECRET_KEY_BASE=$SECRET_KEY_BASE
                    - PHX_HOST=$PUBLIC_IPV4
                  restart: always
              DOCKER

              # Create script to fetch secrets and start app
              cat > /opt/automated-agency/start.sh <<'SCRIPT'
              #!/bin/bash
              
              # Get instance public IP for Phoenix host
              export PUBLIC_IPV4=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
              
              # Get database password from Parameter Store
              export DB_PASSWORD=$(aws ssm get-parameter --name "/automated-agency/database/password" --with-decryption --region eu-west-1 --query "Parameter.Value" --output text)
              
              # Generate Phoenix secret key base
              export SECRET_KEY_BASE=$(openssl rand -base64 48)
              
              # Login to ECR
              aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}
              
              # Pull latest image and start
              docker-compose pull
              docker-compose up -d
              SCRIPT

              chmod +x /opt/automated-agency/start.sh
              cd /opt/automated-agency && ./start.sh
              EOF

  tags = {
    Name = "automated-agency-app-server"
  }

  user_data_replace_on_change = true

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
}