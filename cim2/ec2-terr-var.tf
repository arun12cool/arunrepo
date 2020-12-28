

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
//variable "aws_iam_instance_profile_arn" {
//  type        = string
//  description = "REQUIRED: The ARN of an IAM Instance Profile that created instances will have by default"
//  default     = "arn:aws:iam::092463844305:role/vdi-test"
//}

variable "ami_id" {
  type = string
  description = "AMI-ID"
  default     = "ami-0a243dbef00e96192"
}

variable "instance_type" {
  type        = string
  default     = "c5.large"
  description = "instance type"
}

variable "aws_iam_role_opsworks_arn" {
  type        = string
  description = "REQUIRED: The ARN of an IAM role that the OpsWorks service will act as"
  default     = "arn:aws:iam::092463844305:role/aws-opsworks-service-role"
}
