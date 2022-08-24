#provider
provider "aws" {
  region="ap-south-1"
}
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-VPC"
  }
}

resource "aws_subnet" "Private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Private"
  }
}

        resource "aws_subnet" "Public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Public"
  }
}
resource "aws_security_group" "tsg" {
  name        = "terraform-sg"
  description = "Default SG to allow traffic from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_instance" "web1" {
    ami = "ami-06489866022e12a14"
    instance_type = "t2.micro"
    subnet_id              = aws_subnet.Public.id
    vpc_security_group_ids = [aws_security_group.tsg.id]
    key_name = "tf-key"

    }
provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("/home/ec2-user/.ssh/id_rsa")
      timeout     = "4m"
   }
}

resource "aws_key_pair" "deployer" {
  key_name   = "tf-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAPaE2c14h0ReFhPAllFTgZxd1w/5o+5ceMe59ecU8Ee4PRg9Zk1lYFpwNp9m7aCTfFKC1PwCEzulHL+IRNQDTxtw87GTU+B1JqoVfhEg9HGd1KQP+iPw5YPD8QXf+HWE8CPY8RvPdObcFxE6uZqdg62nbMVex529UNpPZfXq1FI+uD03lGLMCYyZRGRqC5oDsQutPfJBfYjn2WB/gkzODnf1oyBgYYl4InF4Vd3G8DZFqObHcNBLjTKjJ/3M1JOXzZncLoditBubFHJUXPh1o6tghlYDEzkvBL6AuKfCbi+imOVDsB9Hw5Z4AnzGZwjEAa2xAim5FOwgv/mOISk9Z ec2-user@ip-172-31-6-198.ap-south-1.compute.internal"
}
