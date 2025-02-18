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
  region  = var.region
}

resource "aws_instance" "netflix_app" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  tags = {
    Name      = "lidor-tf-netflix-${var.env}"
    Terraform = "owned"
    Env       = var.env
  }
}
