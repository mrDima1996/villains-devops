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

variable "availability_zone" {
  default = [ "eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}


