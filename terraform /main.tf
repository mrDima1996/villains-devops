provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
}

locals {
    tags = {
        origin_of_birth : "terraform"
    }
}

#resource "local_file" "tf_ip" {
#    content = "[ALL]\n${aws_instance.my-machine1[0].public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/Users/oleksahud/ITEA/8/ohud_itea.pem"
#    filename = "../ansible/inventory"
#}