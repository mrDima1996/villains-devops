# villains-devops

install:
-terraform
-awscli
-ansible

create:
file /terraform/credentials.auto.tfvars and add access_key and secret_key variables value

docker build .

list image files::::   docker run --rm -it --entrypoint=/bin/bash img_id

service status: kubectl describe service fe1
