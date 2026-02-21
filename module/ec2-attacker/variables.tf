variable "vpc_public_subnets_id" {
  description = "The PUBLIC subnets id"
  type        = list
}

variable "vpc_private_subnets_id" {
  description = "The PRIVATE subnets id"
  type        = list
}

variable "vpc_id" {
  type        = string
  description = "The vpc id"
}

variable "project_name" {
  type        = string
  description = "The project name"
}

variable "key_pair" {
  type        = string
  description = "The key pair name"
  default = "test-key"
}

variable "aws_ami" {
  type        = string
  description = "The name of default AMI"
}

variable "instance_type" {
  type        = string
}

variable "volume_size" {
  type        = string
}

variable "volume_type" {
  type        = string
}

variable "on_demand_percentage" {
  type        = number
  default = 0
}

variable "capacity_rebalance" {
  type        = bool
  default = true
}

variable "desired_capacity" {
  type        = number
}

variable "max_capacity" {
  type        = number
}

variable "min_capacity" {
  type        = number
}