resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key-name
  subnet_id              = var.subnet-id
  vpc_security_group_ids = [aws_security_group.security-group.id]
  root_block_device {
    volume_size = 15
  }
  user_data = templatefile("./install.sh", {})

  tags = {
    Name = var.instance-name
  }
}



resource "aws_security_group" "security-group" {
  name        = var.sg-name
  description = "Allowing Jenkins, Sonarqube, SSH Access and TLS traffic"

  ingress = [
    for port in [22, 8080, 9000, 9090, 80] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg-name
  }
}

