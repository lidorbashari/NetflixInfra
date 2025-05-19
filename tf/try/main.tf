terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }

  backend "s3" {
    bucket = "lidor-netflix-infra-tfstate-try"
    key    = "tfstate.json"
    region = "us-east-2"
    # optional: dynamodb_table = "<table-name>"
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region  = var.region
  profile = "default" # change in case you want to work with another AWS account profile
}

resource "aws_instance" "netflix_app" {
  #  ami           = "ami-04f7a54071e74f488"
  ami           = var.ami_id
  instance_type = "t3.micro"

  tags = {
    Name      = "lidor-try-${var.env}"
    Terraform = "owned"
    Env       = var.env
  }
}
