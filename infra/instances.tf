data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}

# שרת ג'נקינס (מעודכן עם ZIP, UNZIP ו-PIP)
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "myfirstkey"  # המפתח שלך

  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  user_data = <<-EOF
              #!/bin/bash
              # Update and install basic tools
              sudo apt-get update -y
              # הוספנו כאן את zip ו-unzip
              sudo apt-get install -y fontconfig openjdk-17-jre unzip wget curl gnupg software-properties-common awscli zip

              # --- Python PIP & Venv Setup ---
              sudo apt-get install -y python3-pip python3-venv
              sudo ln -s /usr/bin/pip3 /usr/bin/pip
              # -------------------------------

              # Install Jenkins
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y jenkins

              # Install Docker
              sudo apt-get install -y docker.io
              sudo usermod -aG docker jenkins
              sudo usermod -aG docker ubuntu
              sudo systemctl enable docker
              sudo systemctl start docker

              # Install Terraform
              wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
              echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
              sudo apt-get update && sudo apt-get install terraform -y

              # Restart Jenkins
              sudo systemctl enable jenkins
              sudo systemctl restart jenkins
              EOF

  tags = {
    Name = "Jenkins-Server"
  }
}

# שרת האפליקציה (Docker Host)
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = "myfirstkey" # המפתח שלך

  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io awscli
              sudo usermod -aG docker ubuntu
              sudo systemctl enable docker
              sudo systemctl start docker
              EOF

  tags = {
    Name = "App-Server"
  }
}