locals {
  cidr_block = "10.0.0.0/16"
}
#
# Module for VPC
#
module "vpc" {
  source                      = "./modules/vpc"
  name                        = "My VPC"
  cidr_block                  = "10.0.0.0/16"
  private_subnets_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
  public_subnets_cidr_blocks  = ["10.0.2.0/24", "10.0.4.0/24"]
}

# Creates security group for the EC2 instance, which should be attached to the VPC, with ingress open on all ports restricted in VPC CIDR, and egress open for all
# Documentation : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
#
resource "aws_security_group" "sg" {

  ingress {

  }

  egress {

  }
}

#
# Declares EC2 module to create a bastion host, filling the variables values that needs defining.
#
module "bastion_host" {
  source                 = "./modules/ec2"
  user_data              = <<EOF
    #!/bin/bash
    sudo yum install -y httpd-tools
  EOF
  vpc_security_group_ids = [aws_security_group.sg.id]
}