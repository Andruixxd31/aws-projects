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

resource "aws_launch_template" "scaling-launch-template" {
    name_prefix = "scaling_template"
    instance_type = "t2.micro"
    image_id = "ami-051f7e7f6c2f40dc1"
}

resource "aws_autoscaling_group" "scaling-asg" {
    vpc_zone_identifier  = module.vpc.public_subnets
    desired_capacity = 2
    min_size = 1
    max_size = 4
    
    launch_template {
      id = aws_launch_template.scaling-launch-template.id
      version = "$Latest"
    }
  
}

resource "aws_lb" "scaling-lb" {
    name = "scaling-alb"
    load_balancer_type = "application"
    internal = false 
    security_groups = [aws_security_group.scaling-sg-lb.id]
    subnets = module.vpc.public_subnets

    tags = {
        Name = "Terraform-practice-2"
    }
}

resource "aws_lb_target_group" "scaling-lb-group" {
    name = "scaling-alb-group"
    port = 80
    protocol = "HTTP"
    vpc_id = module.vpc.vpc_id
}

resource "aws_autoscaling_attachment" "scaling-attachment" {
  autoscaling_group_name = aws_autoscaling_group.scaling-asg.id
  lb_target_group_arn   = aws_lb_target_group.scaling-lb-group.arn
}

resource "aws_lb_listener" "scaling-lb-listener" {
    load_balancer_arn = aws_lb.scaling-lb.arn
    port = 80
    protocol = "HTTP"
    
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.scaling-lb-group.arn
    }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_security_group" "scaling-sg-asg" {
    name = "dynamic-scaling-sg-asg"
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

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "scaling-sg-lb" {
    name = "dynamic-scaling-sg-lb"
    ingress {
        description      = "HTTP Access"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
  } 

  vpc_id = module.vpc.vpc_id
}

resource "aws_key_pair" "instance_key" {
  key_name = "scaling-key"
  public_key = file("${var.ssh_key}")
}

