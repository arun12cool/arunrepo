variable "Stack_id_hypertrail" {
	description = "Stack id"
	default = "c179cd93-cc7b-4ae0-853d-5d0cbe4fc102"
	type = string
}

variable "private_subnetid-d"{
	default = "subnet-073ce6ee043d411cb"
	description = "Private subnet id-f"
	type        = string
}

variable "private_subnetid-f"{
        default =  "subnet-02bc8453b188f1483"
        description = "Private subnet id-f"
        type        = string
}
variable "public_subnetid-d"{
	default = "subnet-0822f464b7cd50dd2"
	description = "Public subnet id-d"
	type        = string
}

variable "public_subnetid-f"{
        default = "subnet-0bf2f989863c7cea2"
        description = "Public subnet id-f"
        type        = string
}


variable "availability_zone-d"{
	description = "Run the EC2 Instances in these Availability Zones"
	type = string
	default = "us-east-1d"
}

variable "availability_zone-e"{
        description = "Run the EC2 Instances in these Availability Zones"
        type = string
        default = "us-east-1e"
}

variable "availability_zone-f"{
        description = "Run the EC2 Instances in these Availability Zones"
        type = string
        default = "us-east-1f"
}

variable "ami_id" {
	type = string
	default = "ami-0b148812f7deb6769"
	description = "ami details of hypertrail-staging layer"
}

variable "hypertrail-staging" {
	default = "sg-3ca79542"
	type    = string
	description = "security_group"
}
variable "APP_SEC_GRP" {
	default = "sg-47465b3b"
	type    = string
	description = "security_group"
}

variable "hypertrail-staging_dr" {
	default = "b3167a46-a78d-4fc2-8f55-897b15448bb2"
	description = "ECS Layer ID"
	type = string
}

variable "ALB_SEC_GRP" {
	default = "sg-b4190cca"
	type    = string
	description = "security_group"
}

variable "vpc_id"{
	default = "vpc-d0dea6b6"
	description = "Vpc ID"
	type = string
}
