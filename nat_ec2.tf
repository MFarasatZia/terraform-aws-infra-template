resource "aws_instance" "nat_instance" {
  ami                         = "ami-0abcdef1234567890" # dummy AMI ID, replace with valid NAT AMI
  instance_type               = "t3.nano"
  subnet_id                   = module.vpc.public_subnets[0] # NAT goes in the first public subnet
  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name = "example-nat-instance"
  }
}

resource "aws_security_group" "nat_sg" {
  name   = "example-nat-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-nat-sg"
  }
}

resource "aws_network_interface_sg_attachment" "nat_sg_attachment" {
  security_group_id    = aws_security_group.nat_sg.id
  network_interface_id = aws_instance.nat_instance.primary_network_interface_id
}
