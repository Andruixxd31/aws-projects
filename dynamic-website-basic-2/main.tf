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
    availability_zone = "${var.availability_zoneb}"
    security_groups = ["dynamic-website-2-SG"]
    key_name = aws_key_pair.instance_key.key_name
    user_data = "${file("user-data.sh")}"
    tags = {
        Name = "terraform-practice-1"
    }
}

resource "aws_security_group" "dynamic-website-2" {
    name = "dynamic-website-2-SG"
    ingress {
        description      = "HTTP Access"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH Access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "instance_key" {
  key_name = "my_instance_key"
  public_key = file("${var.ssh_key}")
}

resource "aws_ebs_volume" "dw2-ebs" {
  availability_zone = "${var.availability_zoneb}"
  size              = 1

  tags = {
    Name = "terraform-practice-1"
  }
}

resource "aws_volume_attachment" "dw2-ebs-att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.dw2-ebs.id
  instance_id = aws_instance.dynamic-website-2.id
}
