provider "aws" {
  region     = var.region
}

# Security Group

resource "aws_security_group" "bastion-secgrp" {
  name        = "bastion-secgrp"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["115.112.69.51/32", "182.73.13.166/32", "34.215.228.226/32", "192.168.0.164/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-secgrp"
  }
}


# Opsworks stack

resource "aws_opsworks_stack" "SSH-Bastion-DR" {
  name                          = "SSH-Bastion-DR"
  color                         = lookup(var.colors,var.color)
  region                        = var.region
  vpc_id                        = var.vpc_id
  default_subnet_id             = var.subnet_id
  agent_version			        = "LATEST"
  service_role_arn              = var.aws_iam_role_opsworks_arn
  default_instance_profile_arn  = var.aws_iam_instance_profile_opsworks_arn
  default_os                    = var.default_os
  use_opsworks_security_groups  = false
  configuration_manager_version = var.chef_version
  default_root_device_type      = "ebs"
  use_custom_cookbooks          = true

  custom_cookbooks_source {
    type     = "git"
    url      = var.custom_cookbooks_source_url
    ssh_key  = file("/var/lib/rundeck/bastion_ssh_key/git.pem")
    revision = var.custom_cookbooks_source_revision
  }
//   custom_json = var.custom_json
}

  

#Opsworks Layer

resource "aws_opsworks_custom_layer" "bastion-DR" {
  name                      = "Bastion-DR"
  short_name                = "bastion-dr"
  stack_id                  = aws_opsworks_stack.SSH-Bastion-DR.id
  auto_healing              = false
  custom_security_group_ids = [aws_security_group.bastion-secgrp.id]
  auto_assign_public_ips    = true
  custom_setup_recipes      = var.bastion_setup_recipes

}



resource "aws_opsworks_user_profile" "bastion-DR-role" {
	user_arn     = "arn:aws:iam::092463844305:user/dr-bastion" 
	ssh_username = "dr-bastion"
    ssh_public_key = file("/var/lib/rundeck/bastion_ssh_key/bastion.pub")

}


resource "aws_opsworks_permission" "bastion-DR" {
  allow_ssh = true
  allow_sudo = true
  user_arn = "arn:aws:iam::092463844305:user/dr-bastion"
  stack_id = aws_opsworks_stack.SSH-Bastion-DR.id

      depends_on = [aws_opsworks_user_profile.bastion-DR-role]

}


#Opsworks instance

resource "aws_opsworks_instance" "bastion-DR" {
  stack_id = aws_opsworks_stack.SSH-Bastion-DR.id
  layer_ids = [aws_opsworks_custom_layer.bastion-DR.id]
  instance_type = var.instance_type
  agent_version = "4037-20190604080613"
  state		= "running"
  hostname      = "ssh-bastion-dr-opsworks"
  os		= "Custom"
  ami_id        = var.ami_id
  ssh_key_name  = "bastion-terraform"
  virtualization_type	=  "hvm"
  root_device_type	=  "ebs"
   
  depends_on = [aws_opsworks_permission.bastion-DR]

    connection {
    type        = "ssh"
    user        = "dr-bastion"
    private_key = file("/var/lib/rundeck/bastion_ssh_key/bastion")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Opsworks_instance is running' >> /tmp/test.txt",
      "s3cmd sync /tmp/test.txt s3://screen-record-ci/$HOSTNAME-opsworks/"
    ]
  }

}


output "aws_instance_state" {
  value = aws_opsworks_instance.bastion-DR.state
}

output "aws_opsworks_state" {
  value = aws_opsworks_instance.bastion-DR.status
}


#output

output "security_groups" {
        value = aws_security_group.bastion-secgrp.name
}


output "aws_opsworks_stack" {
        value = aws_opsworks_stack.SSH-Bastion-DR.name
}

output "vpc_id" {
        value = aws_opsworks_stack.SSH-Bastion-DR.vpc_id
}
