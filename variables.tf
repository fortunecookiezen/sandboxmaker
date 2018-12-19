variable "sandbox_name" {
  description = "Sandbox account name"
  default = "sbx"
}
variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/22"
}

# a /28 is the smallest subnet aws will support
variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.0.0/28"
}

variable "private_subnet_a_cidr" {
  description = "CIDR for the private subnet"
  default = "10.0.1.0/24"
}

variable "ami" {
  description = "AMI for EC2"
  default = "ami-0080e4c5bc078760e"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "files/id_rsa.pub"
}
