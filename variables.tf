variable "region" {
  type = string
  default = "us-east-1"
}

variable "CIDR" {
    default = "10.0.0.0/16"
}

variable "subnet1_cidr" {
    default = "10.0.0.0/24"
}

variable "subnet2_cidr" {
    default = "10.0.1.0/24"
}

variable "availability_zone1" {
    default = "us-east-1a"
}

variable "availability_zone2" {
    default = "us-east-1b"
}

variable "ami_id" {
    type = string
    default = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
    type = string
    default = "t3.micro"
}
