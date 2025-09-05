resource "aws_security_group" "bastion_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow SSH access from anywhere (replace with office IP in production!)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-bastion-sg"
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "example-bastion-key"
  public_key = file("~/.ssh/id_rsa.pub") # sanitized path
}

resource "aws_instance" "bastion" {
  ami           = "ami-0abcdef1234567890" # dummy AMI ID
  instance_type = "t4g.nano"
  subnet_id     = module.vpc.public_subnets[0]

  security_groups = [
    aws_security_group.bastion_sg.id
  ]

  key_name = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "example-bastion-host"
  }

  lifecycle {
    ignore_changes = [security_groups]
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  domain   = "vpc"
}
