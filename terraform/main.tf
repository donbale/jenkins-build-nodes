variable "AMI_ID" {}
variable "LIFESPAN" {
  type =string
}
variable "USERNAME" {
  type =string
}
variable "PASSWORD" {
  type =string
}


provider "aws" {
  region     = "eu-west-1"
}

resource "aws_vpc" "aria_vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"
}

resource "aws_spot_instance_request" "roxann" {
  ami = var.AMI_ID
  spot_type = "one-time"
  instance_type = "t3.large"
  vpc_security_group_ids = ["sg-0708866f86a7e87bf"]
  subnet_id = "subnet-09a3cd93539dbc6f1"
  associate_public_ip_address = "false"
  wait_for_fulfillment = true
  user_data            = <<EOF
  #cloud-config
  users:
    - name: ${var.USERNAME}
      groups: [ wheel ]
      sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
      shell: /bin/bash
      ssh-authorized-keys: 
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDsiXlIf2+IL7UHIM2AATLJeD+JKgJWna39mYGaBnram22e8IwFI9irMQiyJ8t4FTHnkgL9ef0ELQc793wQ52QFdYgFw4lBwAs6TadQPy8sH69mRhSbzxC03ZBgx4kZTF/QZMzD2HWTEd1ANNNffyR0YyTXsTusVg3uPqZf60VMc1O+LWCnPAF9KgiHK61oWLkCu/85PdWrjOZ4CdSLEyTf3PhQ76ZzOi8q53/Xqb5F3Gc4Xta0CmsFra0aBi/M/6pMkCLL4oOXPuuwSfzLBFbicNBBGw70lmEj4nrpBxzTevUxfaXI/ZBRpGVbUyy/t0Jw1sXaqeoFbdki27h30nAj ariaeu
  power_state:
   delay: "+${var.LIFESPAN}"
   mode: poweroff
   message: Bye Bye
   timeout: 30
   condition: True
  EOF
  

  tags = {
    Name = var.AMI_ID
  }

}


output "ip" {
  value = aws_spot_instance_request.roxann.private_ip
}