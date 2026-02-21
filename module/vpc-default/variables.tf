
variable "name" {
  type        = string
  description = "name of the VPC"
}

variable "availability_zones" {
  type        = list
  description = "AZ in which all the resources will be deployed"
}

variable "internet_gateway_default" {
  type = string
}
variable "vpc_default_id" {
  type = string
}
variable "private_subnet_defaults_cidr_block" {
  type = list
}
# variable "public_subnet_default" {
#   type = list
# }
variable "public_subnet_defaults_cidr_block" {
  type = list
}