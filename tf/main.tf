terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }


  backend "s3" {
    bucket = "lidor-netflix-infra-tfstate"
    key    = "tfstate.json"
    region = "eu-north-1"
    # optional: dynamodb_table = "<table-name>"
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region = var.region
}

resource "aws_ebs_volume" "lidor_netflix_app_volume" {
  availability_zone = "eu-north-1a"
  size              = 5

  tags = {
    Name = "netflix_app_volume"
  }
}

resource "aws_volume_attachment" "netflix_data_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.lidor_netflix_app_volume.id
  instance_id = aws_instance.netflix_app.id
}

resource "aws_key_pair" "my_key" {
  key_name   = "lidor-key-pair"
  public_key = file("/home/lidorbashari/.ssh/id_rsa.pub")
}

resource "aws_security_group" "netflix_app_sg" {
  name        = "lidor-netflix-app-sg" # change <your-name> accordingly
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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


resource "aws_instance" "netflix_app" {
  ami             = var.ami_id
  instance_type   = "t3.micro"
  vpc_security_group_ids = [aws_security_group.netflix_app_sg.id]
  key_name        = aws_key_pair.my_key.key_name
  user_data       = file("./deploy.sh")
  availability_zone = "eu-north-1a"
  #subnet_id = module.netflix_app_vpc.public_subnets[0]

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 5
    delete_on_termination = true

  }

  tags = {
    Name      = "lidor-tf-netflix-${var.env}"
    Terraform = "owned"
    Env       = var.env
  }
}



