variable "region" {
    description = "Region of instances"
    type = string
    default = "eu-north-1"
}

variable "instance_type" {
    description = "Server instance type"
    type = string
    default = "t3.micro"
}

variable "allow_ports" {
    description = "Open ports"
    type = list
    default = ["8080", "22"]
}

variable "vpc_cidr_block" {
    description = "CIDR block for VPC"
    type    = string
    default = "192.168.1.0/24"
}

variable "ami" {
    type = string
    default = "ami-0ff338189efb7ed37"
}

variable "subnet_cidr_block" {
    type = string
    default = "192.168.1.0/24"
}