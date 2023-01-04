#
# Creates an internal load balancer in the existing VPC subnets
# Documentation : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
#
resource "aws_lb" "load_balancer" {

}

# Creates a target group to attach to the load balancer, accessible on port HTTP:80 and located in the existing VPC
# Documentation : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
#
resource "aws_lb_target_group" "target_group" {

}

# Creates a listener for the load balancer to listen on port TCP:80, with a default action to forward to its target group
# Documentation : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
#
resource "aws_lb_listener" "listener" {

}

resource "aws_iam_role" "asg_iam_role" {
  name = "asg-iam-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.asg_iam_role.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "asg_instance_profile"
  role = aws_iam_role.asg_iam_role.name
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Creates launch configuration for the autoscaling group, with same arguments as for the Bastion EC2 instance
# Documentation : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration
#
resource "aws_launch_configuration" "launch_configuration" {
  image_id             = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux.id
  user_data            = var.user_data
}

# Creates an autoscaling group based on the launch configuration created above. Subnets are the same as from the existing VPC
# The size should be between 1 and 3 instances.
# Documentation : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
#
resource "aws_autoscaling_group" "asg" {

}

# Creates an attachment to link the target group to the autoscaling group.
# Documentation : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment
#
resource "aws_autoscaling_attachment" "asg-attachment" {

}