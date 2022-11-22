variable "ec2_ami" {
  type = map

  default = {
    eu-central-1 = "ami-06148e0e81e5187c8"
  }
}

variable "region" {
  default = "eu-central-1"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

