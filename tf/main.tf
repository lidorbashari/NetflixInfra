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
  #  region  = "eu-north-1"
  region  = var.region
  profile = "default" # change in case you want to work with another AWS account profile
}

resource "aws_instance" "netflix_app" {
  #  ami           = "ami-09a9858973b288bdd"
  ami           = var.ami_id
  instance_type = "t3.micro"

  tags = {
    Name      = "lidor-tf-netflix-${var.env}"
    Terraform = "owned"
    Env       = var.env
  }
}
