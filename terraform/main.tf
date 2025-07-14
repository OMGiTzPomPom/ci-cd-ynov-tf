provider "aws" {
    region = var.region
}

# Security group pour ouvrir port 22 (SSH) et 3000 (Node.js)
resource "aws_security_group" "app_sg" {
    name        = "ynov-node-sg"
    description = "Allow SSH and HTTP"

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Node.js app"
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Instance EC2
resource "aws_instance" "app" {
    ami           = var.ami
    instance_type = var.instance_type
    security_groups = [aws_security_group.app_sg.name]

    user_data = <<-EOF
                #!/bin/bash
                apt update
                apt install -y docker.io git

                # Démarrer docker
                systemctl start docker
                systemctl enable docker

                # Cloner et builder/run le container
                cd /home/ubuntu
                git clone https://github.com/OMGiTzPomPom/ci-cd-ynov-node.git
                cd ci-cd-ynov-node

                # Construire l'image Docker
                docker compose build

                # Lancer le container
                docker compose up -d
                EOF

    tags = {
        Name = "ynov-node-docker-app"
    }
}

output "public_ip" {
    value = aws_instance.app.public_ip
}
