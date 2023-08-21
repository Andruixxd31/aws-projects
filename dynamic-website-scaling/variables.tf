variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "ssh_key" {}

variable "region" {
        default = "us-east-1"
}

variable "availability_zoneb" {
        default = "us-east-1b"
}

variable "profile" {
    description = "AWS credentials profile you want to use"
}
