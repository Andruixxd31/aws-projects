terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.region}"
}

resource "aws_instance" "dynamic-website-2" {
    ami = "ami-06ca3ca175f37dd66"
    instance_type = "t2.micro"
    tags = {
        Name = "terraform-test"
    }
}
