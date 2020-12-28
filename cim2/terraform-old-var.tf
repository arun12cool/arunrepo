variable "color" {
  type        = string
  default     = "red"
  description = "Color to paint next to the stack's resources in the OpsWorks console"
}


variable colors {
  type = map
  default = {
    "purple"     = "rgb(135, 61, 98)"
    "violet"     = "rgb(111, 86, 163)"
    "indigo"     = "rgb(45, 114, 184)"
    "blue"       = "rgb(38, 146, 168)"
    "deepgreen"  = "rgb(57, 131, 94)"
    "green"      = "rgb(100, 131, 57)"
    "lightbrown" = "rgb(184, 133, 46)"
    "brown"      = "rgb(209, 105, 41)"
    "red"        = "rgb(186, 65, 50)"
  }
  description = "RGB for the selected color for stack"
}




variable "region" {
  default     = "us-west-2"
  type        = string
  description = "REQUIRED: Region on which the stack has to be launched"
}

variable "vpc_id" {
  type        = string
  description = "REQUIRED: VPC to which the stack should be a part of"
  default     = "vpc-0f5c57de44e67e07b"
}

variable "subnet_id" {
  type        = string
  description = "REQUIRED: Subnet Id for that VPC"
  default     = "subnet-00e2c392ec0f23379"
}


variable "agent_version" {
  type        = string
  default     = "4037"
  description = "REQUIRED: agent version of the stack"
}

variable "aws_iam_role_opsworks_arn" {
  type        = string
  description = "REQUIRED: The ARN of an IAM role that the OpsWorks service will act as"
  default     = "arn:aws:iam::092463844305:role/aws-opsworks-service-role"
}

variable "aws_iam_instance_profile_opsworks_arn" {
  type        = string
  description = "REQUIRED: The ARN of an IAM Instance Profile that created instances will have by default"
  default     = "arn:aws:iam::092463844305:instance-profile/vdi-test"
}


variable "default_os" {
  type        = string
  default     = "Custom"
  description = "Name of OS that will be installed on instances by default"
}

variable "chef_version" {
  type        = string
  default     = "12"
  description = "Chef version to use for stack automation"
}

variable "ami_id" {
  type = string
  description = "AMI-ID"
  default     = "ami-01191027b839f84d0"
}

variable "instance_type" {
  type        = string
  default     = "c5.large"
  description = "instance type"
}

variable "bastion_setup_recipes" {
  type        = list(string)
  default     = ["screen-amazonlinux2-2018::default"]
  description = "Bastion Setup recipe list"
}

variable "custom_cookbooks_source_url" {
  type        = string
  default     = "git@github.com:freshdesk/Imagehardening-postboot.git"
  description = "REQUIRED: Git URL where the chef cookbooks reside"
}



variable "custom_cookbooks_source_revision" {
  type        = string
  default     = "screen"
  description = "REQUIRED: The Revision of the cookbooks to use"
}
