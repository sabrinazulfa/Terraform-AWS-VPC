## VPC Module - Networking

The purpose of this module is to create VPC associate with new 2 public subnet, 2 private subnet, an Internet gateway for public subnet, NAT Gateway for private subnet, and also route table association for each subnet.

## Planning
Terraform module that creates an VPC with the following features

- Create **New Subnet on VPC Default** associate with subnet public[2] and subnet private[2].
- An **Internet gateway** in front of a public subnet to enable communication between the instances within the public subnet and internet.
- An **Elastic IP addresses (EIPs)** for Internet Gateway
- An **NAT gateway** in front of a private subnet to enable instances within the private subnet to communicate with the internet while maintaining a layer of security
- Create **Route table association** to determine the routing rules for network traffic within a particular subnet in a VPC environment (Route table association for public and private).
- Create **New VPC Attacker** associate with subnet public[1].

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.7 |
| aws | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.34 |

## Input for Variable
| Name | Description | Type |Required |
|------|-------------|------|---------|
|vpc_cidr_block|IP CIDR block of new vpc|`string`|YES|
|public_subnets_cidr_block|IP CIDR for public subnet[2]|`list`|YES|
|private_subnets_cidr_block|IP CIDR for private subnet[2]|`list`|YES|
|availability_zones|AZ in which all the resources will be deployed[2]|`list`|YES|
|route_public_id|ID of exsisting Route table public VPC Production to update with VPC Peering|`string`|YES|
|route_private_id|ID of exsisting Route table private VPC Production to update with VPC Peering|`string`|YES|

## Usage in Module Root (main.tf)
```hcl
module "Networking-default" {
  source                             = "./module/vpc-default"
  name                               = "VPC-Default"
  availability_zones                 = ["${local.region}a", "${local.region}b"]
  vpc_default_id                     = local.vpc_default_id
  internet_gateway_default           = local.igw_id
  public_subnet_defaults_cidr_block  = ["172.31.48.0/24", "172.31.49.0/24"]
  private_subnet_defaults_cidr_block = ["172.31.50.0/24", "172.31.51.0/24"]
}
```
## Developer Setup
+ Install and configure [aws CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
+ Install and configure [terraform](https://www.terraform.io/downloads)