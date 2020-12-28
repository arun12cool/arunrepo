
provider "aws" {
  region     = var.region
}

# Security Group

resource "aws_security_group" "bastion-secgrp-dr" {
  name        = "bastion-secgrp-dr"
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
    Name = "bastion-secgrp-dr"
  }
}



resource "aws_iam_role" "bastion_role-ec2" {
  name = "bastion_role-ec2"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bastion-dr-ec2-role" {
  name = "bastion-dr-ec2-role"
  role = aws_iam_role.bastion_role-ec2.name
}

resource "aws_iam_role_policy" "screen_policy" {
  name = "screen_policy"
  role = aws_iam_role.bastion_role-ec2.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::screen-record-ci",
                "arn:aws:s3:::screen-record-ci/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:HeadBucket"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


data "template_file" "user_data" {
  template =   file("./user_data.tpl")
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion_key"
  public_key = file("/var/lib/rundeck/bastion_ssh_key/bastion.pub")
}

resource "aws_instance" "ec2-dr" {
  ami                    =  var.ami_id
  instance_type          =  var.instance_type
  user_data              =  data.template_file.user_data.rendered
  subnet_id              =  var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion-secgrp-dr.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion-dr-ec2-role.name
  ebs_optimized          = "false"
  source_dest_check      = "false"
  key_name          = aws_key_pair.bastion.key_name
  tags = {
    Name = "Bastion-EC2-DR"
  }


provisioner "file" {
  source      = "script.sh"
  destination = "/tmp/script.sh"

    connection {
      type = "ssh"
      user = "ec2-user"
      host     = self.public_ip
      private_key = file("/var/lib/rundeck/bastion_ssh_key/bastion")
    }
}

provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_ip
      private_key = file("/var/lib/rundeck/bastion_ssh_key/bastion")
    }
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo sh /tmp/script.sh",
      "echo 'Machine is Running' >> /tmp/test.txt",
      "s3cmd sync /tmp/test.txt s3://screen-record-ci/$HOSTNAME/"
    ]
  }
}






#output

output "security_groups" {
        value = aws_security_group.bastion-secgrp-dr.name
}

output "aws_instance_id" {
        value = aws_instance.ec2-dr.id
}


output "aws_instance_ami" {
        value = aws_instance.ec2-dr.ami
}

output "aws_instance_public_ip" {
        value = aws_instance.ec2-dr.public_ip
}

output "aws_iam_role_name" {
        value = aws_iam_role.bastion_role-ec2.name
}


output "aws_iam_role_policy" {
        value = aws_iam_role_policy.screen_policy.name
}
